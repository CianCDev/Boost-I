import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? mobileLarge;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.mobileLarge,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= ResponsiveHelper.desktopBreakpoint && desktop != null) {
      return desktop!;
    } else if (width >= ResponsiveHelper.tabletBreakpoint && tablet != null) {
      return tablet!;
    } else if (width >= 400 && mobileLarge != null) {
      return mobileLarge!;
    } else {
      return mobile;
    }
  }
}