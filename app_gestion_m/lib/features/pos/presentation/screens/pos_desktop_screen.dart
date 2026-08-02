import 'package:app_gestion_m/features/pos/presentation/providers/esc_pos_printer_provider.dart';
import 'package:app_gestion_m/features/pos/presentation/widgets/printer_selection_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/producto_entity.dart';
import '../../data/Local/entities/usuario_entity.dart';
import '../../data/Local/entities/venta_entity.dart';
import '../../domain/models/product_item.dart';
import '../controllers/cart_controller.dart';
import '../providers/bcv_provider.dart';
import '../providers/lock_provider.dart';
import '../services/ticket_service.dart';
import '../widgets/cart_table_widget.dart';
import '../widgets/cobrar_dialog.dart';
import '../widgets/pos_summary_panel.dart';
import '../widgets/scale_visor_widget.dart';
import 'inventory_catalog_screen.dart';
import 'inventory_screen.dart';
import 'login_screen.dart';
import 'sales_history_screen.dart' as sales_history_screen;
import '../../presentation/providers/usuario_provider.dart';
import '../utils/responsive_helper.dart';
import '../widgets/responsive_layout.dart';

/// Vista Principal del Punto de Venta (POS) para Escritorio.
class PosDesktopScreen extends ConsumerStatefulWidget {
  final UsuarioEntity usuarioActual;

  const PosDesktopScreen({super.key, required this.usuarioActual});

  @override
  ConsumerState<PosDesktopScreen> createState() => _PosDesktopScreenState();
}

class _PosDesktopScreenState extends ConsumerState<PosDesktopScreen> {
  // ===========================================================================
  // VARIABLES DE ESTADO Y CONTROLADORES
  // ===========================================================================

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final IsarService _isarService = IsarService();

  late final String _cajeroActual;
  final String _turnoActual = "Turno Activo (Caja Principal)";

  List<ProductoEntity> _productosLocales = [];
  int _ventasPendientesSync = 0;
  bool _sincronizando = false;
  bool _aplicaIva = true;
  final double _pesoBalanzaActual = 0.000;

  // ===========================================================================
  // CICLO DE VIDA
  // ===========================================================================

  @override
  void initState() {
    super.initState();
    _cajeroActual = widget.usuarioActual.nombre;

    HardwareKeyboard.instance.addHandler(_manejarTecladoFisico);

    _cargarProductosAutocompletado();
    _actualizarContadorSync();
    _registrarEstadoUsuario('activo');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(usuarioActualProvider.notifier).setUsuario(widget.usuarioActual);
        ref.read(bcvProvider).actualizarTasa();
      }
    });
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_manejarTecladoFisico);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // ===========================================================================
  // MÉTODOS DE DATOS
  // ===========================================================================

  Future<void> _registrarEstadoUsuario(String estado) async {
    await _isarService.actualizarEstadoUsuario(widget.usuarioActual.id, estado);
  }

  Future<void> _cargarProductosAutocompletado() async {
    final prods = await _isarService.obtenerProductos();
    if (mounted) {
      setState(() {
        _productosLocales = prods;
      });
    }
  }

  Future<void> _actualizarContadorSync() async {
    final pendientes = await _isarService.obtenerVentasPendientesSync();
    if (mounted) {
      setState(() {
        _ventasPendientesSync = pendientes.length;
      });
    }
  }

  Future<void> _sincronizarVentas() async {
    if (_ventasPendientesSync == 0 || _sincronizando) return;

    setState(() => _sincronizando = true);
    try {
      final sincronizadas = await _isarService.sincronizarVentasConServidor();
      await _actualizarContadorSync();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡$sincronizadas ventas sincronizadas con Supabase exitosamente! 🎉'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al sincronizar con Supabase: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _sincronizando = false);
      }
    }
  }

  // ===========================================================================
  // DIÁLOGOS
  // ===========================================================================

  void _mostrarDialogoImpresora() {
    showDialog(
      context: context,
      builder: (context) => const PrinterSelectionDialog(),
    );
  }

  Future<void> _mostrarDialogoStockBajo() async {
    final productosBajos = await _isarService.obtenerProductosStockBajo();
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 28),
              const SizedBox(width: 8),
              Text(
                'Alertas de Stock Bajo (${productosBajos.length})',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SizedBox(
            width: 500,
            height: 350,
            child: productosBajos.isEmpty
                ? const Center(child: Text('¡Excelente! No hay productos con stock crítico.'))
                : ListView.separated(
                    itemCount: productosBajos.length,
                    separatorBuilder: (_, _) => const Divider(),
                    itemBuilder: (context, index) {
                      final p = productosBajos[index];
                      return ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFFEE2E2),
                          child: Icon(Icons.inventory_2, color: Colors.red, size: 20),
                        ),
                        title: Text(p.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        subtitle: Text(
                          'Código: ${p.codigoBarras} | Proveedor: ${p.proveedorNombre.isEmpty ? "No asignado" : p.proveedorNombre}',
                          style: const TextStyle(fontSize: 11),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Text(
                            'Stock: ${p.stock}',
                            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => InventoryScreen(usuarioLogueado: widget.usuarioActual)),
                );
              },
              child: const Text('Ver Inventario General'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarModuloGestionPersonal() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.admin_panel_settings, color: Color(0xFF3B82F6)),
              SizedBox(width: 8),
              Text('Gestión de Personal y Roles', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: const SizedBox(
            width: 450,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Administración de accesos del sistema POS:', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                SizedBox(height: 12),
                ListTile(
                  leading: Icon(Icons.person_add, color: Color(0xFF10B981)),
                  title: Text('Registrar Nuevo Cajero / Empleado'),
                  subtitle: Text('Asignar claves y permisos operativos de caja.'),
                ),
                ListTile(
                  leading: Icon(Icons.security, color: Color(0xFF8B5CF6)),
                  title: Text('Usuarios Importantes y Administradores'),
                  subtitle: Text('Configurar llaves maestras y permisos de anulación.'),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Módulo de personal guardado correctamente.'), backgroundColor: Color(0xFF10B981)),
                );
              },
              child: const Text('Guardar Cambios'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogoCambiarClave() {
    final TextEditingController claveController = TextEditingController();
    bool obscureText = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.lock_reset, color: Color(0xFF3B82F6)),
                  SizedBox(width: 8),
                  Text('Cambiar mi Clave', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ingresa tu nuevo PIN de seguridad:',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: claveController,
                    obscureText: obscureText,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Nuevo PIN (4 dígitos)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      suffixIcon: IconButton(
                        icon: Icon(obscureText ? Icons.visibility : Icons.visibility_off),
                        onPressed: () {
                          setStateDialog(() => obscureText = !obscureText);
                        },
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
                  onPressed: () async {
                    final nuevaClave = claveController.text.trim();
                    if (nuevaClave.length < 4) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('El PIN debe tener 4 dígitos.')),
                      );
                      return;
                    }

                    try {
                      final exito = await _isarService.cambiarClaveUsuario(widget.usuarioActual.id, nuevaClave);

                      if (context.mounted) {
                        if (exito) {
                          widget.usuarioActual.pin = nuevaClave;
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Clave actualizada correctamente.'), backgroundColor: Color(0xFF10B981)),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Error: No se encontró el usuario.'), backgroundColor: Colors.red),
                          );
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Error al cambiar la clave.'), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                  child: const Text('Guardar Nueva Clave'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _mostrarEstadoCajeros(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.monitor_heart_outlined, color: Color(0xFF3B82F6), size: 28),
              SizedBox(width: 10),
              Text('Monitor de Cajeros', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: SizedBox(
            width: 480,
            height: 320,
            child: FutureBuilder<List<UsuarioEntity>>(
              future: _isarService.obtenerUsuarios(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF3B82F6)),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error al consultar usuarios locales: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  );
                }

                final usuarios = snapshot.data ?? [];

                if (usuarios.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay cajeros o usuarios registrados en la base de datos local.',
                      style: TextStyle(color: Color(0xFF64748B)),
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: usuarios.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final usuario = usuarios[index];

                    Color colorEstado;
                    IconData iconoEstado;
                    String textoEstado;

                    final estado = (usuario.estado ?? 'inactivo').toLowerCase();

                    switch (estado) {
                      case 'activo':
                        colorEstado = const Color(0xFF10B981);
                        iconoEstado = Icons.point_of_sale;
                        textoEstado = 'Activo';
                        break;
                      case 'descanso':
                      case 'manualrest':
                        colorEstado = Colors.orange;
                        iconoEstado = Icons.coffee;
                        textoEstado = 'En Descanso';
                        break;
                      default:
                        colorEstado = const Color(0xFF64748B);
                        iconoEstado = Icons.power_off;
                        textoEstado = 'Inactivo';
                    }

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: colorEstado.withOpacity(0.15),
                        child: Icon(iconoEstado, color: colorEstado, size: 20),
                      ),
                      title: Text(
                        usuario.nombre,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      subtitle: Text(
                        'Rol: ${usuario.rol.toUpperCase()} | Caja: ${usuario.cajaAsignada ?? "Caja Principal"}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorEstado.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colorEstado.withOpacity(0.5)),
                        ),
                        child: Text(
                          textoEstado,
                          style: TextStyle(
                            color: colorEstado,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // LÓGICA DE CARRITO
  // ===========================================================================

  Future<double?> _solicitarPesoDialog(ProductoEntity producto) async {
    final controller = TextEditingController(text: '1.000');
    return showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(
            children: [
              const Icon(Icons.scale, color: Color(0xFF3B82F6)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Ingresar Peso: ${producto.nombre}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Precio por kg: \$${producto.precioUnidad.toStringAsFixed(2)}',
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Peso en Kilogramos (kg)',
                  suffixText: 'kg',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onSubmitted: (val) {
                  final peso = double.tryParse(val);
                  Navigator.of(context).pop(peso);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final peso = double.tryParse(controller.text);
                Navigator.of(context).pop(peso);
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _agregarProductoEntityAlCarrito(ProductoEntity producto) async {
    double cantidad = 1.0;

    if (producto.esPesado) {
      if (_pesoBalanzaActual > 0) {
        cantidad = _pesoBalanzaActual;
      } else {
        final pesoIngresado = await _solicitarPesoDialog(producto);
        if (pesoIngresado == null || pesoIngresado <= 0) return;
        cantidad = pesoIngresado;
      }
    }

    final productItem = ProductItem(
      id: producto.id.toString(),
      codigoBarras: producto.codigoBarras,
      nombre: producto.nombre,
      precioUnidad: producto.precioUnidad,
      esPesado: producto.esPesado,
      categoria: producto.categoria,
    );

    ref.read(cartProvider.notifier).agregarProducto(
      productItem,
      cantidad: cantidad,
      stockMaximo: producto.stock,
    );

    _searchController.clear();
    _enfocarBuscador();
  }

  Future<void> _buscarYAgregarProducto(String query) async {
    if (query.trim().isEmpty) return;

    final queryTrim = query.trim().toLowerCase();
    final productosDb = await _isarService.obtenerProductos();

    ProductoEntity? productoEncontrado;
    try {
      productoEncontrado = productosDb.firstWhere(
        (p) => p.codigoBarras.toLowerCase() == queryTrim || p.nombre.toLowerCase().contains(queryTrim),
      );
    } catch (_) {
      productoEncontrado = null;
    }

    if (productoEncontrado != null) {
      await _agregarProductoEntityAlCarrito(productoEncontrado);
    } else {
      _searchController.clear();
      _enfocarBuscador();
    }
  }

  void _enfocarBuscador() {
    _searchFocusNode.requestFocus();
    _searchController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _searchController.text.length,
    );
  }

  void _reiniciarCarrito() {
    ref.read(cartProvider.notifier).limpiarCarrito();
    setState(() {
      _aplicaIva = true;
    });
    ref.read(cartProvider.notifier).setAplicaIva(true);
    _enfocarBuscador();
  }

  // ===========================================================================
  // PROCESAR COBRO
  // ===========================================================================

  Future<void> _abrirCobro() async {
    final cartState = ref.read(cartProvider);
    if (cartState.total <= 0) return;
    double tasaActual = ref.read(bcvProvider).tasa;
    if (tasaActual.isNaN || tasaActual <= 0) {
      tasaActual = 0.0;
    }

    final productosParaDialogo = cartState.items.map((item) {
      return {
        'nombre': item.producto.nombre,
        'cantidad': item.cantidad.toDouble(),
        'precio': item.producto.precioUnidad,
        'esPesado': item.producto.esPesado,
      };
    }).toList();

    final resultado = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CobrarDialog(
        totalAPagar: cartState.total,
        productos: productosParaDialogo,
      ),
    );

    if (resultado != null && resultado['procesado'] == true && mounted) {
      try {
        final String ventaIdStr = 'V-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
        final DateTime ahora = DateTime.now();
        final double totalBsCalculado = cartState.total * tasaActual;

        final itemsIsar = cartState.items.map((cartItem) {
          return VentaItemEntity()
            ..nombreProducto = cartItem.producto.nombre
            ..precioUnidad = cartItem.producto.precioUnidad
            ..cantidad = cartItem.cantidad.toDouble()
            ..subtotal = cartItem.producto.precioUnidad * cartItem.cantidad.toDouble();
        }).toList();

        final nuevaVentaEntity = VentaEntity()
          ..ventaIdString = ventaIdStr
          ..fecha = ahora.toUtc()
          ..total = cartState.total
          ..subtotal = cartState.subtotal
          ..impuesto = cartState.impuesto
          ..tasaBcv = tasaActual
          ..totalBolivares = totalBsCalculado
          ..metodoPago = resultado['metodoPago'] ?? 'Efectivo'
          ..documento= resultado['documento'] ?? 'V-00000000'
          ..empleado = _cajeroActual
          ..items = itemsIsar
          ..sincronizado = false;

        await _isarService.guardarVenta(nuevaVentaEntity);
        await _actualizarContadorSync();
        await _cargarProductosAutocompletado();

        final ticketItems = cartState.items.map((cartItem) {
          return TicketItem(
            nombre: cartItem.producto.nombre,
            precio: cartItem.producto.precioUnidad,
            cantidad: cartItem.cantidad.toDouble(),
            esPesado: cartItem.producto.esPesado,
          );
        }).toList();

        final selectedPrinter = ref.read(printerProvider);

        await TicketService.generarYProcesarPdf(
          items: ticketItems,
          subtotal: cartState.subtotal,
          impuesto: cartState.impuesto,
          total: cartState.total,
          metodoPago: resultado['metodoPago'],
          montoRecibido: (resultado['montoRecibido'] as num?)?.toDouble() ?? 0.0,
          vuelto: (resultado['vuelto'] as num?)?.toDouble() ?? 0.0,
          fechaVenta: ahora,
          impresoraSeleccionada: selectedPrinter,
        );

        _reiniciarCarrito();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Venta registrada con éxito! 🎉'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al procesar la venta: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // ===========================================================================
  // RESUMEN DE CAJA
  // ===========================================================================

  void _mostrarDialogoCaja(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder<List<VentaEntity>>(
          future: _isarService.obtenerVentasPorPeriodo('dia'),
          builder: (context, snapshot) {
            final ventasDelDia = snapshot.data ?? [];

            final double totalEfectivo = ventasDelDia
                .where((v) => v.metodoPago.toLowerCase() == 'efectivo')
                .fold(0.0, (sum, v) => sum + v.total);

            final double totalPagoMovil = ventasDelDia
                .where((v) => v.metodoPago.toLowerCase() == 'pago móvil')
                .fold(0.0, (sum, v) => sum + v.total);

            final double totalPunto = ventasDelDia
                .where((v) => v.metodoPago.toLowerCase() == 'punto de venta')
                .fold(0.0, (sum, v) => sum + v.total);

            final double totalMixto = ventasDelDia
                .where((v) => v.metodoPago.toLowerCase() == 'pago mixto')
                .fold(0.0, (sum, v) => sum + v.total);

            final double granTotal = ventasDelDia.fold(0.0, (sum, v) => sum + v.total);
            final double granTotalBs = ventasDelDia.fold(0.0, (sum, v) => sum + v.totalBolivares);

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.point_of_sale, color: Color(0xFF0F172A), size: 26),
                      SizedBox(width: 10),
                      Text(
                        'Resumen de Caja del Día',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
                  Chip(
                    label: Text(
                      '${ventasDelDia.length} ventas',
                      style: const TextStyle(
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor: const Color(0xFFECFDF5),
                    side: BorderSide.none,
                  ),
                ],
              ),
              content: SizedBox(
                width: 440,
                child: snapshot.connectionState == ConnectionState.waiting
                    ? const SizedBox(
                        height: 140,
                        child: Center(child: CircularProgressIndicator(color: Color(0xFF10B981))),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _filaDetalleCaja('Efectivo USD / Bs', totalEfectivo, Icons.payments_outlined, const Color(0xFF10B981)),
                          const SizedBox(height: 8),
                          _filaDetalleCaja('Pago Móvil', totalPagoMovil, Icons.phone_iphone_rounded, const Color(0xFF0284C7)),
                          const SizedBox(height: 8),
                          _filaDetalleCaja('Punto de Venta', totalPunto, Icons.credit_card_outlined, const Color(0xFF8B5CF6)),
                          const SizedBox(height: 8),
                          _filaDetalleCaja('Pago Mixto', totalMixto, Icons.swap_horiz_rounded, const Color(0xFFD97706)),
                          const Divider(height: 20),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('TOTAL INGRESADO (\$)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
                                    Text('\$${granTotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF34D399))),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('EQUIVALENTE EN BS', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w600)),
                                    Text('Bs. ${granTotalBs.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 13, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
              actions: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.lock_clock, size: 18),
                  label: const Text('Cierre de Caja (Arqueo)', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _ejecutarCierreDeCaja(granTotal, granTotalBs, ventasDelDia.length);
                  },
                ),
                if (widget.usuarioActual.rol == 'admin')
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.analytics_outlined, size: 18),
                    label: const Text('Auditoría', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const sales_history_screen.SalesHistoryScreen(),
                        ),
                      );
                    },
                  ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cerrar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _ejecutarCierreDeCaja(double totalUsd, double totalBs, int cantidadVentas) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.assignment_turned_in_rounded, color: Color(0xFFEF4444)),
            SizedBox(width: 10),
            Text('Confirmar Cierre de Turno'),
          ],
        ),
        content: Text(
          '¿Deseas procesar el arqueo final de la caja actual?\n\n'
          '• Total Ventas: $cantidadVentas\n'
          '• Monto Recaudado: \$$totalUsd / Bs. ${totalBs.toStringAsFixed(2)}\n\n'
          'Se generará un comprobante de cierre de caja para el cajero $_cajeroActual.',
          style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('¡Cierre de caja completado para $_cajeroActual!'),
                  backgroundColor: const Color(0xFF10B981),
                ),
              );
            },
            child: const Text('Realizar Cierre'),
          ),
        ],
      ),
    );
  }

  Widget _filaDetalleCaja(String titulo, double monto, IconData icono, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icono, size: 18, color: color),
            const SizedBox(width: 8),
            Text(titulo, style: const TextStyle(fontSize: 14, color: Color(0xFF475569))),
          ],
        ),
        Text(
          '\$${monto.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ],
    );
  }

  // ===========================================================================
  // ATAJOS DE TECLADO
  // ===========================================================================

  bool _manejarTecladoFisico(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.f1) {
        _mostrarAyudaAtajos();
        return true;
      }
      if (event.logicalKey == LogicalKeyboardKey.f2) {
        _enfocarBuscador();
        return true;
      }
      if (event.logicalKey == LogicalKeyboardKey.f12) {
        _abrirCobro();
        return true;
      }
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        _reiniciarCarrito();
        return true;
      }
    }
    return false;
  }

  void _mostrarAyudaAtajos() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.keyboard, color: Color(0xFF3B82F6)),
            SizedBox(width: 10),
            Text('Atajos de Teclado Rápido', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _itemAtajo('F1', 'Abrir esta guía de ayuda'),
              _itemAtajo('F2', 'Enfocar buscador de productos / balanza'),
              _itemAtajo('F12', 'Abrir pantalla de cobro inmediatamente'),
              _itemAtajo('ESC', 'Limpiar/Reiniciar carrito de compra actual'),
              _itemAtajo('Enter', 'Agregar producto seleccionado / Confirmar cobro'),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  Widget _itemAtajo(String tecla, String descripcion) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              tecla,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              descripcion,
              style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // CONSTRUCCIÓN DE LA UI
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final bcvController = ref.watch(bcvProvider);
    final double tasaBcv = bcvController.tasa;
    final bool cargandoBcv = bcvController.cargando;
    final double totalBs = cartState.total * tasaBcv;
    final usuarioActivo = ref.watch(usuarioActualProvider);

    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        title: Text(
          'Panel de: ${usuarioActivo?.nombre ?? 'Sistema POS'}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: isMobile || isTablet
            ? []
            : _buildDesktopActions(cargandoBcv, tasaBcv),
      ),
      drawer: isMobile || isTablet ? _buildMobileDrawer(cargandoBcv, tasaBcv) : null,
      body: SafeArea(
        child: Padding(
          padding: ResponsiveHelper.getResponsivePadding(context),
          child: ResponsiveLayout(
            mobile: _buildMobileLayout(cartState, totalBs),
            tablet: _buildTabletLayout(cartState, totalBs),
            desktop: _buildDesktopLayout(cartState, totalBs),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // ACCIONES DEL APP BAR (DESKTOP)
  // ==========================================

  List<Widget> _buildDesktopActions(bool cargandoBcv, double tasaBcv) {
    return [
      // Tasa BCV
      Tooltip(
        message: 'Tasa oficial BCV (Haz clic para actualizar)',
        child: InkWell(
          onTap: () => ref.read(bcvProvider).actualizarTasa(),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Row(
              children: [
                const Icon(Icons.currency_exchange, size: 16, color: Color(0xFF38BDF8)),
                const SizedBox(width: 6),
                cargandoBcv
                    ? const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF10B981)),
                      )
                    : Text(
                        'BCV: Bs. ${tasaBcv.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),

      // Sincronización
      Tooltip(
        message: _sincronizando
            ? 'Sincronizando ventas...'
            : (_ventasPendientesSync == 0
                ? 'Todo sincronizado con Supabase'
                : 'Presiona para sincronizar $_ventasPendientesSync ventas pendientes'),
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          child: ElevatedButton.icon(
            onPressed: (_sincronizando || _ventasPendientesSync == 0) ? null : _sincronizarVentas,
            style: ElevatedButton.styleFrom(
              backgroundColor: _ventasPendientesSync > 0 ? const Color(0xFFD97706) : const Color(0xFF059669),
              foregroundColor: Colors.white,
              disabledBackgroundColor: _sincronizando ? const Color(0xFF2563EB) : const Color(0xFF1E293B),
              disabledForegroundColor: Colors.white70,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: _ventasPendientesSync > 0 ? 2 : 0,
            ),
            icon: _sincronizando
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Icon(
                    _ventasPendientesSync == 0 ? Icons.cloud_done_rounded : Icons.sync_rounded,
                    size: 16,
                  ),
            label: Text(
              _sincronizando
                  ? 'Sincronizando...'
                  : (_ventasPendientesSync == 0 ? 'Al Día' : 'Sincronizar ($_ventasPendientesSync)'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ),
      ),

      // Monitor Cajeros (Admin)
      if (widget.usuarioActual.rol == 'admin')
        IconButton(
          icon: const Icon(Icons.monitor_heart_outlined, color: Color(0xFF38BDF8)),
          tooltip: 'Monitor de Cajeros',
          onPressed: () => _mostrarEstadoCajeros(context),
        ),

      // Descanso (Cajero)
      if (widget.usuarioActual.rol == 'cajero')
        IconButton(
          icon: const Icon(Icons.coffee, color: Colors.orange),
          tooltip: 'Tomar Descanso',
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('¿Ir a descanso?'),
                content: const Text('La caja se bloqueará y requerirá un PIN para volver a ingresar.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    onPressed: () async {
                      Navigator.pop(context);
                      await _registrarEstadoUsuario('descanso');
                      ref.read(lockProvider.notifier).manualRest();
                    },
                    child: const Text('Confirmar Descanso', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          },
        ),

      // Stock Bajo
      FutureBuilder<List<ProductoEntity>>(
        future: _isarService.obtenerProductosStockBajo(),
        builder: (context, snapshot) {
          final stockBajoCount = snapshot.data?.length ?? 0;
          return Tooltip(
            message: stockBajoCount == 0 ? 'Inventario en niveles óptimos' : '¡Atención! $stockBajoCount productos con stock bajo',
            child: Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.warning_amber_rounded),
                  color: stockBajoCount > 0 ? Colors.amberAccent : Colors.white70,
                  onPressed: _mostrarDialogoStockBajo,
                ),
                if (stockBajoCount > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '$stockBajoCount',
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),

      // Resumen Caja
      IconButton(
        icon: const Icon(Icons.point_of_sale),
        tooltip: 'Ver Resumen de Caja y Turno',
        onPressed: () => _mostrarDialogoCaja(context),
      ),

      // Catálogo Visual
      IconButton(
        icon: const Icon(Icons.inventory_2_outlined),
        tooltip: 'Abrir Catálogo Visual',
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => InventoryCatalogScreen(usuarioLogueado: widget.usuarioActual),
            ),
          );
          _cargarProductosAutocompletado();
        },
      ),

      // Reiniciar Venta
      IconButton(
        icon: const Icon(Icons.refresh),
        onPressed: _reiniciarCarrito,
        tooltip: 'Reiniciar Venta (Esc)',
      ),

      // Impresora
      IconButton(
        icon: const Icon(Icons.print, color: Color(0xFF38BDF8)),
        tooltip: 'Configurar Impresora POS',
        onPressed: _mostrarDialogoImpresora,
      ),

      const VerticalDivider(color: Colors.white24, indent: 12, endIndent: 12, width: 20),

      // Menú de usuario
      PopupMenuButton<String>(
        tooltip: 'Opciones de Cuenta y Turno',
        icon: const CircleAvatar(
          backgroundColor: Color(0xFF3B82F6),
          foregroundColor: Colors.white,
          radius: 14,
          child: Icon(Icons.person, size: 18),
        ),
        offset: const Offset(0, 50),
        onSelected: (value) async {
          if (value == 'gestion_personal') {
            if (widget.usuarioActual.rol == 'admin') {
              _mostrarModuloGestionPersonal();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Acceso restringido solo a Administradores.'), backgroundColor: Colors.red),
              );
            }
          } else if (value == 'cambiar_clave') {
            _mostrarDialogoCambiarClave();
          } else if (value == 'cerrar_sesion') {
            await _registrarEstadoUsuario('inactivo');
            ref.read(usuarioActualProvider.notifier).cerrarSesion();
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            }
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            enabled: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_cajeroActual, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontSize: 14)),
                const SizedBox(height: 2),
                Text('Rol: ${widget.usuarioActual.rol.toUpperCase()} | $_turnoActual', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              ],
            ),
          ),
          const PopupMenuDivider(),
          if (widget.usuarioActual.rol == 'admin')
            const PopupMenuItem(
              value: 'gestion_personal',
              child: Row(
                children: [
                  Icon(Icons.admin_panel_settings_outlined, size: 18, color: Color(0xFF3B82F6)),
                  SizedBox(width: 8),
                  Text('Gestión de Personal y Admins', style: TextStyle(fontSize: 13)),
                ],
              ),
            ),
          const PopupMenuItem(
            value: 'cambiar_clave',
            child: Row(
              children: [
                Icon(Icons.password, size: 18, color: Color(0xFF8B5CF6)),
                SizedBox(width: 8),
                Text('Cambiar mi Clave', style: TextStyle(fontSize: 13)),
              ],
            ),
          ),
          const PopupMenuDivider(),
          const PopupMenuItem(
            value: 'cerrar_sesion',
            child: Row(
              children: [
                Icon(Icons.logout, size: 18, color: Colors.red),
                SizedBox(width: 8),
                Text('Cerrar Sesión', style: TextStyle(fontSize: 13, color: Colors.red, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(width: 8),
    ];
  }

  // ==========================================
  // LAYOUTS RESPONSIVE
  // ==========================================

  Widget _buildDesktopLayout(dynamic cartState, double totalBs) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 7, child: _buildLeftPanel(cartState, true)),
        const SizedBox(width: 16),
        Expanded(flex: 3, child: _buildRightPanel(cartState, totalBs, true)),
      ],
    );
  }

  Widget _buildTabletLayout(dynamic cartState, double totalBs) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 6, child: _buildLeftPanel(cartState, true)),
        const SizedBox(width: 12),
        Expanded(flex: 4, child: _buildRightPanel(cartState, totalBs, true)),
      ],
    );
  }

  Widget _buildMobileLayout(dynamic cartState, double totalBs) {
    return Column(
      children: [
        _buildMobileSearchBar(),
        const SizedBox(height: 8),
        Expanded(
          flex: 3,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CartTableWidget(
                items: cartState.items,
                onCantidadChanged: (index, cant) {
                  ref.read(cartProvider.notifier).actualizarCantidad(index, cant);
                },
                onEliminarItem: (index) {
                  ref.read(cartProvider.notifier).eliminarItem(index);
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          constraints: const BoxConstraints(maxHeight: 300),
          child: SingleChildScrollView(
            child: _buildRightPanel(cartState, totalBs, false),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // PANEL IZQUIERDO (BÚSQUEDA + TABLA)
  // ==========================================

  Widget _buildLeftPanel(dynamic cartState, bool isDesktop) {
    return Column(
      children: [
        RawAutocomplete<ProductoEntity>(
          textEditingController: _searchController,
          focusNode: _searchFocusNode,
          displayStringForOption: (option) => option.nombre,
          optionsBuilder: (textEditingValue) {
            if (textEditingValue.text.trim().isEmpty) {
              return const Iterable<ProductoEntity>.empty();
            }
            final query = textEditingValue.text.toLowerCase().trim();
            return _productosLocales.where((p) =>
                p.nombre.toLowerCase().contains(query) ||
                p.codigoBarras.toLowerCase().contains(query));
          },
          onSelected: (ProductoEntity selection) {
            _agregarProductoEntityAlCarrito(selection);
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: isDesktop,
              decoration: InputDecoration(
                labelText: 'Escanear código de barras o buscar (F2)...',
                prefixIcon: const Icon(Icons.qr_code_scanner),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () => _buscarYAgregarProducto(controller.text),
                ),
              ),
              onSubmitted: (val) {
                onFieldSubmitted();
                _buscarYAgregarProducto(val);
              },
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Container(
                width: 500,
                margin: const EdgeInsets.only(top: 4.0),
                constraints: const BoxConstraints(maxHeight: 280),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  clipBehavior: Clip.antiAlias,
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    separatorBuilder: (_, _) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    itemBuilder: (context, index) {
                      final item = options.elementAt(index);
                      return Material(
                        color: Colors.transparent,
                        child: ListTile(
                          dense: true,
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFFF1F5F9),
                            radius: 16,
                            child: Icon(
                              item.esPesado ? Icons.scale : Icons.shopping_bag,
                              color: const Color(0xFF3B82F6),
                              size: 16,
                            ),
                          ),
                          title: Text(
                            item.nombre,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          subtitle: Text(
                            'Cód: ${item.codigoBarras} | Stock: ${item.stock}',
                            style: const TextStyle(fontSize: 11),
                          ),
                          trailing: Text(
                            '\$${item.precioUnidad.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Color(0xFF059669),
                            ),
                          ),
                          onTap: () => onSelected(item),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        ScaleVisorWidget(
          pesoActual: _pesoBalanzaActual,
          estaConectada: true,
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CartTableWidget(
                items: cartState.items,
                onCantidadChanged: (index, cant) {
                  ref.read(cartProvider.notifier).actualizarCantidad(index, cant);
                },
                onEliminarItem: (index) {
                  ref.read(cartProvider.notifier).eliminarItem(index);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // PANEL DERECHO (RESUMEN)
  // ==========================================

  Widget _buildRightPanel(dynamic cartState, double totalBs, bool isDesktop) {
    return Column(
      children: [
        // Toggle IVA
        InkWell(
          onTap: () {
            setState(() => _aplicaIva = !_aplicaIva);
            ref.read(cartProvider.notifier).setAplicaIva(_aplicaIva);
            _enfocarBuscador();
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: _aplicaIva ? const Color(0xFFF8FAFC) : const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _aplicaIva ? const Color(0xFFE2E8F0) : const Color(0xFFF59E0B),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _aplicaIva ? Icons.receipt_long_outlined : Icons.money_off_csred_rounded,
                      size: 20,
                      color: _aplicaIva ? const Color(0xFF3B82F6) : const Color(0xFFD97706),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _aplicaIva ? 'IVA Aplicado (16%)' : 'Factura Exenta de IVA',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: _aplicaIva ? const Color(0xFF0F172A) : const Color(0xFFB45309),
                          ),
                        ),
                        Text(
                          _aplicaIva ? 'Calculando 16% sobre subtotal' : 'Venta marcada sin impuesto',
                          style: TextStyle(
                            fontSize: 10,
                            color: _aplicaIva ? const Color(0xFF64748B) : const Color(0xFFD97706),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: _aplicaIva ? const Color(0xFF0F172A) : const Color(0xFFD97706),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() => _aplicaIva = !_aplicaIva);
                        ref.read(cartProvider.notifier).setAplicaIva(_aplicaIva);
                      },
                      borderRadius: BorderRadius.circular(8),
                      hoverColor: Colors.white.withOpacity(0.1),
                      splashColor: Colors.white.withOpacity(0.2),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        child: Text(
                          _aplicaIva ? 'SIN IVA' : 'CON IVA',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Summary Panel
        isDesktop
            ? Expanded(
                child: PosSummaryPanel(
                  subtotal: cartState.subtotal,
                  impuesto: cartState.impuesto,
                  total: cartState.total,
                  onPagarPressed: _abrirCobro,
                  onLimpiarPressed: _reiniciarCarrito,
                ),
              )
            : PosSummaryPanel(
                subtotal: cartState.subtotal,
                impuesto: cartState.impuesto,
                total: cartState.total,
                onPagarPressed: _abrirCobro,
                onLimpiarPressed: _reiniciarCarrito,
              ),
        const SizedBox(height: 10),
        // Total en Bolívares
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL EN BOLÍVARES',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  Text(
                    'Tasa BCV aplicable',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              Text(
                'Bs. ${totalBs.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF34D399),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // BÚSQUEDA MÓVIL
  // ==========================================

  Widget _buildMobileSearchBar() {
    return RawAutocomplete<ProductoEntity>(
      textEditingController: _searchController,
      focusNode: _searchFocusNode,
      displayStringForOption: (option) => option.nombre,
      optionsBuilder: (textEditingValue) {
        if (textEditingValue.text.trim().isEmpty) {
          return const Iterable<ProductoEntity>.empty();
        }
        final query = textEditingValue.text.toLowerCase().trim();
        return _productosLocales.where((p) =>
            p.nombre.toLowerCase().contains(query) ||
            p.codigoBarras.toLowerCase().contains(query));
      },
      onSelected: (ProductoEntity selection) {
        _agregarProductoEntityAlCarrito(selection);
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Escanear o buscar...',
            prefixIcon: const Icon(Icons.qr_code_scanner),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: () => _buscarYAgregarProducto(controller.text),
            ),
          ),
          onSubmitted: (val) {
            onFieldSubmitted();
            _buscarYAgregarProducto(val);
          },
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            margin: const EdgeInsets.only(top: 4.0),
            constraints: const BoxConstraints(maxHeight: 280),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              clipBehavior: Clip.antiAlias,
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = options.elementAt(index);
                  return ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFF1F5F9),
                      radius: 16,
                      child: Icon(
                        item.esPesado ? Icons.scale : Icons.shopping_bag,
                        color: const Color(0xFF3B82F6),
                        size: 16,
                      ),
                    ),
                    title: Text(
                      item.nombre,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    subtitle: Text(
                      'Cód: ${item.codigoBarras}',
                      style: const TextStyle(fontSize: 11),
                    ),
                    trailing: Text(
                      '\$${item.precioUnidad.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFF059669),
                      ),
                    ),
                    onTap: () => onSelected(item),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // DRAWER MÓVIL
  // ==========================================

  Widget _buildMobileDrawer(bool cargandoBcv, double tasaBcv) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF0F172A)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  radius: 30,
                  child: Icon(Icons.person, size: 34),
                ),
                const SizedBox(height: 8),
                Text(_cajeroActual, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                Text('Rol: ${widget.usuarioActual.rol.toUpperCase()}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.currency_exchange, color: Color(0xFF38BDF8)),
                  title: Text(cargandoBcv ? 'Actualizando...' : 'BCV: Bs. ${tasaBcv.toStringAsFixed(2)}'),
                  onTap: () {
                    ref.read(bcvProvider).actualizarTasa();
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(
                    _ventasPendientesSync == 0 ? Icons.cloud_done_rounded : Icons.sync_rounded,
                    color: _ventasPendientesSync > 0 ? const Color(0xFFD97706) : const Color(0xFF059669),
                  ),
                  title: Text(_sincronizando ? 'Sincronizando...' : 'Sincronizar ($_ventasPendientesSync)'),
                  onTap: (_sincronizando || _ventasPendientesSync == 0) ? null : () {
                    Navigator.pop(context);
                    _sincronizarVentas();
                  },
                ),
                const Divider(),
                if (widget.usuarioActual.rol == 'admin')
                  ListTile(
                    leading: const Icon(Icons.monitor_heart_outlined, color: Color(0xFF38BDF8)),
                    title: const Text('Monitor de Cajeros'),
                    onTap: () {
                      Navigator.pop(context);
                      _mostrarEstadoCajeros(context);
                    },
                  ),
                if (widget.usuarioActual.rol == 'cajero')
                  ListTile(
                    leading: const Icon(Icons.coffee, color: Colors.orange),
                    title: const Text('Tomar Descanso'),
                    onTap: () async {
                      Navigator.pop(context);
                      await _registrarEstadoUsuario('descanso');
                      ref.read(lockProvider.notifier).manualRest();
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.point_of_sale),
                  title: const Text('Resumen de Caja'),
                  onTap: () {
                    Navigator.pop(context);
                    _mostrarDialogoCaja(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.inventory_2_outlined),
                  title: const Text('Catálogo Visual'),
                  onTap: () async {
                    Navigator.pop(context);
                    await Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => InventoryCatalogScreen(usuarioLogueado: widget.usuarioActual)),
                    );
                    _cargarProductosAutocompletado();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.print, color: Color(0xFF38BDF8)),
                  title: const Text('Impresora POS'),
                  onTap: () {
                    Navigator.pop(context);
                    _mostrarDialogoImpresora();
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.lock_reset, color: Color(0xFF8B5CF6)),
                  title: const Text('Cambiar mi Clave'),
                  onTap: () {
                    Navigator.pop(context);
                    _mostrarDialogoCambiarClave();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  onTap: () async {
                    await _registrarEstadoUsuario('inactivo');
                    ref.read(usuarioActualProvider.notifier).cerrarSesion();
                    if (mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
