// lib/features/pos/presentation/widgets/diagnostico_lote_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/lotes_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/services/sync_service.dart';

class DiagnosticoLotesDialog extends ConsumerStatefulWidget {
  const DiagnosticoLotesDialog({super.key});

  @override
  ConsumerState<DiagnosticoLotesDialog> createState() => _DiagnosticoLotesDialogState();
}

class _DiagnosticoLotesDialogState extends ConsumerState<DiagnosticoLotesDialog> {
  final IsarService _isar = IsarService();
  bool _isLoading = false;
  String _mensaje = '';
  int _totalLotes = 0;
  int _lotesSinLocal = 0;

  @override
  void initState() {
    super.initState();
    _cargarEstadisticas();
  }

  Future<void> _cargarEstadisticas() async {
    final total = await _isar.contarLotes();
    final lotes = await _isar.obtenerTodosLosLotes();
    final sinLocal = lotes.where((l) => l.localId == 0).length;
    setState(() {
      _totalLotes = total;
      _lotesSinLocal = sinLocal;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: colorScheme.surface,
      title: Row(
        children: [
          Icon(Icons.analytics_rounded, color: colorScheme.primary),
          const SizedBox(width: 8),
          const Text('Diagnóstico de Lotes'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_mensaje.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: _mensaje.contains('✅') ? Colors.green.shade50 : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _mensaje.contains('✅') ? Colors.green.shade200 : Colors.orange.shade200,
                ),
              ),
              child: Text(
                _mensaje,
                style: TextStyle(
                  color: _mensaje.contains('✅') ? Colors.green.shade800 : Colors.orange.shade800,
                ),
              ),
            ),
          _buildInfoRow('Total lotes en Isar', _totalLotes),
          _buildInfoRow('Lotes sin local (localId = 0)', _lotesSinLocal),
          const SizedBox(height: 16),
          const Text(
            'Acciones disponibles:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          // Botón Migrar
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _migrarLotes,
            icon: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.sync_alt_rounded),
            label: Text(_isLoading ? 'Migrando...' : 'Migrar lotes sin local'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 44),
            ),
          ),
          const SizedBox(height: 8),
          // Botón Forzar descarga
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _descargarLotes,
            icon: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.cloud_download_rounded),
            label: Text(_isLoading ? 'Descargando...' : 'Forzar descarga desde nube'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 44),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, int count) {
    final color = count > 0 ? Colors.orange.shade700 : Colors.green.shade700;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Text(
            count.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _migrarLotes() async {
    setState(() {
      _isLoading = true;
      _mensaje = '';
    });

    try {
      final result = await _isar.migrarLotesConLocal();
      final mensaje = '✅ ${result['actualizados']} lotes migrados al local activo. ${result['mensaje']}';
      setState(() => _mensaje = mensaje);
      
      await _cargarEstadisticas();
      await ref.read(lotesProvider.notifier).recargar();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensaje),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _mensaje = '❌ Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _descargarLotes() async {
    setState(() {
      _isLoading = true;
      _mensaje = '';
    });

    try {
      final sync = SyncService();
      await sync.descargarLotesDesdeSupabase();
      setState(() => _mensaje = '✅ Lotes descargados desde Supabase correctamente.');
      
      await _cargarEstadisticas();
      await ref.read(lotesProvider.notifier).recargar();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Lotes sincronizados desde la nube'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _mensaje = '❌ Error al descargar: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }
}