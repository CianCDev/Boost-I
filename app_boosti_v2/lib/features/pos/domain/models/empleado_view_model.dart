// lib/features/pos/domain/models/empleado_view_model.dart
import '../../data/Local/entities/empleado_entity.dart';
import '../../data/Local/entities/usuario_entity.dart';

import '../enums/tipo_documento.dart';
import '../permissions/roles.dart';

/// Vista unificada de un empleado.
///
/// Combina `UsuarioEntity` (datos base de la cuenta) con
/// `EmpleadoInfoEntity` (datos laborales extendidos).
///
/// Es un objeto de solo lectura: para modificar, usa los entities
/// originales y guarda por separado.
class EmpleadoViewModel {
  final UsuarioEntity usuario;
  final EmpleadoInfoEntity? info;

  const EmpleadoViewModel({
    required this.usuario,
    this.info,
  });

  // ══════════════════════════════════════════════════════════════
  // IDENTIDAD
  // ══════════════════════════════════════════════════════════════

  int get id => usuario.id;
  String get nombre => usuario.nombre;
  String get rolRaw => usuario.rol;
  UserRole get rol => UserRole.fromString(usuario.rol);
  bool get activo => usuario.activo;
  String? get email => usuario.email;
  String? get fotoUrl => usuario.fotoUrl;
  String get inicial => nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';

  TipoDocumento? get tipoDocumento => usuario.tipoDocumento;
  String? get numeroDocumento => usuario.numeroDocumento;

  String get documentoCompleto {
    if (usuario.tipoDocumento == null || usuario.numeroDocumento == null) {
      return 'Sin documento';
    }
    return usuario.tipoDocumento!.formatear(usuario.numeroDocumento);
  }

  bool get tieneDocumento => usuario.tieneDocumento;

  String? get telefono => usuario.telefono;
  String? get direccion => usuario.direccion;

  // ══════════════════════════════════════════════════════════════
  // LABORAL
  // ══════════════════════════════════════════════════════════════

  DateTime? get fechaIngreso => info?.fechaIngreso;
  String? get cargo => info?.cargo;
  String? get tipoContrato => info?.tipoContrato;
  int? get numeroEmpleado => info?.numeroEmpleado;
  int? get supervisorId => usuario.supervisorId ?? info?.supervisorId;

  /// Antigüedad legible ("2 años 4 meses") o null si no hay fecha.
  String? get antiguedad {
    if (fechaIngreso == null) return null;
    final d = DateTime.now().difference(fechaIngreso!);
    final anios = d.inDays ~/ 365;
    final meses = (d.inDays % 365) ~/ 30;
    if (anios == 0 && meses == 0) return 'Menos de un mes';
    if (anios == 0) return '$meses mes${meses == 1 ? '' : 'es'}';
    if (meses == 0) return '$anios año${anios == 1 ? '' : 's'}';
    return '$anios año${anios == 1 ? '' : 's'} $meses m';
  }

  // ══════════════════════════════════════════════════════════════
  // COMPENSACIÓN
  // ══════════════════════════════════════════════════════════════

  double? get salarioBase => info?.salarioBase;
  String? get frecuenciaPago => info?.frecuenciaPago;
  String? get monedaSalario => info?.monedaSalario;
  double? get comisionPorcentaje => info?.comisionPorcentaje;
  double? get bonoFijo => info?.bonoFijo;
  bool get recibePropinas => info?.recibePropinas ?? false;

  bool get tieneSalarioConfigurado => salarioBase != null && salarioBase! > 0;

  // ══════════════════════════════════════════════════════════════
  // HORARIO
  // ══════════════════════════════════════════════════════════════

  int? get horarioId => info?.horarioId;
  List<int> get diasLibres => info?.diasLibres ?? const [];

  // ══════════════════════════════════════════════════════════════
  // CONTACTO DE EMERGENCIA
  // ══════════════════════════════════════════════════════════════

  String? get contactoEmergenciaNombre =>
      info?.contactoEmergenciaNombre;
  String? get contactoEmergenciaTelefono =>
      info?.contactoEmergenciaTelefono;

  // ══════════════════════════════════════════════════════════════
  // HELPERS DE UI
  // ══════════════════════════════════════════════════════════════

  /// Texto de una línea para el subtítulo de la card:
  /// "Cajero · Caja Principal · 2 años"
  String get subtitulo {
    final parts = <String>[];
    if (cargo != null && cargo!.isNotEmpty) {
      parts.add(cargo!);
    } else {
      parts.add(rol.label);
    }
    if (usuario.cajaAsignada.isNotEmpty) {
      parts.add(usuario.cajaAsignada);
    }
    final a = antiguedad;
    if (a != null) parts.add(a);
    return parts.join(' · ');
  }

  EmpleadoViewModel copyWith({
    UsuarioEntity? usuario,
    EmpleadoInfoEntity? info,
  }) {
    return EmpleadoViewModel(
      usuario: usuario ?? this.usuario,
      info: info ?? this.info,
    );
  }
}