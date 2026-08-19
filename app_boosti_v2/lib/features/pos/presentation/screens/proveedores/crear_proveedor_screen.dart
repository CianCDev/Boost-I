import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/proveedores_provider.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/proveedor_entity.dart';

class CrearProveedorScreen extends ConsumerStatefulWidget {
  final ProveedorEntity? proveedor; // null = nuevo, con valor = edición

  const CrearProveedorScreen({super.key, this.proveedor});

  @override
  ConsumerState<CrearProveedorScreen> createState() => _CrearProveedorScreenState();
}

class _CrearProveedorScreenState extends ConsumerState<CrearProveedorScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nombreController;
  late TextEditingController _cedulaController;
  late TextEditingController _telefonoController;
  late TextEditingController _direccionController;
  bool _activo = true;

  @override
  void initState() {
    super.initState();
    final p = widget.proveedor;
    _nombreController = TextEditingController(text: p?.nombre ?? '');
    _cedulaController = TextEditingController(text: p?.cedula ?? '');
    _telefonoController = TextEditingController(text: p?.telefono ?? '');
    _direccionController = TextEditingController(text: p?.direccion ?? '');
    _activo = p?.activo ?? true;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _cedulaController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final nombre = _nombreController.text.trim();

    final proveedor = ProveedorEntity()
      ..nombre = nombre
      ..cedula = _cedulaController.text.trim().isNotEmpty ? _cedulaController.text.trim() : null
      ..telefono = _telefonoController.text.trim().isNotEmpty ? _telefonoController.text.trim() : null
      ..direccion = _direccionController.text.trim().isNotEmpty ? _direccionController.text.trim() : null
      ..empresa = nombre
      ..activo = _activo
      ..supabaseId = widget.proveedor?.supabaseId
      ..sincronizado = false;

    if (widget.proveedor != null) {
      proveedor.id = widget.proveedor!.id;
    }

    try {
      await ref.read(guardarProveedorProvider(proveedor).future);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.proveedor == null
                ? '✅ Proveedor creado correctamente'
                : '✅ Proveedor actualizado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.proveedor != null;
    final colorScheme = Theme.of(context).colorScheme; // ✅ Adaptado
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow, // ✅ Adaptado
      appBar: AppBar(
        title: Text(
          esEdicion ? 'Editar Proveedor' : 'Nuevo Proveedor',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromRGBO(68, 109, 241, 1),
                Color.fromARGB(255, 85, 59, 235),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 2,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _guardar,
            icon: const Icon(Icons.save_rounded),
            tooltip: 'Guardar',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Card(
            elevation: 2,
            color: colorScheme.surface, // ✅ Adaptado
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: colorScheme.outlineVariant, width: 1), // ✅ Adaptado
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nombreController,
                    style: TextStyle(color: colorScheme.onSurface), // ✅ Adaptado
                    decoration: InputDecoration(
                      labelText: 'Nombre de la empresa *',
                      labelStyle: TextStyle(color: colorScheme.onSurfaceVariant), // ✅ Adaptado
                      prefixIcon: Icon(Icons.business_center_rounded, color: colorScheme.onSurfaceVariant), // ✅ Adaptado
                      filled: true,
                      fillColor: isDark ? colorScheme.surfaceContainerHighest : Colors.white, // ✅ Adaptado
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.outline), // ✅ Adaptado
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.outline), // ✅ Adaptado
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.primary, width: 2), // ✅ Adaptado
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.error, width: 2), // ✅ Adaptado
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    validator: (v) => v!.trim().isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _cedulaController,
                    style: TextStyle(color: colorScheme.onSurface), // ✅ Adaptado
                    decoration: InputDecoration(
                      labelText: 'RIF / Cédula',
                      labelStyle: TextStyle(color: colorScheme.onSurfaceVariant), // ✅ Adaptado
                      prefixIcon: Icon(Icons.badge_rounded, color: colorScheme.onSurfaceVariant), // ✅ Adaptado
                      filled: true,
                      fillColor: isDark ? colorScheme.surfaceContainerHighest : Colors.white, // ✅ Adaptado
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.outline),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.outline),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.primary, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.error, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _telefonoController,
                    style: TextStyle(color: colorScheme.onSurface), // ✅ Adaptado
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Teléfono',
                      labelStyle: TextStyle(color: colorScheme.onSurfaceVariant), // ✅ Adaptado
                      prefixIcon: Icon(Icons.phone_rounded, color: colorScheme.onSurfaceVariant), // ✅ Adaptado
                      filled: true,
                      fillColor: isDark ? colorScheme.surfaceContainerHighest : Colors.white, // ✅ Adaptado
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.outline),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.outline),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.primary, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.error, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _direccionController,
                    style: TextStyle(color: colorScheme.onSurface), // ✅ Adaptado
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Dirección',
                      labelStyle: TextStyle(color: colorScheme.onSurfaceVariant), // ✅ Adaptado
                      prefixIcon: Icon(Icons.location_on_rounded, color: colorScheme.onSurfaceVariant), // ✅ Adaptado
                      filled: true,
                      fillColor: isDark ? colorScheme.surfaceContainerHighest : Colors.white, // ✅ Adaptado
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.outline),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.outline),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.primary, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.error, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: Text(
                      'Proveedor activo',
                      style: TextStyle(color: colorScheme.onSurface), // ✅ Adaptado
                    ),
                    value: _activo,
                    onChanged: (value) => setState(() => _activo = value),
                    activeColor: const Color(0xFF8B5CF6),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: colorScheme.outline), // ✅ Adaptado
                          ),
                          child: Text(
                            'Cancelar',
                            style: TextStyle(color: colorScheme.onSurfaceVariant), // ✅ Adaptado
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _guardar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B5CF6),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(esEdicion ? 'Actualizar' : 'Crear'),
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
}