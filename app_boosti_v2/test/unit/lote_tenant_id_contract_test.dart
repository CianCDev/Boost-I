import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/lote_entity.dart';

void main() {
  group('LoteEntity tenant_id migration contract', () {
    test('toSupabaseJson includes tenant_id correct UUID', () {
      final lote = LoteEntity()
        ..id = 1
        ..productoId = 7
        ..localId = 33
        ..codigoLoteProveedor = 'LP-001'
        ..cantidadInicial = 10
        ..cantidadRestante = 10
        ..fechaIngreso = DateTime(2026, 9, 12)
        ..estado = 'pendiente'
        ..proveedorId = 'prov-uuid'
        ..proveedorNombre = 'Prov 1'
        ..sincronizado = false;

      final json = lote.toSupabaseJson(
        tenantUuid: '11111111-1111-1111-1111-111111111111',
      );

      expect(json['tenant_id'], '11111111-1111-1111-1111-111111111111');
    });

    test('fromSupabase assigns localIdResuelto into Isar localId', () {
      final json = {
        'id_isar': 99,
        'id': 'supabase-uuid-lote',
        'producto_id_fk': 7,
        'tenant_id': '11111111-1111-1111-1111-111111111111',
        'codigo_lote_proveedor': 'LP-001',
        'cantidad_inicial': 10,
        'cantidad_restante': 10,
        'fecha_ingreso': '2026-09-12T00:00:00.000',
        'fecha_vencimiento': null,
        'estado': 'pendiente',
        'costo_unitario': 4.5,
        'proveedor_id': 'prov-uuid',
        'proveedor_nombre': 'Prov 1',
        'sincronizado': false,
        'fecha_sincronizacion': null,
      };

      final lote = LoteEntity.fromSupabase(json, localIdResuelto: 33);

      expect(lote.localId, 33);
    });

    test('toSupabaseJson omits legacy local_id key', () {
      final lote = LoteEntity()
        ..id = 1
        ..productoId = 7
        ..localId = 33
        ..codigoLoteProveedor = 'LP-001'
        ..cantidadInicial = 10
        ..cantidadRestante = 10
        ..fechaIngreso = DateTime(2026, 9, 12)
        ..estado = 'pendiente'
        ..proveedorId = 'prov-uuid'
        ..proveedorNombre = 'Prov 1'
        ..sincronizado = false;

      final json = lote.toSupabaseJson(
        tenantUuid: '11111111-1111-1111-1111-111111111111',
      );

      expect(json.containsKey('local_id'), isFalse);
    });
  });

  group('sync_service tenant_id payload contract', () {
    test('sync_service payloads use tenant_id not local_id', () async {
      final source = await File(
              'c:\\Users\\torre\\app_gestion_m\\app_boosti_v2\\lib\\features\\pos\\presentation\\services\\sync_service.dart')
          .readAsString();

      expect(source.contains("'tenant_id': localUuid"), isTrue);
      expect(source.contains("data['tenant_id']"), isTrue);
      expect(source.contains("'tenant_id': localSupabaseId"), isTrue);
      expect(source.contains(".eq('tenant_id', localSupabaseId)"), isTrue);
      expect(source.contains("'tenant_id': localOrigenUuid"), isTrue);
      expect(source.contains("local_destino_id"), isFalse);
      expect(source.contains("'local_id': lote.localId"), isFalse);
      expect(source.contains("'local_id': pedido.localOrigenId"), isFalse);
    });
  });
}
