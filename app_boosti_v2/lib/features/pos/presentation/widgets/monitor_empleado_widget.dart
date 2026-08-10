import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/Local/entities/usuario_entity.dart';
import '../../data/Local/entities/isar_service.dart';
import '../utils/responsive_helper.dart';

class EmployeeMonitorDialog extends ConsumerStatefulWidget {
  const EmployeeMonitorDialog({super.key});

  @override
  ConsumerState<EmployeeMonitorDialog> createState() => _EmployeeMonitorDialogState();
}

class _EmployeeMonitorDialogState extends ConsumerState<EmployeeMonitorDialog> {
  List<UsuarioEntity> _usuarios = [];
  bool _isLoading = true;
  String? _error;
  Timer? _timer;
  final IsarService _isarService = IsarService();

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) _cargarUsuarios();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _cargarUsuarios() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final prefs = await SharedPreferences.getInstance();
      final url = prefs.getString('supabase_url');
      final anonKey = prefs.getString('supabase_anon_key');
      final empresaId = prefs.getString('empresa_id');

      if (url == null || anonKey == null) {
        setState(() {
          _error = 'No hay configuración de Supabase. Ve a Configurar Empresa.';
          _isLoading = false;
        });
        return;
      }

      String baseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
      if (!baseUrl.contains('/rest/v1')) {
        baseUrl = '$baseUrl/rest/v1';
      }

      // ✅ Filtrar por empresa si está disponible
      String requestUrl = '$baseUrl/usuarios?select=*';
      if (empresaId != null && empresaId.isNotEmpty) {
        requestUrl = '$baseUrl/usuarios?select=*&empresa_id=eq.$empresaId';
      }

      debugPrint('🔍 Request URL: $requestUrl');

      final response = await http.get(
        Uri.parse(requestUrl),
        headers: {
          'apikey': anonKey,
          'Authorization': 'Bearer $anonKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        final usuarios = data.map<UsuarioEntity>((row) {
          return UsuarioEntity()
            ..id = row['id_isar'] as int
            ..nombre = row['nombre'] as String
            ..rol = row['rol'] as String
            ..estado = row['estado'] as String? ?? 'inactivo'
            ..deviceId = row['device_id'] as String? ?? '';
        }).toList();

        // ✅ Actualizar también la base de datos local para mantener consistencia
        for (final usuario in usuarios) {
          await _isarService.guardarUsuario(usuario);
        }

        setState(() {
          _usuarios = usuarios;
          _isLoading = false;
          _error = null;
        });
      } else {
        setState(() {
          _isLoading = false;
          _error = 'HTTP ${response.statusCode}: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    final double dialogWidth = isMobile 
        ? MediaQuery.of(context).size.width * 0.92 
        : (isTablet ? 700 : 600);
    final double dialogMaxHeight = MediaQuery.of(context).size.height * 0.85;

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
            // HEADER
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF10B981), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.autorenew_rounded, color: const Color(0xFF10B981), size: isMobile ? 12 : 16),
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
                  icon: Icon(Icons.close_rounded, size: 28, color: theme.textTheme.bodyLarge?.color),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Actualización automática cada 5 segundos',
              style: TextStyle(
                fontSize: isMobile ? 12 : 14,
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),

            // LISTA DE EMPLEADOS
            Expanded(
              child: RefreshIndicator(
                onRefresh: _cargarUsuarios,
                color: const Color(0xFF10B981),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)))
                    : _error != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
                                const SizedBox(height: 12),
                                Text(
                                  'Error al cargar empleados',
                                  style: TextStyle(color: theme.colorScheme.error),
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
                                    backgroundColor: const Color(0xFF10B981),
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
                                    Icon(Icons.people_outline, size: 48, color: theme.disabledColor),
                                    const SizedBox(height: 12),
                                    Text(
                                      'No hay empleados registrados',
                                      style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                itemCount: _usuarios.length,
                                separatorBuilder: (_, __) => Divider(
                                  color: theme.dividerColor,
                                  height: 1,
                                ),
                                itemBuilder: (context, index) {
                                  final usuario = _usuarios[index];
                                  final isActive = usuario.estado == 'activo';
                                  final isDescanso = usuario.estado == 'descanso' || usuario.estado == 'manualrest';

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
                                        Text(
                                          usuario.nombre,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: isMobile ? 15 : 17,
                                            color: theme.textTheme.bodyLarge?.color,
                                          ),
                                        ),
                                        if (isAdmin) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(4),
                                              border: Border.all(color: const Color(0xFF3B82F6), width: 0.5),
                                            ),
                                            child: Text(
                                              'ADMIN',
                                              style: TextStyle(
                                                fontSize: isMobile ? 8 : 10,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF3B82F6),
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
                                            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
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
                                              Icon(
                                                estadoIcon,
                                                size: isMobile ? 12 : 14,
                                                color: estadoColor,
                                              ),
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
                                        : null,
                                    dense: true,
                                  );
                                },
                              ),
              ),
            ),

            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),

            // Botón de actualizar manual
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
                    Icon(Icons.refresh_rounded, size: isMobile ? 18 : 20),
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
}