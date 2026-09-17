// lib/features/pos/presentation/screens/empleados/employee_form_dialog.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/Local/entities/empleado_entity.dart';
import '../../../data/Local/entities/horario_entity.dart';
import '../../../data/Local/entities/isar_service.dart';
import '../../../data/Local/entities/log_entity.dart';
import '../../../data/Local/entities/usuario_entity.dart';
import '../../../domain/enums/tipo_documento.dart';
import '../../../domain/models/empleado_view_model.dart';
import '../../../domain/permissions/roles.dart';
import '../../providers/empleados/empleados_provider.dart';
import '../../providers/usuario_provider.dart';
import '../../utils/responsive_helper.dart';

class EmployeeFormDialog extends ConsumerStatefulWidget {
  final EmpleadoViewModel? empleado;

  const EmployeeFormDialog({super.key, this.empleado});

  static Future<bool?> show(
    BuildContext context, {
    EmpleadoViewModel? empleado,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => EmployeeFormDialog(empleado: empleado),
    );
  }

  @override
  ConsumerState<EmployeeFormDialog> createState() =>
      _EmployeeFormDialogState();
}

class _EmployeeFormDialogState extends ConsumerState<EmployeeFormDialog>
    with SingleTickerProviderStateMixin {
  static const _colorPrimary = Color(0xFF10B981);
  static const _colorDanger = Color(0xFFEF4444);
  static const _colorWarning = Color(0xFFF59E0B);

  late final TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _numeroDocController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _pinController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();
  final _cargoController = TextEditingController();
  final _numeroEmpleadoController = TextEditingController();
  final _salarioController = TextEditingController();
  final _comisionController = TextEditingController();
  final _bonoController = TextEditingController();
  final _emergenciaNombreController = TextEditingController();
  final _emergenciaTelefonoController = TextEditingController();

  TipoDocumento _tipoDoc = TipoDocumento.v;
  UserRole _rolSeleccionado = UserRole.cajero;
  String? _tipoContrato = 'tiempo_completo';
  String? _frecuenciaPago = 'mensual';
  String _monedaSalario = 'USD';
  bool _recibePropinas = false;
  DateTime? _fechaIngreso;
  int? _supervisorId;
  int? _horarioId;
  Set<int> _diasLibres = {};

  File? _imagenLocal;
  String? _fotoUrlActual;

  List<UsuarioEntity> _supervisoresPosibles = [];
  List<HorarioEntity> _horariosDisponibles = [];

  bool _isSaving = false;
  bool _isLoadingData = true;
  bool _obscurePassword = true;

  bool get _esEdicion => widget.empleado != null;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _cargarDatosIniciales();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nombreController.dispose();
    _numeroDocController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _pinController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _cargoController.dispose();
    _numeroEmpleadoController.dispose();
    _salarioController.dispose();
    _comisionController.dispose();
    _bonoController.dispose();
    _emergenciaNombreController.dispose();
    _emergenciaTelefonoController.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════════
  // CARGA
  // ══════════════════════════════════════════════════════════════

  Future<void> _cargarDatosIniciales() async {
    try {
      final isar = await IsarService().db;

      final todos = await isar.usuarioEntitys.where().findAll();
      _supervisoresPosibles = todos.where((u) {
        if (!u.activo) return false;
        final r = UserRole.fromString(u.rol);
        return r == UserRole.admin || r == UserRole.supervisor;
      }).toList();

      _horariosDisponibles =
          await isar.horarioEntitys.filter().activoEqualTo(true).findAll();

      if (_esEdicion) {
        final e = widget.empleado!;
        final u = e.usuario;
        final info = e.info;

        _nombreController.text = u.nombre;
        _tipoDoc = u.tipoDocumento ?? TipoDocumento.v;
        _numeroDocController.text = u.numeroDocumento ?? '';
        _emailController.text = u.email ?? '';
        _pinController.text = u.pin;
        _telefonoController.text = u.telefono ?? '';
        _direccionController.text = u.direccion ?? '';
        _fotoUrlActual = u.fotoUrl;
        _rolSeleccionado = e.rol;
        _supervisorId = e.supervisorId;

        if (info != null) {
          _cargoController.text = info.cargo ?? '';
          _numeroEmpleadoController.text =
              info.numeroEmpleado?.toString() ?? '';
          _tipoContrato = info.tipoContrato ?? 'tiempo_completo';
          _fechaIngreso = info.fechaIngreso;
          _salarioController.text = info.salarioBase?.toString() ?? '';
          _frecuenciaPago = info.frecuenciaPago ?? 'mensual';
          _monedaSalario = info.monedaSalario ?? 'USD';
          _comisionController.text =
              info.comisionPorcentaje?.toString() ?? '';
          _bonoController.text = info.bonoFijo?.toString() ?? '';
          _recibePropinas = info.recibePropinas;
          _horarioId = info.horarioId;
          _diasLibres = info.diasLibres.toSet();
          _emergenciaNombreController.text =
              info.contactoEmergenciaNombre ?? '';
          _emergenciaTelefonoController.text =
              info.contactoEmergenciaTelefono ?? '';
        }
      }

      if (mounted) setState(() => _isLoadingData = false);
    } catch (e) {
      debugPrint('Error cargando datos del formulario: $e');
      if (mounted) setState(() => _isLoadingData = false);
    }
  }

  // ══════════════════════════════════════════════════════════════
  // FORTALEZA DE CONTRASEÑA
  // ══════════════════════════════════════════════════════════════

  String _passwordStrength(String password) {
    if (password.isEmpty) return '';
    final length = password.length;
    final hasLower = password.contains(RegExp(r'[a-z]'));
    final hasUpper = password.contains(RegExp(r'[A-Z]'));
    final hasDigit = password.contains(RegExp(r'[0-9]'));
    final hasSpecial = password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));

    int score = 0;
    if (length >= 8) score++;
    if (hasLower && hasUpper) score++;
    if (hasDigit) score++;
    if (hasSpecial) score++;

    if (length < 6) return 'Débil';
    if (score <= 2) return 'Media';
    return 'Fuerte';
  }

  int _passwordScore(String password) {
    switch (_passwordStrength(password)) {
      case 'Débil':
        return 1;
      case 'Media':
        return 2;
      case 'Fuerte':
        return 3;
      default:
        return 0;
    }
  }

  Color _passwordColor(String s) {
    switch (s) {
      case 'Débil':
        return _colorDanger;
      case 'Media':
        return _colorWarning;
      case 'Fuerte':
        return _colorPrimary;
      default:
        return Colors.grey;
    }
  }

  IconData _passwordIcon(String s) {
    switch (s) {
      case 'Débil':
        return Icons.error_outline_rounded;
      case 'Media':
        return Icons.warning_amber_rounded;
      case 'Fuerte':
        return Icons.check_circle_outline_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  // ══════════════════════════════════════════════════════════════
  // IMAGEN
  // ══════════════════════════════════════════════════════════════

  Future<void> _seleccionarImagen() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      if (picked == null) return;
      if (!mounted) return;
      setState(() => _imagenLocal = File(picked.path));
    } catch (e) {
      debugPrint('Error seleccionando imagen: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════
  // GUARDAR
  // ══════════════════════════════════════════════════════════════

  Future<void> _guardar() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      _tabController.animateTo(0);
      _showSnack('Corrige los campos marcados en rojo.', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final isarService = IsarService();
      final usuarioActual = ref.read(usuarioActualProvider);
      final ahora = DateTime.now();

      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      // ── 0. Supabase Auth (solo creación con email + password) ──
      String? supabaseUid;
      if (!_esEdicion && email.isNotEmpty && password.isNotEmpty) {
        try {
          final response = await Supabase.instance.client.auth.signUp(
            email: email,
            password: password,
            data: {
              'nombre': _nombreController.text.trim(),
              'rol': _rolSeleccionado.value,
              'pin': _pinController.text.trim(),
            },
          );
          if (response.user == null) {
            throw Exception(
              'No se pudo crear el usuario en Supabase. '
              'Verifica que el email no esté registrado.',
            );
          }
          supabaseUid = response.user!.id;
        } on AuthWeakPasswordException {
          if (mounted) {
            setState(() => _isSaving = false);
            _showSnack(
              '❌ Contraseña demasiado débil (mínimo 6 caracteres).',
              isError: true,
            );
          }
          return;
        } catch (e) {
          if (mounted) {
            setState(() => _isSaving = false);
            _showSnack('❌ Error Supabase: $e', isError: true);
          }
          return;
        }
      }

      // ── 1. Preparar UsuarioEntity ──
      final usuario = _esEdicion
          ? widget.empleado!.usuario
          : (UsuarioEntity()
            ..activo = true
            ..estado = 'activo'
            ..createdAt = ahora);

      usuario
        ..nombre = _nombreController.text.trim()
        ..tipoDocumento = _tipoDoc
        ..numeroDocumento = _numeroDocController.text.trim()
        ..email = email.isEmpty ? null : email
        ..pin = _pinController.text.trim()
        ..telefono = _telefonoController.text.trim().isEmpty
            ? null
            : _telefonoController.text.trim()
        ..direccion = _direccionController.text.trim().isEmpty
            ? null
            : _direccionController.text.trim()
        ..rol = _rolSeleccionado.value
        ..supervisorId = _supervisorId
        ..updatedAt = ahora
        ..sincronizado = false;

      // Coherencia activo/estado en creación
      if (!_esEdicion) {
        usuario.activo = true;
        usuario.estado = 'activo';
      }

      if (supabaseUid != null) {
        usuario.supabaseId = supabaseUid;
      }

      if (password.isNotEmpty) {
        usuario.password = password;
      }

      if (_fotoUrlActual != null) {
        usuario.fotoUrl = _fotoUrlActual;
      }

      await isarService.guardarUsuario(usuario);

      // ── 2. EmpleadoInfoEntity ──
      final info = _esEdicion && widget.empleado!.info != null
          ? widget.empleado!.info!
          : (EmpleadoInfoEntity()..usuarioId = usuario.id);

      info
        ..usuarioId = usuario.id
        ..cargo = _cargoController.text.trim().isEmpty
            ? null
            : _cargoController.text.trim()
        ..numeroEmpleado = int.tryParse(_numeroEmpleadoController.text.trim())
        ..tipoContrato = _tipoContrato
        ..fechaIngreso = _fechaIngreso
        ..supervisorId = _supervisorId
        ..salarioBase = double.tryParse(_salarioController.text.trim())
        ..frecuenciaPago = _frecuenciaPago
        ..monedaSalario = _monedaSalario
        ..comisionPorcentaje =
            double.tryParse(_comisionController.text.trim())
        ..bonoFijo = double.tryParse(_bonoController.text.trim())
        ..recibePropinas = _recibePropinas
        ..horarioId = _horarioId
        ..diasLibres = _diasLibres.toList()
        ..contactoEmergenciaNombre =
            _emergenciaNombreController.text.trim().isEmpty
                ? null
                : _emergenciaNombreController.text.trim()
        ..contactoEmergenciaTelefono =
            _emergenciaTelefonoController.text.trim().isEmpty
                ? null
                : _emergenciaTelefonoController.text.trim()
        ..updatedAt = ahora
        ..syncStatus = 'pending';

      final db = await isarService.db;
      await db.writeTxn(() async {
        await db.empleadoInfoEntitys.put(info);
      });

      // ── 3. Log ──
      await isarService.guardarLog(
        LogEntity()
          ..accion = _esEdicion ? 'EMPLEADO_EDITADO' : 'EMPLEADO_CREADO'
          ..usuarioNombre = usuarioActual?.nombre ?? 'Sistema'
          ..usuarioRol = usuarioActual?.rol ?? '-'
          ..detalles =
              '${usuario.nombre} (ID: ${usuario.id}) · rol: ${_rolSeleccionado.label}'
          ..fecha = ahora
          ..sincronizado = false,
      );

      ref.invalidate(empleadosProvider);

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('Error guardando empleado: $e');
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showSnack('Error al guardar: $e', isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? _colorDanger : _colorPrimary,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 40,
        vertical: isMobile ? 12 : 32,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 720,
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(isMobile, colorScheme),
            if (_isLoadingData)
              const Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(color: _colorPrimary),
              )
            else ...[
              _buildTabs(colorScheme),
              Flexible(
                child: Form(
                  key: _formKey,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _tabBasicos(isMobile, colorScheme),
                      _tabLaboral(isMobile, colorScheme),
                      _tabCompensacion(isMobile, colorScheme),
                      _tabHorario(isMobile, colorScheme),
                      _tabEmergencia(isMobile, colorScheme),
                    ],
                  ),
                ),
              ),
              _buildFooter(colorScheme, isMobile),
            ],
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // HEADER
  // ══════════════════════════════════════════════════════════════

  Widget _buildHeader(bool isMobile, ColorScheme colorScheme) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 16 : 24,
        isMobile ? 16 : 22,
        12,
        8,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _seleccionarImagen,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: _buildAvatarPreview(isMobile),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _esEdicion ? 'Editar empleado' : 'Nuevo empleado',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _esEdicion
                      ? 'Actualiza los datos del empleado'
                      : 'Completa los datos para dar de alta al empleado',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 22),
            color: colorScheme.onSurfaceVariant,
            onPressed: _isSaving ? null : () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarPreview(bool isMobile) {
    final size = isMobile ? 56.0 : 64.0;
    final tieneFoto = _imagenLocal != null || _fotoUrlActual != null;

    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: tieneFoto
                ? null
                : const LinearGradient(
                    colors: [_colorPrimary, Color(0xFF059669)],
                  ),
            shape: BoxShape.circle,
            border: Border.all(
              color: _colorPrimary.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: ClipOval(
            child: _imagenLocal != null
                ? Image.file(_imagenLocal!, fit: BoxFit.cover)
                : (_fotoUrlActual != null
                    ? Image.network(
                        _fotoUrlActual!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _avatarInicial(),
                      )
                    : _avatarInicial()),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: _colorPrimary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.camera_alt_rounded,
              size: 12,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _avatarInicial() {
    final inicial = _nombreController.text.isNotEmpty
        ? _nombreController.text[0].toUpperCase()
        : '?';
    return Center(
      child: Text(
        inicial,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // TABS
  // ══════════════════════════════════════════════════════════════

  Widget _buildTabs(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelColor: _colorPrimary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        indicatorColor: _colorPrimary,
        indicatorWeight: 2.5,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
        tabs: const [
          Tab(text: 'Básicos'),
          Tab(text: 'Laboral'),
          Tab(text: 'Compensación'),
          Tab(text: 'Horario'),
          Tab(text: 'Emergencia'),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // TAB BÁSICOS
  // ══════════════════════════════════════════════════════════════

  Widget _tabBasicos(bool isMobile, ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _campo(
            _nombreController,
            'Nombre completo *',
            Icons.person_outline_rounded,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Requerido' : null,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 14),
          _tipoDocRow(colorScheme),
          const SizedBox(height: 14),
          _campo(
            _emailController,
            'Correo electrónico',
            Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return null;
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v.trim())) {
                return 'Email inválido';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          if (!_esEdicion) ...[
            _campoPassword(colorScheme),
            const SizedBox(height: 14),
          ],
          _campo(
            _pinController,
            'PIN de acceso *',
            Icons.password_rounded,
            keyboardType: TextInputType.number,
            maxLength: 6,
            validator: (v) {
              final t = v?.trim() ?? '';
              if (t.isEmpty) return 'Requerido';
              if (t.length < 4) return 'Mínimo 4 dígitos';
              if (!RegExp(r'^\d+$').hasMatch(t)) return 'Solo números';
              return null;
            },
          ),
          const SizedBox(height: 14),
          _campo(
            _telefonoController,
            'Teléfono',
            Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 14),
          _campo(
            _direccionController,
            'Dirección',
            Icons.location_on_outlined,
            maxLines: 2,
          ),
          const SizedBox(height: 14),
          _rolDropdown(colorScheme),
        ],
      ),
    );
  }

  Widget _campoPassword(ColorScheme colorScheme) {
    final strength = _passwordStrength(_passwordController.text);
    final color = _passwordColor(strength);
    final score = _passwordScore(_passwordController.text);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
          onChanged: (_) => setState(() {}),
          decoration: _inputDecoration(
            'Contraseña (para login)',
            Icons.lock_outline_rounded,
            colorScheme,
          ).copyWith(
            helperText:
                'Mínimo 6 caracteres. Solo se usa si el email está seteado.',
            helperStyle: TextStyle(
              fontSize: 11,
              color: colorScheme.onSurfaceVariant,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                size: 20,
              ),
              color: colorScheme.onSurfaceVariant,
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return null;
            if (v.trim().length < 6) return 'Mínimo 6 caracteres';
            return null;
          },
        ),
        if (_passwordController.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
            child: Row(
              children: [
                Icon(_passwordIcon(strength), color: color, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Fortaleza: $strength',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 80,
                  child: Row(
                    children: [
                      for (int i = 0; i < 3; i++)
                        Expanded(
                          child: Container(
                            height: 4,
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: i < score
                                  ? color
                                  : Colors.grey.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _tipoDocRow(ColorScheme colorScheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: DropdownButtonFormField<TipoDocumento>(
            value: _tipoDoc,
            decoration: _inputDecoration('Tipo', null, colorScheme),
            items: TipoDocumento.paraUsuarios
                .map((t) => DropdownMenuItem(
                      value: t,
                      child: Text(t.codigo),
                    ))
                .toList(),
            onChanged: (v) {
              if (v != null) setState(() => _tipoDoc = v);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: _numeroDocController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(15),
            ],
            style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
            decoration: _inputDecoration(
              'Número de documento *',
              Icons.badge_outlined,
              colorScheme,
            ),
            validator: (v) {
              final t = v?.trim() ?? '';
              if (t.isEmpty) return 'Requerido';
              if (t.length < 5) return 'Mínimo 5 dígitos';
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _rolDropdown(ColorScheme colorScheme) {
    final rolesDisponibles = [
      UserRole.cajero,
      UserRole.supervisor,
      UserRole.rrhh,
      UserRole.almacen,
      UserRole.soporte,
      UserRole.auditor,
      UserRole.admin,
    ];

    return DropdownButtonFormField<UserRole>(
      initialValue: _rolSeleccionado,
      decoration: _inputDecoration(
        'Rol *',
        Icons.workspace_premium_outlined,
        colorScheme,
      ),
      items: rolesDisponibles
          .map((r) => DropdownMenuItem(
                value: r,
                child: Text(r.label),
              ))
          .toList(),
      onChanged: (v) {
        if (v != null) setState(() => _rolSeleccionado = v);
      },
    );
  }

  // ══════════════════════════════════════════════════════════════
  // TAB LABORAL
  // ══════════════════════════════════════════════════════════════

  Widget _tabLaboral(bool isMobile, ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _campo(_cargoController, 'Cargo', Icons.work_outline_rounded),
          const SizedBox(height: 14),
          _campo(
            _numeroEmpleadoController,
            'Número de empleado',
            Icons.numbers_rounded,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 14),
          _dropdownTipoContrato(colorScheme),
          const SizedBox(height: 14),
          _selectorFecha(isMobile, colorScheme),
          const SizedBox(height: 14),
          _dropdownSupervisor(colorScheme),
        ],
      ),
    );
  }

  Widget _dropdownTipoContrato(ColorScheme colorScheme) {
    const opciones = {
      'tiempo_completo': 'Tiempo completo',
      'medio_tiempo': 'Medio tiempo',
      'pasante': 'Pasante',
      'por_horas': 'Por horas',
      'temporal': 'Temporal',
    };

    return DropdownButtonFormField<String>(
      value: _tipoContrato,
      decoration: _inputDecoration(
        'Tipo de contrato',
        Icons.description_outlined,
        colorScheme,
      ),
      items: opciones.entries
          .map((e) => DropdownMenuItem(
                value: e.key,
                child: Text(e.value),
              ))
          .toList(),
      onChanged: (v) => setState(() => _tipoContrato = v),
    );
  }

  Widget _selectorFecha(bool isMobile, ColorScheme colorScheme) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _fechaIngreso ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (picked != null) setState(() => _fechaIngreso = picked);
      },
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: _inputDecoration(
          'Fecha de ingreso',
          Icons.calendar_today_outlined,
          colorScheme,
        ),
        child: Text(
          _fechaIngreso != null
              ? '${_fechaIngreso!.day.toString().padLeft(2, '0')}/'
                  '${_fechaIngreso!.month.toString().padLeft(2, '0')}/'
                  '${_fechaIngreso!.year}'
              : 'Seleccionar fecha',
          style: TextStyle(
            fontSize: 14,
            color: _fechaIngreso != null
                ? colorScheme.onSurface
                : colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }

  Widget _dropdownSupervisor(ColorScheme colorScheme) {
    return DropdownButtonFormField<int?>(
      value: _supervisorId,
      decoration: _inputDecoration(
        'Supervisor directo',
        Icons.supervisor_account_outlined,
        colorScheme,
      ),
      items: [
        const DropdownMenuItem<int?>(
          value: null,
          child: Text('Sin supervisor'),
        ),
        ..._supervisoresPosibles.map((u) => DropdownMenuItem<int?>(
              value: u.id,
              child: Text('${u.nombre} (${UserRole.fromString(u.rol).label})'),
            )),
      ],
      onChanged: (v) => setState(() => _supervisorId = v),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // TAB COMPENSACIÓN
  // ══════════════════════════════════════════════════════════════

  Widget _tabCompensacion(bool isMobile, ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _campo(
                  _salarioController,
                  'Salario base',
                  Icons.attach_money_rounded,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 100,
                child: DropdownButtonFormField<String>(
                  value: _monedaSalario,
                  decoration: _inputDecoration('Moneda', null, colorScheme),
                  items: const [
                    DropdownMenuItem(value: 'USD', child: Text('USD')),
                    DropdownMenuItem(value: 'VES', child: Text('VES')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _monedaSalario = v);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _frecuenciaPago,
            decoration: _inputDecoration(
              'Frecuencia de pago',
              Icons.repeat_rounded,
              colorScheme,
            ),
            items: const [
              DropdownMenuItem(value: 'mensual', child: Text('Mensual')),
              DropdownMenuItem(value: 'quincenal', child: Text('Quincenal')),
              DropdownMenuItem(value: 'semanal', child: Text('Semanal')),
              DropdownMenuItem(value: 'diario', child: Text('Diario')),
            ],
            onChanged: (v) => setState(() => _frecuenciaPago = v),
          ),
          const SizedBox(height: 14),
          _campo(
            _comisionController,
            'Comisión por ventas (%)',
            Icons.percent_rounded,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 14),
          _campo(
            _bonoController,
            'Bono fijo',
            Icons.card_giftcard_rounded,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 14),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Recibe propinas',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            subtitle: Text(
              'Marcar si el empleado participa del reparto de propinas',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            value: _recibePropinas,
            onChanged: (v) => setState(() => _recibePropinas = v),
            activeThumbColor: _colorPrimary,
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // TAB HORARIO
  // ══════════════════════════════════════════════════════════════

  Widget _tabHorario(bool isMobile, ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<int?>(
            value: _horarioId,
            decoration: _inputDecoration(
              'Horario asignado',
              Icons.schedule_rounded,
              colorScheme,
            ),
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text('Sin horario asignado'),
              ),
              ..._horariosDisponibles.map((h) => DropdownMenuItem<int?>(
                    value: h.id,
                    child: Text(h.nombre),
                  )),
            ],
            onChanged: (v) => setState(() => _horarioId = v),
          ),
          if (_horariosDisponibles.isEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _colorWarning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _colorWarning.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: _colorWarning,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No hay horarios creados. Puedes asignar uno más tarde.',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          Text(
            'Días libres',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Selecciona los días que el empleado descansa habitualmente',
            style: TextStyle(
              fontSize: 11.5,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(7, (i) {
              final weekday = i + 1;
              final selected = _diasLibres.contains(weekday);
              return _diaChip(weekday, selected);
            }),
          ),
        ],
      ),
    );
  }

  Widget _diaChip(int weekday, bool selected) {
    const labels = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

    return GestureDetector(
      onTap: () {
        setState(() {
          if (selected) {
            _diasLibres.remove(weekday);
          } else {
            _diasLibres.add(weekday);
          }
        });
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: selected
                ? _colorPrimary
                : _colorPrimary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? _colorPrimary
                  : _colorPrimary.withValues(alpha: 0.25),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Center(
            child: Text(
              labels[weekday - 1],
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: selected ? Colors.white : _colorPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // TAB EMERGENCIA
  // ══════════════════════════════════════════════════════════════

  Widget _tabEmergencia(bool isMobile, ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.5,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Datos de la persona a contactar en caso de emergencia',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _campo(
            _emergenciaNombreController,
            'Nombre del contacto',
            Icons.contact_emergency_outlined,
          ),
          const SizedBox(height: 14),
          _campo(
            _emergenciaTelefonoController,
            'Teléfono del contacto',
            Icons.phone_in_talk_outlined,
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // FOOTER
  // ══════════════════════════════════════════════════════════════

  Widget _buildFooter(ColorScheme colorScheme, bool isMobile) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 16 : 22,
        12,
        isMobile ? 16 : 22,
        16,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: _isSaving ? null : () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                foregroundColor: colorScheme.onSurfaceVariant,
              ),
              child: const Text(
                'Cancelar',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _guardar,
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check_rounded, size: 18),
              label: Text(
                _isSaving
                    ? 'Guardando...'
                    : (_esEdicion ? 'Actualizar' : 'Crear empleado'),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _colorPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // HELPERS DE INPUT
  // ══════════════════════════════════════════════════════════════

  Widget _campo(
    TextEditingController controller,
    String label,
    IconData icon, {
    String? helper,
    int? maxLength,
    int maxLines = 1,
    bool obscureText = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      maxLength: maxLength,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      onChanged: onChanged,
      style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
      decoration: _inputDecoration(label, icon, colorScheme).copyWith(
        helperText: helper,
        helperStyle: TextStyle(
          fontSize: 11,
          color: colorScheme.onSurfaceVariant,
        ),
        counterText: '',
      ),
    );
  }

  InputDecoration _inputDecoration(
    String label,
    IconData? icon,
    ColorScheme colorScheme,
  ) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        fontSize: 13.5,
        color: colorScheme.onSurfaceVariant,
      ),
      prefixIcon:
          icon != null ? Icon(icon, size: 20, color: _colorPrimary) : null,
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _colorPrimary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _colorDanger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _colorDanger, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
    );
  }
}