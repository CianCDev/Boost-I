// lib/features/pos/presentation/screens/departamentos/departamentos_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/departamentos_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/locales_provider.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/departamento_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/local_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/departamentos/crear_departamento_dialog.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/departamentos/detalle_departamento_dialog.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/appbar.dart';
import 'package:app_boosti_v2/features/pos/presentation/utils/responsive_helper.dart';

import '../../../data/Local/entities/isar_service.dart';
import '../../../data/Local/entities/usuario_entity.dart';
import '../../widgets/dialogos_genericos/dialogos_genericos.dart';
import '../../widgets/dialogos_genericos/error_dialog.dart';
import '../../widgets/dialogos_genericos/succes.dialog.dart';

class DepartamentosScreen extends ConsumerStatefulWidget {
  const DepartamentosScreen({super.key});

  @override
  ConsumerState<DepartamentosScreen> createState() => _DepartamentosScreenState();
}

class _DepartamentosScreenState extends ConsumerState<DepartamentosScreen> {
  String _queryBusqueda = '';
  bool _mostrarInactivos = false;
  int? _localFiltroId;

  @override
  Widget build(BuildContext context) {
    final departamentosAsync = ref.watch(departamentosConFiltroProvider((
      query: _queryBusqueda,
      soloActivos: !_mostrarInactivos,
      localId: _localFiltroId,
    )));
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = ResponsiveHelper.isMobile(context);

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      appBar: CustomAppBar(
        title: isMobile ? 'Departamentos' : 'Gestión de Departamentos',
        showBackButton: true,
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              ref.invalidate(departamentosConFiltroProvider((
                query: _queryBusqueda,
                soloActivos: !_mostrarInactivos,
                localId: _localFiltroId,
              )));
            },
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'Recargar lista',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFiltros(colorScheme),
          Expanded(
            child: departamentosAsync.when(
              data: (departamentos) => _buildListaDepartamentos(departamentos),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline_rounded, size: 60, color: colorScheme.error),
                    const SizedBox(height: 16),
                    Text('Error al cargar departamentos', style: TextStyle(color: colorScheme.onSurface)),
                    const SizedBox(height: 8),
                    Text(err.toString(), style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(departamentosConFiltroProvider((
                          query: _queryBusqueda,
                          soloActivos: !_mostrarInactivos,
                          localId: _localFiltroId,
                        )));
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingButton(),
    );
  }

  Widget _buildSearchBar() {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Buscar por nombre...',
          prefixIcon: Icon(Icons.search_rounded, color: colorScheme.onSurfaceVariant),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: colorScheme.surface,
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        ),
        onChanged: (value) => setState(() => _queryBusqueda = value),
      ),
    );
  }

  Widget _buildFiltros(ColorScheme colorScheme) {
    final localesAsync = ref.watch(localesProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        children: [
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'activos', label: Text('Activos'), icon: Icon(Icons.check_circle_rounded)),
              ButtonSegment(value: 'inactivos', label: Text('Inactivos'), icon: Icon(Icons.cancel_rounded)),
            ],
            selected: {_mostrarInactivos ? 'inactivos' : 'activos'},
            onSelectionChanged: (Set<String> newSelection) {
              setState(() => _mostrarInactivos = newSelection.first == 'inactivos');
              ref.invalidate(departamentosConFiltroProvider((
                query: _queryBusqueda,
                soloActivos: !_mostrarInactivos,
                localId: _localFiltroId,
              )));
            },
            style: SegmentedButton.styleFrom(
              selectedForegroundColor: Colors.white,
              selectedBackgroundColor: const Color(0xFF8B5CF6),
              foregroundColor: colorScheme.onSurfaceVariant,
              backgroundColor: Colors.transparent,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 8),
          localesAsync.when(
            data: (locales) {
              return DropdownButtonFormField<int?>(
                initialValue: _localFiltroId,
                hint: Text(
                  'Filtrar por local',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
                isExpanded: true,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.storefront_rounded, size: 20, color: colorScheme.onSurfaceVariant),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: colorScheme.surface,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('Todos los locales'),
                  ),
                  ...locales.map((local) {
                    return DropdownMenuItem<int?>(
                      value: local.id,
                      child: Text(local.nombre),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    _localFiltroId = value;
                  });
                  ref.invalidate(departamentosConFiltroProvider((
                    query: _queryBusqueda,
                    soloActivos: !_mostrarInactivos,
                    localId: _localFiltroId,
                  )));
                },
                icon: Icon(Icons.arrow_drop_down, color: colorScheme.onSurfaceVariant),
                dropdownColor: colorScheme.surface,
                style: TextStyle(color: colorScheme.onSurface),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Text(
              'Error al cargar locales: $err',
              style: TextStyle(color: colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListaDepartamentos(List<DepartamentoEntity> departamentos) {
    if (departamentos.isEmpty) return _buildEmptyState();

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(departamentosConFiltroProvider((
          query: _queryBusqueda,
          soloActivos: !_mostrarInactivos,
          localId: _localFiltroId,
        )));
        return Future.value();
      },
      child: AnimationLimiter(
        child: ListView.builder(
          padding: const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 88),
          itemCount: departamentos.length,
          itemBuilder: (context, index) {
            final d = departamentos[index];
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 400),
              child: SlideAnimation(
                verticalOffset: 50,
                curve: Curves.easeOutCubic,
                child: FadeInAnimation(
                  curve: Curves.easeOutCubic,
                  child: _buildDepartamentoCard(d),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDepartamentoCard(DepartamentoEntity departamento) {
    final colorScheme = Theme.of(context).colorScheme;
    final localNameAsync = departamento.localId != null
        ? ref.watch(localPorIdProvider(departamento.localId!))
        : const AsyncValue<LocalEntity?>.data(null);
    final usuarioAsync = departamento.usuarioId != null
        ? ref.watch(usuarioPorIdProvider(departamento.usuarioId!))
        : const AsyncValue<UsuarioEntity?>.data(null);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: colorScheme.surface,
      child: InkWell(
        onTap: () => _mostrarDetalle(departamento),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: departamento.activo ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      departamento.nombre,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: departamento.activo ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (departamento.descripcion != null && departamento.descripcion!.isNotEmpty)
                      Text(
                        departamento.descripcion!,
                        style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    Row(
                      children: [
                        Icon(Icons.storefront_rounded, size: 14, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Expanded(
                          child: localNameAsync.when(
                            data: (local) => Text(
                              local?.nombre ?? 'Sin local asignado',
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            loading: () => Text(
                              'Cargando...',
                              style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                            ),
                            error: (err, stack) => Text(
                              'Error',
                              style: TextStyle(fontSize: 12, color: colorScheme.error),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // ✅ Mostrar encargado si existe
                    usuarioAsync.when(
                      data: (usuario) {
                        if (usuario != null) {
                          return Row(
                            children: [
                              Icon(Icons.person_outline_rounded, size: 14, color: colorScheme.onSurfaceVariant),
                              const SizedBox(width: 4),
                              Text(
                                'Encargado: ${usuario.nombre}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: departamento.activo ? Colors.green.withValues(alpha: 0.15) : Colors.red.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      departamento.activo ? 'Activo' : 'Inactivo',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: departamento.activo ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit_rounded, size: 18, color: const Color(0xFF8B5CF6)),
                        onPressed: () => _navegarAEditar(departamento),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(
                          departamento.activo ? Icons.pause_circle_outline_rounded : Icons.play_circle_outline_rounded,
                          size: 18,
                        ),
                        onPressed: () => _toggleActivo(departamento),
                        color: departamento.activo ? Colors.orange : Colors.green,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
                        onPressed: () => _eliminarDepartamento(departamento),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.business_center_rounded, size: 80, color: colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            _localFiltroId != null
                ? 'No hay departamentos para este local'
                : 'No hay departamentos',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea tu primer departamento',
            style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _navegarACrear,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Crear departamento'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingButton() {
    return FloatingActionButton(
      onPressed: _navegarACrear,
      backgroundColor: const Color(0xFF8B5CF6),
      foregroundColor: Colors.white,
      elevation: 4,
      child: const Icon(Icons.add_rounded, size: 32),
    );
  }

  // ============================================================
  // ACCIONES (con diálogos genéricos)
  // ============================================================

  void _navegarACrear() {
    showDialog<bool>(
      context: context,
      builder: (dialogContext) => const CrearDepartamentoDialog(
        localIdPreseleccionado: null,
      ),
    ).then((result) {
      if (result == true && mounted) {
        // ignore: unused_result
        ref.refresh(departamentosConFiltroProvider(
          (query: _queryBusqueda, soloActivos: !_mostrarInactivos, localId: _localFiltroId)
        ));
        setState(() {});
      }
    });
  }

  void _navegarAEditar(DepartamentoEntity departamento) {
    showDialog<bool>(
      context: context,
      builder: (dialogContext) => CrearDepartamentoDialog(
        departamento: departamento,
        localIdPreseleccionado: departamento.localId,
      ),
    ).then((result) {
      if (result == true && mounted) {
        // ignore: unused_result
        ref.refresh(departamentosConFiltroProvider(
          (query: _queryBusqueda, soloActivos: !_mostrarInactivos, localId: _localFiltroId)
        ));
        setState(() {});
      }
    });
  }

  void _mostrarDetalle(DepartamentoEntity departamento) {
    showDialog(
      context: context,
      builder: (dialogContext) => DetalleDepartamentoDialog(departamento: departamento),
    );
  }

  Future<void> _toggleActivo(DepartamentoEntity departamento) async {
    try {
      final actualizado = DepartamentoEntity()
        ..id = departamento.id
        ..nombre = departamento.nombre
        ..descripcion = departamento.descripcion
        ..localId = departamento.localId
        ..usuarioId = departamento.usuarioId
        ..activo = !departamento.activo
        ..supabaseId = departamento.supabaseId
        ..sincronizado = false;
      await ref.read(guardarDepartamentoProvider(actualizado).future);
      ref.invalidate(departamentosConFiltroProvider((
        query: _queryBusqueda,
        soloActivos: !_mostrarInactivos,
        localId: _localFiltroId,
      )));
      setState(() {});
    } catch (e) {
      if (mounted) {
        await showDialog(
          context: context,
          builder: (_) => ErrorDialog(
            title: 'Error al cambiar estado',
            content: e.toString(),
          ),
        );
      }
    }
  }

  Future<void> _eliminarDepartamento(DepartamentoEntity departamento) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => ConfirmDialog(
        title: 'Eliminar Departamento',
        content: '¿Estás seguro de eliminar "${departamento.nombre}"?',
        confirmText: 'Eliminar',
        confirmColor: Colors.red, onConfirm: () {  },
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(eliminarDepartamentoProvider(departamento.id).future);
        if (mounted) {
          await showDialog(
            context: context,
            builder: (_) => const SuccessDialog(
              title: 'Departamento eliminado',
              content: 'El departamento se ha eliminado correctamente.',
            ),
          );
        }
        ref.invalidate(departamentosConFiltroProvider((
          query: _queryBusqueda,
          soloActivos: !_mostrarInactivos,
          localId: _localFiltroId,
        )));
        setState(() {});
      } catch (e) {
        if (mounted) {
          await showDialog(
            context: context,
            builder: (_) => ErrorDialog(
              title: 'Error al eliminar',
              content: e.toString(),
            ),
          );
        }
      }
    }
  }
}

// ✅ Provider para obtener un usuario por ID (necesario para mostrar encargado)
final usuarioPorIdProvider = FutureProvider.family<UsuarioEntity?, int>((ref, id) async {
  final isar = IsarService();
  return await isar.obtenerUsuarioPorId(id);
});