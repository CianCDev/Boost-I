// lib/features/pos/presentation/utils/post_login_router.dart
import 'package:flutter/material.dart';

import '../../data/Local/entities/usuario_entity.dart';
import '../../domain/permissions/roles.dart';

/// Navegación post-login según rol.
///
/// Centraliza la decisión de a dónde va cada usuario tras autenticarse.
/// Si añades roles restringidos en el futuro, solo tocas este archivo.
class PostLoginRouter {
  PostLoginRouter._();

  static void redirect(BuildContext context, UsuarioEntity usuario) {
    final role = UserRole.fromString(usuario.rol);
    final route = _routeFor(role);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => route),
    );
  }

  static Widget _routeFor(UserRole role) {
    // Roles con acceso restringido: van directo a su única pantalla.
    if (Permissions.isEmployeesOnlyRole(role)) {
      // TODO Fase 2: reemplazar por `EmployeesScreen()` real.
      return const _EmployeesPlaceholderScreen();
    }

    // Resto → POS por defecto.
    return const _PosRootPlaceholderScreen();
  }
}

/// Placeholder temporal mientras se construye `EmployeesScreen` en Fase 2.
/// Al terminar el módulo, eliminar este widget.
class _EmployeesPlaceholderScreen extends StatelessWidget {
  const _EmployeesPlaceholderScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Módulo de Empleados')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.construction_rounded, size: 64),
              SizedBox(height: 16),
              Text(
                'Módulo de Empleados',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Disponible en la próxima actualización.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Placeholder que apunta al root del POS. Reemplaza por tu navegación
/// real (probablemente `InventoryCatalogScreen` o `MainPosScreen`).
class _PosRootPlaceholderScreen extends StatelessWidget {
  const _PosRootPlaceholderScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
    // TODO: reemplazar por el widget raíz real del POS.
  }
}