// lib/features/pos/presentation/widgets/tutorial_dialog.dart
import 'package:app_boosti_v2/features/pos/presentation/widgets/common/glass_dialog.dart';
import 'package:flutter/material.dart';

/// Diálogo de tutorial / guía rápida de la app.
///
/// Muestra una secuencia de "pasos" con:
///   - Un título y una descripción breve.
///   - Un espacio reservado para una imagen o GIF demostrativo.
///   - Navegación: Atrás / Siguiente / Saltar.
///   - Indicador de progreso (puntitos).
///
/// Para rellenar las imágenes, cada paso tiene un `imagePath` opcional.
/// Coloca los archivos en `assets/tutorial/` y regístralos en
/// `pubspec.yaml` bajo la sección `flutter: assets:`.
class TutorialDialog extends StatefulWidget {
  const TutorialDialog({super.key});

  /// Atajo: abre el tutorial como diálogo.
  static Future<void> mostrar(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => const TutorialDialog(),
    );
  }

  @override
  State<TutorialDialog> createState() => _TutorialDialogState();
}

class _TutorialDialogState extends State<TutorialDialog> {
  final PageController _pageController = PageController();
  int _paginaActual = 0;

  /// Contenido de cada paso del tutorial.
  ///
  /// Para añadir imágenes más adelante, simplemente coloca la ruta en
  /// `imagePath` (ej: 'assets/tutorial/venta_basica.gif'). El widget
  /// detecta si es null y muestra un placeholder en su lugar.
  static const List<_TutorialPaso> _pasos = [
    _TutorialPaso(
      icono: Icons.shopping_cart_rounded,
      color: Color(0xFF10B981),
      titulo: 'Venta básica',
      descripcion:
          'Registra una venta en segundos. Escanea el código de barras o '
          'busca el producto por nombre, ajusta la cantidad y presiona '
          'Cobrar para seleccionar el método de pago.',
      imagePath: null, // 'assets/tutorial/venta_basica.gif'
    ),
    _TutorialPaso(
      icono: Icons.workspaces_rounded,
      color: Color(0xFF3B82F6),
      titulo: 'Venta al mayor',
      descripcion:
          'Cambia al modo mayorista para aplicar precios por volumen. '
          'Ideal para clientes con RIF o que compran por bulto. '
          'Los descuentos se aplican automáticamente según la cantidad.',
      imagePath: null, // 'assets/tutorial/venta_mayor.gif'
    ),
    _TutorialPaso(
      icono: Icons.admin_panel_settings_rounded,
      color: Color(0xFF8B5CF6),
      titulo: 'Administración',
      descripcion:
          'Gestiona productos, categorías, marcas y proveedores. '
          'Actualiza precios, stock mínimo, y sube imágenes de los '
          'productos. Los cambios se sincronizan automáticamente.',
      imagePath: null, // 'assets/tutorial/administracion.gif'
    ),
    _TutorialPaso(
      icono: Icons.history_rounded,
      color: Color(0xFFF59E0B),
      titulo: 'Historiales',
      descripcion:
          'Consulta todas las ventas, movimientos de inventario, turnos '
          'y auditoría. Filtra por fecha, empleado o tipo de operación. '
          'Exporta los reportes que necesites.',
      imagePath: null, // 'assets/tutorial/historiales.gif'
    ),
    _TutorialPaso(
      icono: Icons.badge_rounded,
      color: Color(0xFFEC4899),
      titulo: 'Empleados',
      descripcion:
          'Crea usuarios, asígnales un rol (admin, cajero, supervisor) '
          'y configura su PIN de acceso. Cada empleado verá únicamente '
          'las pantallas que le corresponden.',
      imagePath: null, // 'assets/tutorial/empleados.gif'
    ),
    _TutorialPaso(
      icono: Icons.people_alt_rounded,
      color: Color(0xFF06B6D4),
      titulo: 'Monitor de empleados',
      descripcion:
          'Ve en tiempo real quién está activo, en descanso o '
          'desconectado. Desde aquí puedes supervisar la operación '
          'de todos los locales conectados.',
      imagePath: null, // 'assets/tutorial/monitor_empleados.gif'
    ),
    _TutorialPaso(
      icono: Icons.dashboard_customize_rounded,
      color: Color(0xFF64748B),
      titulo: 'Barras laterales y atajos',
      descripcion:
          'La barra lateral te da acceso rápido a todos los módulos. '
          'Usa los atajos de teclado para acelerar tu trabajo: '
          'F1 ayuda, F2 venta rápida, F3 buscar producto, Esc cerrar.',
      imagePath: null, // 'assets/tutorial/atajos.gif'
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _irAPagina(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  void _siguiente() {
    if (_paginaActual < _pasos.length - 1) {
      _irAPagina(_paginaActual + 1);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _anterior() {
    if (_paginaActual > 0) {
      _irAPagina(_paginaActual - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final esUltimo = _paginaActual == _pasos.length - 1;
    final esPrimero = _paginaActual == 0;

    return GlassDialog(
      maxWidth: 640,
      maxHeightFactor: 0.9,
      accentColor: _pasos[_paginaActual].color,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ═══ HEADER ═══
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 16, 8),
            child: Row(
              children: [
                Icon(
                  Icons.school_rounded,
                  color: _pasos[_paginaActual].color,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Guía rápida de BoostiPos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: isDark ? Colors.white70 : Colors.grey.shade700,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // ═══ CONTENIDO (PageView) ═══
          Flexible(
            child: SizedBox(
              height: 460,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pasos.length,
                onPageChanged: (i) => setState(() => _paginaActual = i),
                itemBuilder: (context, index) {
                  return _PasoContenido(paso: _pasos[index]);
                },
              ),
            ),
          ),

          // ═══ INDICADOR DE PÁGINA ═══
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pasos.length, (i) {
                final activo = i == _paginaActual;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: activo ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: activo
                        ? _pasos[_paginaActual].color
                        : _pasos[_paginaActual]
                            .color
                            .withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),

          const Divider(height: 1),

          // ═══ NAVEGACIÓN ═══
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Row(
              children: [
                // Botón "Saltar" solo si no está en el último paso
                if (!esUltimo)
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor:
                          isDark ? Colors.white60 : Colors.grey.shade600,
                    ),
                    child: const Text('Saltar'),
                  ),
                const Spacer(),

                // Botón "Anterior"
                if (!esPrimero)
                  OutlinedButton.icon(
                    onPressed: _anterior,
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    label: const Text('Anterior'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _pasos[_paginaActual].color,
                      side: BorderSide(
                        color: _pasos[_paginaActual]
                            .color
                            .withValues(alpha: 0.4),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),

                if (!esPrimero) const SizedBox(width: 10),

                // Botón "Siguiente" / "Finalizar"
                ElevatedButton.icon(
                  onPressed: _siguiente,
                  icon: Icon(
                    esUltimo
                        ? Icons.check_rounded
                        : Icons.arrow_forward_rounded,
                    size: 18,
                  ),
                  label: Text(esUltimo ? '¡Entendido!' : 'Siguiente'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _pasos[_paginaActual].color,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// CONTENIDO DE UN PASO
// ══════════════════════════════════════════════════════════════════

class _PasoContenido extends StatelessWidget {
  final _TutorialPaso paso;

  const _PasoContenido({required this.paso});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Encabezado del paso: ícono + título ──
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: paso.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(paso.icono, color: paso.color, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  paso.titulo,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // ── Área de imagen / GIF ──
          _ImagenArea(paso: paso),

          const SizedBox(height: 18),

          // ── Descripción ──
          Text(
            paso.descripcion,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.85)
                  : const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}

/// Muestra la imagen del paso si existe; si no, un placeholder
/// con el ícono del paso y un mensaje sutil.
class _ImagenArea extends StatelessWidget {
  final _TutorialPaso paso;

  const _ImagenArea({required this.paso});

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          color: paso.color.withValues(alpha: 0.08),
          border: Border.all(
            color: paso.color.withValues(alpha: 0.25),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: paso.imagePath != null
            ? Image.asset(
                paso.imagePath!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(context),
              )
            : _placeholder(context),
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            paso.icono,
            size: 64,
            color: paso.color.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 12),
          Text(
            'Aquí irá la imagen o GIF de\ndemostración',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.4)
                  : Colors.black.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// MODELO DE UN PASO
// ══════════════════════════════════════════════════════════════════

class _TutorialPaso {
  final IconData icono;
  final Color color;
  final String titulo;
  final String descripcion;
  final String? imagePath;

  const _TutorialPaso({
    required this.icono,
    required this.color,
    required this.titulo,
    required this.descripcion,
    this.imagePath,
  });
}