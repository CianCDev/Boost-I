// lib/features/pos/domain/services/barcode_validation_service.dart
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/lote_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/producto_entity.dart';

enum BarcodeValidationType {
  free,           // Código completamente nuevo
  usedInLote,     // Código usado en un lote (puede estar agotado o activo)
  usedAsAlias,    // Código usado como alias de otro producto
  usedAsProduct,  // Código principal de otro producto
  invalid,        // Código inválido (formato incorrecto)
  tooShort,       // Código demasiado corto
}

class BarcodeValidationResult {
  final BarcodeValidationType type;
  final String? message;
  final LoteEntity? loteExistente;
  final ProductoEntity? productoExistente;
  final bool isAllowed;

  BarcodeValidationResult({
    required this.type,
    this.message,
    this.loteExistente,
    this.productoExistente,
    this.isAllowed = false,
  });

  factory BarcodeValidationResult.success() {
    return BarcodeValidationResult(
      type: BarcodeValidationType.free,
      isAllowed: true,
      message: 'Código válido',
    );
  }

  factory BarcodeValidationResult.usedInLote(LoteEntity lote) {
    final isAgotado = lote.cantidadRestante == 0;
    return BarcodeValidationResult(
      type: BarcodeValidationType.usedInLote,
      loteExistente: lote,
      isAllowed: isAgotado,
      message: isAgotado
          ? 'Código usado en lote agotado (Lote #${lote.id})'
          : 'Código en uso en lote activo (Lote #${lote.id}, ${lote.cantidadRestante} kg)',
    );
  }

  factory BarcodeValidationResult.usedAsAlias(ProductoEntity producto) {
    return BarcodeValidationResult(
      type: BarcodeValidationType.usedAsAlias,
      productoExistente: producto,
      isAllowed: false,
      message: 'Código asignado como alias a "${producto.nombre}"',
    );
  }

  factory BarcodeValidationResult.usedAsProduct(ProductoEntity producto) {
    return BarcodeValidationResult(
      type: BarcodeValidationType.usedAsProduct,
      productoExistente: producto,
      isAllowed: false,
      message: 'Código principal de "${producto.nombre}"',
    );
  }

  factory BarcodeValidationResult.tooShort(int length) {
    return BarcodeValidationResult(
      type: BarcodeValidationType.tooShort,
      isAllowed: true, // Lo permitimos con advertencia
      message: 'Código muy corto ($length dígitos)',
    );
  }

  factory BarcodeValidationResult.invalid(String reason) {
    return BarcodeValidationResult(
      type: BarcodeValidationType.invalid,
      isAllowed: false,
      message: reason,
    );
  }
}

class BarcodeValidationService {
  final IsarService _isar = IsarService();
  final int minProductCodeLength = 4;

  Future<BarcodeValidationResult> validate(String codigo, {int? loteIdIgnorar}) async {
    final codigoLimpio = codigo.trim();
    
    // 1. Validar longitud mínima
    if (codigoLimpio.isEmpty) {
      return BarcodeValidationResult.invalid('Código vacío');
    }

    // 2. Códigos cortos (< 4 dígitos): permitir con advertencia
    if (codigoLimpio.length < minProductCodeLength) {
      return BarcodeValidationResult.tooShort(codigoLimpio.length);
    }

    // 3. Verificar si el código es alias de otro producto
    final alias = await _isar.obtenerAliasPorCodigo(codigoLimpio);
    if (alias != null) {
      final producto = await _isar.obtenerProductoPorId(alias.productoId);
      if (producto != null && producto.id != loteIdIgnorar) {
        return BarcodeValidationResult.usedAsAlias(producto);
      }
    }

    // 4. Verificar si el código es código principal de otro producto
    final productos = await _isar.obtenerProductos();
    final productoConCodigo = productos.firstWhere(
      (p) => p.codigoBarras == codigoLimpio && p.id != loteIdIgnorar,
      orElse: () => ProductoEntity(),
    );
    if (productoConCodigo.id != 0) {
      // Solo bloquear si el producto tiene nombre
      if (productoConCodigo.nombre.isNotEmpty) {
        return BarcodeValidationResult.usedAsProduct(productoConCodigo);
      } else {
        // Producto sin nombre: permitir (es un dato corrupto)
        return BarcodeValidationResult.success();
      }
    }

    // 5. Verificar si el código está en otro lote
    final todosLosLotes = await _isar.obtenerTodosLosLotes();
    final loteExistente = todosLosLotes.firstWhere(
      (l) => l.codigoLoteProveedor == codigoLimpio && l.id != loteIdIgnorar,
      orElse: () => LoteEntity(),
    );
    if (loteExistente.id != 0) {
      return BarcodeValidationResult.usedInLote(loteExistente);
    }

    // ✅ Código libre
    return BarcodeValidationResult.success();
  }
}