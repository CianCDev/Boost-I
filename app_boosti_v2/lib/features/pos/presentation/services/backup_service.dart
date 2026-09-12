// lib/features/pos/services/backup_service.dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter/foundation.dart';
import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/usuario_entity.dart';
import 'error_service.dart';

/// Servicio para realizar backups automáticos de la base de datos Isar a Supabase Storage.
class BackupService {
  static const String backupTask = 'backupTask';

  final IsarService _isarService = IsarService();

  /// Inicializa el WorkManager (llamar en main.dart)
  static void register() {
    Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: kDebugMode,
    );
    Workmanager().registerPeriodicTask(
      backupTask,
      backupTask,
      frequency: const Duration(hours: 12),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
        requiresCharging: false,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
    );
    debugPrint('✅ Backup programado cada 12 horas');
  }

  /// Callback que ejecuta WorkManager (debe ser una función top-level)
  @pragma('vm:entry-point')
  static void callbackDispatcher() {
    Workmanager().executeTask((task, inputData) async {
      if (task == backupTask) {
        try {
          await BackupService().crearBackupAutomatico(reason: 'programado');
          return true;
        } catch (e) {
          debugPrint('❌ Error en backup automático: $e');
          return false;
        }
      }
      return false;
    });
  }

  // ============================================================
  // 🔐 VERIFICAR AUTENTICACIÓN (ROBUSTA)
  // ============================================================

  /// Verifica que el usuario esté autenticado en Supabase.
  /// Si no hay sesión, intenta autenticar usando las credenciales del usuario local.
  /// Retorna `true` si hay sesión activa, `false` en caso contrario.
  Future<bool> _ensureAuthenticated() async {
    try {
      final supabase = Supabase.instance.client;
      var session = supabase.auth.currentSession;

      // 1. Si hay sesión activa, verificar que no expire pronto
      if (session != null) {
        final expiresAt = session.expiresAt;
        if (expiresAt != null) {
          final expiresDateTime =
              DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000);
          final timeLeft = expiresDateTime.difference(DateTime.now()).inSeconds;
          if (timeLeft < 300) {
            debugPrint(
                '🔄 Token próximo a expirar ($timeLeft segundos). Refrescando...');
            try {
              await supabase.auth.refreshSession();
              session = supabase.auth.currentSession;
              debugPrint('✅ Token refrescado correctamente.');
              return true;
            } catch (e) {
              debugPrint('⚠️ Error al refrescar token: $e');
              // Si falla el refresco, intentamos autenticar de nuevo con credenciales
            }
          } else {
            debugPrint('✅ Sesión activa (expira en $timeLeft segundos)');
            return true;
          }
        } else {
          debugPrint('✅ Sesión activa (sin fecha de expiración)');
          return true;
        }
      }

      // 2. No hay sesión → intentar autenticar con credenciales del usuario local
      debugPrint(
          '⚠️ No hay sesión activa. Intentando autenticar con credenciales locales...');

      // Obtener el usuario actual desde Isar (el que está logueado localmente)
      final usuarioLocal = await _obtenerUsuarioLocalActivo();
      if (usuarioLocal == null) {
        debugPrint('❌ No hay usuario local activo.');
        return false;
      }

      // Verificar que tenga email y password
      if (usuarioLocal.email == null || usuarioLocal.email!.isEmpty) {
        debugPrint(
            '❌ Usuario local sin email. No se puede autenticar en Supabase.');
        return false;
      }

      if (usuarioLocal.password == null || usuarioLocal.password!.isEmpty) {
        debugPrint(
            '❌ Usuario local sin password. No se puede autenticar en Supabase.');
        return false;
      }

      // Intentar login en Supabase con las credenciales del usuario local
      try {
        debugPrint(
            '🔑 Intentando login en Supabase con ${usuarioLocal.email}...');
        await supabase.auth.signInWithPassword(
          email: usuarioLocal.email!,
          password: usuarioLocal.password!,
        );
        session = supabase.auth.currentSession;
        if (session != null) {
          debugPrint('✅ Autenticación en Supabase exitosa.');
          return true;
        } else {
          debugPrint('❌ Autenticación en Supabase falló (sesión nula).');
          return false;
        }
      } catch (e) {
        debugPrint('❌ Error al autenticar en Supabase: $e');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error en _ensureAuthenticated: $e');
      return false;
    }
  }

  /// Obtiene el usuario local que está actualmente logueado (estado = 'activo')
  Future<UsuarioEntity?> _obtenerUsuarioLocalActivo() async {
    try {
      final usuarios = await _isarService.obtenerUsuarios();
      // Buscar el usuario con estado 'activo' (el que está logueado)
      for (var u in usuarios) {
        if (u.estado == 'activo') {
          debugPrint(
              '👤 Usuario local activo encontrado: ${u.nombre} (${u.email})');
          return u;
        }
      }
      debugPrint('⚠️ No se encontró usuario local con estado "activo".');
      return null;
    } catch (e) {
      debugPrint('❌ Error obteniendo usuario local activo: $e');
      return null;
    }
  }

  // ============================================================
  // 📦 CREAR BACKUP
  // ============================================================

  /// Crea un backup completo y lo sube a Supabase Storage.
  Future<bool> crearBackupAutomatico({String reason = 'programado'}) async {
    try {
      debugPrint('🔄 Iniciando backup ($reason)...');
      ErrorService.addBreadcrumb('Inicio de backup', data: {'reason': reason});

      // ✅ PASO 1: Verificar autenticación antes de hacer cualquier cosa
      final isAuthenticated = await _ensureAuthenticated();
      if (!isAuthenticated) {
        debugPrint('❌ No hay sesión activa. El backup no se puede completar.');
        return false;
      }

      // ✅ PASO 2: Cerrar Isar para evitar corrupción
      final isar = await _isarService.db;
      if (!isar.isOpen) {
        debugPrint('❌ Isar no está abierto');
        return false;
      }

      await isar.close();
      debugPrint('🔒 Isar cerrado para backup');

      // ✅ PASO 3: Obtener ruta de la base de datos
      final appDir = await getApplicationDocumentsDirectory();
      final prefs = await SharedPreferences.getInstance();
      final empresaId = prefs.getString('empresa_id') ?? 'default';
      final dbPath = '${appDir.path}/isar_$empresaId';

      // ✅ PASO 4: Comprimir todos los archivos de Isar en un ZIP
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final zipFile = File('${appDir.path}/backup_temp.zip');
      final archive = Archive();

      final isarFiles = Directory(dbPath).listSync().where((f) =>
          f.path.endsWith('.isar') ||
          f.path.endsWith('.isar.lock') ||
          f.path.endsWith('.isar.wal'));

      for (var file in isarFiles) {
        final bytes = await File(file.path).readAsBytes();
        final filename = file.path.split('/').last;
        archive.addFile(ArchiveFile(filename, bytes.length, bytes));
      }

      final zipBytes = ZipEncoder().encode(archive);
      await zipFile.writeAsBytes(zipBytes!);
      debugPrint('📦 Backup comprimido: ${zipFile.lengthSync()} bytes');

      // ✅ PASO 5: Subir a Supabase Storage (con el cliente autenticado)
      final supabase = Supabase.instance.client;
      final bucketName = 'backups';

      // Crear el bucket si no existe (opcional)
      try {
        await supabase.storage.createBucket(
          bucketName,
          const BucketOptions(public: false),
        );
        debugPrint('📁 Bucket "$bucketName" creado');
      } catch (_) {
        // El bucket ya existe, ignorar
      }

      final motivo = reason == 'programado' ? 'auto' : reason;
      final remotePath = '$empresaId/backup_${timestamp}_$motivo.zip';

      // ✅ Subir usando el cliente autenticado (seguro)
      await supabase.storage.from(bucketName).upload(remotePath, zipFile);

      // ✅ PASO 6: Limpieza local
      await zipFile.delete();
      debugPrint('✅ Backup subido a Supabase: $remotePath');

      // ✅ PASO 7: Reabrir Isar
      await _isarService.db;
      debugPrint('🔓 Isar reabierto');

      ErrorService.addBreadcrumb('Backup exitoso',
          data: {'path': remotePath, 'size': zipFile.lengthSync()});
      return true;
    } catch (e, stack) {
      debugPrint('❌ Error en backup ($reason): $e');
      ErrorService.captureError(e,
          stack: stack, hint: 'Backup_fallido', extras: {'reason': reason});

      // Intentar reabrir Isar si estaba cerrado
      try {
        await _isarService.db;
      } catch (_) {}
      return false;
    }
  }

  /// Backup manual (desde el menú)
  Future<bool> crearBackupYCompartir() async {
    return await crearBackupAutomatico(reason: 'manual');
  }

  /// Backup al cerrar turno
  Future<bool> crearBackupPorTurno() async {
    return await crearBackupAutomatico(reason: 'turno_cerrado');
  }

  // ============================================================
  // 🔄 RESTAURAR BACKUP
  // ============================================================

  /// Restaura un backup desde Supabase Storage.
  Future<bool> restaurarBackup(String remotePath) async {
    try {
      // 🔥 Verificar autenticación antes de descargar
      final isAuthenticated = await _ensureAuthenticated();
      if (!isAuthenticated) {
        debugPrint('❌ No hay sesión activa. No se puede restaurar.');
        return false;
      }

      final supabase = Supabase.instance.client;
      final bucketName = 'backups';

      final bytes =
          await supabase.storage.from(bucketName).download(remotePath);

      final appDir = await getApplicationDocumentsDirectory();
      final zipFile = File('${appDir.path}/restore_temp.zip');
      await zipFile.writeAsBytes(bytes);

      final isar = await _isarService.db;
      await isar.close();

      final prefs = await SharedPreferences.getInstance();
      final empresaId = prefs.getString('empresa_id') ?? 'default';
      final dbPath = '${appDir.path}/isar_$empresaId';

      final dir = Directory(dbPath);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
      await dir.create(recursive: true);

      final archive = ZipDecoder().decodeBytes(bytes);
      for (var file in archive) {
        if (file.isFile) {
          final outFile = File('${dir.path}/${file.name}');
          await outFile.create(recursive: true);
          await outFile.writeAsBytes(file.content as List<int>);
        }
      }

      await _isarService.db;
      debugPrint('✅ Backup restaurado desde: $remotePath');

      return true;
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'Restaurar_backup_fallido');
      return false;
    }
  }

  /// Lista los backups disponibles en Supabase.
  Future<List<String>> listarBackups() async {
    try {
      // 🔥 Verificar autenticación antes de listar
      final isAuthenticated = await _ensureAuthenticated();
      if (!isAuthenticated) {
        debugPrint('❌ No hay sesión activa. No se pueden listar backups.');
        return [];
      }

      final supabase = Supabase.instance.client;
      final bucketName = 'backups';
      final prefs = await SharedPreferences.getInstance();
      final empresaId = prefs.getString('empresa_id') ?? 'default';

      final response =
          await supabase.storage.from(bucketName).list(path: empresaId);
      return response.map((obj) => obj.name).toList();
    } catch (e) {
      ErrorService.captureError(e, hint: 'Listar_backups_fallido');
      return [];
    }
  }
}
