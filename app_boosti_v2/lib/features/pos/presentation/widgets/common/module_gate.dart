// lib/features/pos/presentation/widgets/common/module_gate.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/business_mode_provider.dart';

/// Envuelve una pantalla que requiere un plan activo.
///
/// Si `planActivo == false`, muestra una pantalla de bloqueo con salida
/// limpia (`Volver`). No hace `Navigator.pop` automático: el usuario
/// puede haber llegado por ruta alternativa (deep link, dashboard,
/// hotkey) y necesita entender por qué no puede usar el módulo.
///
/// ## Por qué existe
/// El gating por plan hoy vive solo en la entrada del menú
/// (`menu_config.dart:169`). `PedidosProveedorScreen` y `LotesScreen` se
/// montan vía `Navigator.push` sin guarda, así que cualquier ruta
/// alternativa las abre sin validar el plan. `ModuleGate` cierra ese
/// agujero en un solo sitio.
///
/// ## ⚠️ Gatea por PLAN, no por feature
/// Se apoya en `planActivo` y no en `flags.lotes` / `flags.pedidosProveedores`
/// a propósito. Ambas features usan `defaultVisible: true` porque no
/// tienen clave real en `plans.features`
/// (`business_mode_provider.dart:244-246`), así que se reducen a
/// `planActivo`. Usar el flag de feature hoy no aportaría nada y daría
/// la falsa impresión de que hay granularidad por plan.
class ModuleGate extends ConsumerWidget {
  final Widget child;
  final String moduleName;

  const ModuleGate({
    super.key,
    required this.child,
    required this.moduleName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flags = ref.watch(featureFlagsProvider);
    if (!flags.planActivo) {
      return _ModuleLockedScreen(moduleName: moduleName);
    }
    return child;
  }
}

class _ModuleLockedScreen extends StatelessWidget {
  final String moduleName;

  const _ModuleLockedScreen({required this.moduleName});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(moduleName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 64,
                color: cs.onSurfaceVariant.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 20),
              Text(
                'Módulo no disponible',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Tu suscripción actual no incluye "$moduleName".',
                style: TextStyle(
                  fontSize: 14,
                  color: cs.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text('Volver'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
