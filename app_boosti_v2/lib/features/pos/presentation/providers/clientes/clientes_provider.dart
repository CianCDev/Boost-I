import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/Local/entities/isar_service.dart';
import '../../../data/Local/entities/cliente_entity.dart';
import '../sync_provider.dart'; // Asegúrate de tener este provider

final isarServiceProvider = Provider<IsarService>((ref) {
  return IsarService();
});

final clientesProvider = StateNotifierProvider<ClientesNotifier, List<ClienteEntity>>((ref) {
  return ClientesNotifier(ref);
});

final clientesFrecuentesProvider = Provider<List<ClienteEntity>>((ref) {
  final all = ref.watch(clientesProvider);
  return all.where((c) => c.frecuente).toList();
});

class ClientesNotifier extends StateNotifier<List<ClienteEntity>> {
  final Ref ref;

  ClientesNotifier(this.ref) : super([]) {
    cargarClientes();
  }

  IsarService get _isar => ref.read(isarServiceProvider);

  Future<void> cargarClientes() async {
    final clientes = await _isar.obtenerClientes(soloActivos: true);
    if (!mounted) return;
    state = clientes;
  }

  Future<ClienteEntity> guardarCliente(ClienteEntity cliente) async {
    final guardado = await _isar.guardarCliente(cliente);
    await cargarClientes();
    // Sincronizar en segundo plano (comentado si no tienes syncServiceProvider aún)
   ref.read(syncServiceProvider).sincronizarClientesPendientes();
    return guardado;
  }

  Future<bool> eliminarCliente(int id) async {
    final eliminado = await _isar.eliminarCliente(id);
    if (eliminado) {
      await cargarClientes();
    }
    return eliminado;
  }

  Future<List<ClienteEntity>> buscarClientes(String query, {bool soloFrecuentes = false}) async {
    return await _isar.buscarClientes(query, soloFrecuentes: soloFrecuentes);
  }
}