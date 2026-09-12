import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'package:app_boosti_v2/features/pos/data/Local/entities/producto_entity.dart';

// ============================================================
// HELPERS
// ============================================================

Map<String, dynamic> productoJsonCompleto() => {
      'uuid': 'abc-123-uuid',
      'codigo_barras': '75010001',
      'nombre': 'Manzana Roja Importada',
      'marca': 'Del Campo',
      'marca_supabase_id': 'marca-uuid-456',
      'precio_unidad': 3.50,
      'stock': 50.0,
      'es_pesado': true,
      'categoria': 'Frutas',
      'categoria_id': 5,
      'proveedor_id': 'prov-uuid-789',
      'proveedor_nombre': 'Distribuidora C.A.',
      'proveedor_telefono': '0412-1234567',
      'proveedor_email': 'ventas@dist.com',
      'proveedor_direccion': 'Zona Industrial',
      'stock_minimo': 10.0,
      'activo': true,
      'imagen_url': 'https://ik.imagekit.io/manzana.png',
      'created_at': '2026-09-12T10:00:00Z',
      'updated_at': '2026-09-12T11:30:00Z',
      'created_by': 1,
      'updated_by': 2,
      'created_by_name': 'Admin',
      'updated_by_name': 'Cajero',
      'version': 3,
    };

// ============================================================

void main() {
  // ============================================================
  // GRUPO 1: Constructor y defaults
  // ============================================================
  group('ProductoEntity — Constructor y defaults', () {
    test('constructor vacío usa defaults correctos', () {
      final p = ProductoEntity();

      expect(p.id, Isar.autoIncrement);
      expect(p.codigoBarras, '');
      expect(p.nombre, '');
      expect(p.precioUnidad, 0.0);
      expect(p.stock, 0.0);
      expect(p.esPesado, false);
      expect(p.activo, true);
      expect(p.categoria, 'General');
      expect(p.stockMinimo, 5.0);
      expect(p.version, 0);
      expect(p.sincronizado, false);
    });

    test('constructor con parámetros asigna valores', () {
      final p = ProductoEntity(
        codigoBarras: '123',
        nombre: 'Test',
        precioUnidad: 15.5,
        stock: 100,
        esPesado: true,
        categoria: 'Bebidas',
      );

      expect(p.codigoBarras, '123');
      expect(p.nombre, 'Test');
      expect(p.precioUnidad, 15.5);
      expect(p.stock, 100.0);
      expect(p.esPesado, true);
      expect(p.categoria, 'Bebidas');
    });

    test('campos nullables arrancan en null', () {
      final p = ProductoEntity();

      expect(p.supabaseId, isNull);
      expect(p.marcaSupabaseId, isNull);
      expect(p.proveedorSupabaseId, isNull);
      expect(p.categoriaId, isNull);
      expect(p.proveedorId, isNull);
      expect(p.imagenUrl, isNull);
      expect(p.createdAt, isNull);
      expect(p.updatedAt, isNull);
      expect(p.createdBy, isNull);
      expect(p.updatedBy, isNull);
      expect(p.createdByName, isNull);
      expect(p.updatedByName, isNull);
      expect(p.fechaSincronizacion, isNull);
    });

    test('defaults son lógicos para venta', () {
      final p = ProductoEntity();

      expect(p.activo, true);
      expect(p.esPesado, false);
      expect(p.categoria, 'General');
      expect(p.stockMinimo, 5.0);
    });
  });

  // ============================================================
  // GRUPO 2: fromJson
  // ============================================================
  group('ProductoEntity — fromJson', () {
    test('parsea respuesta completa de Supabase', () {
      final p = ProductoEntity.fromJson(productoJsonCompleto());

      expect(p.supabaseId, 'abc-123-uuid');
      expect(p.codigoBarras, '75010001');
      expect(p.nombre, 'Manzana Roja Importada');
      expect(p.marca, 'Del Campo');
      expect(p.marcaSupabaseId, 'marca-uuid-456');
      expect(p.precioUnidad, 3.50);
      expect(p.stock, 50.0);
      expect(p.esPesado, true);
      expect(p.categoria, 'Frutas');
      expect(p.categoriaId, 5);
      expect(p.proveedorSupabaseId, 'prov-uuid-789');
      expect(p.proveedorNombre, 'Distribuidora C.A.');
      expect(p.proveedorTelefono, '0412-1234567');
      expect(p.proveedorEmail, 'ventas@dist.com');
      expect(p.proveedorDireccion, 'Zona Industrial');
      expect(p.stockMinimo, 10.0);
      expect(p.activo, true);
      expect(p.imagenUrl, 'https://ik.imagekit.io/manzana.png');
      expect(p.version, 3);
      expect(p.createdByName, 'Admin');
      expect(p.updatedByName, 'Cajero');
    });

    test('parsea fechas ISO 8601 a DateTime', () {
      final p = ProductoEntity.fromJson(productoJsonCompleto());

      expect(p.createdAt, isA<DateTime>());
      expect(p.createdAt!.year, 2026);
      expect(p.createdAt!.month, 9);
      expect(p.updatedAt, isNotNull);
    });

    test('parsea int de auditoría', () {
      final p = ProductoEntity.fromJson(productoJsonCompleto());

      expect(p.createdBy, 1);
      expect(p.updatedBy, 2);
    });

    test('campos faltantes usan defaults', () {
      final p = ProductoEntity.fromJson({});

      expect(p.supabaseId, isNull);
      expect(p.codigoBarras, '');
      expect(p.nombre, '');
      expect(p.precioUnidad, 0.0);
      expect(p.stock, 0.0);
      expect(p.esPesado, false);
      expect(p.categoria, 'General');
      expect(p.stockMinimo, 5.0);
      expect(p.activo, true);
      expect(p.version, 0);
    });

    test('parsea numéricos enteros como double', () {
      final json = {
        'precio_unidad': 5,
        'stock': 100,
        'stock_minimo': 10,
      };
      final p = ProductoEntity.fromJson(json);

      expect(p.precioUnidad, 5.0);
      expect(p.stock, 100.0);
      expect(p.stockMinimo, 10.0);
    });

    test('parsea precios con decimales', () {
      final json = {'precio_unidad': 3.456};
      final p = ProductoEntity.fromJson(json);

      expect(p.precioUnidad, 3.456);
    });

    test('maneja null en campos nullable', () {
      final json = {
        'uuid': null,
        'marca_supabase_id': null,
        'categoria_id': null,
        'proveedor_id': null,
        'imagen_url': null,
        'created_at': null,
        'updated_at': null,
        'created_by': null,
        'updated_by': null,
        'created_by_name': null,
        'updated_by_name': null,
      };
      final p = ProductoEntity.fromJson(json);

      expect(p.supabaseId, isNull);
      expect(p.marcaSupabaseId, isNull);
      expect(p.categoriaId, isNull);
      expect(p.proveedorSupabaseId, isNull);
      expect(p.imagenUrl, isNull);
      expect(p.createdAt, isNull);
      expect(p.updatedAt, isNull);
      expect(p.createdBy, isNull);
      expect(p.updatedBy, isNull);
      expect(p.createdByName, isNull);
      expect(p.updatedByName, isNull);
    });

    test('activo false se respeta', () {
      final p = ProductoEntity.fromJson({'activo': false});
      expect(p.activo, false);
    });

    test('esPesado true se respeta', () {
      final p = ProductoEntity.fromJson({'es_pesado': true});
      expect(p.esPesado, true);
    });

    // ✅ NUEVOS: robustez de tipos
    test('proveedor_id como UUID (String) → proveedorSupabaseId', () {
      final p = ProductoEntity.fromJson({'proveedor_id': 'uuid-abc-123'});
      expect(p.proveedorSupabaseId, 'uuid-abc-123');
      expect(p.proveedorId, isNull);
    });

    test('proveedor_id como int legacy → proveedorId', () {
      final p = ProductoEntity.fromJson({'proveedor_id': 42});
      expect(p.proveedorId, 42);
      expect(p.proveedorSupabaseId, isNull);
    });

    test('proveedor_id numérico con decimal se convierte a int', () {
      final p = ProductoEntity.fromJson({'proveedor_id': 42.7});
      expect(p.proveedorId, 42);
    });

    test('categoria_id como String numérico se parsea', () {
      final p = ProductoEntity.fromJson({'categoria_id': '5'});
      expect(p.categoriaId, 5);
    });

    test('categoria_id inválido se convierte en null', () {
      final p = ProductoEntity.fromJson({'categoria_id': 'abc'});
      expect(p.categoriaId, isNull);
    });

    test('created_by como String numérico se parsea', () {
      final p = ProductoEntity.fromJson({'created_by': '10'});
      expect(p.createdBy, 10);
    });

    test('acepta "id" como fallback para supabaseId (legacy)', () {
      final p = ProductoEntity.fromJson({'id': 'legacy-uuid'});
      expect(p.supabaseId, 'legacy-uuid');
    });

    test('"uuid" tiene prioridad sobre "id"', () {
      final p = ProductoEntity.fromJson({
        'uuid': 'uuid-nuevo',
        'id': 'id-viejo',
      });
      expect(p.supabaseId, 'uuid-nuevo');
    });

    test('precio como String numérico se parsea', () {
      final p = ProductoEntity.fromJson({'precio_unidad': '3.50'});
      expect(p.precioUnidad, 3.50);
    });

    test('precio inválido cae a 0', () {
      final p = ProductoEntity.fromJson({'precio_unidad': 'no-es-numero'});
      expect(p.precioUnidad, 0.0);
    });
  });

  // ============================================================
  // GRUPO 3: toJson
  // ============================================================
  group('ProductoEntity — toJson', () {
    test('serializa todos los campos a snake_case', () {
      final p = ProductoEntity(
        codigoBarras: '75010001',
        nombre: 'Manzana',
        precioUnidad: 3.50,
        stock: 50,
        esPesado: true,
        categoria: 'Frutas',
        stockMinimo: 10,
      );

      final json = p.toJson();

      expect(json['codigo_barras'], '75010001');
      expect(json['nombre'], 'Manzana');
      expect(json['precio_unidad'], 3.50);
      expect(json['stock'], 50.0);
      expect(json['es_pesado'], true);
      expect(json['categoria'], 'Frutas');
      expect(json['stock_minimo'], 10.0);
    });

    test('serializa fechas a ISO 8601', () {
      final now = DateTime.now();
      final p = ProductoEntity()..createdAt = now;

      final json = p.toJson();

      expect(json['created_at'], isA<String>());
      expect(json['created_at'], contains('T'));
    });

    test('serializa campos nullable como null', () {
      final p = ProductoEntity();
      final json = p.toJson();

      expect(json['uuid'], isNull);
      expect(json['marca_supabase_id'], isNull);
      expect(json['categoria_id'], isNull);
      expect(json['proveedor_id'], isNull);
      expect(json['imagen_url'], isNull);
      expect(json['created_at'], isNull);
      expect(json['updated_at'], isNull);
    });

    // ✅ ACTUALIZADO: usa 'uuid' en lugar de 'id'
    test('usa supabaseId como "uuid" en el JSON', () {
      final p = ProductoEntity()..supabaseId = 'uuid-test-123';
      final json = p.toJson();

      expect(json['uuid'], 'uuid-test-123');
      expect(json.containsKey('id'), isFalse,
          reason: 'toJson ya no debe usar "id"');
    });

    test('usa proveedorSupabaseId como "proveedor_id"', () {
      final p = ProductoEntity()..proveedorSupabaseId = 'prov-uuid-abc';
      final json = p.toJson();

      expect(json['proveedor_id'], 'prov-uuid-abc');
    });

    test('usa proveedorId legacy como fallback si no hay UUID', () {
      final p = ProductoEntity()..proveedorId = 42;
      final json = p.toJson();

      expect(json['proveedor_id'], '42');
    });

    test('proveedorSupabaseId tiene prioridad sobre proveedorId', () {
      final p = ProductoEntity()
        ..proveedorSupabaseId = 'uuid-prioridad'
        ..proveedorId = 42;
      final json = p.toJson();

      expect(json['proveedor_id'], 'uuid-prioridad');
    });
  });

  // ============================================================
  // GRUPO 4: Round-trip
  // ============================================================
  group('ProductoEntity — Round-trip', () {
    test('fromJson → toJson preserva los campos principales', () {
      final original = ProductoEntity.fromJson(productoJsonCompleto());
      final json = original.toJson();

      expect(json['codigo_barras'], '75010001');
      expect(json['nombre'], 'Manzana Roja Importada');
      expect(json['precio_unidad'], 3.50);
      expect(json['stock'], 50.0);
      expect(json['es_pesado'], true);
      expect(json['categoria'], 'Frutas');
      expect(json['stock_minimo'], 10.0);
      expect(json['activo'], true);
      expect(json['version'], 3);
    });

    test('toJson → fromJson preserva los datos', () {
      final original = ProductoEntity(
        codigoBarras: 'ABC-123',
        nombre: 'Producto Test',
        precioUnidad: 99.99,
        stock: 42.5,
        esPesado: true,
        categoria: 'Test',
        stockMinimo: 7.5,
      )..supabaseId = 'uuid-roundtrip';

      final json = original.toJson();
      final reconstruido = ProductoEntity.fromJson(json);

      expect(reconstruido.supabaseId, 'uuid-roundtrip');
      expect(reconstruido.codigoBarras, 'ABC-123');
      expect(reconstruido.nombre, 'Producto Test');
      expect(reconstruido.precioUnidad, 99.99);
      expect(reconstruido.stock, 42.5);
      expect(reconstruido.esPesado, true);
      expect(reconstruido.categoria, 'Test');
      expect(reconstruido.stockMinimo, 7.5);
    });

    test('round-trip de proveedorSupabaseId funciona', () {
      final original = ProductoEntity()..proveedorSupabaseId = 'prov-uuid-xyz';

      final reconstruido = ProductoEntity.fromJson(original.toJson());

      expect(reconstruido.proveedorSupabaseId, 'prov-uuid-xyz');
      expect(reconstruido.proveedorId, isNull);
    });
  });

  // ============================================================
  // GRUPO 5: Casos edge
  // ============================================================
  group('ProductoEntity — Casos edge', () {
    test('precio 0 es válido (producto gratuito)', () {
      final p = ProductoEntity(precioUnidad: 0.0);
      expect(p.precioUnidad, 0.0);
    });

    test('stock 0 es válido (sin stock)', () {
      final p = ProductoEntity(stock: 0.0);
      expect(p.stock, 0.0);
    });

    test('nombre vacío se permite (validación en capa superior)', () {
      final p = ProductoEntity(nombre: '');
      expect(p.nombre, '');
    });

    test('nombre muy largo se preserva', () {
      final nombreLargo = 'A' * 500;
      final p = ProductoEntity(nombre: nombreLargo);
      expect(p.nombre.length, 500);
    });

    test('código de barras vacío es válido', () {
      final p = ProductoEntity(codigoBarras: '');
      expect(p.codigoBarras, '');
    });

    test('código de barras con caracteres especiales', () {
      final codigo = 'ABC-123/XYZ#456';
      final p = ProductoEntity(codigoBarras: codigo);
      expect(p.codigoBarras, codigo);
    });

    test('version se incrementa manualmente', () {
      final p = ProductoEntity()..version = 5;
      expect(p.version, 5);
    });

    test('auditoría se preserva al reasignar', () {
      final p = ProductoEntity()
        ..createdBy = 10
        ..createdByName = 'Admin'
        ..updatedBy = 20
        ..updatedByName = 'Cajero';

      expect(p.createdBy, 10);
      expect(p.updatedBy, 20);
      expect(p.createdByName, 'Admin');
      expect(p.updatedByName, 'Cajero');
    });

    test('sincronizado y fechaSincronizacion funcionan juntos', () {
      final ahora = DateTime.now();
      final p = ProductoEntity()
        ..sincronizado = true
        ..fechaSincronizacion = ahora;

      expect(p.sincronizado, true);
      expect(p.fechaSincronizacion, ahora);
    });

    test('nombre con caracteres unicode', () {
      final p = ProductoEntity(nombre: 'Café ☕ Molido 500g');
      expect(p.nombre, 'Café ☕ Molido 500g');
    });

    test('precio con 4 decimales se preserva', () {
      final p = ProductoEntity(precioUnidad: 3.4567);
      expect(p.precioUnidad, 3.4567);
    });
  });
}