// lib/features/pos/data/Local/entities/venta_entity.dart

import 'detalle_venta_entity.dart';

class VentaEntity {
  int id = 0; // 0 = nuevo
  String? idSupabase;

  DateTime? fecha;
  double total = 0.0;
  double subtotal = 0.0;
  double impuesto = 0.0;
  double tasaBcv = 0.0;
  double totalBolivares = 0.0;
  String metodoPago = '';
  int documento = 0;
  String empleado = 'Administrador / Catálogo';
  String? syncStatus = 'pending';

  // 🔥 Nuevos campos
  bool tieneDescuentoEspecial = false;
  double montoDescuentoTotal = 0.0;

  // Relaciones en memoria (se manejan manualmente en Sembast, sin IsarLinks)
  List<DetalleVentaEntity> items = [];

  String get ventaIdString => idSupabase ?? '';
  String get empleadoNombre => empleado;

  VentaEntity();

  // ✅ Convertir a Mapa (para Sembast)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idSupabase': idSupabase,
      'fecha': fecha?.toIso8601String(),
      'total': total,
      'subtotal': subtotal,
      'impuesto': impuesto,
      'tasaBcv': tasaBcv,
      'totalBolivares': totalBolivares,
      'metodoPago': metodoPago,
      'documento': documento,
      'empleado': empleado,
      'syncStatus': syncStatus,
      'tieneDescuentoEspecial': tieneDescuentoEspecial,
      'montoDescuentoTotal': montoDescuentoTotal,
      // Para Sembast guardamos los items serializados en un sub-mapa o lista
      'items': items.map((e) => e.toMap()).toList(),
    };
  }

  // ✅ Crear desde Mapa (Sembast)
  factory VentaEntity.fromMap(Map<String, dynamic> map) {
    return VentaEntity()
      ..id = (map['id'] as int?) ?? 0
      ..idSupabase = map['idSupabase'] as String?
      ..fecha = map['fecha'] != null ? DateTime.tryParse(map['fecha'] as String) : null
      ..total = (map['total'] as num?)?.toDouble() ?? 0.0
      ..subtotal = (map['subtotal'] as num?)?.toDouble() ?? 0.0
      ..impuesto = (map['impuesto'] as num?)?.toDouble() ?? 0.0
      ..tasaBcv = (map['tasaBcv'] as num?)?.toDouble() ?? 0.0
      ..totalBolivares = (map['totalBolivares'] as num?)?.toDouble() ?? 0.0
      ..metodoPago = (map['metodoPago'] as String?) ?? ''
      ..documento = (map['documento'] as int?) ?? 0
      ..empleado = (map['empleado'] as String?) ?? 'Administrador / Catálogo'
      ..syncStatus = map['syncStatus'] as String? ?? 'pending'
      ..tieneDescuentoEspecial = (map['tieneDescuentoEspecial'] as bool?) ?? false
      ..montoDescuentoTotal = (map['montoDescuentoTotal'] as num?)?.toDouble() ?? 0.0
      ..items = (map['items'] is List)
          ? (map['items'] as List).map((e) => DetalleVentaEntity.fromMap(e as Map<String, dynamic>)).toList()
          : [];
  }
}