import 'package:isar/isar.dart';

import 'estado_plato.dart';

part 'cart_session_entity.g.dart';

enum CartSessionStatus {
  enEspera,
  abandonado,
}

/// Estado de una COMANDA (restaurante · R.2).
///
/// ⚠️ Solo se usan `abierta`, `enviada`, `cerrada` y `cancelada`.
///
/// `enPreparacion` y `entregada` estaban declarados para el KDS de R.3,
/// pero R.3.1 los reemplazó por `EstadoPlato` (estado POR PLATO, que es
/// lo que el KDS realmente necesita). Se conservan aquí por
/// compatibilidad, pero no los asigna ningún flujo.
enum ComandaEstado {
  abierta,
  enviada,

  /// Sin uso. El estado por plato vive en `EstadoPlato` (R.3.1).
  enPreparacion,

  /// Sin uso. El estado por plato vive en `EstadoPlato` (R.3.1).
  entregada,

  cerrada,
  cancelada,
}

@collection
class CartSessionEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String sessionId;

  @Index()
  late int usuarioId;

  String nombre = 'Carrito';

  // ✅ Inicializado con lista vacía para evitar LateInitializationError
  List<String> itemsNombres = [];

  // ==================== CLIENTE (opcional) ====================
  int? clienteIsarId;
  String? clienteSupabaseId;
  String? clienteNombre;
  String? clienteDocumento;

  // ==================== NOTAS ====================
  String? notas;

  // ==================== CONFIG IVA (congelada) ====================
  String configIvaPais = 'VE';
  double configIvaPorcentaje = 0.16;
  bool configIvaPreciosIncluyenIva = true;
  bool ivaHabilitado = true;

  // ==================== TIMESTAMPS ====================
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  // ==========================================================
  // R.2 · COMANDA (restaurante)
  //
  // Todos los campos siguientes son ADITIVOS. Una sesión con
  // `mesaId == null` es un carrito aparcado de retail y se comporta
  // EXACTAMENTE igual que antes de R.2.
  //
  // La discriminación es `mesaId != null`, nunca `esAbandonado` ni
  // `status`: esos siguen siendo exclusively del carrito de retail.
  // ==========================================================

  /// Id (Isar) de la MesaEntity dueña. `null` → carrito de retail.
  int? mesaId;

  /// Snapshot del nombre, por si la mesa se renombra o se elimina.
  String? mesaNombre;

  /// Id de la mesa en Supabase. R.1b lo puebla cuando haya sync.
  // ignore: unused_field
  int? mesaSupabaseId;

  // ── Sync (convención A) ──
  /// UUID de la comanda en Supabase. `null` → nunca sincronizada.
  String? supabaseId;
  bool sincronizado = false;
  DateTime? fechaSincronizacion;

  /// R.1c · Identidad de sync de la comanda.
  ///
  /// ⚠️ [sessionId] NO sirve para esto: en una comanda vale
  /// `mesa:<idIsar>`, y el id de Isar es de ESTE dispositivo. `syncKey` es
  /// un UUID que se genera en el primer push y no cambia nunca; la tabla
  /// `comandas` tiene `UNIQUE (tenant_id, sync_key)`.
  String? syncKey;

  // ── Estado comanda ──
  @Enumerated(EnumType.name)
  ComandaEstado comandaEstado = ComandaEstado.abierta;

  // ── Mesero ──
  //
  // Genérico a propósito: Q2 unifica mesero/cajero y el refactor de
  // roles se hace en R.5, no aquí.
  int? meseroId;
  String? meseroNombre;

  // ── Comensales ──
  int comensales = 1;

  /// Id del cliente que pidió la comanda.
  ///
  /// OJO: el `clienteNombre` ya existe arriba (bloque CLIENTE, campo
  /// pre-existente de retail). No se duplica aquí a propósito: es el
  /// mismo dato y así ambos flujos escriben en el mismo sitio.
  int? clienteId;

  // ── Timestamps comanda ──
  DateTime? enviadaCocinaAt;
  DateTime? cerradaAt;

  /// true si esta sesión es una comanda de restaurante (no un carrito).
  @ignore
  bool get esComanda => mesaId != null;

  /// true si la comanda sigue en un estado que admite cambios.
  @ignore
  bool get comandaEditable =>
      comandaEstado == ComandaEstado.abierta ||
      comandaEstado == ComandaEstado.enviada;

  // ==================== ESTADO ====================
  @Enumerated(EnumType.name)
  CartSessionStatus status = CartSessionStatus.enEspera;

  List<CartSessionItem> items = [];

  CartSessionEntity();

  // ── Identidad local (R.1c) ──────────────────────────────────────────
  //
  // `sessionId` es UNICO en Isar y es lo que usan `ComandaScreen` y
  // `abrirComanda` para encontrar la comanda de una mesa. El builder vive
  // acá (y no en el notifier) porque `SyncService` también lo necesita al
  // bajar comandas de otro dispositivo.

  /// `sessionId` de la comanda VIVA de una mesa.
  static String sessionIdDeMesa(int mesaId) => 'mesa:$mesaId';

  /// `sessionId` de una comanda HISTÓRICA (cerrada o cancelada).
  ///
  /// Lleva el `syncKey` porque `mesa:<id>` está reservado para la viva: dos
  /// históricas de la misma mesa chocarían contra el índice único y una
  /// borraría a la otra en silencio.
  static String sessionIdHistorico(int mesaId, String syncKey) {
    final marca = syncKey.trim();
    return 'mesa:$mesaId#${marca.length > 8 ? marca.substring(0, 8) : marca}';
  }

  @ignore
  bool get esAbandonado =>
      DateTime.now().difference(createdAt) > const Duration(hours: 24);

  @ignore
  int get cantidadItems => items.length;

  @ignore
  double get total {
    return items.fold<double>(0.0, (sum, item) {
      return sum + (item.precioUnidad * item.cantidad);
    });
  }
}

@embedded
class CartSessionItem {
  String productoId = '';
  String productoNombre = '';
  String productoCodigoBarras = '';
  String productoCategoria = 'General';
  double precioUnidad = 0.0;
  double precioOriginal = 0.0;
  double cantidad = 0.0;
  bool esPesado = false;
  bool esDescuentoEspecial = false;

  // ==========================================================
  // R.2 · Comanda — additives
  //
  // ⚠️ `nota` y `estacionId` son INFORMATIVOS en R.2: no llegan al
  // ticket ni a la venta, porque `ProductItem` y `DetalleVentaEntity`
  // no tienen esos campos. Se pierden al restaurar la comanda al
  // carrito vivo. Ver `docs/TODO.md` → "Notas y estación por ítem".
  // ==========================================================

  /// "sin cebolla", "poco picante", etc.
  String? nota;

  /// Q1: línea por estación → departamento destino (KDS, R.3).
  ///
  /// Apunta a `DepartamentoEntity.id`. Viene de
  /// `ProductoEntity.departamentoId` → `CartItem.estacionId`.
  /// `null` si el producto no requiere preparación.
  int? estacionId;

  /// Snapshot del nombre de la estación (evita el JOIN en el KDS).
  String? estacionNombre;

  // ==========================================================
  // R.4 · Enlace con la receta (G.3)
  // ==========================================================

  /// Id LOCAL de Isar del `ProductoEntity` al que pertenece este item.
  ///
  /// ⚠️ [productoId] (arriba) es el UUID de **Supabase**, un `String`. Este
  /// es el id de **Isar**, un `int`. No son intercambiables y por eso
  /// conviven: `productoId` es lo que se sincroniza y lo que viaja en la
  /// venta; este es lo único con lo que `RecetaEntity.productoId` y
  /// `RecetaItemEntity.ingredienteId` se pueden enlazar.
  ///
  /// Se rellena al volcar el carrito en la comanda, con un lookup
  /// `ProductoEntity.supabaseId == productoId`. `null` si el producto no
  /// existe todavía en Isar, y en ese caso G.3 no encuentra receta y no
  /// descuenta nada.
  ///
  /// ⚠️ LOCAL-ONLY por el mismo criterio que [departamentoId] (D2a): no
  /// está en ningún `toJson`, así que no viaja a Supabase. Es una tabla
  /// local que se puede volver a derivar desde `productoId`.
  int? productoIdLocal;

  /// Snapshot del mesero al enviar (Q10).
  // ignore: unused_field
  int? meseroId;

  /// Snapshot del nombre del mesero al enviar (Q10).
  // ignore: unused_field
  String? meseroNombre;

  // ==========================================================
  // R.3 · Ciclo de cocina (KDS)
  //
  // `estacionId` / `estacionNombre` ya existían desde R.2 y son
  // el destino de preparación de esta línea. NO se duplican aquí
  // (decisión D1a): el KDS los lee tal cual.
  // ==========================================================

  /// Estado de ESTE plato en el flujo de cocina.
  ///
  /// ⚠️ NO confundir con `CartSessionEntity.comandaEstado`, que es el
  /// estado de la comanda completa.
  ///
  /// ⚠️ Va anotado con `@Enumerated(EnumType.name)` dentro de un
  /// `@embedded`. `CartSessionItem` es el único `@embedded` del proyecto y
  /// no tenía ningún enum antes de R.3, así que este patrón no tiene
  /// precedente: si `build_runner` lo rechaza, se cae a `int` + un mapper
  /// (ver `test/features/pos/kds_estado_plato_test.dart`, que escribe y
  /// relee cada estado contra Isar real).
  @Enumerated(EnumType.name)
  EstadoPlato estadoPlato = EstadoPlato.pendiente;

  /// Cuándo entró al KDS. Es la clave del orden FIFO de la cola: los
  /// tickets se ordenan por este campo ascendente.
  DateTime? enviadoACocinaAt;

  /// Cuándo el cocinero lo tomó.
  DateTime? preparacionIniciadaAt;

  /// Cuándo terminó de cocinarlo.
  DateTime? listoAt;

  /// Cuándo salió hacia la mesa.
  DateTime? entregadoAt;

  // ── R.3.2 · Pausa en cocina ──────────────────────────────────────
  //
  // Un plato se pausa cuando NO se puede seguir: falta ingrediente, hay
  // que esperar al comensal, error de equipo. El KDS lo sigue mostrando
  // (con rojo intenso) pero sus botones de avance quedan deshabilitados
  // hasta que se reanude.

  /// R.3.2 · URL de la imagen del producto, como SNAPSHOT.
  ///
  /// Viene de `ProductoEntity.imagenUrl` a través de `CartItem.imagenUrl`.
  /// Existe para que `ComandaScreen` y el KDS pinten miniatura sin hacer un
  /// lookup a `ProductoEntity` por cada fila (que además fallaría si el
  /// producto se borró después de abrir la comanda).
  ///
  /// `null` si el producto no tiene foto.
  String? imagenUrl;

  /// Plato pausado. Mientras sea `true`, el KDS no ofrece avanzar su
  /// estado y el contador del menú lo excluye.
  bool pausado = false;

  /// Cuándo se pausó. Se limpia al reanudar.
  DateTime? pausadoEn;

  /// Motivo corto y opcional que escribe el cocinero ("falta pescado").
  ///
  /// ⚠️ El límite de 60 caracteres se valida en
  /// `ComandasNotifier.pausarItem`, no aquí: el campo es un `String` sin
  /// restricción en el schema.
  String? motivoPausa;

  CartSessionItem();
}