import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Gradient? gradient;
  final Widget? leading;
  final double? leadingWidth;
  final bool centerTitle;
  final String? logoAsset;  // Ruta del logo (puede ser PNG o SVG)
  final double logoSize;    // Tamaño del logo en el AppBar

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = false,
    this.onBackPressed,
    this.gradient,
    this.leading,
    this.leadingWidth,
    this.centerTitle = false,
    this.logoAsset,
    this.logoSize = 32,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultGradient = isDark
        ? const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF10B981), Color(0xFF059669)],
          )
        : const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF5352ED), Color(0xFF4840E8), Color(0xFF5955EE)],
          );

    // 🔥 Construir título con logo (blanco forzado)
    Widget titleWidget;
    if (logoAsset != null) {
      final isSvg = logoAsset!.toLowerCase().endsWith('.svg');
      titleWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          isSvg
              ? SvgPicture.asset(
                  logoAsset!,
                  width: logoSize,
                  height: logoSize,
                  fit: BoxFit.contain,
                  // ✅ FUERZA EL COLOR BLANCO
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                )
              : Image.asset(
                  logoAsset!,
                  width: logoSize,
                  height: logoSize,
                  fit: BoxFit.contain,
                  color: Colors.white, // Para PNG también se fuerza blanco
                ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      );
    } else {
      titleWidget = Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      );
    }

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: gradient ?? defaultGradient,
        ),
      ),
      title: titleWidget,
      foregroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.white),
      actions: actions,
      leading: leading ?? (showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: onBackPressed ?? () => Navigator.pop(context),
            )
          : null),
      leadingWidth: leadingWidth,
      centerTitle: centerTitle,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}