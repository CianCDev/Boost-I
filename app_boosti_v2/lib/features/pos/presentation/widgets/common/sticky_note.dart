// lib/features/pos/presentation/widgets/common/sticky_note.dart
import 'package:flutter/material.dart';

/// Nota adhesiva de un ítem de comanda ("sin cebolla", "extra queso").
///
/// ⚠️ v1 ESTÁTICA: no se puede arrastrar ni reposicionar. El drag & drop
/// con posición persistida queda para una v2 (ver `docs/TODO.md`).
///
/// Sin nota → el propio constructor recibe `texto` no vacío; si llega
/// vacío, el widget **no se dibuja** y ocupa cero alto. Eso permite
/// escribir `if (nota != null) StickyNote(texto: nota)` en la pantalla sin
/// ensuciarlo de `SizedBox`.
class StickyNote extends StatelessWidget {
  final String texto;

  /// Si es `null`, la nota es de solo lectura y no responde al tap.
  final VoidCallback? onEdit;

  /// Versión compacta para listas densas.
  final bool small;

  static const _fondo = Color(0xFFFEF3C7);
  static const _borde = Color(0xFFFCD34D);
  static const _texto = Color(0xFF78350F);

  const StickyNote({
    super.key,
    required this.texto,
    this.onEdit,
    this.small = false,
  });

  bool get _vacia => texto.trim().isEmpty;

  @override
  Widget build(BuildContext context) {
    if (_vacia) return const SizedBox.shrink();

    final contenido = Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6 : 10,
        vertical: small ? 3 : 6,
      ),
      decoration: BoxDecoration(
        color: _fondo,
        borderRadius: BorderRadius.circular(small ? 6 : 8),
        border: Border.all(color: _borde, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.edit_note_rounded, size: small ? 12 : 14, color: _texto),
          SizedBox(width: small ? 3 : 5),
          Flexible(
            child: Text(
              texto,
              style: TextStyle(
                fontSize: small ? 11 : 12,
                fontStyle: FontStyle.italic,
                color: _texto,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );

    if (onEdit == null) return contenido;

    return InkWell(
      onTap: onEdit,
      borderRadius: BorderRadius.circular(small ? 6 : 8),
      child: contenido,
    );
  }
}
