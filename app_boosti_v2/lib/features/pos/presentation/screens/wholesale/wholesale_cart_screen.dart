// lib/features/pos/presentation/screens/wholesale/wholesale_cart_screen.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/permissions/roles.dart';
import '../../../domain/wholesale/wholesale_cart_item.dart';
import '../../providers/bcv_provider.dart';
import '../../providers/usuario_provider.dart';
import '../../providers/wholesale/wholesale_cart_provider.dart';
import '../../providers/wholesale/wholesale_client_provider.dart';
import '../../services/mayoreo/venta_mayor_service.dart';
import '../../utils/responsive_helper.dart';
import '../../widgets/appbar.dart';
import '../../widgets/wholesale/wholesale_authorization_banner.dart';
import '../../widgets/wholesale/wholesale_cart_line.dart';
import '../../widgets/wholesale/wholesale_cart_summary.dart';
import '../../widgets/wholesale/wholesale_client_selector.dart';
import '../../widgets/wholesale/wholesale_cobrar_dialog.dart';
import '../../widgets/wholesale/wholesale_discount_dialog.dart';

class WholesaleCartScreen extends ConsumerStatefulWidget {
  const WholesaleCartScreen({super.key});

  @override
  ConsumerState<WholesaleCartScreen> createState() =>
      _WholesaleCartScreenState();
}

class _WholesaleCartScreenState extends ConsumerState<WholesaleCartScreen> {
  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(wholesaleCartProvider);
    final clienteState = ref.watch(wholesaleClientProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    // Tasa BCV
    final bcvSnapshot = ref.watch(bcvProvider);
    final tasaBcv = bcvSnapshot.tasa;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLow,
      appBar: CustomAppBar(
        title: 'Carrito al Mayor',
        showBackButton: true,
        actions: [
          if (cartState.tieneItems)
            IconButton(
              tooltip: 'Vaciar carrito',
              onPressed: () => _confirmarVaciar(context),
              icon: const Icon(Icons.delete_sweep_rounded, size: 22),
              color: Colors.white,
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: cartState.tieneItems
                ? _buildContenido(
                    context,
                    cartState,
                    clienteState,
                    tasaBcv,
                    isMobile,
                    isTablet,
                  )
                : _buildEmptyState(cs),
          ),
        ),
      ),
      bottomNavigationBar: cartState.tieneItems
          ? _buildBottomBar(context, cartState, clienteState, tasaBcv, isMobile)
          : null,
    );
  }

  // ──────────────── Contenido principal ────────────────

  Widget _buildContenido(
    BuildContext context,
    WholesaleCartState cartState,
    WholesaleClientState clienteState,
    double tasaBcv,
    bool isMobile,
    bool isTablet,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Cliente ──
        Padding(
          padding: EdgeInsets.fromLTRB(
            isMobile ? 12 : 20,
            12,
            isMobile ? 12 : 20,
            8,
          ),
          child: _buildClienteBanner(clienteState),
        ),

        // ── Banner de autorizaciones pendientes ──
        const WholesaleAuthorizationBanner(),

        // ── Lista de items ──
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(
              isMobile ? 12 : 20,
              4,
              isMobile ? 12 : 20,
              20,
            ),
            itemCount: cartState.items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final item = cartState.items[i];
              return WholesaleCartLine(
                item: item,
                onEdit: () => _editarCantidad(context, item),
                onDelete: () => _confirmarEliminar(context, item),
                onEditDiscount: () => _editarDescuentoLinea(context, item),
              );
            },
          ),
        ),
      ],
    );
  }

  // ──────────────── Banner de cliente ────────────────

  Widget _buildClienteBanner(WholesaleClientState clienteState) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (!clienteState.tieneCliente) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _abrirSelectorCliente,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark
                  ? cs.surfaceContainerHigh.withValues(alpha: 0.5)
                  : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                width: 1.4,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.person_search_rounded,
                  size: 22,
                  color: Color(0xFFF59E0B),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sin cliente asignado',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFF59E0B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Toca aquí para seleccionar un cliente',
                        style: TextStyle(
                          fontSize: 11,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 22,
                  color: Color(0xFFF59E0B),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Cliente seleccionado
    final cliente = clienteState.cliente!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? cs.surfaceContainerHigh.withValues(alpha: 0.5)
            : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.4),
          width: 1.4,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.person_rounded,
              size: 20,
              color: Color(0xFF10B981),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cliente.nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if ((cliente.rif ?? '').isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.badge_rounded,
                        size: 12,
                        color: cs.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'RIF: ${cliente.rif}',
                        style: TextStyle(
                          fontSize: 11,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: 'Cambiar cliente',
            onPressed: _abrirSelectorCliente,
            icon: const Icon(Icons.swap_horiz_rounded, size: 20),
            color: cs.primary,
          ),
        ],
      ),
    );
  }

  Future<void> _abrirSelectorCliente() async {
    final seleccionado = await WholesaleClientSelectorDialog.show(context);
    if (seleccionado != null && mounted) {
      setState(() {});
    }
  }

  // ──────────────── Bottom bar ────────────────

  Widget _buildBottomBar(
    BuildContext context,
    WholesaleCartState cartState,
    WholesaleClientState clienteState,
    double tasaBcv,
    bool isMobile,
  ) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 12 : 20,
        12,
        isMobile ? 12 : 20,
        isMobile ? 12 : 20,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? cs.surfaceContainerHigh.withValues(alpha: 0.95)
            : Colors.white,
        border: Border(
          top: BorderSide(
            color: cs.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Resumen
            WholesaleCartSummary(
              cartState: cartState,
              tasaBcv: tasaBcv,
            ),

            const SizedBox(height: 10),

            // Botón descuento global
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                onPressed: () => _editarDescuentoGlobal(context, cartState),
                icon: Icon(
                  cartState.descuentoGlobalPorcentaje > 0
                      ? Icons.percent_rounded
                      : Icons.local_offer_outlined,
                  size: 18,
                ),
                label: Text(
                  cartState.descuentoGlobalPorcentaje > 0
                      ? 'Descuento global: ${cartState.descuentoGlobalPorcentaje.toStringAsFixed(0)}%'
                      : 'Aplicar descuento global',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF8B5CF6),
                  side: BorderSide(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.5),
                    width: 1.2,
                  ),
                  backgroundColor:
                      const Color(0xFF8B5CF6).withValues(alpha: 0.06),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Botón cobrar
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () =>
                    _intentarCobrar(context, cartState, clienteState),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 3,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.point_of_sale_rounded, size: 22),
                    SizedBox(width: 10),
                    Text(
                      'COBRAR',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────── Empty state ────────────────

  Widget _buildEmptyState(ColorScheme cs) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.85, end: 1.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) =>
                  Transform.scale(scale: scale, child: child),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 80,
                color: cs.onSurfaceVariant.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'El carrito está vacío',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vuelve al catálogo y agrega productos\npara comenzar la venta al mayor.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: cs.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text(
                'Volver al catálogo',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: cs.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────── Acciones ────────────────

  Future<void> _editarCantidad(
    BuildContext context,
    WholesaleCartItem item,
  ) async {
    final controller = TextEditingController(
      text: item.cantidad.toString(),
    );
    final formKey = GlobalKey<FormState>();

    final resultado = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          item.producto.nombre,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Nueva cantidad (unidades)',
              prefixIcon: Icon(Icons.numbers_rounded),
              border: OutlineInputBorder(),
            ),
            validator: (v) {
              final n = int.tryParse(v ?? '');
              if (n == null || n <= 0) return 'Ingresa una cantidad válida';
              return null;
            },
            onFieldSubmitted: (_) {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.of(dialogContext)
                    .pop(int.tryParse(controller.text));
              }
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.of(dialogContext)
                    .pop(int.tryParse(controller.text));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (resultado != null && mounted) {
      await ref
          .read(wholesaleCartProvider.notifier)
          .actualizarCantidad(item.lineId, resultado);
    }
  }

  Future<void> _confirmarEliminar(
    BuildContext context,
    WholesaleCartItem item,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Quitar producto'),
        content: Text(
          '¿Eliminar "${item.producto.nombre}" del carrito?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: const Text('Quitar'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      ref.read(wholesaleCartProvider.notifier).eliminarItem(item.lineId);
    }
  }

  Future<void> _confirmarVaciar(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Vaciar carrito'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar todos los productos del carrito?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: const Text('Vaciar todo'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      ref.read(wholesaleCartProvider.notifier).limpiarCarrito();
    }
  }

  // ──────────────── Descuentos ────────────────

  Future<void> _editarDescuentoLinea(
    BuildContext context,
    WholesaleCartItem item,
  ) async {
    final usuario = ref.read(usuarioActualProvider);
    final rol = usuario != null
        ? UserRole.fromString(usuario.rol)
        : UserRole.cajero;

    final result = await WholesaleDiscountDialog.show(
      context,
      titulo: item.producto.nombre,
      subtitulo: 'Descuento por línea',
      rolUsuario: rol,
      porcentajeInicial: item.descuentoManualPorcentaje,
      esGlobal: false,
    );

    if (result == null || !mounted) return;

    final notifier = ref.read(wholesaleCartProvider.notifier);
    final requiereAuth = notifier.aplicarDescuentoLinea(
      lineId: item.lineId,
      porcentaje: result.porcentaje,
    );

    if (requiereAuth && result.autorizadoPorNombre != null) {
      notifier.autorizarDescuentoLinea(
        lineId: item.lineId,
        autorizadoPor: result.autorizadoPorNombre!,
      );
    }
  }

  Future<void> _editarDescuentoGlobal(
    BuildContext context,
    WholesaleCartState cartState,
  ) async {
    final usuario = ref.read(usuarioActualProvider);
    final rol = usuario != null
        ? UserRole.fromString(usuario.rol)
        : UserRole.cajero;

    final result = await WholesaleDiscountDialog.show(
      context,
      titulo: 'Descuento global',
      subtitulo: 'Sobre el subtotal',
      rolUsuario: rol,
      porcentajeInicial: cartState.descuentoGlobalPorcentaje,
      esGlobal: true,
    );

    if (result == null || !mounted) return;

    final notifier = ref.read(wholesaleCartProvider.notifier);
    final requiereAuth = notifier.aplicarDescuentoGlobal(result.porcentaje);

    if (requiereAuth && result.autorizadoPorNombre != null) {
      notifier.autorizarDescuentoGlobal(
        autorizadoPor: result.autorizadoPorNombre!,
      );
    }
  }

  // ──────────────── Cobrar ────────────────

    Future<void> _intentarCobrar(
    BuildContext context,
    WholesaleCartState cartState,
    WholesaleClientState clienteState,
  ) async {
    // 1. Si no hay cliente, abrir el selector
    if (!clienteState.tieneCliente) {
      final seleccionado = await WholesaleClientSelectorDialog.show(context);
      if (seleccionado == null || !mounted) return;

      final nuevoClienteState = ref.read(wholesaleClientProvider);
      if (!nuevoClienteState.tieneCliente) return;
    }

    if (!mounted) return;

    // 2. Validar descuentos pendientes
    final cartStateActual = ref.read(wholesaleCartProvider);
    if (cartStateActual.requiereAutorizacion) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Hay descuentos pendientes de autorización'),
          backgroundColor: Color(0xFFF59E0B),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // 3. Tasa BCV
    final bcvSnapshot = ref.read(bcvProvider);
    final tasaBcv = bcvSnapshot.tasa;
    if (tasaBcv <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ No hay tasa BCV disponible'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // 4. Abrir modal de cobro
    final cobroResult = await WholesaleCobrarDialog.show(
      context,
      totalUsd: cartStateActual.total,
      tasaBcv: tasaBcv,
      minimoRequeridoPorcentaje: cartStateActual.minimoRequeridoPorcentaje,
    );

    if (cobroResult == null || !mounted) return;

    // 5. Procesar venta
    await _procesarVenta(context, cobroResult);
  }

  Future<void> _procesarVenta(
    BuildContext context,
    WholesaleCobrarResult cobroResult,
  ) async {
    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF10B981)),
      ),
    );

    try {
      final service = ref.read(ventaMayorServiceProvider);
      final result = await service.ejecutar(pago: cobroResult.pago);

      if (!mounted) return;
      Navigator.of(context).pop(); // Cerrar loading

      if (!result.exito) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${result.mensajeError ?? "Error desconocido"}'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      // Éxito: limpiar carrito y mostrar confirmación
      ref.read(wholesaleCartProvider.notifier).limpiarCarrito();
      ref.read(wholesaleClientProvider.notifier).limpiarSeleccion();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '✅ Venta registrada · \$${result.total.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );

      // Volver a la pantalla anterior
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Cerrar loading

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error al procesar venta: $e'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
