// movimiento_inventario_entity.dart
import 'package:isar/isar.dart';
part 'movimiento_inventario_entity.g.dart';

@Collection()
class MovimientoInventarioEntity {
  Id id = Isar.autoIncrement;

 int productoId = 0;
  String nombreProducto = '';
  String tipoMovimiento = '';
  double cantidad = 0.0;
  double stockResultante = 0.0;
  DateTime fecha = DateTime.now();
  int usuarioId = 0;
  // ✅ Campo syncStatus con valor por defecto 'pending'

  String syncStatus = 'pending';

  // ──────────────── R.4 · Multi-local ────────────────
  //
  // ⚠️ Esta entidad NO tenía `localId`, y eso era un problema de DATOS,
  // no de UI: sin local, el histórico de movimientos de todas las
  // sucursales salía mezclado en la misma consulta. En un solo local no se
  // notaba.
  //
  // `0` = local desconocido (movimientos legacy anteriores a R.4). No se usa
  // `null` porque el resto del repo indexa y filtra por `localId` con
  // `int`, no con `int?` (ver `LoteEntity.localId`, que sí es `int?` pero
  // se filtraría aparte).
  @Index()
  int localId = 0;
}