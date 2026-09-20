import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/Local/entities/usuario_entity.dart';
import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/json_utils.dart';
import '../utils/responsive_helper.dart';
import '../services/sync_service.dart';

class EmployeeMonitorDialog extends ConsumerStatefulWidget {
  const EmployeeMonitorDialog({super.key});

  @override
  ConsumerState<EmployeeMonitorDialog> createState() =>
      _EmployeeMonitorDialogState();
}

class _EmployeeMonitorDialogState extends ConsumerState<EmployeeMonitorDialog> {
  List<UsuarioEntity> _usuarios = [];
  List<String> _departamentos = [];
  String? _departamentoSeleccionado;
  bool _isLoading = true;
  String? _error;
  Timer? _timer;
  Timer? _searchDebounce;
  final IsarService _isarService = IsarService();
  final SyncService _syncService = SyncService();

  // ✅ Nuevos: buscador + filtro por estado
  final TextEditingController _searchController = TextEditingController();
  String _queryBusqueda = '';
  String _filtroEstado = 'todos'; // todos | activos | inactivos | descanso

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) _sincronizarYActualizar();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════
  // CARGA Y SINCRONIZACIÓN
  // ═══════════════════════════════════════════════════════════════

  Future<void> _sincronizarYActualizar() async {
    try {
      await _syncService.sincronizarUsuariosDesdeSupabase();
      await _actualizarEstadosDesdeNube();
      await _cargarUsuariosLocal();
    } catch (e) {
      debugPrint('⚠️ Error en sincronización: $e');
      await _cargarUsuariosLocal();
    }
  }

  Future<void> _cargarUsuarios() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await _syncService.sincronizarUsuariosDesdeSupabase();
      await _actualizarEstadosDesdeNube();
      await _cargarUsuariosLocal();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _actualizarEstadosDesdeNube() async {
    try {
      final nubeUsuarios = await _syncService.obtenerUsuariosDesdeSupabase();
      if (nubeUsuarios.isEmpty) return;

      final Map<int, String> estadosNube = {};
      for (var row in nubeUsuarios) {
        // ✅ Acepta id_isar como int o String (PostgREST bigint)
        final raw = row['id_isar'];
        final id = raw is int ? raw : int.tryParse(raw?.toString() ?? '');
        if (id != null && id > 0) {
          estadosNube[id] = (row['estado'] as String? ?? 'inactivo');
        }
      }

      final locales = await _isarService.obtenerUsuarios();
      for (var local in locales) {
        if (estadosNube.containsKey(local.id)) {
          final estadoNube = estadosNube[local.id]!;
          if (local.estado != estadoNube) {
            await _isarService.actualizarEstadoUsuario(local.id, estadoNube);
            debugPrint(
                '🔄 Monitor: ${local.nombre} → $estadoNube');
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error actualizando estados desde nube: $e');
    }
  }

  Future<void> _cargarUsuariosLocal() async {
    try {
      final todos = await _isarService.obtenerUsuarios();

      // Departamentos únicos ordenados
      final depts = todos
          .map((u) => u.departamento ?? '')
          .where((d) => d.isNotEmpty)
          .toSet()
          .toList()
        ..sort();

      // ✅ Filtro en cascada: departamento → estado → búsqueda
      List<UsuarioEntity> filtrados = todos;

      if (_departamentoSeleccionado != null &&
          _departamentoSeleccionado!.isNotEmpty) {
        filtrados = filtrados
            .where((u) => u.departamento == _departamentoSeleccionado)
            .toList();
      }

      switch (_filtroEstado) {
        case 'activos':
          filtrados = filtrados.where((u) => u.estado == 'activo').toList();
          break;
        case 'inactivos':
          filtrados = filtrados
              .where((u) =>
                  u.estado == 'inactivo' || u.estado == 'desconectado')
              .toList();
          break;
        case 'descanso':
          filtrados =
              filtrados.where((u) => u.estado == 'descanso').toList();
          break;
        default:
          break;
      }

      final q = _queryBusqueda.trim().toLowerCase();
      if (q.isNotEmpty) {
        filtrados = filtrados.where((u) {
          final nombre = u.nombre.toLowerCase();
          final email = (u.email ?? '').toLowerCase();
          final rol = u.rol.toLowerCase();
          return nombre.contains(q) ||
              email.contains(q) ||
              rol.contains(q);
        }).toList();
      }

      if (!mounted) return;
      setState(() {
        _departamentos = depts;
        if (_departamentoSeleccionado == null && depts.isNotEmpty) {
          _departamentoSeleccionado = depts.first;
        }
        _usuarios = filtrados;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // HELPERS DE UI
  // ═══════════════════════════════════════════════════════════════

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() => _queryBusqueda = value);
      _cargarUsuariosLocal();
    });
  }

  Widget _estadoChip(String label, String value, IconData icon) {
    final selected = _filtroEstado == value;
    final color = switch (value) {
      'activos' => const Color(0xFF10B981),
      'inactivos' => const Color(0xFF64748B),
      'descanso' => Colors.orange,
      _ => const Color(0xFF3B82F6),
    };

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          setState(() => _filtroEstado = value);
          _cargarUsuariosLocal();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? color : color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? color : color.withValues(alpha: 0.3),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: selected ? Colors.white : color),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    final double dialogWidth = isMobile
        ? MediaQuery.of(context).size.width * 0.92
        : (isTablet ? 700 : 620);
    final double dialogMaxHeight = MediaQuery.of(context).size.height * 0.88;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: theme.brightness == Brightness.dark
              ? Colors.grey.shade700
              : Colors.transparent,
          width: 1,
        ),
      ),
      elevation: 8,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12.0 : (isTablet ? 60.0 : 40.0),
        vertical: 24.0,
      ),
      child: Container(
        width: dialogWidth,
        constraints: BoxConstraints(maxHeight: dialogMaxHeight),
        padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ═══ HEADER ═══
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.people_alt_rounded,
                    color: theme.brightness == Brightness.dark
                        ? Colors.blue.shade300
                        : const Color(0xFF3B82F6),
                    size: isMobile ? 20 : 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Monitor de Empleados',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 18 : 22,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: const Color(0xFF10B981), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.autorenew_rounded,
                          color: const Color(0xFF10B981),
                          size: isMobile ? 12 : 16),
                      const SizedBox(width: 4),
                      Text(
                        'AUTO',
                        style: TextStyle(
                          fontSize: isMobile ? 8 : 10,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.close_rounded,
                      size: 28, color: theme.textTheme.bodyLarge?.color),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Actualización automática cada 5 segundos · ${_usuarios.length} visibles',
              style: TextStyle(
                fontSize: isMobile ? 12 : 14,
                color: theme.textTheme.bodyMedium?.color
                    ?.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 14),

            // ═══ BUSCADOR ═══
            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: TextStyle(
                color: theme.textTheme.bodyLarge?.color,
                fontSize: 13,
              ),
              decoration: InputDecoration(
                hintText: 'Buscar por nombre, email o rol…',
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: theme.textTheme.bodySmall?.color,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: theme.textTheme.bodyMedium?.color,
                ),
                suffixIcon: _queryBusqueda.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      ),
                filled: true,
                fillColor: theme.brightness == Brightness.dark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.03),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF3B82F6), width: 1.6),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // ═══ CHIPS DE ESTADO ═══
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _estadoChip(
                      'Todos', 'todos', Icons.list_alt_rounded),
                  const SizedBox(width: 6),
                  _estadoChip('Activos', 'activos',
                      Icons.check_circle_rounded),
                  const SizedBox(width: 6),
                  _estadoChip('Inactivos', 'inactivos',
                      Icons.cancel_rounded),
                  const SizedBox(width: 6),
                  _estadoChip('Descanso', 'descanso', Icons.coffee_rounded),
                ],
              ),
            ),

            // ═══ DEPARTAMENTO (solo si hay >1) ═══
            if (_departamentos.length > 1) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.3),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _departamentoSeleccionado,
                    isExpanded: true,
                    icon: Icon(Icons.keyboard_arrow_down_rounded,
                        color: theme.textTheme.bodyMedium?.color),
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: '',
                        child: Text('Todos los departamentos'),
                      ),
                      ..._departamentos.map((d) =>
                          DropdownMenuItem(value: d, child: Text(d))),
                    ],
                    onChanged: (value) {
                      setState(() => _departamentoSeleccionado = value);
                      _cargarUsuariosLocal();
                    },
                  ),
                ),
              ),
            ],

            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 12),

            // ═══ LISTA ═══
            Expanded(
              child: RefreshIndicator(
                onRefresh: _cargarUsuarios,
                color: const Color(0xFF10B981),
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFF3B82F6)))
                    : _error != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline,
                                    size: 48, color: theme.colorScheme.error),
                                const SizedBox(height: 12),
                                Text(
                                  'Error al cargar empleados',
                                  style: TextStyle(
                                      color: theme.colorScheme.error),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _error!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.textTheme.bodySmall?.color,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: _cargarUsuarios,
                                  icon: const Icon(Icons.refresh_rounded),
                                  label: const Text('Reintentar'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color(0xFF10B981),
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : _usuarios.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.people_outline,
                                        size: 48,
                                        color: theme.disabledColor),
                                    const SizedBox(height: 12),
                                    Text(
                                      _queryBusqueda.isNotEmpty ||
                                              _filtroEstado != 'todos'
                                          ? 'Sin resultados para los filtros aplicados'
                                          : 'No hay empleados registrados',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: theme
                                            .textTheme.bodyMedium?.color,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.separated(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                itemCount: _usuarios.length,
                                separatorBuilder: (_, __) => Divider(
                                  color: theme.dividerColor,
                                  height: 1,
                                ),
                                itemBuilder: (context, index) {
                                  return _buildEmployeeTile(
                                    context,
                                    _usuarios[index],
                                    isMobile,
                                    theme,
                                  );
                                },
                              ),
              ),
            ),

            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF10B981),
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 24,
                    vertical: isMobile ? 10 : 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: const Color(0xFF10B981).withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                ),
                onPressed: _cargarUsuarios,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded,
                        size: isMobile ? 18 : 20),
                    const SizedBox(width: 8),
                    Text(
                      'Actualizar ahora',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 13 : 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeTile(
    BuildContext context,
    UsuarioEntity usuario,
    bool isMobile,
    ThemeData theme,
  ) {
    final isActive = usuario.estado == 'activo';
    final isDescanso = usuario.estado == 'descanso';
    final isInactive =
        usuario.estado == 'inactivo' || usuario.estado == 'desconectado';

    Color estadoColor;
    String estadoTexto;
    IconData estadoIcon;

    if (isActive) {
      estadoColor = const Color(0xFF10B981);
      estadoTexto = 'Activo';
      estadoIcon = Icons.point_of_sale;
    } else if (isDescanso) {
      estadoColor = Colors.orange;
      estadoTexto = 'En Descanso';
      estadoIcon = Icons.coffee;
    } else {
      estadoColor = theme.brightness == Brightness.dark
          ? Colors.grey.shade500
          : const Color(0xFF64748B);
      estadoTexto = 'Inactivo';
      estadoIcon = Icons.power_off;
    }

    final isAdmin = usuario.rol == 'admin';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      leading: CircleAvatar(
        radius: isMobile ? 20 : 24,
        backgroundColor: estadoColor.withValues(alpha: 0.15),
        child: Icon(
          estadoIcon,
          color: estadoColor,
          size: isMobile ? 18 : 22,
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              usuario.nombre,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isMobile ? 15 : 17,
                color: theme.textTheme.bodyLarge?.color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isAdmin && !isMobile) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                    color: const Color(0xFF3B82F6), width: 0.5),
              ),
              child: const Text(
                'ADMIN',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3B82F6),
                ),
              ),
            ),
          ],
          if (usuario.departamento != null &&
              usuario.departamento!.isNotEmpty &&
              !isMobile) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                usuario.departamento!,
                style: TextStyle(
                  fontSize: isMobile ? 10 : 12,
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
            ),
          ],
        ],
      ),
      subtitle: Row(
        children: [
          Text(
            'Rol: ${usuario.rol.toUpperCase()}',
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              color: theme.textTheme.bodyMedium?.color
                  ?.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 6 : 8,
              vertical: isMobile ? 2 : 4,
            ),
            decoration: BoxDecoration(
              color: estadoColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: estadoColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(estadoIcon,
                    size: isMobile ? 12 : 14, color: estadoColor),
                const SizedBox(width: 4),
                Text(
                  estadoTexto,
                  style: TextStyle(
                    color: estadoColor,
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 11 : 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      trailing: isActive
          ? Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withValues(alpha: 0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            )
          : isInactive
              ? Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                )
              : null,
      dense: true,
    );
  }
}
