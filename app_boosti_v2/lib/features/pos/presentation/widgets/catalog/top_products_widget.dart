// lib/features/pos/presentation/widgets/catalog/top_products_widget.dart
import 'dart:ui';
import 'package:app_boosti_v2/features/pos/domain/models/product_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/Local/entities/producto_entity.dart';
import '../../controllers/cart_controller.dart';
import '../../providers/catalog/top_products_provider.dart';
import '../../providers/themes/app_colors.dart';
import 'top_product_card.dart';
import 'quantity_dialog.dart';

class TopProductsWidget extends ConsumerStatefulWidget {
  final VoidCallback onClose;

  const TopProductsWidget({super.key, required this.onClose});

  @override
  ConsumerState<TopProductsWidget> createState() => _TopProductsWidgetState();
}

class _TopProductsWidgetState extends ConsumerState<TopProductsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _close() {
    _controller.reverse().then((_) => widget.onClose());
  }

  void _agregarAlCarrito(BuildContext context, ProductoEntity producto) {
    final navigatorContext = Navigator.of(context, rootNavigator: true).context;
    
    // 1. SOLUCIÓN: Capturamos el notifier ANTES de cerrar y destruir el widget
    final cartNotifier = ref.read(cartProvider.notifier);

    _controller.reverse().then((_) {
      widget.onClose();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!navigatorContext.mounted) return;

        showDialog(
          context: navigatorContext,
          builder: (_) => QuantityDialog(
            producto: producto,
            cantidadInicial: 1.0,
            onAgregar: (prodEntidad, cantidad) {
              
              // 2. SOLUCIÓN: Instanciar ProductItem correctamente en lugar de usar "as"
              // Si tienes un método como ProductItem.fromEntity(prodEntidad), úsalo aquí.
              // De lo contrario, mapea los valores manualmente:
              final itemParaCarrito = ProductItem(
                id: prodEntidad.id.toString(),
                codigoBarras: prodEntidad.codigoBarras,
                nombre: prodEntidad.nombre,
                precioUnidad: prodEntidad.precioUnidad,
                esPesado: prodEntidad.esPesado,
                categoria: prodEntidad.categoria,
              );

              // Usamos la referencia segura que guardamos arriba
              cartNotifier.agregarItem(itemParaCarrito, cantidad);
              
              ScaffoldMessenger.of(navigatorContext).showSnackBar(
                SnackBar(
                  content: Text('${prodEntidad.nombre} agregado al carrito'),
                  backgroundColor: primaryGreen,
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final panelWidth = screenWidth < 600
        ? screenWidth * 0.85
        : (screenWidth < 1200 ? 380.0 : 400.0);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _close();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: GestureDetector(
              onTap: _close,
              behavior: HitTestBehavior.opaque,
              child: Container(
                color: Colors.black.withValues(alpha: 0.4 * _fadeAnimation.value),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: GestureDetector(
                      onTap: () {},
                      child: Material(
                        color: Colors.transparent,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(24),
                            bottomRight: Radius.circular(24),
                          ),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                            child: Container(
                              width: panelWidth,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1A1A1A).withValues(alpha: 0.75)
                                    : Colors.white.withValues(alpha: 0.75),
                                border: Border(
                                  right: BorderSide(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.1)
                                        : Colors.white.withValues(alpha: 0.5),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              child: Column(
                                children: [
                                  _buildHeader(context),
                                  Expanded(
                                    child: _buildBody(context),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

 Widget _buildHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 48, 20, 20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.trending_up_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          // ✅ Título con Expanded y ajuste de texto en móvil
          Expanded(
            child: Text(
              isMobile ? 'Destacados' : 'Productos Destacados',
              style: TextStyle(
                fontSize: isMobile ? 18 : 22,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
                color: isDark ? Colors.white : Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Spacer(),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _close,
              borderRadius: BorderRadius.circular(12),
              mouseCursor: SystemMouseCursors.click,
              hoverColor: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.close_rounded,
                  size: 24,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final topProducts = ref.watch(topProductosProvider);

    return topProducts.when(
      data: (productos) {
        if (productos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_rounded, size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text(
                  'No hay productos destacados aún',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.all(16),
          child: ListView.separated(
            itemCount: productos.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final producto = productos[index];
              return TopProductCard(
                producto: producto,
                onAdd: () => _agregarAlCarrito(context, producto),
              );
            },
          ),
        );
      },
      loading: () => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando productos...'),
          ],
        ),
      ),
      error: (err, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: Colors.red.shade300),
            const SizedBox(height: 12),
            Text(
              'Error al cargar: $err',
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}