// lib/features/pos/data/Local/entities/zona_entity.dart
import 'package:isar/isar.dart';

part 'zona_entity.g.dart';

/// Zona del local (salón, terraza, bar, patio…).
///
/// R.1b: reemplaza al enum fijo `MesaZona` como fuente de verdad. Las
/// zonas son editables por el local, así que no pueden vivir en un enum
/// compilado. El enum se conserva SOLO como fallback de mesas antiguas
/// que todavía no fueron migradas.
@Collection()
class ZonaEntity {
  Id id = Isar.autoIncrement;

  // ── Sync (convención A) ─────────────────────────────────────────────
  String? supabaseId;
  bool sincronizado = false;
  DateTime? fechaSincronizacion;

  /// Borrado lógico (R.1b): ver `MesaEntity.eliminado`.
  bool eliminado = false;

  // ── Local ───────────────────────────────────────────────────────────
  @Index()
  int localId = 0;

  /// UUID del local, por si el local aún no está sincronizado.
  String? localSupabaseId;

  // ── Zona ────────────────────────────────────────────────────────────
  @Index()
  String nombre = '';

  /// Clave única = `'$localId::$nombre'`.
  ///
  /// Igual que en `MesaEntity`: Isar no permite índices compuestos por
  /// anotación de forma verificable, así que se usa un campo sintético.
  @Index(unique: true, replace: true)
  String claveUnica = '';

  /// Orden de aparición en filtros y selectores.
  int orden = 0;

  bool activo = true;

  DateTime? createdAt;
  DateTime? updatedAt;

  ZonaEntity();

  /// Recalcula `claveUnica` a partir de `localId` y `nombre`.
  ///
  /// Llamar SIEMPRE antes de persistir.
  ///
  /// Un tombstone sale del índice único con sufijo `#del<id>`: si no, no
  /// se podría volver a crear una zona con el mismo nombre.
  void recalcularClaveUnica() {
    claveUnica = eliminado
        ? '$localId::$nombre#del$id'
        : '$localId::$nombre';
  }
}
