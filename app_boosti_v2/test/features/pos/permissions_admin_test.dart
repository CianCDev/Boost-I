// test/features/pos/permissions_admin_test.dart
//
// El cambio de contraseña de empresa está limitado a administradores.
// El gate debe pasar por `Permissions.isAdmin`, nunca por una comparación
// directa de string contra el rol.
import 'package:app_boosti_v2/features/pos/domain/permissions/roles.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Permissions.isAdmin', () {
    test('solo acepta al rol admin', () {
      expect(Permissions.isAdmin(UserRole.admin), isTrue);

      for (final rol in UserRole.values.where((r) => r != UserRole.admin)) {
        expect(
          Permissions.isAdmin(rol),
          isFalse,
          reason: '$rol no debe considerarse administrador',
        );
      }
    });

    test('resuelve el rol desde el string de la entidad', () {
      expect(Permissions.isAdmin(UserRole.fromString('admin')), isTrue);
      expect(Permissions.isAdmin(UserRole.fromString('Admin')), isTrue);

      expect(Permissions.isAdmin(UserRole.fromString('supervisor')), isFalse);
      expect(Permissions.isAdmin(UserRole.fromString('cajero')), isFalse);

      // Rol ausente o desconocido cae en `cajero`, que no es admin.
      expect(Permissions.isAdmin(UserRole.fromString(null)), isFalse);
      expect(Permissions.isAdmin(UserRole.fromString('rol-inexistente')), isFalse);
    });
  });
}
