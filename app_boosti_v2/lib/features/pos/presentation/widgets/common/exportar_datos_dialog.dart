// lib/features/pos/presentation/widgets/common/exportar_datos_dialog.dart
//
// R.5 · Diálogo de exportación de datos (ZIP con un CSV por tabla).
//
// La exportación puede tardar unos segundos en una base grande, así que se
// dispara a pedido (no al abrir el diálogo) y muestra progreso.
import 'package:flutter/material.dart';

import '../../services/exportacion_datos_service.dart';
import 'dialog_header.dart';
import 'glass_dialog.dart';

/// Abre el diálogo de exportación.
Future<void> mostrarExportarDatosDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (_) => const ExportarDatosDialog(),
  );
}

class ExportarDatosDialog extends StatefulWidget {
  const ExportarDatosDialog({super.key});

  @override
  State<ExportarDatosDialog> createState() => _ExportarDatosDialogState();
}

class _ExportarDatosDialogState extends State<ExportarDatosDialog> {
  final ExportacionDatosService _servicio = ExportacionDatosService();

  bool _exportando = false;
  bool _compartiendo = false;
  ResultadoExportacion? _resultado;
  String? _error;

  static const Color _acento = Color(0xFF10B981);

  Future<void> _exportar() async {
    setState(() {
      _exportando = true;
      _error = null;
      _resultado = null;
    });

    try {
      final resultado = await _servicio.exportar();
      if (!mounted) return;
      setState(() => _resultado = resultado);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'No se pudo exportar: $e');
    } finally {
      if (mounted) setState(() => _exportando = false);
    }
  }

  Future<void> _compartir() async {
    final resultado = _resultado;
    if (resultado == null) return;

    setState(() => _compartiendo = true);
    try {
      await _servicio.compartir(resultado);
    } finally {
      if (mounted) setState(() => _compartiendo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassDialog(
      maxWidth: 520,
      accentColor: _acento,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DialogHeader(
              icon: Icons.file_download_outlined,
              title: 'Exportar datos',
              subtitle: 'Un CSV por tabla, dentro de un ZIP',
              color: _acento,
              onClose: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 16),
            Text(
              'Se exportan las ventas, productos, clientes, comandas, mesas, '
              'inventario y el resto de las tablas del negocio para abrirlas '
              'en Excel o LibreOffice.\n\n'
              'No se incluyen PIN, contraseñas ni la configuración de '
              'Telegram.',
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 18),
            if (_error != null) ...[
              _Aviso(
                icono: Icons.error_outline,
                texto: _error!,
                color: const Color(0xFFEF4444),
                isDark: isDark,
              ),
              const SizedBox(height: 14),
            ],
            if (_resultado != null) ...[
              _Resumen(resultado: _resultado!, isDark: isDark),
              const SizedBox(height: 14),
            ],
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        _exportando ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cerrar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: _exportando
                        ? null
                        : (_resultado == null ? _exportar : _compartir),
                    style: FilledButton.styleFrom(backgroundColor: _acento),
                    icon: _exportando || _compartiendo
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(
                            _resultado == null
                                ? Icons.download_rounded
                                : Icons.share_rounded,
                          ),
                    label: Text(
                      _exportando
                          ? 'Exportando…'
                          : _compartiendo
                              ? 'Compartiendo…'
                              : _resultado == null
                                  ? 'Generar exportación'
                                  : 'Compartir ZIP',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Resumen extends StatelessWidget {
  const _Resumen({required this.resultado, required this.isDark});

  final ResultadoExportacion resultado;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final tablas = resultado.filasPorTabla.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_outline,
                  color: Color(0xFF10B981), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${resultado.totalTablas} tablas · '
                  '${resultado.totalFilas} filas · '
                  '${resultado.tamanoKb.toStringAsFixed(0)} KB',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SelectableText(
            resultado.archivo.path,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 132,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: tablas.length,
              itemBuilder: (context, index) {
                final tabla = tablas[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          tabla.key,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ),
                      Text(
                        '${tabla.value}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Aviso extends StatelessWidget {
  const _Aviso({
    required this.icono,
    required this.texto,
    required this.color,
    required this.isDark,
  });

  final IconData icono;
  final String texto;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.14 : 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(icono, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(fontSize: 12.5, color: color),
            ),
          ),
        ],
      ),
    );
  }
}
