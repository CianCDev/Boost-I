// lib/features/pos/data/Local/entities/mesa_entity.dart
import 'package:isar/isar.dart';

part 'mesa_entity.g.dart';

/// Estado operativo de una mesa.
///
/// ⚠️ CONVENCIÓN PARA SUPABASE (R.1b): `EnumType.name` guarda el nombre
/// del enumerado tal cual ("porLimpiar"). La tabla en Supabase usará
/// snake_case ("por_limpiar"), así que el sync tendrá que mapear.
enum MesaEstado { libre, ocupada, reservada, porLimpiar }

/// Zona del local donde está la mesa.
enum MesaZona { salon, terraza, bar, privado, vip }

/// Mesa del salón (restaurante / B.2B).
///
/// R.1: alta, edición, estado y unión de mesas.
/// R.2: comandas. R.7: reservas (campo `reservaId`).
@Collection()
class MesaEntity {
  Id id = Isar.autoIncrement;

  // ── Sync (convención A) ─────────────────────────────────────────────
  // R.1b implementa los métodos de sync; los campos ya quedan listos.
  String? supabaseId;
  bool sincronizado = false;
  DateTime? fechaSincronizacion;

  // ── Local ───────────────────────────────────────────────────────────

  /// Id Isar del local dueño de la mesa.
  ///
  /// 0 es un centinela válido: `Isar.autoIncrement` arranca en 1, así que
  /// 0 nunca es un id real. Existe para que un `MesaEntity()` recién
  /// construido no tenga `null` y rompa los `@Index`.
  ///
  /// `MesasProvider.crearMesa()` RECHAZA crear con 0: si no hay local
  /// activo no se guarda nada, para no dejar mesas huérfanas.
  @Index()
  int localId = 0;

  /// UUID del local, por si el local aún no está sincronizado.
  String? localSupabaseId;

  // ── Mesa ────────────────────────────────────────────────────────────

  @Index()
  String nombre = '';

  /// Clave única = `'$localId::$nombre'`.
  ///
  /// Existe porque Isar no permite declarar índices compuestos por
  /// anotación de forma verificable: o se usa un campo sintético como
  /// este, o `IsarIndex(composite: [...])` cuya firma exacta depende de
  /// la versión del generador. El campo sintético es inequívoco.
  ///
  /// NO se escribe a mano: usar `recalcularClaveUnica()` antes de guardar,
  /// o el índice único no protege contra "Mesa 1" duplicada en un local.
  @Index(unique: true, replace: true)
  String claveUnica = '';

  @Enumerated(EnumType.name)
  MesaZona zona = MesaZona.salon;

  /// Comensales que caben. Validado en el formulario (1..49).
  int capacidad = 4;

  @Enumerated(EnumType.name)
  MesaEstado estado = MesaEstado.libre;

  /// Posición en el grid estático del salón (croquis v1).
  ///
  /// R.1: orden manual. R.3: croquis real con drag & drop.
  int ordenGrid = 0;

  // ── Estado vivo ─────────────────────────────────────────────────────

  /// Id (Isar) de la mesa con la que está unida, si aplica.
  ///
  /// `replace: true` en `claveUnica` no afecta a este campo: es una
  /// relación lógica, la FK real llega con comandas en R.2.
  int? unidaConMesaId;

  /// Cuándo se ocupó. Se limpia al volver a `libre`.
  DateTime? ocupadaDesde;

  /// FK lógica a la reserva que bloquea la mesa (R.7).
  int? reservaId;

  // ── Audit ───────────────────────────────────────────────────────────

  DateTime? createdAt;
  DateTime? updatedAt;

  MesaEntity();

  /// Recalcula `claveUnica` a partir de `localId` y `nombre`.
  ///
  /// Llamar SIEMPRE antes de persistir (crear o editar).
  void recalcularClaveUnica() {
    claveUnica = '$localId::$nombre';
  }

  /// true si la mesa está unida a otra.
  bool get estaUnida => unidaConMesaId != null;

  /// true si admite una comanda nueva (R.2 usará esto).
  bool get disponibleParaComanda =>
      estado == MesaEstado.libre && !estaUnida;
}