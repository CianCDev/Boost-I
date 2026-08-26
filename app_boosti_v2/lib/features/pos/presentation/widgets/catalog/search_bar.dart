import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/catalog_provider.dart';
import '../../utils/responsive_helper.dart';
import '../../providers/themes/app_colors.dart';

class CatalogSearchBar extends ConsumerWidget {
  final FocusNode focusNode;
  final VoidCallback onScanPressed;

  const CatalogSearchBar({
    super.key,
    required this.focusNode,
    required this.onScanPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Colores del esquema
    final backgroundColor = isDark ? bgDark : bgLight;
    final textColor = isDark ? Colors.white : textDark;
    final hintColor = textMuted;

    // Bordes más sutiles en modo oscuro
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : textMuted.withValues(alpha: 0.2);
    final focusedColor = primaryGreen; // #10B981

    return Row(
      children: [
        // 1. Campo de búsqueda
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: isDark
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: TextField(
              focusNode: focusNode,
              onChanged: (value) =>
                  ref.read(catalogProvider.notifier).setBusqueda(value),
              style: TextStyle(
                color: textColor,
                fontSize: isMobile ? 14 : 16,
              ),
              decoration: InputDecoration(
                hintText: 'Buscar por nombre / código (F2)',
                hintStyle: TextStyle(
                  color: hintColor,
                  fontSize: isMobile ? 13 : 15,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: hintColor,
                  size: 22,
                ),
                suffixIcon: Consumer(
                  builder: (context, ref, child) {
                    final busqueda = ref.watch(catalogProvider).busqueda;
                    if (busqueda.isNotEmpty) {
                      return IconButton(
                        icon: Icon(Icons.clear_rounded,
                            color: hintColor, size: 20),
                        onPressed: () {
                          ref.read(catalogProvider.notifier).setBusqueda('');
                          focusNode.requestFocus();
                        },
                        padding: EdgeInsets.zero,
                        splashRadius: 20,
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                filled: true,
                fillColor: backgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: borderColor,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: focusedColor,
                    width: 2,
                  ),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              ),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // 2. Botón de escáner extraído a su propio StatefulWidget
        _ScanButton(
          onPressed: onScanPressed,
          isMobile: isMobile,
        ),
      ],
    );
  }
}

// ✅ Extrayendo el botón resolvemos el problema de "Dead Code" 
// al mantener el estado persistente durante el ciclo de vida del widget.
class _ScanButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isMobile;

  const _ScanButton({
    required this.onPressed,
    required this.isMobile,
  });

  @override
  State<_ScanButton> createState() => _ScanButtonState();
}

class _ScanButtonState extends State<_ScanButton> {
  // Las variables ahora están fuera de la función build
  bool isPressed = false;
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    // ✅ Calcular factor de escala usando el estándar con llaves {}
    double scaleFactor = 1.0;
    
    if (isPressed) {
      scaleFactor = 0.92;
    } else if (isHovered) {
      scaleFactor = 1.05;
    }

    return Tooltip(
      message: 'Escanear código de barras',
      waitDuration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(8),
        // ✅ Corregido: Usando Border.all() en lugar de BorderSide()
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => isHovered = true),
        onExit: (_) => setState(() => isHovered = false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => isPressed = true),
          onTapUp: (_) => setState(() => isPressed = false),
          onTapCancel: () => setState(() => isPressed = false),
          onTap: widget.onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            // ✅ Corregido: Usando Matrix4.diagonal3Values en vez del obsoleto ..scale()
            transform: Matrix4.diagonal3Values(scaleFactor, scaleFactor, 1.0),
            transformAlignment: Alignment.center,
            padding: EdgeInsets.all(widget.isMobile ? 12 : 14),
            decoration: BoxDecoration(
              color: primaryGreen,
              borderRadius: BorderRadius.circular(16),
              boxShadow: isHovered
                  ? [
                      BoxShadow(
                        color: primaryGreen.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: primaryGreen.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: const Icon(
              Icons.qr_code_scanner_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}