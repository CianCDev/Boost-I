// lib/features/pos/presentation/widgets/keyboard_shortcuts_dialog.dart
import 'package:flutter/material.dart';
import 'dart:ui';

class KeyboardShortcutsDialog extends StatelessWidget {
  const KeyboardShortcutsDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const KeyboardShortcutsDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;

    // Lista de atajos actuales
    final shortcuts = [
      _Shortcut('F1', 'Ayuda'),
      _Shortcut('F2', 'Buscar producto'),
      _Shortcut('Ctrl+N', 'Nuevo pedido'),
      _Shortcut('Ctrl+E', 'Editar producto'),
      _Shortcut('Ctrl+S', 'Guardar'),
    ];

    // TO DO: Atajos futuros (5)
    final futureShortcuts = [
      _Shortcut('Ctrl+F', 'Finalizar pedido', isFuture: true),
      _Shortcut('Ctrl+P', 'Imprimir ticket', isFuture: true),
      _Shortcut('Ctrl+R', 'Refrescar datos', isFuture: true),
      _Shortcut('Ctrl+Z', 'Deshacer', isFuture: true),
      _Shortcut('F12', 'Abrir cajón', isFuture: true),
    ];

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 40,
        vertical: isMobile ? 16 : 40,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      elevation: 8,
      child: Container(
        width: isMobile ? double.infinity : 480,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.grey[900]!.withValues(alpha: 0.9)
                    : Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.white.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Cabecera
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.keyboard_rounded,
                            color: Color(0xFF8B5CF6),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Atajos de teclado',
                            style: TextStyle(
                              fontSize: isMobile ? 18 : 22,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.close_rounded,
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                          tooltip: 'Cerrar',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Lista de atajos actuales
                    Text(
                      'Atajos disponibles',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : Colors.black54,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...shortcuts.map((s) => _buildShortcutTile(s, isDark)),
                    const Divider(height: 32),

                    // TO DO: Próximamente
                    Row(
                      children: [
                        Icon(
                          Icons.timer_rounded,
                          size: 16,
                          color: isDark ? Colors.white54 : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Próximamente',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white54 : Colors.grey.shade600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...futureShortcuts.map((s) => _buildShortcutTile(s, isDark, isFuture: true)),
                    const SizedBox(height: 8),

                    // Pie de página
                    Center(
                      child: Text(
                        'Más atajos en futuras actualizaciones',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white38 : Colors.grey.shade500,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShortcutTile(_Shortcut shortcut, bool isDark, {bool isFuture = false}) {
    final color = isFuture
        ? (isDark ? Colors.white38 : Colors.grey.shade400)
        : (isDark ? Colors.white : Colors.black87);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isFuture
                  ? (isDark ? Colors.white10 : Colors.grey.shade200)
                  : const Color(0xFF8B5CF6).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isFuture
                    ? (isDark ? Colors.white24 : Colors.grey.shade300)
                    : const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Text(
              shortcut.key,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isFuture
                    ? (isDark ? Colors.white54 : Colors.grey.shade600)
                    : const Color(0xFF8B5CF6),
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              shortcut.description,
              style: TextStyle(
                fontSize: 14,
                color: color,
                fontWeight: isFuture ? FontWeight.normal : FontWeight.w500,
              ),
            ),
          ),
          if (isFuture)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isDark ? Colors.white12 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'TO DO',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white54 : Colors.grey.shade600,
                  letterSpacing: 0.8,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Shortcut {
  final String key;
  final String description;
  final bool isFuture;

  _Shortcut(this.key, this.description, {this.isFuture = false});
}