import 'package:flutter/material.dart';
import '../../data/Local/entities/isar_service.dart';
import '../utils/responsive_helper.dart';

class PersonnelManagementDialog extends StatefulWidget {
  const PersonnelManagementDialog({super.key});

  @override
  State<PersonnelManagementDialog> createState() => _PersonnelManagementDialogState();
}

class _PersonnelManagementDialogState extends State<PersonnelManagementDialog> {
  final IsarService _isarService = IsarService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  String _selectedRol = 'cajero';

  @override
  void dispose() {
    _nameController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _crearNuevoUsuario() async {
    if (_nameController.text.trim().isEmpty || _pinController.text.trim().length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('El nombre y un PIN de 4 dígitos son obligatorios.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }
    await _isarService.crearUsuario(
      nombre: _nameController.text.trim(),
      pin: _pinController.text.trim(),
      rol: _selectedRol,
      caja: 'Caja Principal',
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    // Dimensiones dinámicas
    final double dialogWidth = isMobile
        ? MediaQuery.of(context).size.width * 0.92
        : (isTablet ? 500 : 450);

    final double paddingHorizontal = isMobile ? 16 : 24;
    final double paddingVertical = isMobile ? 12 : 16;
    final double fontSizeTitle = isMobile ? 16 : 18;
    final double fontSizeBody = isMobile ? 13 : 14;
    final double fontSizeLabel = isMobile ? 12 : 13;
    final double fontSizeHint = isMobile ? 12 : 13;
    final double fontSizeHelper = isMobile ? 11 : 12;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.brightness == Brightness.dark
              ? Colors.grey.shade700
              : Colors.transparent,
          width: 1,
        ),
      ),
      backgroundColor: theme.cardColor,
      titlePadding: EdgeInsets.symmetric(
        horizontal: paddingHorizontal,
        vertical: paddingVertical,
      ),
      title: Row(
        children: [
          Icon(
            Icons.admin_panel_settings,
            color: theme.brightness == Brightness.dark
                ? Colors.blue.shade300
                : const Color(0xFF3B82F6),
            size: 24,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Gestión de Personal y Roles',
              style: TextStyle(
                fontSize: fontSizeTitle,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: paddingHorizontal,
        vertical: isMobile ? 8 : 12,
      ),
      content: SizedBox(
        width: dialogWidth,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Administración de accesos del sistema POS:',
                style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                  fontSize: fontSizeBody,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                style: TextStyle(
                  fontSize: fontSizeBody,
                  color: theme.textTheme.bodyLarge?.color,
                ),
                decoration: InputDecoration(
                  labelText: 'Nombre del nuevo empleado',
                  labelStyle: TextStyle(
                    fontSize: fontSizeLabel,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: theme.brightness == Brightness.dark
                          ? Colors.grey.shade700
                          : const Color(0xFFCBD5E1),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: isMobile ? 12 : 16,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _pinController,
                obscureText: true,
                maxLength: 4,
                keyboardType: TextInputType.number,
                style: TextStyle(
                  fontSize: fontSizeBody,
                  color: theme.textTheme.bodyLarge?.color,
                ),
                decoration: InputDecoration(
                  labelText: 'PIN de acceso (4 dígitos)',
                  labelStyle: TextStyle(
                    fontSize: fontSizeLabel,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                  counterText: '',
                  filled: true,
                  fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: theme.brightness == Brightness.dark
                          ? Colors.grey.shade700
                          : const Color(0xFFCBD5E1),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: isMobile ? 12 : 16,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedRol,
                items: const [
                  DropdownMenuItem(value: 'cajero', child: Text('Cajero')),
                  DropdownMenuItem(value: 'admin', child: Text('Administrador')),
                ],
                onChanged: (val) => setState(() => _selectedRol = val!),
                style: TextStyle(
                  fontSize: fontSizeBody,
                  color: theme.textTheme.bodyLarge?.color,
                ),
                dropdownColor: theme.cardColor,
                decoration: InputDecoration(
                  labelText: 'Rol / Permisos',
                  labelStyle: TextStyle(
                    fontSize: fontSizeLabel,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: theme.brightness == Brightness.dark
                          ? Colors.grey.shade700
                          : const Color(0xFFCBD5E1),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: isMobile ? 12 : 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Para editar roles existentes o eliminar usuarios, ve a Configuración de Usuarios.',
                style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                  fontSize: fontSizeHelper,
                ),
              ),
            ],
          ),
        ),
      ),
      actionsPadding: EdgeInsets.symmetric(
        horizontal: paddingHorizontal,
        vertical: isMobile ? 8 : 12,
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: theme.textTheme.bodyMedium?.color,
          ),
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cerrar',
            style: TextStyle(
              fontSize: isMobile ? 13 : 14,
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
          ),
          onPressed: _crearNuevoUsuario,
          child: Text(
            'Crear Nuevo Usuario',
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}