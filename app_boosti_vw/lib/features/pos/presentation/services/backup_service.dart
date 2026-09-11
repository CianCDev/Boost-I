import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart';

class BackupService {
  /// Genera un archivo .zip de la base de datos Isar y lo comparte
  Future<bool> crearBackupYCompartir() async {
    try {
      // 1. Obtener el directorio de la base de datos
      final appDir = await getApplicationDocumentsDirectory();
      final isarDir = Directory('${appDir.path}/isar'); // Ajusta si tu ruta es diferente
      
      if (!await isarDir.exists()) {
        debugPrint('⚠️ No se encontró la carpeta de Isar');
        return false;
      }

      // 2. Crear un archivo .zip
      final encoder = ZipFileEncoder();
      final zipPath = '${appDir.path}/backup_${DateTime.now().millisecondsSinceEpoch}.zip';
      final zipFile = File(zipPath);
      
      // 3. Comprimir toda la carpeta isar
      encoder.zipDirectory(isarDir, filename: zipFile.path);
      
      debugPrint('✅ Backup creado en: $zipPath');

      // 4. Compartir el archivo
      await Share.shareXFiles(
        [XFile(zipPath)],
        text: 'Backup de la base de datos POS - ${DateTime.now().toLocal()}',
      );

      // 5. (Opcional) Eliminar el archivo después de un tiempo o dejarlo
      // Por ahora lo dejamos en el directorio de la app
      return true;
    } catch (e) {
      debugPrint('❌ Error al crear backup: $e');
      return false;
    }
  }
}