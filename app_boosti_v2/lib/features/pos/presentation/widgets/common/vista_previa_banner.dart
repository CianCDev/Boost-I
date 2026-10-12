// lib/features/pos/presentation/widgets/common/vista_previa_banner.dart
//
// Banner global de "modo vista previa": avisa que el local que se está
// viendo no es el tenant de la sesión.
//
// Se muestra solo cuando `tenantAlineadoProvider` es `false`, que es el
// estado de hot-switch cross-tenant. En ese estado las escrituras caen en
// el tenant del JWT, no en el local visible, así que el usuario tiene que
// saberlo antes de intentar cobrar.
//
// Es un widget separado (y no un bloque inline en el Scaffold) porque se
// usa en dos sitios con la misma semántica: como `bottom` del `PreferredSize`
// del AppBar principal, y pegado encima del `body` en pantallas secundarias.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/local_actual_provider.dart';
import '../../providers/locales_provider.dart';
import '../../providers/tenant_alineado_provider.dart';

/// Ámbar de advertencia. Es el color que ya usa el repo para avisos no
/// bloqueantes (`_BcvBadge`, banners de stock).
const Color _kBannerFondo = Color(0xFFF59E0B);

/// Banner que avisa que la sesión no corresponde al local visible.
///
/// Devuelve un [SizedBox.shrink] cuando todo está alineado, así que el
/// caller puede insertarlo sin un `if` alrededor.
class VistaPreviaBanner extends ConsumerWidget {
  const VistaPreviaBanner({super.key, this.onCambiarCuenta});

  /// Acción del botón. Si es `null`, el bannerno muestra botón: solo
  /// informa. El caller pone el suyo cuando sabe cómo cerrar sesión
  /// (p. ej. `main_pos_screen` ya tiene `_confirmLogout`).
  final VoidCallback? onCambiarCuenta;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alineado = ref.watch(tenantAlineadoProvider);
    if (alineado) return const SizedBox.shrink();

    final localId = ref.watch(localActualProvider);
    final local = localId == null
        ? null
        : ref.watch(localPorIdProvider(localId)).value;
    final nombreLocal = local?.nombre ?? 'otro local';

    return Material(
      color: _kBannerFondo,
      elevation: 2,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
          child: Row(
            children: [
              const Icon(Icons.visibility_outlined,
                  color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Modo vista previa · $nombreLocal',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Tu sesión es de otro negocio. Podés mirar, pero no '
                      'vender ni hacer cambios acá.',
                      style: TextStyle(color: Colors.white, fontSize: 11.5),
                    ),
                  ],
                ),
              ),
              if (onCambiarCuenta != null)
                TextButton(
                  onPressed: onCambiarCuenta,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.white.withValues(alpha: 0.18),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: const Size(0, 32),
                  ),
                  child: const Text('Cambiar de cuenta',
                      style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
