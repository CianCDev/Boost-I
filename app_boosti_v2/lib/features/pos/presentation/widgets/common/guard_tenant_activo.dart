// lib/features/pos/presentation/widgets/common/guard_tenant_activo.dart
//
// Envuelve una acción de escritura y la bloquea si el JWT y el local activo
// no están alineados (hot-switch cross-tenant).
//
// POR QUÉ EXISTE
//
// Cuando el usuario cambia de local a uno de OTRO tenant, `cargarLocalActual`
// escribe el local nuevo en Isar de inmediato, pero el JWT sigue firmado con
// el tenant del login. En esa ventana un INSERT o una RPC aterriza en el
// tenant del JWT: la venta se sube a JAHTLABS aunque el usuario esté viendo
// "centro". No hay error, solo datos en el tenant equivocado.
//
// Ver `tenant_alineado_provider.dart` para el detalle del mecanismo.
//
// DISEÑO
//
// El widget hijo (normalmente un botón) se envuelve en [AbsorbPointer] para
// que su propio `onPressed` no dispare, y el tap se intercepta afuera con un
// [GestureDetector]. Así:
//   - Alineado → ejecuta `onEjecutar`.
//   - Desalineado → abre el diálogo explicativo.
//
// ⚠️ `AbsorbPointer` dentro de un `GestureDetector` externo: el hijo no
//    recibe el pointer, pero el `GestureDetector` sí (está por encima en el
//    árbol de hit-test). Es lo que permite interceptar sin duplicar el tap.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/tenant_alineado_provider.dart';

/// Diálogo de "modo vista previa".
///
/// Es una función de nivel superior, no un método privado, para que cualquier
/// pantalla pueda invocarla sin montar el widget (p. ej. desde un
/// `onPressed` suelto).
Future<bool> mostrarDialogoVistaPrevia(BuildContext context) async {
  final confirmado = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.visibility_outlined, color: Color(0xFFF59E0B)),
          SizedBox(width: 10),
          Text('Modo vista previa'),
        ],
      ),
      content: const Text(
        'Estás viendo un local de otro negocio. Tu sesión pertenece a uno '
        'distinto, así que lo que hagas acá se guardaría en el negocio '
        'equivocado.\n\n'
        'Para operar en este local, cerrá sesión y entrá con la cuenta de '
        'este negocio.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Entendido'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
          ),
          child: const Text('Cambiar de cuenta'),
        ),
      ],
    ),
  );

  return confirmado ?? false;
}

/// Envuelve una acción de escritura y la bloquea si el JWT y el local activo
/// no están alineados.
///
/// Uso:
/// ```dart
/// GuardTenantActivo(
///   onEjecutar: () => _confirmarVenta(),
///   child: ElevatedButton(onPressed: null, child: Text('Confirmar')),
/// )
/// ```
///
/// El hijo debe llevar `onPressed: null` (o el que use en moda normal): el
/// [AbsorbPointer] lo anula de todas formas. Dejarlo explícitamente en
/// `null` evita que un lector piense que el botón funciona solo.
class GuardTenantActivo extends ConsumerWidget {
  const GuardTenantActivo({
    super.key,
    required this.child,
    required this.onEjecutar,
    this.onCambiarCuenta,
  });

  /// Widget a proteger (normalmente un botón de escritura).
  final Widget child;

  /// Qué ejecutar cuando el tenant está alineado.
  final VoidCallback onEjecutar;

  /// Acción del botón "Cambiar de cuenta" del diálogo. Si es `null`, el
  /// diálogo solo informa y el usuario sale con "Entendido".
  final VoidCallback? onCambiarCuenta;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alineado = ref.watch(tenantAlineadoProvider);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: alineado
          ? onEjecutar
          : () async {
              final cambiar = await mostrarDialogoVistaPrevia(context);
              if (cambiar) onCambiarCuenta?.call();
            },
      child: AbsorbPointer(child: child),
    );
  }
}
