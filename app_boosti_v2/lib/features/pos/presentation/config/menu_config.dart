// lib/features/pos/presentation/config/menu_config.dart
import 'package:flutter/material.dart';

import '../../data/Local/entities/usuario_entity.dart';
import '../../domain/permissions/roles.dart';
import '../providers/business_mode_provider.dart';
import '../screens/audit_log_screen.dart';
import '../screens/cash_closing_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/departamentos/departamentos_screen.dart';
import '../screens/empleados/employees_screen.dart';
import '../screens/gastos_screen.dart';
import '../screens/locales/locales_screen.dart';
import '../screens/lotes_screen.dart';
import '../screens/pedido/pedidos_screen.dart';
import '../screens/proveedores/proveedores_screen.dart';
import '../screens/restaurante/kds_screen.dart';
import '../screens/sales_history_screen.dart';
import '../screens/salon/salon_screen.dart';
import '../screens/telegram/telegram_config_screen.dart';
import '../screens/user_settings_screen.dart';
import '../screens/wholesale/wholesale_screen.dart';
import '../widgets/gestion_personal_dialog.dart';
import '../widgets/menu/diagnostico_lote_dialog.dart';
import '../widgets/monitor_empleado_widget.dart';
import '../widgets/printer_selection_widget.dart';
import '../screens/inventory_screen.dart';

// ═══════════════════════════════════════════════════════════════════════
// MODELOS DE MENÚ
// ═══════════════════════════════════════════════════════════════════════

class MenuOption {
  final String id;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  /// R.3.2 · Contador de la esquina (KDS).
  ///
  /// `null` = sin badge. `0` tampoco se dibuja: `PosMenuCard` exige
  /// `> 0` (`pos_menu_card.dart:178` y `:227`), así que una opción con
  /// 0 plazas libres queda visualmente idéntica a una sin contador.
  ///
  /// ⚠️ Es un `int?` y no un callback a propósito: `buildSections` es
  /// `static` y se ejecuta una vez por reconstrucción, no por frame.
  /// Quien lo pinta (el `Badge` del KDS) lo lee del provider.
  final int? badge;

  /// Color del badge. Si es `null`, `PosMenuCard` usa [color].
  ///
  /// Existe para que el KDS pueda ser verde (su color de sección) y aun
  /// así mostrar el contador en rojo de alerta.
  final Color? badgeColor;

  const MenuOption({
    required this.id,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.badge,
    this.badgeColor,
  });
}

class MenuSection {
  final String title;
  final Color color;
  final List<MenuOption> options;

  const MenuSection({
    required this.title,
    required this.color,
    required this.options,
  });

  MenuSection copyWith({List<MenuOption>? options}) => MenuSection(
        title: title,
        color: color,
        options: options ?? this.options,
      );
}

// ═══════════════════════════════════════════════════════════════════════
// CONSTRUCCIÓN DEL MENÚ
// ═══════════════════════════════════════════════════════════════════════

class MenuBuilder {
  /// Verifica si un rol puede ver una opción específica,
  /// **combinando** permisos de rol + feature flags del plan/modo.
  static bool puedeVerOpcion(
    UserRole role,
    String opcionId,
    FeatureFlags flags,
  ) {
    if (!_rolPermite(role, opcionId)) return false;
    return _flagPermite(opcionId, flags);
  }

  // ══════════════════════════════════════════════════════════════
  // FILTRO POR ROL (permisos de usuario)
  // ══════════════════════════════════════════════════════════════

  static bool _rolPermite(UserRole role, String opcionId) {
    return switch (opcionId) {
      'dashboard' => Permissions.canViewDashboard(role),
      'empleados' => Permissions.canAccessEmployees(role),
      'ventas' => Permissions.canViewDashboard(role),
      'gastos' => Permissions.canViewFinancials(role),
      'inventario' => Permissions.canAccessInventory(role),
      'lotes' => Permissions.canManageLotes(role),
      'pedidos' => Permissions.canAccessInventory(role),
      'proveedores' => Permissions.canAccessInventory(role),
      'locales' => Permissions.canManageLocales(role),
      'departamentos' => Permissions.canManageLocales(role),
      'personal' => Permissions.canManageUsers(role),
      'monitor' => Permissions.canViewEmployeeList(role),
      'caja' => Permissions.canOpenCashRegister(role),
      'telegram' => Permissions.canManageTelegram(role),
      'auditoria' => Permissions.canViewAuditLog(role),
      'backup' => Permissions.canAccessSettings(role),
      'configuracion' => Permissions.canAccessSettings(role),
      'impresoras' => true,
      'diagnostico' => Permissions.canManageLotes(role),
      'perfil' => true,
      'sync' => !Permissions.isEmployeesOnlyRole(role),
      'ventas_mayor' => Permissions.canAccessWholesale(role),
      'punto_venta' => Permissions.canAccessPos(role),
      'mesas' => Permissions.canAccessPos(role),
      'kds' => Permissions.canAccessPos(role),
      _ => true,
    };
  }

  // ══════════════════════════════════════════════════════════════
  // FILTRO POR FEATURE FLAGS (modo + plan)
  // ══════════════════════════════════════════════════════════════

  static bool _flagPermite(String opcionId, FeatureFlags flags) {
    return switch (opcionId) {
      // ── POS / Operación ──
      // Ventas al Mayor es un módulo B2B de retail. En restaurante la
      // venta es por mesa/comanda, sin lista mayorista que aplicar, así
      // que la pantalla se deja entera (tarifa,andas, descuentos por
      // cliente) sin nada que orchestrar.
      //
      // El criterio de QUÉ MODO lo admite vive en
      // `FeatureFlags.modoPermiteVentasMayor`, no como condición compuesta
      // aquí: así se puede cambiar sin volver a tocar el menú.
      'ventas_mayor' =>
        flags.ventasAlMayor && flags.modoPermiteVentasMayor,

      // Salón: solo tiene sentido en modo restaurante. El flag sale de
      // `FeatureFlags.requiereMesa`, que es `esRestaurante`.
      'mesas' => flags.requiereMesa,

      // KDS: misma puerta que el salón. En retail no hay comandas por
      // mesa, así que la pantalla no tendría nada que mostrar.
      'kds' => flags.requiereMesa,

      // ── Inventario ──
      'inventario' => flags.mostrarInventario,
      'lotes' => flags.mostrarLotes,
      'pedidos' => flags.pedidosProveedores && !flags.esServicios,
      // Antes: `!flags.esServicios` a secas. El plan básico veía
      // Proveedores aunque no lo contrate (2026-10-15).
      'proveedores' => flags.proveedores && !flags.esServicios,
      'diagnostico' => flags.mostrarLotes,

      // ── Reportes ──
      'dashboard' => flags.dashboard,
      'ventas' => flags.historialVentas,
      'gastos' => flags.historialGastos,

      // ── Personal ──
      'monitor' => flags.monitorEmpleados,

      // ── Configuración ──
      'locales' => flags.multiLocal,
      'departamentos' => flags.departamentos,
      'telegram' => flags.telegram,

      // ── Sin restricción por feature ──
      _ => true,
    };
  }

  // ══════════════════════════════════════════════════════════════
  // CONSTRUCCIÓN DE SECCIONES
  // ══════════════════════════════════════════════════════════════

  /// Construye todas las secciones del menú.
  ///
  /// NOTA: este método NO filtra por rol ni por flags. Devuelve
  /// TODAS las opciones posibles. El filtrado final se hace en
  /// `PosMenuScreen` con `puedeVerOpcion(role, id, flags)`.
  static List<MenuSection> buildSections({
    required UsuarioEntity usuario,
    required BuildContext context,
    required FeatureFlags flags,   // 🎯 NUEVO: solo para futuras extensiones
    required Future<void> Function() onCrearBackup,
    required Future<void> Function() onSincronizar,
    required int ventasPendientesSync,

    /// R.3.2 · Platos en cola de cocina, para el badge de la opción
    /// `'kds'`.
    ///
    /// ⚠️ Llega como `int?` y NO como provider: `buildSections` es
    /// `static` y no tiene `ref`. Quien lo lee es `PosMenuScreen`, con
    /// `comandasProvider.select((s) => s.totalItemsEnKds)` (devuelve
    /// `int` a propósito para que Riverpod no re-dispare en bucle).
    int? kdsBadge,
  }) {
    return [
      // ─────────────────────────────────────────────────────────────
      // INICIO
      //
      // Va primero a propósito: el POS es la acción que más se usa, y
      // antes no existía forma de volver a él desde este menú.
      //
      // `PosMenuScreen` se empuja con `Navigator.push` SOBRE el POS
      // (`catalog_app_bar.dart:174` y `main_pos_screen.dart:1569`), así
      // que `Navigator.pop()` devuelve al POS sin crear una ruta nueva.
      // Es la opción menos invasiva: no toca la pila de navegación.
      // ─────────────────────────────────────────────────────────────
      MenuSection(
        title: 'INICIO',
        color: const Color(0xFF10B981),
        options: [
          MenuOption(
            id: 'punto_venta',
            icon: Icons.point_of_sale_rounded,
            title: 'Punto de venta',
            subtitle: 'Vender productos y cobrar',
            color: const Color(0xFF10B981),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
      // ─────────────────────────────────────────────────────────────
      // OPERACIÓN
      // ─────────────────────────────────────────────────────────────
      MenuSection(
        title: 'OPERACIÓN',
        color: const Color(0xFF3B82F6),
        options: [
          MenuOption(
            id: 'mesas',
            icon: Icons.table_restaurant_rounded,
            title: 'Salón',
            subtitle: 'Mesas, estados y uniones',
            color: const Color(0xFF10B981),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SalonScreen()),
            ),
          ),
          // R.3.2 · KDS. Va pegado a "Salón" porque son las dos caras de
          // lo mismo: el salón mira la mesa, la cocina mira el plato.
          MenuOption(
            id: 'kds',
            icon: Icons.soup_kitchen_rounded,
            title: 'Estaciones',
            subtitle: 'Áreas de preparación',
            color: const Color(0xFF10B981),
            badge: kdsBadge,
            // El contador va en rojo aunque la opción sea verde: es una
            // alerta de trabajo pendiente, no un adorno de la sección.
            badgeColor: const Color(0xFFEF4444),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const KdsScreen()),
            ),
          ),
          MenuOption(
            id: 'ventas_mayor',
            icon: Icons.warehouse_rounded,
            title: 'Ventas al Mayor',
            subtitle: 'Ventas B2B con descuentos',
            color: const Color(0xFF8B5CF6),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WholesaleScreen()),
            ),
          ),
          MenuOption(
            id: 'caja',
            // Antes `Icons.point_of_sale_rounded`, el MISMO que "Punto de
            // venta" (menu_config.dart:234). En el menú se veían dos tiles
            // idénticos y no se distinguían.
            icon: Icons.savings_rounded,
            title: 'Cierre de caja',
            subtitle: 'Corte del día y arqueo',
            color: const Color(0xFF10B981),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CashClosingScreen()),
            ),
          ),
          MenuOption(
            id: 'ventas',
            icon: Icons.receipt_long_rounded,
            title: 'Historial de ventas',
            subtitle: 'Consulta y exporta ventas',
            color: const Color(0xFF3B82F6),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SalesHistoryScreen()),
            ),
          ),
          MenuOption(
            id: 'gastos',
            icon: Icons.payments_outlined,
            title: 'Gastos',
            subtitle: 'Registra gastos operativos',
            color: const Color(0xFFF59E0B),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GastosScreen()),
            ),
          ),
        ],
      ),

      // ─────────────────────────────────────────────────────────────
      // INVENTARIO
      // ─────────────────────────────────────────────────────────────
      MenuSection(
        title: 'INVENTARIO',
        color: const Color(0xFF8B5CF6),
        options: [
          MenuOption(
            id: 'inventario',
            icon: Icons.inventory_rounded,
            title: 'Productos',
            subtitle: 'Catálogo, precios y stock',
            color: const Color(0xFF14B8A6),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const InventoryScreen()),
            ),
          ),
          MenuOption(
            id: 'lotes',
            icon: Icons.inventory_2_outlined,
            title: 'Lotes y vencimientos',
            subtitle: 'Control de lotes por fecha',
            color: const Color(0xFF8B5CF6),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LotesScreen()),
            ),
          ),
          MenuOption(
            id: 'pedidos',
            icon: Icons.shopping_cart_rounded,
            title: 'Pedidos a proveedores',
            subtitle: 'Gestiona pedidos y recepciones',
            color: const Color(0xFFEC4899),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const PedidosProveedorScreen()),
            ),
          ),
          MenuOption(
            id: 'proveedores',
            icon: Icons.local_shipping_outlined,
            title: 'Proveedores',
            subtitle: 'Catálogo de proveedores',
            color: const Color(0xFF6366F1),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProveedoresScreen()),
            ),
          ),
        ],
      ),

      // ─────────────────────────────────────────────────────────────
      // ANÁLISIS
      // ─────────────────────────────────────────────────────────────
      MenuSection(
        title: 'ANÁLISIS',
        color: const Color(0xFF06B6D4),
        options: [
          MenuOption(
            id: 'dashboard',
            icon: Icons.dashboard_rounded,
            title: 'Dashboard',
            subtitle: 'Métricas y estadísticas',
            color: const Color(0xFF06B6D4),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DashboardScreen()),
            ),
          ),
          MenuOption(
            id: 'auditoria',
            icon: Icons.history_edu_rounded,
            title: 'Auditoría',
            subtitle: 'Log de acciones del sistema',
            color: const Color(0xFF64748B),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AuditLogScreen()),
            ),
          ),
        ],
      ),

      // ─────────────────────────────────────────────────────────────
      // PERSONAL
      // ─────────────────────────────────────────────────────────────
      MenuSection(
        title: 'PERSONAL',
        color: const Color(0xFF10B981),
        options: [
          MenuOption(
            id: 'empleados',
            icon: Icons.badge_rounded,
            title: 'Empleados',
            subtitle: 'Ficha completa y nómina',
            color: const Color(0xFF10B981),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EmployeesScreen()),
            ),
          ),
          MenuOption(
            id: 'personal',
            icon: Icons.people_alt_rounded,
            title: 'Gestión de personal',
            subtitle: 'Crear y editar usuarios',
            color: const Color(0xFF14B8A6),
            onTap: () => showDialog(
              context: context,
              builder: (_) => const PersonnelManagementDialog(),
            ),
          ),
          MenuOption(
            id: 'monitor',
            icon: Icons.visibility_rounded,
            title: 'Monitor de empleados',
            subtitle: 'Estado en tiempo real',
            color: const Color(0xFF0EA5E9),
            onTap: () => showDialog(
              context: context,
              builder: (_) => const EmployeeMonitorDialog(),
            ),
          ),
        ],
      ),

      // ─────────────────────────────────────────────────────────────
      // CONFIGURACIÓN
      // ─────────────────────────────────────────────────────────────
      MenuSection(
        title: 'CONFIGURACIÓN',
        color: const Color(0xFF64748B),
        options: [
          MenuOption(
            id: 'locales',
            icon: Icons.store_rounded,
            title: 'Locales',
            subtitle: 'Sucursales y multi-local',
            color: const Color(0xFF0EA5E9),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LocalesScreen()),
            ),
          ),
          MenuOption(
            id: 'departamentos',
            icon: Icons.business_center_rounded,
            title: 'Departamentos',
            subtitle: 'Organización interna',
            color: const Color(0xFF6366F1),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const DepartamentosScreen()),
            ),
          ),
          MenuOption(
            id: 'impresoras',
            icon: Icons.print_rounded,
            title: 'Impresoras',
            subtitle: 'Configurar dispositivos',
            color: const Color(0xFF8B5CF6),
            onTap: () => showDialog(
              context: context,
              builder: (_) => const PrinterSelectionDialog(),
            ),
          ),
          MenuOption(
            id: 'telegram',
            icon: Icons.telegram,
            title: 'Bot de Telegram',
            subtitle: 'Notificaciones al móvil',
            color: const Color(0xFF0EA5E9),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const TelegramConfigScreen()),
            ),
          ),
          MenuOption(
            id: 'diagnostico',
            icon: Icons.build_circle_outlined,
            title: 'Diagnóstico de lotes',
            subtitle: 'Verifica integridad de inventario',
            color: const Color(0xFFEF4444),
            onTap: () => showDialog(
              context: context,
              builder: (_) => const DiagnosticoLotesDialog(),
            ),
          ),
          MenuOption(
            id: 'backup',
            icon: Icons.cloud_upload_rounded,
            title: 'Backup',
            subtitle: 'Respaldo de la base local',
            color: const Color(0xFF10B981),
            onTap: onCrearBackup,
          ),
        ],
      ),

      // ─────────────────────────────────────────────────────────────
      // MI CUENTA
      // ─────────────────────────────────────────────────────────────
      MenuSection(
        title: 'MI CUENTA',
        color: const Color(0xFF8B5CF6),
        options: [
          MenuOption(
            id: 'sync',
            icon: Icons.cloud_sync_rounded,
            title: 'Sincronizar ahora',
            subtitle: ventasPendientesSync > 0
                ? '$ventasPendientesSync pendientes'
                : 'Todo al día',
            color: const Color(0xFF3B82F6),
            onTap: onSincronizar,
          ),
          MenuOption(
            id: 'perfil',
            icon: Icons.person_rounded,
            title: 'Mi perfil',
            subtitle: 'Ajustes personales',
            color: const Color(0xFF8B5CF6),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UserSettingsScreen()),
            ),
          ),
        ],
      ),
    ];
  }
}