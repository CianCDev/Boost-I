import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/Local/entities/usuario_entity.dart';
import '../providers/bcv_provider.dart';
import 'inventory_screen.dart';
import 'inventory_catalog_screen.dart';
import 'pos_menu_screen.dart';
import '../utils/responsive_helper.dart';

class MainPosScreen extends ConsumerStatefulWidget {
  final UsuarioEntity usuarioLogueado;
  const MainPosScreen({super.key, required this.usuarioLogueado});

  @override
  ConsumerState<MainPosScreen> createState() => _MainPosScreenState();
}

class _MainPosScreenState extends ConsumerState<MainPosScreen> {
  final PageController _pageController = PageController(initialPage: 1);
  int _currentIndex = 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
  }

  void _onNavTap(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(context, isMobile, isTablet),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const BouncingScrollPhysics(),
        children: [
          InventoryScreen(
            usuarioLogueado: widget.usuarioLogueado,
            showAppBar: false,
          ),
          InventoryCatalogScreen(
            usuarioLogueado: widget.usuarioLogueado,
            showAppBar: false,
          ),
          PosMenuScreen(showAppBar: false), // ✅ único y con parámetro
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
        elevation: 8,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF10B981),
        unselectedItemColor: Colors.grey.shade600,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Inventario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_rounded),
            label: 'Catálogo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Menú',
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isMobile, bool isTablet) {
    final bcvState = ref.watch(bcvProvider);

    return AppBar(
      leadingWidth: 85,
      leading: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Image.asset(
          'assets/logo.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.storefront, color: Colors.white, size: 32),        ),
      ),
      title: Text(
        _currentIndex == 1 ? 'Catálogo' : (_currentIndex == 0 ? 'Inventario' : 'Menú POS'),
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
      ),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromRGBO(68, 109, 241, 1),
              Color.fromARGB(255, 85, 59, 235),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 2,
      foregroundColor: Colors.white,
      actions: [
        Tooltip(
          message: 'Tasa oficial BCV (Haz clic para actualizar)',
          child: InkWell(
            onTap: () => ref.read(bcvProvider).actualizarTasa(),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: bcvState.cargando
                    ? Colors.white.withValues(alpha: 0.25)
                    : Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.currency_exchange, size: 16, color: Color(0xFF38BDF8)),
                  const SizedBox(width: 6),
                  if (bcvState.cargando)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF10B981)),
                    )
                  else
                    Text(
                      'BCV: Bs. ${bcvState.tasa.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}