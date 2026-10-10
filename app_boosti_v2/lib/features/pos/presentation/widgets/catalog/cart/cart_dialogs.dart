// lib/features/pos/presentation/widgets/catalog/cart/cart_dialogs.dart
import 'package:flutter/material.dart';
import '../../../providers/themes/app_colors.dart';

/// Confirmación de eliminación de un producto del carrito.
///
/// Devuelve `true` si el usuario confirma, `false`/`null` si cancela.
///
/// Estaba duplicado en `cart_sidebar.dart` (`_confirmarEliminarProducto`)
/// y `cart_bottom_sheet.dart` (ídem). Unificarlo aquí evita que las dos
/// copias diverjan, que es el mismo problema que había con el markup del
/// item y con el stepper de cantidad.
Future<bool?> confirmarEliminarProducto(
  BuildContext context,
  String nombre,
) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text('Eliminar producto'),
      content: Text('¿Seguro que deseas eliminar "$nombre" del carrito?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          style: TextButton.styleFrom(
            foregroundColor:
                Theme.of(dialogContext).colorScheme.onSurfaceVariant,
          ),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: TextButton.styleFrom(foregroundColor: redError),
          child: const Text('Eliminar'),
        ),
      ],
    ),
  );
}

/// Confirmación de "vaciar todo el carrito".
///
/// Devuelve `true` si el usuario confirma, `false`/`null` si cancela.
///
/// Antes vivía duplicado: `cart_bottom_sheet.dart` lo tenía inline en un
/// método privado propio y `cart_sidebar.dart` no lo tenía en absoluto
/// (el botón 🗑 de la cabecera del sidebar llamaba `onLimpiar` directo,
/// sin preguntar). Ese era el bug: en desktop se borraba sin
/// confirmación, en móvil sí se confirmaba.
Future<bool?> confirmarLimpiarCarrito(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text('Limpiar carrito'),
      content: const Text(
        '¿Seguro que deseas eliminar todos los productos del carrito?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          style: TextButton.styleFrom(
            foregroundColor:
                Theme.of(dialogContext).colorScheme.onSurfaceVariant,
          ),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: TextButton.styleFrom(foregroundColor: redError),
          child: const Text('Limpiar'),
        ),
      ],
    ),
  );
}