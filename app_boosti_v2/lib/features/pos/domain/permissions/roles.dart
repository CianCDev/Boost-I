// lib/features/pos/domain/permissions/roles.dart

/// Roles del sistema. El string debe coincidir con el valor almacenado
/// en `usuarios.rol` (Supabase) y `UsuarioEntity.rol` (Isar).
enum UserRole {
  admin('admin'),
  supervisor('supervisor'),
  rrhh('rrhh'),
  cajero('cajero'),
  auditor('auditor'),
  almacen('almacen'),
  dev('dev'),
  soporte('soporte');

  final String value;
  const UserRole(this.value);

  /// Parser robusto: si el string no coincide, cae a `cajero` (rol más
  /// restrictivo). Esto evita crash por roles nuevos aún no mapeados.
  static UserRole fromString(String? raw) {
    if (raw == null || raw.isEmpty) return UserRole.cajero;
    final lower = raw.toLowerCase().trim();
    return UserRole.values.firstWhere(
      (r) => r.value == lower,
      orElse: () => UserRole.cajero,
    );
  }

  /// Nombre legible para UI.
  String get label {
    switch (this) {
      case UserRole.admin:      return 'Administrador';
      case UserRole.supervisor: return 'Supervisor';
      case UserRole.rrhh:       return 'Recursos Humanos';
      case UserRole.cajero:     return 'Cajero';
      case UserRole.auditor:    return 'Auditor';
      case UserRole.almacen:    return 'Almacén';
      case UserRole.dev:        return 'Desarrollo';
      case UserRole.soporte:    return 'Soporte';
    }
  }
}

/// Evaluación centralizada de permisos.
///
/// Regla de oro: **nunca** comparar `rol == 'admin'` directo en el
/// codebase. Siempre pasar por aquí. Si mañana cambia la política de un
/// rol, se edita en un solo lugar.
class Permissions {
  Permissions._(); // No instanciable

  // ══════════════════════════════════════════════════════════════
  // MÓDULO: EMPLEADOS
  // ══════════════════════════════════════════════════════════════

  /// Acceso completo al módulo (listar, ver ficha, editar, nómina).
  static bool canAccessEmployees(UserRole r) =>
      r == UserRole.admin || r == UserRole.supervisor || r == UserRole.rrhh;

  /// Ver el listado general de empleados (aunque sea solo lectura).
  static bool canViewEmployeeList(UserRole r) =>
      canAccessEmployees(r) || r == UserRole.auditor || r == UserRole.dev;

  /// Ver la ficha completa de cualquier empleado.
  static bool canViewEmployeeDetail(UserRole r) =>
      canAccessEmployees(r) || r == UserRole.auditor || r == UserRole.dev;

  /// Ver datos salariales (base, comisiones, bonos, nómina).
  static bool canViewEmployeeSalary(UserRole r) =>
      r == UserRole.admin || r == UserRole.rrhh;

  /// Ver estadísticas de ventas del empleado.
  static bool canViewEmployeeSales(UserRole r) =>
      canAccessEmployees(r) || r == UserRole.auditor;

  /// Editar datos de perfil (nombre, cédula, teléfono, foto).
  static bool canEditEmployeeBasicInfo(UserRole r) =>
      r == UserRole.admin || r == UserRole.rrhh;

  /// Editar datos laborales (cargo, contrato, supervisor).
  static bool canEditEmployeeContract(UserRole r) =>
      r == UserRole.admin || r == UserRole.rrhh;

  /// Editar salario, comisiones, bonos.
  static bool canEditEmployeeSalary(UserRole r) =>
      r == UserRole.admin || r == UserRole.rrhh;

  /// Editar horario y días libres.
  static bool canEditEmployeeSchedule(UserRole r) =>
      r == UserRole.admin || r == UserRole.supervisor || r == UserRole.rrhh;

  /// Procesar/registrar pagos de nómina.
  static bool canProcessPayroll(UserRole r) =>
      r == UserRole.admin || r == UserRole.rrhh;

  /// Eliminar (soft delete) empleados.
  static bool canDeleteEmployee(UserRole r) => r == UserRole.admin;

  /// Gestionar horarios base (crear/editar modelos de horario).
  static bool canManageSchedules(UserRole r) =>
      r == UserRole.admin || r == UserRole.rrhh;

       /// Puede acceder al módulo de Ventas al Mayor.
  ///
  /// Solo admin, supervisor y cajero. Otros roles quedan fuera.
  static bool canAccessWholesale(UserRole role) {
    return role == UserRole.admin ||
        role == UserRole.supervisor ||
        role == UserRole.cajero;
  }

  // ══════════════════════════════════════════════════════════════
  // MÓDULO: POS / VENTAS
  // ══════════════════════════════════════════════════════════════

  static bool canAccessPos(UserRole r) =>
      r == UserRole.admin ||
      r == UserRole.supervisor ||
      r == UserRole.cajero;

  static bool canVoidSale(UserRole r) =>
      r == UserRole.admin || r == UserRole.supervisor;

  static bool canApplySpecialDiscount(UserRole r) =>
      r == UserRole.admin || r == UserRole.supervisor;

  static bool canOpenCashRegister(UserRole r) =>
      r == UserRole.admin ||
      r == UserRole.supervisor ||
      r == UserRole.cajero;

  // ══════════════════════════════════════════════════════════════
  // MÓDULO: INVENTARIO
  // ══════════════════════════════════════════════════════════════

  static bool canAccessInventory(UserRole r) =>
      r == UserRole.admin ||
      r == UserRole.supervisor ||
      r == UserRole.almacen ||
      r == UserRole.auditor;

  static bool canEditProducts(UserRole r) =>
      r == UserRole.admin || r == UserRole.almacen;

  static bool canDeleteProducts(UserRole r) => r == UserRole.admin;

  static bool canManageLotes(UserRole r) =>
      r == UserRole.admin || r == UserRole.almacen;

  // ══════════════════════════════════════════════════════════════
  // MÓDULO: DASHBOARD / REPORTES
  // ══════════════════════════════════════════════════════════════

  static bool canViewDashboard(UserRole r) =>
      r != UserRole.cajero && r != UserRole.soporte;

  static bool canViewFinancials(UserRole r) =>
      r == UserRole.admin || r == UserRole.auditor;

  static bool canExportReports(UserRole r) =>
      r == UserRole.admin || r == UserRole.auditor || r == UserRole.rrhh;

  // ══════════════════════════════════════════════════════════════
  // MÓDULO: CONFIGURACIÓN
  // ══════════════════════════════════════════════════════════════

  static bool canAccessSettings(UserRole r) => r == UserRole.admin;

  static bool canManageLocales(UserRole r) => r == UserRole.admin;

  static bool canManageUsers(UserRole r) =>
      r == UserRole.admin || r == UserRole.rrhh;

  static bool canManageTelegram(UserRole r) => r == UserRole.admin;

  static bool canViewAuditLog(UserRole r) =>
      r == UserRole.admin || r == UserRole.auditor;

  // ══════════════════════════════════════════════════════════════
  // ROUTING POST-LOGIN
  // ══════════════════════════════════════════════════════════════

  /// Roles cuyo acceso está limitado exclusivamente al módulo de
  /// empleados. Al hacer login, se les redirige directamente ahí.
  static bool isEmployeesOnlyRole(UserRole r) => r == UserRole.rrhh;

  /// Pantalla inicial sugerida tras login según el rol.
  /// `null` significa "usar el flujo por defecto (POS)".
  static EmployeesOnlyRoute? employeesOnlyRoute(UserRole r) {
    if (r == UserRole.rrhh) return EmployeesOnlyRoute.employees;
    return null;
  }
}

/// Enum auxiliar para que el router sepa a dónde redirigir.
enum EmployeesOnlyRoute { employees }

extension UsuarioRolX on dynamic {
  // El `dynamic` permite usarlo con UsuarioEntity sin import circular.
  // En su lugar, puedes importar UsuarioEntity arriba y tipar bien.
  
  UserRole get rolEnum => UserRole.fromString(this.rol as String?);
  bool get esAdmin => rolEnum == UserRole.admin;
  bool get esSupervisor => rolEnum == UserRole.supervisor;
  bool get esRrhh => rolEnum == UserRole.rrhh;
}