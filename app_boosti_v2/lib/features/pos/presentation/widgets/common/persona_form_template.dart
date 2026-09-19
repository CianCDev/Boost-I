// lib/features/pos/presentation/widgets/common/forms/persona_form_template.dart
//
// ═══════════════════════════════════════════════════════════════════════
// ÁTOMOS REUTILIZABLES PARA FORMULARIOS DE "PERSONAS"
// ═══════════════════════════════════════════════════════════════════════
//
// Sirven para cualquier formulario que capture datos de identidad +
// contacto (clientes, proveedores, empleados, etc.).
//
// REGLA DE ORO: los widgets de este archivo son PUROS. No conocen
// entidades (ClienteEntity, ProveedorEntity). Solo reciben controllers
// y callbacks. La composición vive en cada diálogo específico.
//
// ── Cómo se usan (ejemplo mental) ──
//
//   FormSection(
//     title: 'Identificación',
//     icon: Icons.badge_rounded,
//     children: [
//       PersonaTextField(controller: _nombre, label: 'Nombre', ...),
//       DocumentoIdentidadField(
//         tipoDocumento: _tipoDoc,
//         onTipoDocumentoChanged: (v) => setState(...),
//         numeroController: _documento,
//       ),
//       RifField(controller: _rif),
//     ],
//   )

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ═══════════════════════════════════════════════════════════════════════
// CONSTANTES COMPARTIDAS
// ═══════════════════════════════════════════════════════════════════════

/// Tipos de documento soportados (Venezuela).
/// `key` → valor que se guarda. `value` → tooltip / label largo.
const kTiposDocumento = <String, String>{
  'V': 'Venezolano',
  'E': 'Extranjero',
  'J': 'Jurídico (RIF)',
  'G': 'Gubernamental',
  'P': 'Pasaporte',
  'C': 'Comuna',
};

/// Validación de RIF venezolano: `J-12345678-9`.
/// Acepta 6 a 10 dígitos, con o sin dígito verificador final.
final kRifRegex = RegExp(r'^[VEJGP]-\d{6,10}(-\d)?$');

/// Formateador de RIF: convierte "J12345678" o "J-12345678-9" al
/// formato canónico con guiones. Uppercase automático.
class RifInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text.toUpperCase();
    // Solo letras iniciales válidas + dígitos + guiones
    text = text.replaceAll(RegExp(r'[^VEJGP0-9\-]'), '');

    // Si el usuario escribe la letra sola sin guion, se lo agregamos
    if (text.length == 1 && RegExp(r'[VEJGP]').hasMatch(text)) {
      return TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// 1. FormSection — agrupador visual con título + icono opcional
// ═══════════════════════════════════════════════════════════════════════

class FormSection extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Color? accentColor;
  final List<Widget> children;
  final bool showDivider;

  const FormSection({
    super.key,
    required this.title,
    this.icon,
    this.accentColor,
    required this.children,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = accentColor ?? colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12, top: 4),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: accent),
                const SizedBox(width: 8),
              ],
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: accent,
                ),
              ),
              if (showDivider) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: Divider(
                    color: accent.withValues(alpha: 0.25),
                    height: 1,
                    thickness: 1,
                  ),
                ),
              ],
            ],
          ),
        ),
        ...children,
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// 2. PersonaTextField — campo de texto estandarizado
// ═══════════════════════════════════════════════════════════════════════

class PersonaTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final Color accentColor;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final TextCapitalization textCapitalization;
  final int maxLines;
  final bool enabled;

  const PersonaTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.accentColor,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      textCapitalization: textCapitalization,
      maxLines: maxLines,
      enabled: enabled,
      style: TextStyle(color: colorScheme.onSurface),
      decoration: buildInputDecoration(
        label: label,
        icon: icon,
        accentColor: accentColor,
        colorScheme: colorScheme,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// 3. DocumentoIdentidadField — dropdown tipo + campo número
// ═══════════════════════════════════════════════════════════════════════

class DocumentoIdentidadField extends StatelessWidget {
  /// Valor actual del tipo de documento ('V' | 'E' | 'J' | 'G' | 'P' | 'C').
  final String? tipoDocumento;

  /// Callback cuando cambia el tipo.
  final ValueChanged<String?> onTipoDocumentoChanged;

  /// Controller para el número de documento (se guarda como int afuera).
  final TextEditingController numeroController;

  final Color accentColor;
  final String? Function(String?)? numeroValidator;
  final bool enabled;

  /// Ancho del dropdown de tipo. Default 110.
  final double dropdownWidth;

  const DocumentoIdentidadField({
    super.key,
    required this.tipoDocumento,
    required this.onTipoDocumentoChanged,
    required this.numeroController,
    required this.accentColor,
    this.numeroValidator,
    this.enabled = true,
    this.dropdownWidth = 110,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: dropdownWidth,
          child: DropdownButtonFormField<String>(
            initialValue: tipoDocumento,
            isExpanded: true,
            decoration: buildInputDecoration(
              label: 'Tipo',
              icon: Icons.badge_outlined,
              accentColor: accentColor,
              colorScheme: colorScheme,
            ),
            hint: const Text('V/E/J…', style: TextStyle(fontSize: 12)),
            items: kTiposDocumento.entries.map((e) {
              return DropdownMenuItem<String>(
                value: e.key,
                child: Text(
                  e.key,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              );
            }).toList(),
            onChanged: enabled ? onTipoDocumentoChanged : null,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: PersonaTextField(
            controller: numeroController,
            label: 'Número',
            icon: Icons.numbers_rounded,
            accentColor: accentColor,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: numeroValidator,
            enabled: enabled,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// 4. RifField — campo RIF con formato y validación
// ═══════════════════════════════════════════════════════════════════════

class RifField extends StatelessWidget {
  final TextEditingController controller;
  final Color accentColor;
  final bool obligatorio;
  final bool enabled;

  const RifField({
    super.key,
    required this.controller,
    required this.accentColor,
    this.obligatorio = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return PersonaTextField(
      controller: controller,
      label: obligatorio ? 'RIF *' : 'RIF (opcional)',
      icon: Icons.receipt_outlined,
      accentColor: accentColor,
      textCapitalization: TextCapitalization.characters,
      inputFormatters: [RifInputFormatter()],
      validator: (v) {
        final val = (v ?? '').trim();
        if (obligatorio && val.isEmpty) return 'RIF obligatorio';
        if (val.isNotEmpty && !kRifRegex.hasMatch(val.toUpperCase())) {
          return 'Formato: J-12345678-9';
        }
        return null;
      },
      enabled: enabled,
    );
  }
}


// ═══════════════════════════════════════════════════════════════════════
// 5. FormActions — fila Cancelar + Guardar
// ═══════════════════════════════════════════════════════════════════════

class FormActions extends StatelessWidget {
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;
  final bool isSaving;
  final String confirmLabel;
  final String cancelLabel;
  final Color accentColor;

  const FormActions({
    super.key,
    this.onCancel,
    this.onConfirm,
    required this.isSaving,
    required this.confirmLabel,
    required this.accentColor,
    this.cancelLabel = 'Cancelar',
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: TextButton(
              onPressed: isSaving ? null : onCancel,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                cancelLabel,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: MouseRegion(
            cursor: isSaving
                ? SystemMouseCursors.forbidden
                : SystemMouseCursors.click,
            child: ElevatedButton(
              onPressed: isSaving ? null : onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: isSaving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      confirmLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// HELPERS COMPARTIDOS (NO USAR FUERA DE ESTE ARCHIVO)
// ═══════════════════════════════════════════════════════════════════════

/// InputDecoration unificada para todos los campos del template.
/// Mantiene consistencia visual: radius 14, border 1px, focus 2px.
InputDecoration buildInputDecoration({
  required String label,
  required IconData icon,
  required Color accentColor,
  required ColorScheme colorScheme,
}) {
  final isDark = colorScheme.brightness == Brightness.dark;

  return InputDecoration(
    labelText: label,
    labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
    prefixIcon: Icon(icon, color: accentColor),
    filled: true,
    fillColor: isDark
        ? Colors.white.withValues(alpha: 0.04)
        : const Color(0xFFF9FAFB),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        width: 1,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: accentColor, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: colorScheme.error, width: 1.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: colorScheme.error, width: 2),
    ),
    contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  );
}