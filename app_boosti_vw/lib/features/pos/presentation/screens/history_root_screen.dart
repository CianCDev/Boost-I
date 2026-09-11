// lib/features/pos/presentation/screens/history_root_screen.dart
import 'package:app_boosti_v2/features/pos/presentation/screens/gastos_screen.dart';
import 'package:app_boosti_v2/features/pos/presentation/screens/sales_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/responsive_helper.dart';

class HistoryRootScreen extends ConsumerStatefulWidget {
  const HistoryRootScreen({super.key});

  @override
  ConsumerState<HistoryRootScreen> createState() => _HistoryRootScreenState();
}

class _HistoryRootScreenState extends ConsumerState<HistoryRootScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = ResponsiveHelper.isMobile(context);

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      appBar: AppBar(
        title: Text(
          'Historial',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isMobile ? 18 : 24,
            color: colorScheme.onPrimary,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isMobile ? 13 : 16,
          ),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: isMobile ? 13 : 16,
          ),
          tabs: const [
            Tab(
              icon: Icon(Icons.receipt_long_rounded),
              text: 'Ventas',
            ),
            Tab(
              icon: Icon(Icons.money_off_rounded),
              text: 'Gastos',
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: isDark
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primaryContainer.withValues(alpha: 0.9),
                      colorScheme.primary,
                    ],
                  )
                : const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color.fromRGBO(81, 120, 252, 1), Color.fromARGB(255, 62, 40, 189)],
                  ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          SalesHistoryScreen(showAppBar: false),
          GastosScreen(showAppBar: false),
        ],
      ),
    );
  }
}