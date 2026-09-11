import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext, bool, bool, bool) builder;

  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return builder(context, isMobile, isTablet, isDesktop);
  }
}