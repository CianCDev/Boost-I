// lib/features/pos/presentation/screens/departamentos/departamentos_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/departamentos_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/locales_provider.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/departamento_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/departamentos/crear_departamento_dialog.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/departamentos/detalle_departamento_dialog.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/departamentos/departamento_card.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/appbar.dart';
import 'package:app_boosti_v2/features/pos/presentation/utils/responsive_helper.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/common/glass_search_bar.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/common/segmented_toggle.dart';

import '../../../data/Local/entities/isar_service.dart';
import '../../../data/Local/entities/usuario_entity.dart';
import '../../widgets/dialogos_genericos/dialogos_genericos.dart';
import '../../widgets/dialogos_genericos/error_dialog.dart';
import '../../widgets/dialogos_genericos/succes_dialog.dart';

class DepartamentosScreen extends ConsumerStatefulWidget {
  const DepartamentosScreen({super.key});

  @override
  ConsumerState<DepartamentosScreen> createState() =>
      _DepartamentosScreenState();
}

class _DepartamentosScreenState extends ConsumerState<DepartamentosScreen> {
  String _queryBusqueda = '';
  String _estado = 'activos';
  int? _localFiltroId;

  static const _colorPrimary = Color(0xFF8B5CF6);
  static const _colorSuccess = Color(0xFF10B981);
  static const _colorDanger = Color(0xFFEF4444);

  void _invalidarLista() {
    ref.invalidate(departamentosConFiltroProvider((
      query: _queryBusqueda,
      estado: _estado,
      localId: _localFiltroId,
    )));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isMobile = ResponsiveHelper.isMobile(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(
        title: isMobile ? 'Departamentos' : 'Gestión de Departamentos',
        showBackButton: true,
        centerTitle: false,
        actions: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: IconButton(
              onPressed: _invalidarLista,
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              tooltip: 'Recargar lista',
            ),
          ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              GlassSearchBar(
                hint: 'Buscar por nombre...',
                onChanged: (value) {
                  setState(() => _queryBusqueda = value);
                  _invalidarLista();
                },
              ),
              const SizedBox(height: 12),
              _buildFiltros(colorScheme),
              const SizedBox(height: 12),
              Expanded(child: _buildBody(colorScheme)),
            ],
          ),
        ),
      ),
      floatingActionButton: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: FloatingActionButton(
          onPressed: _navegarACrear,
          backgroundColor: _colorPrimary,
          foregroundColor: Colors.white,
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.add_rounded, size: 32),
        ),
      ),
    );
  }

  // ============================================================
  // FILTROS
  // ============================================================
  Widget _buildFiltros(ColorScheme colorScheme) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final localesAsync = ref.watch(localesProvider);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        children: [
          SegmentedToggle<String>(
            selected: _estado,
            onChanged: (value) {
              setState(() => _estado = value);
              _invalidarLista();
            },
            items: const [
              SegmentedToggleItem(
                value: 'activos',
                label: 'Activos',
                icon: Icons.check_circle_rounded,
              ),
              SegmentedToggleItem(
                value: 'inactivos',
                label: 'Inactivos',
                icon: Icons.cancel_rounded,
              ),
            ],
          ),
          const SizedBox(height: 10),
          localesAsync.when(
            data: (locales) => DropdownButtonFormField<int?>(
              initialValue: _localFiltroId,
              isExpanded: true,
              hint: Text(
                'Filtrar por local',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.storefront_rounded,
                    size: 20, color: colorScheme.onSurfaceVariant),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color:
                        colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color:
                        colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: _colorPrimary, width: 2),
                ),
                filled: true,
                fillColor: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.02),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12),
              ),
              items: [
                DropdownMenuItem<int?>(
                  value: null,
                  child: Text(
                    'Todos los locales',
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                ),
                ...locales.map(
                  (l) => DropdownMenuItem<int?>(
                    value: l.id,
                    child: Text(
                      l.nombre,
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() => _localFiltroId = value);
                _invalidarLista();
              },
              icon: Icon(Icons.arrow_drop_down,
                  color: colorScheme.onSurfaceVariant),
              dropdownColor: colorScheme.surface,
            ),
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (err, _) => Text(
              'Error al cargar locales: $err',
              style: TextStyle(color: colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BODY
  // ============================================================
  Widget _buildBody(ColorScheme colorScheme) {
    final departamentosAsync = ref.watch(departamentosConFiltroProvider((
      query: _queryBusqueda,
      estado: _estado,
      localId: _localFiltroId,
    )));

    return departamentosAsync.when(
      data: (departamentos) => _buildLista(departamentos, colorScheme),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => _buildError(err, colorScheme),
    );
  }

  Widget _buildLista(
    List<DepartamentoEntity> departamentos,
    ColorScheme colorScheme,
  ) {
    if (departamentos.isEmpty) return _buildEmpty(colorScheme);

    return RefreshIndicator(
      onRefresh: () async {
        _invalidarLista();
        await Future.delayed(const Duration(milliseconds: 300));
      },
      child: AnimationLimiter(
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: departamentos.length,
          itemBuilder: (context, index) {
            final d = departamentos[index];
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 350),
              child: SlideAnimation(
                verticalOffset: 30,
                curve: Curves.easeOutCubic,
                child: FadeInAnimation(
                  child: DepartamentoCard(
                    departamento: d,
                    onTap: () => _mostrarDetalle(d),
                    onEdit: () => _navegarAEditar(d),
                    onToggleActivo: () => _toggleActivo(d),
                    onDelete: () => _eliminarDepartamento(d),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // ESTADOS
  // ============================================================
  Widget _buildEmpty(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _colorPrimary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.business_center_rounded,
              size: 48,
              color: _colorPrimary.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _localFiltroId != null
                ? 'No hay departamentos para este local'
                : 'No hay departamentos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Crea tu primer departamento para empezar',
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: ElevatedButton.icon(
              onPressed: _navegarACrear,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Crear departamento'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _colorPrimary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(Object err, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded,
              size: 60, color: colorScheme.error),
          const SizedBox(height: 16),
          Text(
            'Error al cargar departamentos',
            style: TextStyle(color: colorScheme.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            err.toString(),
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _invalidarLista,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACCIONES
  // ============================================================
  void _navegarACrear() {
    showDialog<bool>(
      context: context,
      builder: (_) => const CrearDepartamentoDialog(
        localIdPreseleccionado: null,
      ),
    ).then((result) {
      if (result == true && mounted) {
        _invalidarLista();
        setState(() {});
      }
    });
  }

  void _navegarAEditar(DepartamentoEntity departamento) {
    showDialog<bool>(
      context: context,
      builder: (_) => CrearDepartamentoDialog(
        departamento: departamento,
        localIdPreseleccionado: departamento.localId,
      ),
    ).then((result) {
      if (result == true && mounted) {
        _invalidarLista();
        setState(() {});
      }
    });
  }

  void _mostrarDetalle(DepartamentoEntity departamento) {
    showDialog(
      context: context,
      builder: (_) => DetalleDepartamentoDialog(departamento: departamento),
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
      _invalidarLista();
      if (mounted) setState(() {});
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
      builder: (_) => ConfirmDialog(
        title: 'Eliminar Departamento',
        content: '¿Estás seguro de eliminar "${departamento.nombre}"?',
        confirmText: 'Eliminar',
        confirmColor: _colorDanger,
        onConfirm: () {},
      ),
    );

    if (confirm != true) return;

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
      _invalidarLista();
      if (mounted) setState(() {});
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

// ============================================================
// PROVIDER PARA OBTENER USUARIO POR ID
// ============================================================
final usuarioPorIdProvider =
    FutureProvider.family<UsuarioEntity?, int>((ref, id) async {
  final isar = IsarService();
  return await isar.obtenerUsuarioPorId(id);
});