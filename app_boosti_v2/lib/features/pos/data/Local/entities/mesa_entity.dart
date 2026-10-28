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

  /// Zona legacy (enum fijo). R.1b: se conserva SOLO como fallback de
  /// mesas creadas antes de que existieran las zonas editables.
  ///
  /// La fuente de verdad es [zonaNombre] + [zonaSupabaseId]. Para leer
  /// la zona de una mesa usar SIEMPRE [zonaEfectiva], nunca este campo.
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

  // ── R.1b ────────────────────────────────────────────────────────────
  //
  // ⚠️ Los campos nuevos van AL FINAL a propósito: Isar asigna los ids de
  // propiedad por orden de declaración. Insertarlos en medio corre todos
  // los ids existentes y una base ya instalada leería cada campo con el
  // dato del vecino.

  /// Nombre de la zona (fuente de verdad desde R.1b).
  ///
  /// Es un snapshot a propósito: si la zona se renombra, el provider
  /// actualiza las mesas en cascada. Así el grid no necesita un JOIN
  /// por mesa y funciona igual offline.
  String? zonaNombre;

  /// UUID de la zona en Supabase. `null` mientras la zona no subió.
  String? zonaSupabaseId;

  /// UUID de la mesa principal en Supabase (R.1b).
  ///
  /// Necesario para reconstruir [unidaConMesaId] en OTRO dispositivo: el
  /// id de Isar es local y no significa lo mismo allá.
  String? unidaConMesaSupabaseId;

  /// Borrado lógico (R.1b). Una fila `eliminado` se sube como tombstone
  /// para que el otro dispositivo no la resucite en el próximo pull.
  bool eliminado = false;

  MesaEntity();

  /// Recalcula `claveUnica` a partir de `localId` y `nombre`.
  ///
  /// Llamar SIEMPRE antes de persistir (crear o editar).
  ///
  /// Un tombstone sale del índice único con sufijo `#del<id>`: si no, no
  /// se podría volver a crear una mesa con el mismo nombre.
  void recalcularClaveUnica() {
    claveUnica = eliminado
        ? '$localId::$nombre#del$id'
        : '$localId::$nombre';
  }

  /// true si la mesa está unida a otra.
  bool get estaUnida => unidaConMesaId != null;

  /// true si admite una comanda nueva (R.2 usará esto).
  bool get disponibleParaComanda =>
      estado == MesaEstado.libre && !estaUnida;

  /// Nombre de zona que debe mostrar la UI.
  ///
  /// Prefiere la zona editable ([zonaNombre]); si la mesa es anterior a
  /// R.1b y todavía no fue migrada, cae al enum legacy.
  String get zonaEfectiva {
    final nombre = zonaNombre?.trim() ?? '';
    if (nombre.isNotEmpty) return nombre;
    return etiquetaZonaLegacy(zona);
  }
}

/// Etiqueta legible de una zona legacy (enum `MesaZona`).
///
/// Vive en la entidad y no en el provider para que `MesaEntity` pueda
/// usarla sin importar la capa de presentación.
String etiquetaZonaLegacy(MesaZona zona) {
  switch (zona) {
    case MesaZona.salon:
      return 'Salón';
    case MesaZona.terraza:
      return 'Terraza';
    case MesaZona.bar:
      return 'Bar';
    case MesaZona.privado:
      return 'Privado';
    case MesaZona.vip:
      return 'VIP';
  }
}

/// Mapea el nombre editable de una zona al enum legacy.
///
/// Se usa al crear/renombrar para no dejar `MesaEntity.zona` incoherente
/// mientras convivan ambos campos. Una zona nueva ("Patio") cae a
/// `MesaZona.salon`; el dato que manda es `zonaNombre`.
MesaZona mesaZonaDesdeNombre(String nombre) {
  final n = nombre
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .trim();
  switch (n) {
    case 'terraza':
      return MesaZona.terraza;
    case 'bar':
      return MesaZona.bar;
    case 'privado':
      return MesaZona.privado;
    case 'vip':
      return MesaZona.vip;
    default:
      return MesaZona.salon;
  }
}