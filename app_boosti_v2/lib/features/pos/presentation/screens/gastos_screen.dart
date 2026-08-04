import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/Local/entities/gasto_entity.dart';
import '../../data/Local/entities/isar_service.dart';
import '../providers/bcv_provider.dart';
import '../../presentation/providers/usuario_provider.dart'; // ✅ IMPORT AGREGADO
import '../utils/responsive_helper.dart';


class GastosScreen extends ConsumerStatefulWidget {
  const GastosScreen({super.key});

  @override
  ConsumerState<GastosScreen> createState() => _GastosScreenState();
}

class _GastosScreenState extends ConsumerState<GastosScreen> {
  final IsarService _isarService = IsarService();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _montoController = TextEditingController();
  String _monedaSeleccionada = 'USD';
  String _categoriaSeleccionada = 'General';
  final List<String> _categorias = ['General', 'Alimentación', 'Transporte', 'Servicios', 'Otros'];

  List<GastoEntity> _gastos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarGastos();
  }

  Future<void> _cargarGastos() async {
    setState(() => _isLoading = true);
    try {
      final gastos = await _isarService.obtenerGastos();
      if (mounted) {
        setState(() {
          _gastos = gastos;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar gastos: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _registrarGasto() async {
    final descripcion = _descripcionController.text.trim();
    final montoStr = _montoController.text.trim().replaceAll(',', '.');
    final monto = double.tryParse(montoStr);

    if (descripcion.isEmpty || monto == null || monto <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa una descripción y un monto válido.'), backgroundColor: Colors.orange),
      );
      return;
    }

    final usuario = ref.read(usuarioActualProvider);
    if (usuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario no identificado.'), backgroundColor: Colors.red),
      );
      return;
    }

    final tasaBcv = ref.read(bcvProvider).tasa;
    final gasto = GastoEntity()
      ..descripcion = descripcion
      ..monto = monto
      ..moneda = _monedaSeleccionada
      ..tasaBcv = _monedaSeleccionada == 'Bs' ? tasaBcv : null
      ..categoria = _categoriaSeleccionada
      ..usuarioId = usuario.id
      ..usuarioNombre = usuario.nombre
      ..fecha = DateTime.now()
      ..syncStatus = 'pending';

    await _isarService.guardarGasto(gasto);
    _descripcionController.clear();
    _montoController.clear();
    await _cargarGastos();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Gasto registrado correctamente.'), backgroundColor: Color(0xFF10B981)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = ResponsiveHelper.isMobile(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Registro de Gastos', style: TextStyle(fontWeight: FontWeight.bold)),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [theme.primaryColor, theme.primaryColorDark],
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 2,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarGastos,
          ),
        ],
      ),
      body: Column(
        children: [
          // Formulario de registro
          Container(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            margin: EdgeInsets.all(isMobile ? 12 : 24),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _descripcionController,
                        style: theme.textTheme.bodyMedium,
                        decoration: InputDecoration(
                          labelText: 'Descripción del gasto *',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _montoController,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        style: theme.textTheme.bodyMedium,
                        decoration: InputDecoration(
                          labelText: 'Monto *',
                          prefixText: _monedaSeleccionada == 'USD' ? '\$ ' : 'Bs. ',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _monedaSeleccionada, // ✅ CORREGIDO: use initialValue
                        items: const [
                          DropdownMenuItem(value: 'USD', child: Text('USD')),
                          DropdownMenuItem(value: 'Bs', child: Text('Bolívares')),
                        ],
                        onChanged: (val) => setState(() => _monedaSeleccionada = val!),
                        decoration: InputDecoration(
                          labelText: 'Moneda',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _categoriaSeleccionada, // ✅ CORREGIDO: use initialValue
                        items: _categorias.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (val) => setState(() => _categoriaSeleccionada = val!),
                        decoration: InputDecoration(
                          labelText: 'Categoría',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _registrarGasto,
                  icon: const Icon(Icons.add),
                  label: const Text('Registrar Gasto', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          // Lista de gastos
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)))
                : _gastos.isEmpty
                    ? Center(
                        child: Text(
                          'No hay gastos registrados.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24, vertical: 12),
                        itemCount: _gastos.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10), // ✅ CORREGIDO: (_, __) está bien
                        itemBuilder: (context, index) {
                          final gasto = _gastos[index];
                          final fechaLocal = gasto.fecha.toLocal();
                          final String fechaStr =
                              '${fechaLocal.day.toString().padLeft(2, '0')}/${fechaLocal.month.toString().padLeft(2, '0')}/${fechaLocal.year} ${fechaLocal.hour.toString().padLeft(2, '0')}:${fechaLocal.minute.toString().padLeft(2, '0')}';
                          final String montoStr =
                              gasto.moneda == 'USD' ? '\$${gasto.monto.toStringAsFixed(2)}' : 'Bs. ${gasto.monto.toStringAsFixed(2)}';

                          return Card(
                            color: theme.cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.3)),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.1),
                                child: const Icon(Icons.money_off, color: Color(0xFFEF4444)),
                              ),
                              title: Text(gasto.descripcion, style: theme.textTheme.titleMedium),
                              subtitle: Text('$fechaStr • ${gasto.usuarioNombre} • ${gasto.categoria}'),
                              trailing: Text(
                                montoStr,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: gasto.moneda == 'USD' ? const Color(0xFFEF4444) : const Color(0xFF0284C7),
                                ),
                              ),
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