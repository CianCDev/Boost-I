import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'package:uuid/uuid.dart';

// Entidades locales (solo para firmas de métodos)
import '../../data/Local/entities/categoria_entity.dart';
import '../../data/Local/entities/gasto_entity.dart';
import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/producto_entity.dart';
import '../../data/Local/entities/venta_entity.dart';
import '../../data/Local/entities/movimiento_inventario_entity.dart';
import '../../data/Local/entities/usuario_entity.dart';
import '../../data/Local/entities/turno_entity.dart';
import '../../data/Local/entities/detalle_venta_entity.dart';
import '../../data/Local/entities/proveedor_entity.dart';
import '../../data/Local/entities/recepcion_entity.dart';
import '../../data/Local/entities/pedido_entity.dart';
import '../../data/Local/entities/detalle_pedido_entity.dart';
import '../../data/Local/entities/local_entity.dart';
import '../../data/Local/entities/departamento_entity.dart';
import '../../data/Local/entities/telegram_config_entity.dart';
import '../../data/Local/entities/marca_entity.dart';
import '../../data/Local/entities/movimiento_lote_entity.dart';
import '../../data/Local/entities/cliente_entity.dart';

/// Servicio de sincronización. 
/// ⚠️ MÉTODOS VACIADOS PARA COMPILAR EN WEB. 
/// La lógica de nube se implementará cuando se configure Supabase.
class SyncService {
  final IsarService _isarService = IsarService();
  final Connectivity _connectivity = Connectivity();
  // Ignoramos el uso del cliente para evitar problemas si no está inicializado
  // final SupabaseClient _supabase = Supabase.instance.client; // Comentado para evitar crash

  String _syncServerUrl = 'https://your-sync-server.example';
  String _syncApiKey = '<REPLACE_WITH_SYNC_API_KEY>';

  bool _configLoaded = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isSyncing = false;

  // Callbacks
  final VoidCallback? onDataChanged;

  SyncService({this.onDataChanged});

  // ============================================================
  // SUSCRIPCIONES REALTIME Y CALLBACK
  // ============================================================
  final List<RealtimeChannel> _channels = [];

  void iniciarSuscripcionesRealtime() {
    debugPrint('✅ (Vaciado) Suscripciones Realtime deshabilitadas en Web');
  }

  void _suscribirATabla(String tabla, Future<void> Function() onCambio) {
    // Vacío
  }

  void detenerSuscripcionesRealtime() {
    // Vacío
  }

  // ============================================================
  // CONFIGURACIÓN Y MONITOREO
  // ============================================================

  Map<String, String> _authHeaders() => {};

  bool _hasValidSyncConfig() => false;

  Future<void> _loadConfig() async {
    // Vacío
  }

  void iniciarMonitoreo() {
    // Vacío
  }

  void detenerMonitoreo() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  void dispose() {
    detenerMonitoreo();
    detenerSuscripcionesRealtime();
  }

  // ============================================================
  // USUARIOS (Vacío pero seguro)
  // ============================================================

  Future<void> sincronizarUsuariosASupabase() async {
    debugPrint('⚠️ SyncService: sincronizarUsuariosASupabase vacío');
  }

  Future<void> sincronizarUsuariosDesdeSupabase() async {
    debugPrint('⚠️ SyncService: sincronizarUsuariosDesdeSupabase vacío');
  }

  Future<List<Map<String, dynamic>>> obtenerUsuariosDesdeSupabase() async => [];

  Future<bool> actualizarEstadoUsuarioEnSupabase(int userId, String nuevoEstado) async => false;

  Future<bool> eliminarUsuarioEnSupabase(int userId) async => false;

  Stream<List<UsuarioEntity>> streamUsuariosEnTiempoReal() {
    return const Stream.empty();
  }

  // ============================================================
  // PROVEEDORES
  // ============================================================

  Future<void> sincronizarProveedoresPendientes() async {}
  Future<void> descargarProveedoresDesdeSupabase() async {}
  Future<bool> eliminarProveedorEnSupabase(String supabaseId) async => false;

  // ============================================================
  // PRODUCTOS
  // ============================================================

  double _limpiarNumero(double? valor, [double valorPorDefecto = 0.0]) => valor ?? valorPorDefecto;

  Future<bool> sincronizarProductosASupabase() async => false;
  Future<void> descargarProductosDesdeSupabase() async {}
  Future<bool> eliminarProductoEnSupabase(String codigoBarras) async => false;

  // ============================================================
  // VENTAS
  // ============================================================

  Future<int> sincronizarVentasPendientes() async => 0;
  Future<bool> _enviarVentaAlServidor(VentaEntity venta) async => false;
  Map<String, dynamic> _ventaToJson(VentaEntity venta) => {};
  Map<String, dynamic> _detalleToJson(DetalleVentaEntity detalle) => {};
  Future<void> descargarVentasDesdeSupabase() async {}

  // ============================================================
  // MOVIMIENTOS DE INVENTARIO
  // ============================================================

  Future<int> sincronizarMovimientosInventario() async => 0;
  Future<bool> _enviarMovimientoAlServidor(MovimientoInventarioEntity mov) async => false;

  // ============================================================
  // CATEGORÍAS
  // ============================================================

  Future<void> sincronizarCategorias() async {}
  Future<void> descargarCategoriasDesdeSupabase() async {}

  // ============================================================
  // MARCAS
  // ============================================================

  Future<void> sincronizarMarcasPendientes() async {}
  Future<bool> _enviarMarcaAlServidor(MarcaEntity marca) async => false;
  Future<void> descargarMarcasDesdeSupabase() async {}

  // ============================================================
  // GASTOS
  // ============================================================

  Future<void> descargarGastosDesdeSupabase() async {}
  Future<int> sincronizarGastosPendientes() async => 0;
  Future<bool> _enviarGastoAlServidor(GastoEntity gasto) async => false;

  // ============================================================
  // TURNOS
  // ============================================================

  Future<int> sincronizarTurnos() async => 0;
  Future<bool> _enviarTurnoAlServidor(TurnoEntity turno) async => false;

  // ============================================================
  // LOCALES
  // ============================================================

  Future<void> sincronizarLocalesPendientes() async {}
  Future<void> descargarLocalesDesdeSupabase() async {}

  // ============================================================
  // DEPARTAMENTOS
  // ============================================================

  Future<void> sincronizarDepartamentosPendientes() async {}
  Future<void> descargarDepartamentosDesdeSupabase() async {}

  // ============================================================
  // CLIENTES
  // ============================================================

  Future<void> sincronizarClientesPendientes() async {}
  Future<void> descargarClientesDesdeSupabase() async {}
  Future<bool> eliminarClienteEnSupabase(String supabaseId) async => false;

  // ============================================================
  // CÓDIGOS DE BARRAS ALIAS
  // ============================================================

  Future<void> sincronizarAliasPendientes() async {}

  // ============================================================
  // LOTES
  // ============================================================

  Future<void> sincronizarLotesPendientes() async {}

  // ============================================================
  // MOVIMIENTOS DE LOTE
  // ============================================================

  Future<void> sincronizarMovimientosLotePendientes() async {}
  Future<void> descargarMovimientosLoteDesdeSupabase() async {}

  // ============================================================
  // TELEGRAM CONFIG
  // ============================================================

  Future<void> sincronizarTelegramConfigPendientes() async {}
  Future<void> descargarTelegramConfigDesdeSupabase() async {}

  // ============================================================
  // PEDIDOS
  // ============================================================

  Future<void> sincronizarPedidosPendientes() async {}
  Future<void> descargarPedidosDesdeSupabase() async {}

  // ============================================================
  // MÉTODOS AUXILIARES
  // ============================================================

  Future<String?> _obtenerSupabaseIdLocal(int isarId) async => null;
  Future<String?> _obtenerSupabaseIdUsuario(int isarId) async => null;
  Future<String?> _obtenerSupabaseIdProducto(int isarId) async => null;
  Future<int> _obtenerIsarIdLocal(String supabaseId) async => 0;
  Future<int> _obtenerIsarIdUsuario(String supabaseId) async => 0;
  Future<int> _obtenerIsarIdProducto(String supabaseId) async => 0;
  Future<String?> _obtenerLocalActualUuid() async => null;

  // ============================================================
  // REPARACIÓN DE IMÁGENES
  // ============================================================

  Future<int> repararImagenesFaltantes() async => 0;

  // ============================================================
  // SINCRONIZACIÓN COMPLETA
  // ============================================================

  Future<void> sincronizarTodo() async {
    debugPrint('🔄 [SyncService] (Vacío) Sincronización completa no implementada en Web');
    onDataChanged?.call();
  }

  Future<Map<String, int>> sincronizarTodoConResumen() async => {
        'ventas': 0,
        'productos': 0,
        'proveedores': 0,
        'gastos': 0,
        'pedidos': 0,
        'lotes': 0,
        'marcas': 0,
        'locales': 0,
        'departamentos': 0,
        'telegram': 0,
      };
}