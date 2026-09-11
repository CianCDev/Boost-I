// lib/features/pos/presentation/providers/invalidation_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../productos_provider.dart';
import '../catalog_provider.dart';
import '../inventory_provider.dart';
import '../dashboard_provider.dart';
import '../lotes_provider.dart';

final invalidationProvider = Provider<InvalidationService>((ref) {
  return InvalidationService(ref);
});

class InvalidationService {
  final Ref _ref;

  InvalidationService(this._ref);

  void invalidarStock() {
    // Invalidar todos los providers que dependen del stock
    _ref.invalidate(productosProvider);
    _ref.invalidate(catalogProvider);
    _ref.invalidate(inventoryProvider);
    _ref.invalidate(dashboardProvider);
    _ref.invalidate(lotesProvider);
  }
}