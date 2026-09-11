// lib/features/pos/presentation/screens/departamentos/departamentos_screen.dart
import 'dart:ui';
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
import '../../widgets/dialogos_genericos/succes_dialog.dart';

class DepartamentosScreen extends ConsumerStatefulWidget {
  const DepartamentosScreen({super.key});

  @override
  ConsumerState<DepartamentosScreen> createState() => _DepartamentosScreenState();
}

class _DepartamentosScreenState extends ConsumerState<DepartamentosScreen> {
  String _queryBusqueda = '';
  String _estado = 'activos'; // 'activos' | 'inactivos' | 'todos'
  int? _localFiltroId;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = ResponsiveHelper.isMobile(context);

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF0F4F8),
      appBar: CustomAppBar(
        title: isMobile ? 'Departamentos' : 'Gestión de Departamentos',
        showBackButton: true,
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              ref.invalidate(departamentosConFiltroProvider((
                query: _queryBusqueda,
                estado: _estado,
                localId: _localFiltroId,
              )));
            },
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'Recargar lista',
          ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              _buildSearchBar(colorScheme, isDark),
              const SizedBox(height: 12),
              _buildFiltros(colorScheme, isDark),
              const SizedBox(height: 8),
              Expanded(
                child: _buildBody(colorScheme, isDark),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingButton(),
    );
  }

  // ============================================================
  // SEARCH BAR CON GLASSMORPHISM
  // ============================================================
  Widget _buildSearchBar(ColorScheme colorScheme, bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Buscar por nombre...',
              hintStyle: TextStyle(
                color: isDark ? Colors.white54 : Colors.black54,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
            ),
            onChanged: (value) => setState(() => _queryBusqueda = value),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FILTROS CON GLASSMORPHISM
  // ============================================================
  Widget _buildFiltros(ColorScheme colorScheme, bool isDark) {
    final localesAsync = ref.watch(localesProvider);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'activos',
                    label: Text('Activos'),
                    icon: Icon(Icons.check_circle_rounded, size: 18),
                  ),
                  ButtonSegment(
                    value: 'inactivos',
                    label: Text('Inactivos'),
                    icon: Icon(Icons.cancel_rounded, size: 18),
                  ),
                ],
                selected: {_estado},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() => _estado = newSelection.first);
                  ref.invalidate(departamentosConFiltroProvider((
                    query: _queryBusqueda,
                    estado: _estado,
                    localId: _localFiltroId,
                  )));
                },
                style: SegmentedButton.styleFrom(
                  selectedForegroundColor: Colors.white,
                  selectedBackgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: isDark ? Colors.white70 : Colors.black54,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide.none,
                ),
              ),
              const SizedBox(height: 8),
              localesAsync.when(
                data: (locales) {
                  return DropdownButtonFormField<int?>(
                    initialValue: _localFiltroId,
                    hint: Text(
                      'Filtrar por local',
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                    isExpanded: true,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.storefront_rounded,
                        size: 20,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.black.withValues(alpha: 0.05),
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.black.withValues(alpha: 0.05),
                          width: 1,
                        ),
                      ),
                      filled: true,
                      fillColor: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.black.withValues(alpha: 0.02),
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
                      setState(() => _localFiltroId = value);
                      ref.invalidate(departamentosConFiltroProvider((
                        query: _queryBusqueda,
                        estado: _estado,
                        localId: _localFiltroId,
                      )));
                    },
                    dropdownColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  );
                },
                loading: () => const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                error: (err, stack) => Text(
                  'Error al cargar locales: $err',
                  style: TextStyle(color: colorScheme.error),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BODY PRINCIPAL
  // ============================================================
  Widget _buildBody(ColorScheme colorScheme, bool isDark) {
    final departamentosAsync = ref.watch(departamentosConFiltroProvider((
      query: _queryBusqueda,
      estado: _estado,
      localId: _localFiltroId,
    )));

    return departamentosAsync.when(
      data: (departamentos) => _buildListaDepartamentos(departamentos, colorScheme, isDark),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => _buildErrorState(err, colorScheme),
    );
  }

  // ============================================================
  // LISTA CON CARDS GLASSMORPHISM
  // ============================================================
  Widget _buildListaDepartamentos(
    List<DepartamentoEntity> departamentos,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    if (departamentos.isEmpty) return _buildEmptyState(colorScheme, isDark);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(departamentosConFiltroProvider((
          query: _queryBusqueda,
          estado: _estado,
          localId: _localFiltroId,
        )));
        return Future.value();
      },
      child: AnimationLimiter(
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 16),
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
                  child: _buildDepartamentoCard(d, colorScheme, isDark),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // CARD INDIVIDUAL CON GLASSMORPHISM + HOVER + SOMBRA
  // ============================================================
  Widget _buildDepartamentoCard(
    DepartamentoEntity departamento,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final localNameAsync = departamento.localId != null
        ? ref.watch(localPorIdProvider(departamento.localId!))
        : const AsyncValue<LocalEntity?>.data(null);
    final usuarioAsync = departamento.usuarioId != null
        ? ref.watch(usuarioPorIdProvider(departamento.usuarioId!))
        : const AsyncValue<UsuarioEntity?>.data(null);

    final bool activo = departamento.activo;
    final Color estadoColor = activo ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    // Variables de hover
    bool isHovered = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: isHovered ? 0.10 : 0.06)
                    : Colors.white.withValues(alpha: isHovered ? 0.85 : 0.7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: isHovered ? 0.15 : 0.08)
                      : Colors.white.withValues(alpha: isHovered ? 0.7 : 0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isHovered ? 0.15 : 0.06),
                    blurRadius: isHovered ? 20 : 10,
                    offset: Offset(0, isHovered ? 8 : 4),
                  ),
                  BoxShadow(
                    color: estadoColor.withValues(alpha: isHovered ? 0.15 : 0.05),
                    blurRadius: isHovered ? 15 : 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: InkWell(
                onTap: () => _mostrarDetalle(departamento),
                borderRadius: BorderRadius.circular(16),
                mouseCursor: SystemMouseCursors.click,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      // Indicador de estado (barra lateral)
                      Container(
                        width: 4,
                        height: 48,
                        decoration: BoxDecoration(
                          color: estadoColor,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: estadoColor.withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Información principal
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              departamento.nombre,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            if (departamento.descripcion != null &&
                                departamento.descripcion!.isNotEmpty)
                              Text(
                                departamento.descripcion!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? Colors.white54 : Colors.black54,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            // Fila: local + encargado
                            Row(
                              children: [
                                Icon(Icons.storefront_rounded,
                                    size: 14, color: isDark ? Colors.white54 : Colors.black54),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: localNameAsync.when(
                                    data: (local) => Text(
                                      local?.nombre ?? 'Sin local asignado',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? Colors.white54 : Colors.black54,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    loading: () => Text(
                                      'Cargando...',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? Colors.white54 : Colors.black54,
                                      ),
                                    ),
                                    error: (_, __) => Text(
                                      'Error',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: colorScheme.error,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // Encargado
                            usuarioAsync.when(
                              data: (usuario) {
                                if (usuario != null) {
                                  return Row(
                                    children: [
                                      Icon(Icons.person_outline_rounded,
                                          size: 14, color: isDark ? Colors.white54 : Colors.black54),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Encargado: ${usuario.nombre}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark ? Colors.white54 : Colors.black54,
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
                      // Estado + Botones de acción
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Badge de estado
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: estadoColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: estadoColor.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              activo ? 'Activo' : 'Inactivo',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: estadoColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Botones de acción
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildActionButton(
                                icon: Icons.edit_rounded,
                                color: const Color(0xFF8B5CF6),
                                onPressed: () => _navegarAEditar(departamento),
                                tooltip: 'Editar',
                                isDark: isDark,
                              ),
                              _buildActionButton(
                                icon: activo
                                    ? Icons.pause_circle_outline_rounded
                                    : Icons.play_circle_outline_rounded,
                                color: activo ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
                                onPressed: () => _toggleActivo(departamento),
                                tooltip: activo ? 'Desactivar' : 'Activar',
                                isDark: isDark,
                              ),
                              _buildActionButton(
                                icon: Icons.delete_outline_rounded,
                                color: const Color(0xFFEF4444),
                                onPressed: () => _eliminarDepartamento(departamento),
                                tooltip: 'Eliminar',
                                isDark: isDark,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // BOTÓN DE ACCIÓN MEJORADO
  // ============================================================
  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String tooltip,
    required bool isDark,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: color,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ESTADOS VACÍO Y ERROR
  // ============================================================
  Widget _buildEmptyState(ColorScheme colorScheme, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.business_center_rounded,
            size: 80,
            color: isDark ? Colors.white24 : Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            _localFiltroId != null
                ? 'No hay departamentos para este local'
                : 'No hay departamentos',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea tu primer departamento',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _navegarACrear,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Crear departamento'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object err, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 60, color: colorScheme.error),
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
            onPressed: () {
              ref.invalidate(departamentosConFiltroProvider((
                query: _queryBusqueda,
                estado: _estado,
                localId: _localFiltroId,
              )));
            },
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FLOATING BUTTON
  // ============================================================
  Widget _buildFloatingButton() {
    return FloatingActionButton(
      onPressed: _navegarACrear,
      backgroundColor: const Color(0xFF8B5CF6),
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Icon(Icons.add_rounded, size: 32),
    );
  }

  // ============================================================
  // ACCIONES
  // ============================================================
  void _navegarACrear() {
    showDialog<bool>(
      context: context,
      builder: (dialogContext) => const CrearDepartamentoDialog(
        localIdPreseleccionado: null,
      ),
    ).then((result) {
      if (result == true && mounted) {
        ref.invalidate(departamentosConFiltroProvider((
          query: _queryBusqueda,
          estado: _estado,
          localId: _localFiltroId,
        )));
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
        ref.invalidate(departamentosConFiltroProvider((
          query: _queryBusqueda,
          estado: _estado,
          localId: _localFiltroId,
        )));
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
        estado: _estado,
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
        confirmColor: const Color(0xFFEF4444),
        onConfirm: () {},
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
          estado: _estado,
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

// ============================================================
// PROVIDER PARA OBTENER USUARIO POR ID
// ============================================================
final usuarioPorIdProvider = FutureProvider.family<UsuarioEntity?, int>((ref, id) async {
  final isar = IsarService();
  return await isar.obtenerUsuarioPorId(id);
});