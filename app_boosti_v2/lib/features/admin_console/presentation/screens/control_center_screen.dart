import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../pos/presentation/utils/responsive_helper.dart';
import '../../../pos/presentation/widgets/appbar.dart';
import '../../providers/admin_access_provider.dart';
import 'admin_dashboard_screen.dart';
import 'clients_screen.dart';
import 'dev_tools_screen.dart';
import 'plans_screen.dart';

/// Contenedor raíz del Control Center.
///
/// Alberga las 4 secciones del panel y cambia entre ellas con un
/// `NavigationRail` (desktop/tablet) o `NavigationBar` (móvil). El
/// `IndexedStack` conserva el estado de cada sección al cambiar de pestaña,
/// para no perder la carga ya hecha del Dashboard o de la lista de Clientes.
///
/// Además de la navegación, se repite la comprobación de acceso que ya
/// hace `user_settings_screen.dart`: aunque el botón esté oculto, un
/// deep-link o un futuro refactor podrían saltar ese gate. El RLS de
/// Supabase seguiría bloqueando los datos, pero es mejor fallar antes.
class ControlCenterScreen extends ConsumerStatefulWidget {
  const ControlCenterScreen({super.key});

  @override
  ConsumerState<ControlCenterScreen> createState() =>
      _ControlCenterScreenState();
}

class _ControlCenterScreenState extends ConsumerState<ControlCenterScreen> {
  /// Índice de la sección visible dentro de [_secciones].
  int _seccionActual = 0;

  /// Las 4 secciones del Control Center, en orden de navegación.
  ///
  /// Son `const`: las pantallas no reciben parámetros y sus widgets son
  /// inmutables, así que se pueden reutilizar entre instancias.
  static const List<_SeccionCC> _secciones = [
    _SeccionCC(
      icono: Icons.dashboard_rounded,
      label: 'Dashboard',
      pantalla: AdminDashboardScreen(),
    ),
    _SeccionCC(
      icono: Icons.people_rounded,
      label: 'Clientes',
      pantalla: ClientsScreen(),
    ),
    _SeccionCC(
      icono: Icons.credit_card_rounded,
      label: 'Planes',
      pantalla: PlansScreen(),
    ),
    _SeccionCC(
      icono: Icons.build_rounded,
      label: 'Dev Tools',
      pantalla: DevToolsScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // En ConsumerState el `ref` es una propiedad, no un parámetro de build.
    final tieneAcceso = ref.watch(hasAdminAccessProvider);

    if (!tieneAcceso) return _sinAcceso();

    // Tablet se trata como desktop: el rail lateral cabe mejor que una
    // barra inferior en pantallas anchas.
    final esAncho = ResponsiveHelper.isDesktop(context) ||
        ResponsiveHelper.isTablet(context);

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Control Center',
        showBackButton: true,
      ),
      body: esAncho ? _buildRail() : _stack(),
      bottomNavigationBar: esAncho ? null : _buildBottomNav(),
    );
  }

  // ═════════════════════════════════════════════════════════════
  // NAVEGACIÓN
  // ═════════════════════════════════════════════════════════════

  /// Layout desktop/tablet: rail lateral + contenido.
  Widget _buildRail() {
    return Row(
      children: [
        NavigationRail(
          selectedIndex: _seccionActual,
          onDestinationSelected: (i) => setState(() => _seccionActual = i),
          labelType: NavigationRailLabelType.all,
          leading: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.admin_panel_settings_rounded,
                color: Color(0xFF8B5CF6),
                size: 22,
              ),
            ),
          ),
          destinations: [
            for (final s in _secciones)
              NavigationRailDestination(
                icon: Icon(s.icono),
                label: Text(s.label),
              ),
          ],
        ),
        const VerticalDivider(thickness: 1, width: 1),
        Expanded(child: _stack()),
      ],
    );
  }

  /// Barra inferior para móvil.
  Widget _buildBottomNav() {
    return NavigationBar(
      selectedIndex: _seccionActual,
      onDestinationSelected: (i) => setState(() => _seccionActual = i),
      destinations: [
        for (final s in _secciones)
          NavigationDestination(
            icon: Icon(s.icono),
            label: s.label,
          ),
      ],
    );
  }

  /// Contenido de la sección activa, preservando el estado de las demás.
  Widget _stack() {
    return IndexedStack(
      index: _seccionActual,
      children: [for (final s in _secciones) s.pantalla],
    );
  }

  // ═════════════════════════════════════════════════════════════
  // SIN ACCESO
  // ═════════════════════════════════════════════════════════════

  /// Pantalla mostrada cuando el usuario no cumple los requisitos de acceso.
  Widget _sinAcceso() {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Control Center',
        showBackButton: true,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No tienes acceso al Control Center.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

/// Definición de una sección del Control Center.
class _SeccionCC {
  final IconData icono;
  final String label;
  final Widget pantalla;

  const _SeccionCC({
    required this.icono,
    required this.label,
    required this.pantalla,
  });
}
