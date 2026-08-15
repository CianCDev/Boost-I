import 'package:flutter/material.dart';
import '../../../data/Local/entities/proveedor_entity.dart';

class ProveedorAutocomplete extends StatelessWidget {
  final List<ProveedorEntity> proveedores;
  final Function(ProveedorEntity) onSelected;

  const ProveedorAutocomplete({
    super.key,
    required this.proveedores,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Autocomplete<ProveedorEntity>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return proveedores;
        }
        return proveedores.where((p) =>
            p.nombre.toLowerCase().contains(textEditingValue.text.toLowerCase()));
      },
      displayStringForOption: (proveedor) => proveedor.nombre,
      onSelected: onSelected,
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          style: TextStyle(color: colorScheme.onSurface), // ✅ Texto DINÁMICO
          decoration: InputDecoration(
            hintText: 'Escribe el nombre de la empresa',
            hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withOpacity(0.6)),
            prefixIcon: Icon(Icons.search_rounded, color: colorScheme.onSurfaceVariant),
            filled: true,
            // ✅ Fondo dinámico: oscuro en dark mode, blanco en light mode
            fillColor: isDark ? colorScheme.surfaceContainerHighest : Colors.white, 
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
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Material(
          elevation: 4,
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options.elementAt(index);
                return ListTile(
                  title: Text(option.nombre, style: TextStyle(color: colorScheme.onSurface)),
                  subtitle: option.cedula != null
                      ? Text('RIF: ${option.cedula}', style: TextStyle(color: colorScheme.onSurfaceVariant))
                      : null,
                  leading: Icon(Icons.business_rounded, color: colorScheme.primary),
                  onTap: () => onSelected(option),
                  hoverColor: colorScheme.primary.withOpacity(0.08),
                );
              },
            ),
          ),
        );
      },
    );
  }
}