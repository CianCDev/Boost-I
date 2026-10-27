// lib/features/pos/presentation/utils/home_por_rol.dart
//
// Punto ÚNICO donde se decide en qué pantalla aterriza un usuario.
//
// ⚠️ POR QUÉ EXISTE
//
// La decisión estaba duplicada en tres sitios (`app.dart:_homeInicial`,
// `login_screen.redirigirSegunRol` y `splash_screen._decidirNavegacion`),
// cada uno con su propio `Permissions.isEmployeesOnlyRole`. Al añadir el
// aterrizaje del cajero en la caja, tres copias habrían significado tres
// reglas que se desincronizan: una pantalla nueva se agregaba en una y no
// en las otras dos.
//
// ⚠️ POR QUÉ RECIBE `FeatureFlags` Y NO EL `BusinessMode`
//
// Regla del proyecto (AGENTS.md §6.2): la UI no compara
// `mode == 'restaurante'` a mano, consulta `flags.requiereMesa`. Ese getter
// es el que puede cambiar de criterio sin tocar las pantallas.
import 'package:flutter/widgets.dart';

import '../../data/Local/entities/usuario_entity.dart';
import '../../domain/permissions/roles.dart';
import '../providers/business_mode_provider.dart';
import '../screens/caja/caja_screen.dart';
import '../screens/empleados/employees_screen.dart';
import '../screens/main_pos_screen.dart';

/// Pantalla inicial que corresponde a [usuario].
///
/// Orden de las reglas:
///   1. Roles de solo-personal (RRHH) → `EmployeesScreen`. Mandan sobre
///      todo lo demás: ese rol no opera el POS.
///   2. Cajero en un local con mesas → `CajaScreen`. Es su puesto de
///      trabajo; obligarlo a buscar "Caja" en el menú agrega dos toques a
///      cada cobro.
///   3. Resto → `MainPosScreen`.
///
/// El cajero en modo retail NO va a la caja: ahí no hay comandas, el cobro
/// se hace con el carrito del propio POS.
Widget destinoInicialPorRol({
  required UsuarioEntity usuario,
  required FeatureFlags flags,
}) {
  final role = UserRole.fromString(usuario.rol);

  if (Permissions.isEmployeesOnlyRole(role)) {
    return const EmployeesScreen();
  }

  if (role == UserRole.cajero && flags.requiereMesa) {
    return const CajaScreen();
  }

  return const MainPosScreen();
}
