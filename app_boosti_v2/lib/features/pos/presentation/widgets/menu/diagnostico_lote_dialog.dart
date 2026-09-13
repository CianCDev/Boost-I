// ignore_for_file: use_build_context_synchronously

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/proveedores_provider.dart';

class DiagnosticoLotesDialog extends ConsumerStatefulWidget {
  const DiagnosticoLotesDialog({super.key});

  static Future<void> mostrar(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => const DiagnosticoLotesDialog(),
    );
  }

  @override
  ConsumerState<DiagnosticoLotesDialog> createState() =>
      _DiagnosticoLotesDialogState();
}

class _DiagnosticoLotesDialogState
    extends ConsumerState<DiagnosticoLotesDialog> {
  late Future<Map<String, dynamic>> _diagnosticoFuture;
  bool _isMigrating = false;
  bool _mostrarDetalles = false;

  // Paleta adaptativa
  static const Color _colorPrimary = Color(0xFF3B82F6); // azul info
  static const Color _colorSuccess = Color(0xFF10B981);
  static const Color _colorWarning = Color(0xFFF59E0B);
  static const Color _colorDanger = Color(0xFFEF4444);
  static const Color _colorPurple = Color(0xFF8B5CF6);

  @override
  void initState() {
    super.initState();
    _cargarDiagnostico();
  }

  void _cargarDiagnostico() {
    final isar = ref.read(isarServiceProvider);
    _diagnosticoFuture = _obtenerDiagnostico(isar);
  }

  Future<Map<String, dynamic>> _obtenerDiagnostico(IsarService isar) async {
    final totalProductos = await isar.contarProductos();
    final totalLotes = await isar.contarLotes();

    final productos = await isar.obtenerTodosLosProductos();
    final todosLosLotes = await isar.obtenerTodosLosLotes();

    final productosSinLote = <String>[];
    final productosConStockSinLote = <String>[];

    for (var p in productos) {
      final lotesProducto =
          todosLosLotes.where((lote) => lote.productoId == p.id).toList();

      if (lotesProducto.isEmpty) {
        productosSinLote.add(p.nombre);
        if (p.stock > 0) {
          productosConStockSinLote.add('${p.nombre} (stock: ${p.stock})');
        }
      }
    }

    final porcentaje = totalProductos > 0
        ? ((totalProductos - productosSinLote.length) /
                totalProductos *
                100)
            .toStringAsFixed(1)
        : '0.0';

    return {
      'totalProductos': totalProductos,
      'totalLotes': totalLotes,
      'productosSinLote': productosSinLote,
      'productosSinLoteCount': productosSinLote.length,
      'productosConStockSinLote': productosConStockSinLote,
      'porcentajeCobertura': '$porcentaje%',
    };
  }

  Future<void> _ejecutarMigracion() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final colorScheme = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _colorPrimary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.play_circle_outline_rounded,
                    color: _colorPrimary, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(child: Text('Confirmar migración')),
            ],
          ),
          content: const Text(
            'Se crearán lotes para todos los productos que tengan stock y no tengan lotes asignados.\n\n'
            'Esta operación no modifica el stock total, solo reorganiza el inventario en lotes para permitir un mejor seguimiento.',
            style: TextStyle(height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(dialogContext, true),
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text('Ejecutar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _colorSuccess,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() => _isMigrating = true);
    try {
      final isar = ref.read(isarServiceProvider);
      final result = await isar.migrarStockExistenteALotes();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          content: Row(
            children: [
              Icon(
                result['success']
                    ? Icons.check_circle_rounded
                    : Icons.error_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  result['success']
                      ? 'Migración exitosa · ${result['lotesCreados']} lotes creados'
                      : 'Error: ${result['error']}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: result['success'] ? _colorSuccess : _colorDanger,
        ),
      );
      setState(() {
        _cargarDiagnostico();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('❌ Error: $e'),
          backgroundColor: _colorDanger,
        ),
      );
    } finally {
      if (mounted) setState(() => _isMigrating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final screen = MediaQuery.of(context).size;
    final isMobile = screen.width < 600;

    final surfaceColor = isDark
        ? colorScheme.surface.withValues(alpha: 0.85)
        : Colors.white.withValues(alpha: 0.85);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 40,
        vertical: isMobile ? 12 : 32,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 620,
          maxHeight: screen.height * 0.9,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
            child: Container(
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.white.withValues(alpha: 0.6),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withValues(alpha: isDark ? 0.5 : 0.15),
                    blurRadius: 40,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 18 : 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(colorScheme, isDark, isMobile),
                      const SizedBox(height: 18),
                      _buildExplicacion(colorScheme, isDark, isMobile),
                      const SizedBox(height: 18),
                      _buildContenido(colorScheme, isDark, isMobile),
                      const SizedBox(height: 20),
                      _buildAcciones(colorScheme, isDark, isMobile),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ======================================================
  // HEADER
  // ======================================================
  Widget _buildHeader(
      ColorScheme colorScheme, bool isDark, bool isMobile) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _colorPrimary,
                _colorPrimary.withValues(alpha: 0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: _colorPrimary.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.analytics_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Diagnóstico de Inventario',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 17 : 20,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Audita y repara la asignación de lotes',
                style: TextStyle(
                  fontSize: isMobile ? 11 : 12,
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: IconButton(
            icon: Icon(Icons.close_rounded,
                color: colorScheme.onSurfaceVariant),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Cerrar',
          ),
        ),
      ],
    );
  }

  // ======================================================
  // EXPLICACIÓN
  // ======================================================
  Widget _buildExplicacion(
      ColorScheme colorScheme, bool isDark, bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _colorPrimary.withValues(alpha: isDark ? 0.12 : 0.08),
            _colorPurple.withValues(alpha: isDark ? 0.10 : 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _colorPrimary.withValues(alpha: 0.25),
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _colorPrimary.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.info_outline_rounded,
                color: _colorPrimary, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¿Qué hace esta herramienta?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 12 : 13,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Detecta productos que tienen stock pero no tienen lotes asignados. '
                  'La migración crea automáticamente un lote inicial por cada producto afectado '
                  'para que el sistema pueda llevar un control de vencimientos y trazabilidad.',
                  style: TextStyle(
                    fontSize: isMobile ? 11 : 12,
                    height: 1.45,
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ======================================================
  // CONTENIDO PRINCIPAL (métricas + estado)
  // ======================================================
  Widget _buildContenido(
      ColorScheme colorScheme, bool isDark, bool isMobile) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _diagnosticoFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 12),
                Text(
                  'Analizando inventario...',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }
        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _colorDanger.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: _colorDanger.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: _colorDanger, size: 40),
                const SizedBox(height: 8),
                Text(
                  'Error al cargar diagnóstico',
                  style: TextStyle(
                    color: _colorDanger,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() => _cargarDiagnostico());
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Reintentar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _colorDanger,
                      side: BorderSide(
                          color: _colorDanger.withValues(alpha: 0.4)),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final data = snapshot.data!;
        final totalProductos = data['totalProductos'] as int;
        final totalLotes = data['totalLotes'] as int;
        final productosSinLoteCount = data['productosSinLoteCount'] as int;
        final productosConStockSinLote =
            data['productosConStockSinLote'] as List<String>;
        final porcentaje = data['porcentajeCobertura'] as String;
        final cobertura =
            double.tryParse(porcentaje.replaceAll('%', '')) ?? 0;

        final bool todoOk = productosSinLoteCount == 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== MÉTRICAS =====
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    label: 'Productos',
                    value: '$totalProductos',
                    icon: Icons.inventory_2_rounded,
                    color: _colorPrimary,
                    colorScheme: colorScheme,
                    isDark: isDark,
                    isMobile: isMobile,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricCard(
                    label: 'Lotes',
                    value: '$totalLotes',
                    icon: Icons.qr_code_2_rounded,
                    color: _colorPurple,
                    colorScheme: colorScheme,
                    isDark: isDark,
                    isMobile: isMobile,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricCard(
                    label: 'Cobertura',
                    value: porcentaje,
                    icon: Icons.pie_chart_rounded,
                    color: cobertura >= 80
                        ? _colorSuccess
                        : (cobertura >= 50 ? _colorWarning : _colorDanger),
                    colorScheme: colorScheme,
                    isDark: isDark,
                    isMobile: isMobile,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ===== BANNER DE ESTADO =====
            if (todoOk)
              _buildBannerExito(colorScheme, isDark, isMobile)
            else
              _buildBannerAdvertencia(
                productosSinLoteCount: productosSinLoteCount,
                productosConStockSinLote: productosConStockSinLote,
                colorScheme: colorScheme,
                isDark: isDark,
                isMobile: isMobile,
              ),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required ColorScheme colorScheme,
    required bool isDark,
    required bool isMobile,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 12 : 14,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: isDark ? 0.15 : 0.10),
            color.withValues(alpha: isDark ? 0.05 : 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: isMobile ? 18 : 22,
                color: color,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 10 : 11,
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  // ======================================================
  // BANNER ÉXITO
  // ======================================================
  Widget _buildBannerExito(
      ColorScheme colorScheme, bool isDark, bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _colorSuccess.withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _colorSuccess.withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _colorSuccess.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_rounded,
                color: _colorSuccess, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Inventario consistente',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 12 : 13,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Todos los productos tienen al menos un lote asignado.',
                  style: TextStyle(
                    fontSize: isMobile ? 11 : 12,
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ======================================================
  // BANNER ADVERTENCIA
  // ======================================================
  Widget _buildBannerAdvertencia({
    required int productosSinLoteCount,
    required List<String> productosConStockSinLote,
    required ColorScheme colorScheme,
    required bool isDark,
    required bool isMobile,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _colorWarning.withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _colorWarning.withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _colorWarning.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_amber_rounded,
                    color: _colorWarning, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$productosSinLoteCount producto${productosSinLoteCount == 1 ? "" : "s"} sin lote',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 12 : 13,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      productosConStockSinLote.isNotEmpty
                          ? '${productosConStockSinLote.length} de ellos tienen stock y requieren migración'
                          : 'Ninguno tiene stock actualmente, pero conviene migrar por consistencia',
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (productosConStockSinLote.isNotEmpty)
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: IconButton(
                    icon: AnimatedRotation(
                      turns: _mostrarDetalles ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: _colorWarning,
                        size: 22,
                      ),
                    ),
                    onPressed: () => setState(
                        () => _mostrarDetalles = !_mostrarDetalles),
                    tooltip: _mostrarDetalles ? 'Ocultar' : 'Ver detalles',
                  ),
                ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOutCubic,
            child: !_mostrarDetalles ||
                    productosConStockSinLote.isEmpty
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.2)
                            : Colors.white.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            productosConStockSinLote.map((p) {
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.fiber_manual_record,
                                  size: 6,
                                  color: _colorWarning
                                      .withValues(alpha: 0.7),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    p,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ======================================================
  // ACCIONES
  // ======================================================
  Widget _buildAcciones(
      ColorScheme colorScheme, bool isDark, bool isMobile) {
    final Widget recargarBtn = MouseRegion(
      cursor: SystemMouseCursors.click,
      child: SizedBox(
        height: 48,
        child: OutlinedButton.icon(
          onPressed: () {
            setState(() => _cargarDiagnostico());
          },
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: const Text(
            'Recargar',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          style: ButtonStyle(
            foregroundColor: const WidgetStatePropertyAll(_colorPrimary),
            side: WidgetStatePropertyAll(
              BorderSide(
                  color: _colorPrimary.withValues(alpha: 0.45), width: 1.4),
            ),
            backgroundColor: WidgetStatePropertyAll(
              _colorPrimary.withValues(alpha: 0.06),
            ),
            overlayColor: WidgetStatePropertyAll(
              _colorPrimary.withValues(alpha: 0.15),
            ),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ),
    );

    final Widget migrarBtn = MouseRegion(
      cursor: _isMigrating
          ? SystemMouseCursors.forbidden
          : SystemMouseCursors.click,
      child: SizedBox(
        height: 48,
        child: ElevatedButton.icon(
          onPressed: _isMigrating ? null : _ejecutarMigracion,
          icon: _isMigrating
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.play_arrow_rounded, size: 20),
          label: Text(
            _isMigrating ? 'Migrando...' : 'Ejecutar Migración',
            style: const TextStyle(
                fontWeight: FontWeight.bold, letterSpacing: 0.3),
          ),
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(
              _isMigrating ? _colorSuccess.withValues(alpha: 0.6) : _colorSuccess,
            ),
            foregroundColor: const WidgetStatePropertyAll(Colors.white),
            overlayColor: WidgetStatePropertyAll(
              Colors.white.withValues(alpha: 0.15),
            ),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            elevation: const WidgetStatePropertyAll(0),
          ),
        ),
      ),
    );

    if (isMobile) {
      return Column(
        children: [
          SizedBox(width: double.infinity, child: migrarBtn),
          const SizedBox(height: 10),
          SizedBox(width: double.infinity, child: recargarBtn),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        recargarBtn,
        const SizedBox(width: 12),
        migrarBtn,
      ],
    );
  }
}