import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/client_note.dart';

/// Repositorio de notas internas de cliente del Control Center.
///
/// Mapea la tabla `notas_cliente`. El RLS exige `is_superadmin()` para
/// escribir y para leer notas de tenants ajenos al propio.
class NotesRepository {
  /// Se resuelve en cada llamada para no capturar el cliente antes de
  /// que `Supabase.initialize()` se haya ejecutado.
  SupabaseClient get _client => Supabase.instance.client;

  // ═══════════════════════════════════════════════════════════════
  // LECTURA
  // ═══════════════════════════════════════════════════════════════

  /// Lista las notas de un tenant: primero las fijadas, luego por fecha
  /// descendente.
  Future<List<ClientNote>> listarPorTenant(String tenantId) async {
    try {
      final response = await _client
          .from('notas_cliente')
          .select('*')
          .eq('tenant_id', tenantId)
          .order('fijada', ascending: false)
          .order('created_at', ascending: false);

      return response.map(ClientNote.fromMap).toList();
    } catch (e, stack) {
      debugPrint(
        '[NotesRepository] Error listando notas de $tenantId: $e',
      );
      debugPrint('[NotesRepository] Stack: $stack');
      return [];
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // ESCRITURA
  // ═══════════════════════════════════════════════════════════════

  /// Crea una nota interna para un tenant.
  ///
  /// Lanza [Exception] si el insert falla.
  Future<void> crear({
    required String tenantId,
    required String contenido,
    required String? autorId,
    List<String> tags = const [],
    bool fijada = false,
  }) async {
    try {
      await _client.from('notas_cliente').insert({
        'tenant_id': tenantId,
        'contenido': contenido,
        'autor_id': autorId,
        'tags': tags,
        'fijada': fijada,
      });

      debugPrint('[NotesRepository] Nota creada para $tenantId');
    } catch (e, stack) {
      debugPrint('[NotesRepository] Error creando nota: $e');
      debugPrint('[NotesRepository] Stack: $stack');
      Error.throwWithStackTrace(
        Exception('No se pudo crear la nota: $e'),
        stack,
      );
    }
  }

  /// Marca o desmarca una nota como fijada.
  ///
  /// Lanza [Exception] si el update falla o si la nota no existe.
  Future<void> toggleFijada(String notaId, bool fijada) async {
    try {
      final response = await _client
          .from('notas_cliente')
          .update({'fijada': fijada})
          .eq('id', notaId)
          .select('id');

      if (response.isEmpty) {
        debugPrint('[NotesRepository] Nota no encontrada: $notaId');
        Error.throwWithStackTrace(
          Exception('La nota $notaId no existe'),
          StackTrace.current,
        );
      }

      debugPrint('[NotesRepository] Nota $notaId → fijada=$fijada');
    } catch (e, stack) {
      debugPrint('[NotesRepository] Error actualizando nota $notaId: $e');
      debugPrint('[NotesRepository] Stack: $stack');
      Error.throwWithStackTrace(
        Exception('No se pudo actualizar la nota: $e'),
        stack,
      );
    }
  }

  /// Elimina una nota.
  ///
  /// Lanza [Exception] si el delete falla o si la nota no existe.
  Future<void> eliminar(String notaId) async {
    try {
      final response = await _client
          .from('notas_cliente')
          .delete()
          .eq('id', notaId)
          .select('id');

      if (response.isEmpty) {
        debugPrint('[NotesRepository] Nota no encontrada: $notaId');
        Error.throwWithStackTrace(
          Exception('La nota $notaId no existe'),
          StackTrace.current,
        );
      }

      debugPrint('[NotesRepository] Nota eliminada: $notaId');
    } catch (e, stack) {
      debugPrint('[NotesRepository] Error eliminando nota $notaId: $e');
      debugPrint('[NotesRepository] Stack: $stack');
      Error.throwWithStackTrace(
        Exception('No se pudo eliminar la nota: $e'),
        stack,
      );
    }
  }
}
