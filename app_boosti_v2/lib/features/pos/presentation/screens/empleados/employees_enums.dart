// lib/features/pos/presentation/screens/empleados/employees_enums.dart
import 'package:flutter/material.dart';
import '../../../data/Local/entities/usuario_entity.dart';
// ═══════════════════════════════════════════════════════════════
// ENUMS + EXTENSIONS DE LA PANTALLA DE EMPLEADOS
// ═══════════════════════════════════════════════════════════════

enum EmployeeTab { empleados, monitor }
enum EmployeeView { detailed, compact }
enum EmployeeFilter { todos, activos, inactivos, descanso, sinPin }
enum EmployeeSort { nombre, estado }

extension EmployeeFilterX on EmployeeFilter {
  String get label => switch (this) {
        EmployeeFilter.todos => 'Todos',
        EmployeeFilter.activos => 'Activos',
        EmployeeFilter.inactivos => 'Inactivos',
        EmployeeFilter.descanso => 'En descanso',
        EmployeeFilter.sinPin => 'Sin PIN',
      };
  IconData get icon => switch (this) {
        EmployeeFilter.todos => Icons.groups_rounded,
        EmployeeFilter.activos => Icons.check_circle_rounded,
        EmployeeFilter.inactivos => Icons.block_rounded,
        EmployeeFilter.descanso => Icons.free_breakfast_rounded,
        EmployeeFilter.sinPin => Icons.password_rounded,
      };
  Color get color => switch (this) {
        EmployeeFilter.todos => const Color(0xFF3B82F6),
        EmployeeFilter.activos => const Color(0xFF10B981),
        EmployeeFilter.inactivos => const Color(0xFFEF4444),
        EmployeeFilter.descanso => const Color(0xFFF59E0B),
        EmployeeFilter.sinPin => const Color(0xFFEC4899),
      };
}

extension EmployeeSortX on EmployeeSort {
  String get label => switch (this) {
        EmployeeSort.nombre => 'Nombre (A-Z)',
        EmployeeSort.estado => 'Estado',
      };
  IconData get icon => switch (this) {
        EmployeeSort.nombre => Icons.sort_by_alpha_rounded,
        EmployeeSort.estado => Icons.circle_outlined,
      };
}

// ═══════════════════════════════════════════════════════════════
// HELPERS DE ESTADO (funciones puras)
// ═══════════════════════════════════════════════════════════════



String estadoEfectivo(UsuarioEntity u) {
  final e = u.estado.toLowerCase().trim();
  if (e == 'descanso') return 'descanso';
  if (e == 'inactivo') return 'inactivo';
  if (e == 'desconectado') return 'inactivo';
  if (!u.activo) return 'inactivo';
  return 'activo';
}

int estadoOrden(UsuarioEntity u) => switch (estadoEfectivo(u)) {
      'activo' => 0,
      'descanso' => 1,
      _ => 2,
    };

String labelEstado(UsuarioEntity u) => switch (estadoEfectivo(u)) {
      'inactivo' => 'Inactivo',
      'descanso' => 'En descanso',
      _ => 'Activo',
    };