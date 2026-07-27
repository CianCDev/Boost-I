import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/themes/app_theme.dart';
import 'features/pos/presentation/screens/pos_desktop_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: AppGestionM(),
    ),
  );
}
//
class AppGestionM extends StatelessWidget {
  const AppGestionM({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POS Desktop',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.desktopTheme,
      home: const PosDesktopScreen(),
    );
  }
}