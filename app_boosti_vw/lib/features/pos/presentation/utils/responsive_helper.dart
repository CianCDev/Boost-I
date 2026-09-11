import 'package:flutter/material.dart';

class ResponsiveHelper {
  // Breakpoints estándar
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < desktopBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  static bool isMobileOrTablet(BuildContext context) {
    return MediaQuery.of(context).size.width < desktopBreakpoint;
  }

  // Obtener el tamaño de pantalla
  static Size getSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  // Padding responsive
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(12.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(20.0);
    } else {
      return const EdgeInsets.all(32.0);
    }
  }

  // Tamaño de fuente responsive
  static double getFontSize(BuildContext context, {double baseSize = 14}) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return baseSize * 0.9;
    if (width < 900) return baseSize * 1.0;
    if (width < 1200) return baseSize * 1.1;
    return baseSize * 1.2;
  }
}