// lib/features/pos/presentation/widgets/cambiar_cajero_dialog.dart
// ignore_for_file: use_build_context_synchronously

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/Local/entities/usuario_entity.dart';
import '../../providers/auth_provider.dart';

class CambiarCajeroDialog extends ConsumerStatefulWidget {
  const CambiarCajeroDialog({super.key});

  @override
  ConsumerState<CambiarCajeroDialog> createState() => _CambiarCajeroDialogState();
}

class _CambiarCajeroDialogState extends ConsumerState<CambiarCajeroDialog> {
  UsuarioEntity? _selectedCajero;
  final TextEditingController _pinController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final currentUser = authState.currentUser;
    
    // 🔥 Lista de cajeros disponibles (excluyendo al actual y solo rol cajero)
    final List<UsuarioEntity> cajerosDisponibles = authState.usuarios
        .where((u) => u.id != currentUser?.id && u.rol == 'cajero')
        .toList();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        width: 480,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    Colors.grey[900]!.withValues(alpha: 0.88),
                    Colors.grey[850]!.withValues(alpha: 0.92),
                  ]
                : [
                    Colors.white.withValues(alpha: 0.85),
                    const Color(0xFFF5F6FA).withValues(alpha: 0.90),
                  ],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.4),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.5)
                  : Colors.black.withValues(alpha: 0.12),
              blurRadius: 40,
              spreadRadius: 4,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: isDark
                ? ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12)
                : ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---- CABECERA ----
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.purple.shade400,
                              Colors.purple.shade600,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.switch_account_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cambiar Cajero',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                              letterSpacing: 0.3,
                            ),
                          ),
                          Text(
                            'Selecciona un nuevo cajero para el turno',
                            style: TextStyle(
                              fontSize: 13,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // ---- LISTA DE CAJEROS ----
                  if (cajerosDisponibles.isEmpty)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.orange.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.orange.shade600,
                              size: 40,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No hay cajeros disponibles',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.orange.shade800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Asegúrate de que haya usuarios con rol "cajero"',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.orange.shade600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: cajerosDisponibles.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final cajero = cajerosDisponibles[index];
                          final isSelected = _selectedCajero?.id == cajero.id;

                          return _buildCajeroCard(
                            cajero: cajero,
                            isSelected: isSelected,
                            onTap: () {
                              setState(() {
                                _selectedCajero = cajero;
                              });
                              ref.read(authProvider.notifier).clearError();
                            },
                            isDark: isDark,
                            colorScheme: colorScheme,
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 16),

                  // ---- CAMPO PIN ----
                  TextField(
                    controller: _pinController,
                    obscureText: true,
                    maxLength: 4,
                    keyboardType: TextInputType.number,
                    enabled: _selectedCajero != null,
                    onChanged: (_) {
                      if (authState.errorMessage != null) {
                        ref.read(authProvider.notifier).clearError();
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'PIN del cajero',
                      hintText: _selectedCajero == null
                          ? 'Selecciona un cajero primero'
                          : 'Ingresa el PIN de ${_selectedCajero!.nombre}',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.black.withValues(alpha: 0.04),
                      counterText: '',
                      errorText: authState.errorMessage,
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: colorScheme.error,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ---- BOTONES ----
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                ref.read(authProvider.notifier).clearError();
                                Navigator.pop(context);
                              },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cancelar'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: (_selectedCajero != null && !_isLoading)
                            ? _confirmarCambio
                            : null,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.swap_horiz_rounded),
                        label: _isLoading ? const Text('Cambiando...') : const Text('Confirmar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: _isLoading ? 0 : 4,
                          shadowColor: Colors.purple.withValues(alpha: 0.3),
                        ),
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
  }

  // ==================== TARJETA DE CAJERO ====================

  Widget _buildCajeroCard({
    required UsuarioEntity cajero,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
    required ColorScheme colorScheme,
  }) {
    final initial = cajero.nombre.isNotEmpty ? cajero.nombre[0].toUpperCase() : '?';
    final avatarColor = _getColorFromString(cajero.nombre);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                  ? Colors.purple.withValues(alpha: 0.25)
                  : Colors.purple.withValues(alpha: 0.10))
              : (isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.white.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Colors.purple.shade400
                : (isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.06)),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.purple.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      avatarColor,
                      avatarColor.withValues(alpha: 0.7),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: avatarColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cajero.nombre,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.business_center_rounded,
                          size: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          cajero.departamento ?? 'Sin departamento',
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: cajero.rol == 'admin'
                                ? Colors.red.withValues(alpha: 0.15)
                                : Colors.blue.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            cajero.rol,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: cajero.rol == 'admin'
                                  ? Colors.red.shade600
                                  : Colors.blue.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.purple,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== COLOR DE AVATAR ====================

  Color _getColorFromString(String name) {
    final colors = [
      const Color(0xFFE57373),
      const Color(0xFF81C784),
      const Color(0xFF64B5F6),
      const Color(0xFFFFB74D),
      const Color(0xFFBA68C8),
      const Color(0xFF4DD0E1),
      const Color(0xFFFF8A65),
      const Color(0xFFA1887F),
      const Color(0xFF90A4AE),
      const Color(0xFFDCE775),
    ];
    if (name.isEmpty) return colors[0];
    final index = name.codeUnitAt(0) % colors.length;
    return colors[index];
  }

  // ==================== CONFIRMAR CAMBIO ====================

  void _confirmarCambio() async {
    if (_selectedCajero == null) return;

    final pin = _pinController.text.trim();
    if (pin.isEmpty) {
      ref.read(authProvider.notifier).setError('Debes ingresar el PIN del cajero');
      return;
    }
    if (pin.length != 4) {
      ref.read(authProvider.notifier).setError('El PIN debe tener 4 dígitos');
      return;
    }

    setState(() => _isLoading = true);
    final authNotifier = ref.read(authProvider.notifier);
    final success = await authNotifier.cambiarCajero(_selectedCajero!, pin);
    setState(() => _isLoading = false);

    if (success) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Cajero cambiado exitosamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      // El error ya está en el provider
      setState(() {});
    }
  }
}