// lib/features/pos/presentation/widgets/departamentos/detalle_departamento_dialog.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/departamento_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/local_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/usuario_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/departamentos_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/locales_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/usuario_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/utils/responsive_helper.dart';
import 'crear_departamento_dialog.dart';

class DetalleDepartamentoDialog extends ConsumerWidget {
  final DepartamentoEntity departamento;

  const DetalleDepartamentoDialog({super.key, required this.departamento});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localAsync = departamento.localId != null
        ? ref.watch(localPorIdProvider(departamento.localId!))
        : const AsyncValue<LocalEntity?>.data(null);
    final usuarioAsync = departamento.usuarioId != null
        ? ref.watch(usuarioPorIdProvider(departamento.usuarioId!))
        : const AsyncValue<UsuarioEntity?>.data(null);
    final productosCount = ref.watch(productosPorDepartamentoProvider(departamento.id));

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = ResponsiveHelper.isMobile(context);
    final bool activo = departamento.activo;
    final Color estadoColor = activo ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 500,
              maxHeight: MediaQuery.of(context).size.height * 0.90,
            ),
            padding: EdgeInsets.all(isMobile ? 20 : 28),
            decoration: BoxDecoration(
              // Mayor opacidad para evitar que el fondo se vea gris/apagado
              color: isDark
                  ? const Color(0xFF1A1A1A).withValues(alpha: 0.90)
                  : Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.8),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                  blurRadius: 40,
                  spreadRadius: -10,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // HEADER
                  _buildHeader(context, ref, isDark, isMobile, activo, estadoColor),
                  const SizedBox(height: 24),
                  // INFORMACIÓN (Rediseñada para móvil)
                  _buildInfoSection(context, ref, isDark, localAsync, usuarioAsync, productosCount),
                  const SizedBox(height: 20),
                  // NOTA INFORMATIVA
                  _buildNote(isDark),
                  const SizedBox(height: 24),
                  // BOTONES DE ACCIÓN
                  _buildActionButtons(context, ref, activo, isDark),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, bool isDark, bool isMobile, bool activo, Color estadoColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.business_center_rounded, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                departamento.nombre,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 20 : 24,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                  letterSpacing: -0.5,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: estadoColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: estadoColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      activo ? 'Activo' : 'Inactivo',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: estadoColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (departamento.supabaseId != null)
                    Text(
                      'ID: ${departamento.supabaseId!.substring(0, 8)}...',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white54 : Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(Icons.close_rounded, color: isDark ? Colors.white70 : Colors.black54),
            onPressed: () => Navigator.pop(context),
            splashRadius: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context, WidgetRef ref, bool isDark, AsyncValue<LocalEntity?> localAsync, AsyncValue<UsuarioEntity?> usuarioAsync, AsyncValue<int> productosCount) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildInfoTile(
            Icons.description_rounded,
            'Descripción',
            departamento.descripcion?.isNotEmpty == true ? departamento.descripcion! : 'Sin descripción',
            isDark,
          ),
          _buildDivider(isDark),
          _buildInfoTile(
            Icons.storefront_rounded,
            'Local asociado',
            localAsync.when(
              data: (local) => local?.nombre ?? 'Sin local asignado',
              loading: () => 'Cargando...',
              error: (_, __) => 'Error',
            ),
            isDark,
          ),
          _buildDivider(isDark),
          _buildInfoTile(
            Icons.person_rounded,
            'Encargado',
            usuarioAsync.when(
              data: (u) => u != null ? '${u.nombre} (${u.rol})' : 'Sin encargado',
              loading: () => 'Cargando...',
              error: (_, __) => 'Error',
            ),
            isDark,
            trailingAvatar: usuarioAsync.whenOrNull(data: (u) => u),
          ),
          _buildDivider(isDark),
          _buildInfoTile(
            Icons.inventory_2_rounded,
            'Productos',
            productosCount.when(
              data: (count) => count > 0 ? '$count productos enlazados' : 'Sin productos',
              loading: () => 'Cargando...',
              error: (_, __) => 'Error',
            ),
            isDark,
          ),
        ],
      ),
    );
  }

  // WIDGET REDISEÑADO: Evita el corte de palabras apilando el título y el valor
  Widget _buildInfoTile(IconData icon, String label, String value, bool isDark, {UsuarioEntity? trailingAvatar}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF8B5CF6)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
          if (trailingAvatar != null) ...[
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
              child: Text(
                trailingAvatar.nombre.isNotEmpty ? trailingAvatar.nombre[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Color(0xFF8B5CF6),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFE5E7EB),
      indent: 60,
      endIndent: 16,
    );
  }

  Widget _buildNote(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF8B5CF6).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.info_outline_rounded, color: Color(0xFF8B5CF6), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Los productos de este departamento se pueden gestionar desde el inventario.',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : const Color(0xFF4B5563),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, bool activo, bool isDark) {
    bool isUpdating = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isUpdating
                    ? null
                    : () {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (_) => CrearDepartamentoDialog(
                            departamento: departamento,
                            localIdPreseleccionado: departamento.localId,
                          ),
                        );
                      },
                icon: const Icon(Icons.edit_rounded, size: 20),
                label: const Text('Editar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isUpdating
                    ? null
                    : () => _toggleActivo(
                        context,
                        ref,
                        setState,
                        (value) => setState(() => isUpdating = value),
                      ),
                icon: isUpdating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Icon(activo ? Icons.pause_circle_outline_rounded : Icons.play_circle_outline_rounded, size: 20),
                label: Text(
                  isUpdating ? 'Procesando' : (activo ? 'Desactivar' : 'Activar'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: activo ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _toggleActivo(BuildContext context, WidgetRef ref, StateSetter setState, ValueSetter<bool> setUpdating) async {
    setUpdating(true);
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

      if (context.mounted) {
        setUpdating(false);
        Navigator.pop(context);
        showDialog(context: context, builder: (_) => DetalleDepartamentoDialog(departamento: actualizado));
      }
    } catch (e) {
      if (context.mounted) {
        setUpdating(false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }
}