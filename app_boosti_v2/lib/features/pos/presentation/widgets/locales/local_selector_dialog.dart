// lib/features/pos/presentation/widgets/locales/local_selector_dialog.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';
import '../../providers/tenant_provider.dart';

/// Diálogo para cambiar de local (tenant) activo.
///
/// Muestra una lista con todos los locales a los que el usuario tiene acceso.
/// El local activo aparece con un check verde.
class LocalSelectorDialog extends ConsumerStatefulWidget {
  const LocalSelectorDialog({super.key});

  /// Abre el diálogo y retorna `true` si el usuario cambió de local.
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const LocalSelectorDialog(),
    );
  }

  @override
  ConsumerState<LocalSelectorDialog> createState() =>
      _LocalSelectorDialogState();
}

class _LocalSelectorDialogState extends ConsumerState<LocalSelectorDialog> {
  List<Map<String, dynamic>> _locales = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _cambiandoTenantId;

  @override
  void initState() {
    super.initState();
    _cargarLocales();
  }

  Future<void> _cargarLocales() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final locales = await ref.read(authProvider.notifier).obtenerMisLocales();

    if (!mounted) return;

    setState(() {
      _locales = locales;
      _isLoading = false;
      if (locales.isEmpty) {
        _errorMessage = 'No tienes acceso a ningún local.';
      }
    });
  }

  Future<void> _cambiarLocal(String tenantId) async {
    // No hacer nada si ya es el activo
    final tenantActual = ref.read(tenantActualProvider).tenantId;
    if (tenantId == tenantActual) {
      return;
    }

    setState(() => _cambiandoTenantId = tenantId);

    final ok =
        await ref.read(authProvider.notifier).cambiarLocal(tenantId);

    if (!mounted) return;

    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _cambiandoTenantId = null;
        _errorMessage = 'No se pudo cambiar de local. Intenta de nuevo.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tenantActual = ref.watch(tenantActualProvider).tenantId;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 80,
        vertical: 24,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1.2,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1A1A4E).withValues(alpha: 0.95),
                  const Color(0xFF2D1B69).withValues(alpha: 0.95),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ============================================================
                // HEADER
                // ============================================================
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.business_rounded,
                        color: Color(0xFF8B5CF6),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Cambiar local',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Selecciona el local que quieres usar',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ============================================================
                // CONTENIDO
                // ============================================================
                Flexible(
                  child: _buildContenido(tenantActual),
                ),

                // ============================================================
                // ERROR
                // ============================================================
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.red.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // ============================================================
                // BOTÓN CANCELAR
                // ============================================================
                SizedBox(
                  height: 48,
                  child: TextButton(
                    onPressed: _cambiandoTenantId == null
                        ? () => Navigator.of(context).pop(false)
                        : null,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white.withValues(alpha: 0.8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContenido(String? tenantActual) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF8B5CF6)),
        ),
      );
    }

    if (_locales.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
            'No hay locales disponibles',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      itemCount: _locales.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final local = _locales[index];
        final tenantId = local['tenant_id'] as String?;
        final nombre = local['nombre'] as String? ?? 'Sin nombre';
        final direccion = local['direccion'] as String?;
        final rol = local['rol'] as String? ?? 'cajero';
        final esActivo = tenantId == tenantActual;
        final cambiando = _cambiandoTenantId == tenantId;

        return _buildLocalCard(
          tenantId: tenantId,
          nombre: nombre,
          direccion: direccion,
          rol: rol,
          esActivo: esActivo,
          cambiando: cambiando,
        );
      },
    );
  }

  Widget _buildLocalCard({
    required String? tenantId,
    required String nombre,
    required String? direccion,
    required String rol,
    required bool esActivo,
    required bool cambiando,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: tenantId == null || esActivo || _cambiandoTenantId != null
            ? null
            : () => _cambiarLocal(tenantId),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: esActivo
                ? const Color(0xFF10B981).withValues(alpha: 0.15)
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: esActivo
                  ? const Color(0xFF10B981).withValues(alpha: 0.6)
                  : Colors.white.withValues(alpha: 0.1),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              // Check / Spinner
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: esActivo
                      ? const Color(0xFF10B981)
                      : Colors.transparent,
                  border: esActivo
                      ? null
                      : Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 2,
                        ),
                ),
                child: cambiando
                    ? const Padding(
                        padding: EdgeInsets.all(3),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : esActivo
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 16,
                          )
                        : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            nombre,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.95),
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (esActivo)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'ACTIVO',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (direccion != null && direccion.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        direccion,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.55),
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      'Rol: $rol',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}