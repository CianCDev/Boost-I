import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/product_item.dart';
import '../controllers/cart_controller.dart';
import '../providers/bcv_provider.dart';
import '../services/ticket_service.dart';
import '../widgets/cart_table_widget.dart';
import '../widgets/cobrar_dialog.dart';
import '../widgets/pos_summary_panel.dart';
import '../widgets/scale_visor_widget.dart';
import 'sales_history_screen.dart' as sales_history_screen;
import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/venta_entity.dart';
import '../../data/Local/entities/producto_entity.dart';
import '../../data/Local/entities/usuario_entity.dart';
import 'inventory_screen.dart';
import 'inventory_catalog_screen.dart';
import 'login_screen.dart';
import '../providers/lock_provider.dart';

class PosDesktopScreen extends ConsumerStatefulWidget {
  final UsuarioEntity usuarioActual;
  const PosDesktopScreen({super.key, required this.usuarioActual});

  @override
  ConsumerState<PosDesktopScreen> createState() => _PosDesktopScreenState();
}

class _PosDesktopScreenState extends ConsumerState<PosDesktopScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final IsarService _isarService = IsarService();

  late final String _cajeroActual;
  final String _turnoActual = "Turno Activo (Caja Principal)";

  List<ProductoEntity> _productosLocales = [];
  int _ventasPendientesSync = 0;
  bool _sincronizando = false;
  final double _pesoBalanzaActual = 0.000;

  @override
  void initState() {
    super.initState();
    _cajeroActual = widget.usuarioActual.nombre;

    HardwareKeyboard.instance.addHandler(_manejarTecladoFisico);
    _cargarProductosAutocompletado();
    _actualizarContadorSync();
    _registrarEstadoUsuario('activo');
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bcvProvider).actualizarTasa();
    });
  }

  /// Actualiza el estado operativo del usuario en Isar DB y Supabase
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

  /// Ejecuta la sincronización offline-first de ventas con Supabase
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
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final p = productosBajos[index];
                      return ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFFEE2E2),
                          child: Icon(Icons.inventory_2, color: Colors.red, size: 20),
                        ),
                        title: Text(p.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        subtitle: Text('Código: ${p.codigoBarras} | Proveedor: ${p.proveedorNombre.isEmpty ? "No asignado" : p.proveedorNombre}', style: const TextStyle(fontSize: 11)),
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
                  MaterialPageRoute(builder: (context) => InventoryScreen(usuarioActual: widget.usuarioActual)),
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

  /// Módulo para que el usuario activo cambie su propio PIN
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
                      // Llamamos a IsarService para guardar la nueva clave
                      final exito = await _isarService.cambiarClaveUsuario(widget.usuarioActual.id, nuevaClave);

                      if (context.mounted) {
                        if (exito) {
                          widget.usuarioActual.pin = nuevaClave; // Actualizar localmente para la sesión
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
                          const SnackBar(content: Text('Asegúrate de agregar cambiarClaveUsuario() en IsarService.'), backgroundColor: Colors.red),
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

  /// Monitor de Cajeros conectado dinámicamente a la Base de Datos Isar DB
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
                  separatorBuilder: (_, __) => const Divider(height: 1),
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
                          color: colorEstado.withOpacity(0.1),
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

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_manejarTecladoFisico);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  bool _manejarTecladoFisico(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.f2) {
        _enfocarBuscador();
        return true;
      }
      if (event.logicalKey == LogicalKeyboardKey.f12) {
        _abrirCobro();
        return true;
      }
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        ref.read(cartProvider.notifier).limpiarCarrito();
        _enfocarBuscador();
        return true;
      }
    }
    return false;
  }

  void _enfocarBuscador() {
    _searchFocusNode.requestFocus();
    _searchController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _searchController.text.length,
    );
  }

  Future<void> _abrirCobro() async {
    final cartState = ref.read(cartProvider);
    if (cartState.total <= 0) return;
    double tasaActual = ref.read(bcvProvider).tasa;
    if (tasaActual.isNaN || tasaActual <= 0) {
      tasaActual = 0.0;
    }

    final resultado = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CobrarDialog(
        totalAPagar: cartState.total,
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
          ..cedulaCliente = resultado['cedulaCliente'] ?? 'V-00000000'
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

        await TicketService.generarYProcesarPdf(
          items: ticketItems,
          subtotal: cartState.subtotal,
          impuesto: cartState.impuesto,
          total: cartState.total,
          metodoPago: resultado['metodoPago'],
          montoRecibido: resultado['montoRecibido'],
          vuelto: resultado['vuelto'],
          fechaVenta: ahora,
        );

        ref.read(cartProvider.notifier).limpiarCarrito();
        _enfocarBuscador();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Venta registrada con éxito con tasa BCV e importe en Bs.! 🎉'),
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

            final double totalTarjeta = ventasDelDia
                .where((v) => v.metodoPago.toLowerCase() == 'tarjeta')
                .fold(0.0, (sum, v) => sum + v.total);

            final double totalOtros = ventasDelDia
                .where((v) =>
                    v.metodoPago.toLowerCase() != 'efectivo' &&
                    v.metodoPago.toLowerCase() != 'tarjeta')
                .fold(0.0, (sum, v) => sum + v.total);

            final double granTotal =
                ventasDelDia.fold(0.0, (sum, v) => sum + v.total);

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.point_of_sale, color: Color(0xFF0F172A)),
                      SizedBox(width: 8),
                      Text(
                        'Caja del Día',
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
                width: 400,
                child: snapshot.connectionState == ConnectionState.waiting
                    ? const SizedBox(
                        height: 120,
                        child: Center(child: CircularProgressIndicator(color: Color(0xFF10B981))),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _filaDetalleCaja('Efectivo', totalEfectivo, Icons.payments_outlined, const Color(0xFF10B981)),
                          const SizedBox(height: 10),
                          _filaDetalleCaja('Tarjeta', totalTarjeta, Icons.credit_card, const Color(0xFF3B82F6)),
                          const SizedBox(height: 10),
                          _filaDetalleCaja('Otros / Transf.', totalOtros, Icons.qr_code, const Color(0xFF8B5CF6)),
                          const Divider(height: 24),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'TOTAL EN CAJA',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                Text(
                                  '\$${granTotal.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Color(0xFF34D399),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
              actions: [
                if (widget.usuarioActual.rol == 'admin')
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.analytics_outlined, size: 18),
                    label: const Text('Ver Registro y Auditoría', style: TextStyle(fontWeight: FontWeight.bold)),
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

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final bcvController = ref.watch(bcvProvider);
    final double tasaBcv = bcvController.tasa;
    final bool cargandoBcv = bcvController.cargando;
    final double totalBs = cartState.total * tasaBcv;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        title: const Text(
          'app_gestion_m — POS Caja 01',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
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
          if (widget.usuarioActual.rol == 'admin')
            IconButton(
              icon: const Icon(Icons.monitor_heart_outlined, color: Color(0xFF38BDF8)),
              tooltip: 'Monitor de Cajeros',
              onPressed: () => _mostrarEstadoCajeros(context),
            ),
          Tooltip(
            message: _ventasPendientesSync == 0
                ? 'Todo sincronizado con el servidor'
                : '$_ventasPendientesSync ventas pendientes (Haz clic para sincronizar)',
            child: InkWell(
              onTap: _sincronizarVentas,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: _ventasPendientesSync == 0 ? const Color(0xFF064E3B) : const Color(0xFF78350F),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _ventasPendientesSync == 0 ? const Color(0xFF059669) : const Color(0xFFD97706),
                  ),
                ),
                child: Row(
                  children: [
                    _sincronizando
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.amber),
                          )
                        : Icon(
                            _ventasPendientesSync == 0 ? Icons.cloud_done_outlined : Icons.cloud_upload_outlined,
                            size: 18,
                            color: _ventasPendientesSync == 0 ? const Color(0xFF34D399) : Colors.amber,
                          ),
                    if (_ventasPendientesSync > 0) ...[
                      const SizedBox(width: 6),
                      Text(
                        '$_ventasPendientesSync',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
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
          IconButton(
            icon: const Icon(Icons.point_of_sale),
            tooltip: 'Ver Resumen de Caja y Turno',
            onPressed: () => _mostrarDialogoCaja(context),
          ),
          IconButton(
            icon: const Icon(Icons.inventory_2_outlined),
            tooltip: 'Abrir Catálogo Visual',
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => InventoryCatalogScreen(usuarioActual: widget.usuarioActual),
                ),
              );
              _cargarProductosAutocompletado();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(cartProvider.notifier).limpiarCarrito();
              _enfocarBuscador();
            },
            tooltip: 'Reiniciar Venta (Esc)',
          ),
          const VerticalDivider(color: Colors.white24, indent: 12, endIndent: 12, width: 20),
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
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
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
                        autofocus: true,
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
                              separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
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
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Expanded(
                    child: PosSummaryPanel(
                      subtotal: cartState.subtotal,
                      impuesto: cartState.impuesto,
                      total: cartState.total,
                      onPagarPressed: _abrirCobro,
                      onLimpiarPressed: () {
                        ref.read(cartProvider.notifier).limpiarCarrito();
                        _enfocarBuscador();
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}