import 'package:flutter/material.dart';

/// Paleta y etiqueta del badge de vencimiento.
///
/// Compartido por `product_card.dart` (grid) y `product_list_tile.dart`
/// (lista). Antes vivían duplicados dentro de `_ProductCardState`; al
/// llevar el mismo diseño a la lista, la duplicación garantizaba
/// divergencia: dos paletas que alguien iba a cambiar un día y olvidar
/// el otro día.
///
/// Los tres umbrales (3 / 7 / >7) tienen que coincidir con los de
/// `ExpiryUtils.clasificar`, que es el que decide SI se muestra el
/// badge. Acá solo se pinta.

/// Etiqueta corta del pill ("Vencido" / "8 d").
///
/// Corta a propósito: convive con "¡Stock bajo!" en la misma esquina y
/// en móvil el contenedor ronda los 150 px.
String expiryLabel(int dias) {
  if (dias <= 0) return 'Vencido';
  return '$dias d';
}

/// Fondo pastel del pill.
///
/// Pastel y no saturado porque el texto va encima: un fondo saturado
///obligaría a texto blanco y volvería a caer en el problema de
/// legibilidad que se resolvió en el AppBar del POS.
Color expiryFondo(int dias) {
  if (dias <= 3) return const Color(0xFFFEE2E2); // rojo suave
  if (dias <= 7) return const Color(0xFFFEF3C7); // ámbar suave
  return const Color(0xFFD1FAE5); // verde suave
}

/// Glifo saturado del pill.
///
/// Sobre su propio fondo pastel pasa WCAG AA: `#DC2626` sobre `#FEE2E2`
/// da ~5.9:1 y `#059669` sobre `#D1FAE5` ~4.6:1 (AA pide 4.5:1).
Color expiryTexto(int dias) {
  if (dias <= 3) return const Color(0xFFDC2626);
  if (dias <= 7) return const Color(0xFFD97706);
  return const Color(0xFF059669);
}
