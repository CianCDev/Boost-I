import 'package:flutter/material.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/producto_entity.dart';

class ProductoSelector extends StatelessWidget {
  final List<ProductoEntity> productos;
  final ProductoEntity? valorSeleccionado;
  final Function(ProductoEntity?) onChanged;
  final TextEditingController cantidadController;
  final TextEditingController precioController;
  final VoidCallback onAgregar;

  const ProductoSelector({
    super.key,
    required this.productos,
    required this.valorSeleccionado,
    required this.onChanged,
    required this.cantidadController,
    required this.precioController,
    required this.onAgregar,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        DropdownButtonFormField<ProductoEntity>(
          value: valorSeleccionado,
          hint: Text(
            productos.isEmpty ? 'No hay productos para este proveedor' : 'Seleccionar producto',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
          items: productos.map((p) {
            return DropdownMenuItem(
              value: p,
              child: Text(
                '${p.nombre} (Stock: ${p.stock})',
                style: TextStyle(color: colorScheme.onSurface), // ✅ Adaptado
              ),
            );
          }).toList(),
          onChanged: onChanged,
          dropdownColor: colorScheme.surface, // ✅ Fondo del dropdown adaptado
          style: TextStyle(color: colorScheme.onSurface), // ✅ Texto del dropdown adaptado
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark ? colorScheme.surfaceContainerHighest : Colors.grey.shade50, // ✅ Adaptado
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: cantidadController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: colorScheme.onSurface), // ✅ Texto DINÁMICO (AQUÍ ESTABA EL ERROR)
                decoration: InputDecoration(
                  labelText: 'Cantidad',
                  labelStyle: TextStyle(color: colorScheme.onSurfaceVariant), // ✅ Etiqueta adaptada
                  filled: true,
                  fillColor: isDark ? colorScheme.surfaceContainerHighest : Colors.grey.shade50, // ✅ Fondo adaptado
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: precioController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: colorScheme.onSurface), // ✅ Texto DINÁMICO (AQUÍ ESTABA EL ERROR)
                decoration: InputDecoration(
                  labelText: 'Precio Unitario (Bs)',
                  labelStyle: TextStyle(color: colorScheme.onSurfaceVariant), // ✅ Etiqueta adaptada
                  filled: true,
                  fillColor: isDark ? colorScheme.surfaceContainerHighest : Colors.grey.shade50, // ✅ Fondo adaptado
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: onAgregar,
                icon: const Icon(Icons.add_rounded, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}