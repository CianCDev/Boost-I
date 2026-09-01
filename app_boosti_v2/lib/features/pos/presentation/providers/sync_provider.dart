// lib/features/pos/presentation/providers/sync_provider.dart
import 'package:app_boosti_v2/features/pos/presentation/providers/marca_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/sync_service.dart';
import 'catalog_provider.dart';
import 'categorias_provider.dart';
import 'dashboard_provider.dart';
import 'departamentos_provider.dart';
import 'inventory_provider.dart';
import 'locales_provider.dart';
import 'productos_provider.dart';
import 'proveedores_provider.dart';
import 'usuario_provider.dart'; // ✅ para usarlo si es necesario

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    onDataChanged: () {
      // Invalida solo los providers que existen y se usan en la UI
      ref.invalidate(productosProvider);
      ref.invalidate(categoriasProvider);
      ref.invalidate(marcasProvider);       // definido en marca_provider.dart
      ref.invalidate(localesProvider);
      ref.invalidate(departamentosProvider);
      ref.invalidate(usuariosProvider);
      ref.invalidate(catalogProvider);      // escucha productosProvider, pero mejor invalidar directo
      ref.invalidate(inventoryProvider);
      // Si tienes dashboardProvider, puedes invalidarlo para refrescar resúmenes
      ref.invalidate(dashboardProvider);
      // Si tienes un provider de gastos, invalídalo (solo si existe)
      // ref.invalidate(gastosProvider);    // NO LO TIENES, así que comentado
      // proveedoresProvider no existe como tal, pero invalidamos el que se usa
      ref.invalidate(proveedoresConFiltroProvider);
    },
  );
});