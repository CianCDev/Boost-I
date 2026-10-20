// lib/features/legal/presentation/terminos_aceptacion_screen.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../pos/presentation/utils/responsive_helper.dart';
import '../data/legal_acceptance_store.dart';
import '../data/legal_texts.dart';

/// Pantalla de aceptacion de terminos y politica de privacidad.
///
/// Va **justo antes** del PIN en el alta. Si el usuario no acepta las dos
/// casillas, el boton sigue deshabilitado: no hay "no acepto", no hay
/// "omitir". El unico camino es volver al registro.
///
/// ## Por que antes del PIN y no despues
///
/// El PIN es el que habilita el acceso al POS. Si la aceptacion ocurriera
/// despues, un usuario con un PIN ya configurado podria entrar sin haber
/// aceptado nunca. Ahi el aviso legal no protege nada.
///
/// ## Por que no puede salirse
///
/// `WillPopScope` intercepta el gesto de atras de Android. Si el usuario
/// retrocede, vuelve al registro, que es la unica salida. Es lo que pides:
/// si no acepta, se devuelve al registro.
class TerminosAceptacionScreen extends StatefulWidget {
  /// A donde ir cuando las dos casillas estan marcadas.
  final Widget destino;

  /// Se invoca antes de navegar a [destino].
  ///
  /// Lo usa [RegisterCompanyScreen] para encadenar con `SetupPinScreen`
  /// dentro del mismo `pushReplacement`, de modo que el gesto de atras no
  /// deje al usuario volver a una pantalla de aceptacion ya superada.
  final Future<void> Function()? onAceptado;

  const TerminosAceptacionScreen({
    super.key,
    required this.destino,
    this.onAceptado,
  });

  @override
  State<TerminosAceptacionScreen> createState() =>
      _TerminosAceptacionScreenState();
}

class _TerminosAceptacionScreenState extends State<TerminosAceptacionScreen> {
  final ScrollController _scroll = ScrollController();

  LegalAcceptanceStore? _store;
  bool _aceptaTerminos = false;
  bool _aceptaPrivacidad = false;
  bool _leyoTerminos = false;
  bool _leyoPrivacidad = false;
  bool _guardando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _preparar();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _preparar() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _store = LegalAcceptanceStore(prefs));
  }

  /// El boton se habilita solo con las dos casillas marcadas y despues de
  /// haber abierto los dos documentos.
  bool get _puedeAceptar =>
      !_guardando && _aceptaTerminos && _aceptaPrivacidad && _leyoTerminos && _leyoPrivacidad;

  Future<void> _aceptar() async {
    final store = _store;
    if (store == null) {
      setState(() => _error = 'No se pudo leer el almacenamiento local.');
      return;
    }

    setState(() {
      _guardando = true;
      _error = null;
    });

    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';

    final guardado = await store.registrar(userId);
    if (!guardado) {
      if (!mounted) return;
      setState(() {
        _guardando = false;
        _error = 'No se pudo registrar la aceptacion. '
            'Verificá el espacio disponible del dispositivo.';
      });
      return;
    }

    debugPrint('legal: aceptacion registrada · v$kLegalVersion · $userId');

    if (widget.onAceptado != null) {
      await widget.onAceptado!();
    }

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => widget.destino),
    );
  }

  Future<void> _abrirDocumento(String titulo, String subtitulo,
      List<({String titulo, String cuerpo})> secciones) async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => _DocumentoDialog(
        titulo: titulo,
        subtitulo: subtitulo,
        secciones: secciones,
      ),
    );
    if (!mounted) return;
    setState(() {
      if (titulo == LegalTerminos.titulo) {
        _leyoTerminos = true;
      } else {
        _leyoPrivacidad = true;
      }
    });
  }

  /// Vuelve al registro sin haber aceptado.
  ///
  /// Un `pop` simple alcanza: `RegisterCompanyScreen` hace `push` (no
  /// `replace`) para dejar el formulario debajo. Si por lo que sea no hay
  /// ruta debajo, se cae al inicio en lugar de dejar al usuario en el
  /// vacio.
  void _volverAlRegistro() {
    final nav = Navigator.of(context);
    if (nav.canPop()) {
      nav.pop();
    } else {
      nav.popUntil((r) => r.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final cs = Theme.of(context).colorScheme;
    final ancho = isMobile ? double.infinity : 560.0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _volverAlRegistro();
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                cs.surfaceContainerHighest.withValues(alpha: 0.8),
                cs.primaryContainer,
              ],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Container(
                width: ancho,
                padding: EdgeInsets.all(isMobile ? 20 : 28),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.gavel_rounded,
                          size: 32,
                          color: cs.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'Antes de empezar',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isMobile ? 20 : 24,
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Leé los terminos del servicio y la politica de '
                      'privacidad. Necesitas marcar las dos casillas para '
                      'seguir.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.45,
                        color: cs.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 20),

                    _BotonDocumento(
                      titulo: LegalTerminos.titulo,
                      leido: _leyoTerminos,
                      secciones: LegalTerminos.secciones.length,
                      color: cs.primary,
                      onTap: () => _abrirDocumento(
                        LegalTerminos.titulo,
                        'Version $kLegalVersion · $kLegalFecha',
                        LegalTerminos.secciones,
                      ),
                    ),
                    const SizedBox(height: 10),

                    _BotonDocumento(
                      titulo: LegalPrivacidad.titulo,
                      leido: _leyoPrivacidad,
                      secciones: LegalPrivacidad.secciones.length,
                      color: const Color(0xFF7C3AED),
                      onTap: () => _abrirDocumento(
                        LegalPrivacidad.titulo,
                        'Version $kLegalVersion · $kLegalFecha',
                        LegalPrivacidad.secciones,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _Casilla(
                      valor: _aceptaTerminos,
                      habilitado: !_guardando,
                      etiqueta: 'Acepto los Terminos y Condiciones de '
                          '${LegalIdentidad.razonSocial}.',
                      onChanged: (v) => setState(() => _aceptaTerminos = v),
                    ),
                    const SizedBox(height: 8),
                    _Casilla(
                      valor: _aceptaPrivacidad,
                      habilitado: !_guardando,
                      etiqueta: 'Acepto la Politica de Privacidad y el '
                          'tratamiento de mis datos personales.',
                      onChanged: (v) => setState(() => _aceptaPrivacidad = v),
                    ),

                    if (!_leyoTerminos || !_leyoPrivacidad) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.info_outline_rounded,
                              size: 15, color: cs.onSurface.withValues(alpha: 0.6)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Abrí los dos documentos para habilitar el boton.',
                              style: TextStyle(
                                fontSize: 12,
                                color: cs.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline_rounded,
                                size: 18, color: Colors.red.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _error!,
                                style: TextStyle(
                                    fontSize: 13, color: Colors.red.shade700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),

                    SizedBox(
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: _puedeAceptar ? _aceptar : null,
                        icon: _guardando
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.check_circle_outline),
                        label: Text(
                          _guardando ? 'Guardando…' : 'Aceptar y continuar',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextButton.icon(
                      onPressed: _guardando ? null : _volverAlRegistro,
                      icon: const Icon(Icons.arrow_back, size: 18),
                      label: const Text('Volver al registro'),
                    ),

                    const SizedBox(height: 4),
                    Text(
                      '${LegalIdentidad.razonSocial} · ${LegalIdentidad.contacto}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10.5,
                        color: cs.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Boton que abre un documento legal.
class _BotonDocumento extends StatelessWidget {
  final String titulo;
  final bool leido;
  final int secciones;
  final Color color;
  final VoidCallback onTap;

  const _BotonDocumento({
    required this.titulo,
    required this.leido,
    required this.secciones,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surfaceContainerHighest.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              Icon(
                leido ? Icons.task_alt_rounded : Icons.article_outlined,
                size: 22,
                color: color,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$secciones secciones',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: cs.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              if (leido)
                Icon(Icons.check_circle, size: 18, color: color)
              else
                const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

/// Casilla de aceptacion con la misma validacion de PIN que el resto del app.
class _Casilla extends StatelessWidget {
  final bool valor;
  final bool habilitado;
  final String etiqueta;
  final ValueChanged<bool> onChanged;

  const _Casilla({
    required this.valor,
    required this.habilitado,
    required this.etiqueta,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: habilitado ? () => onChanged(!valor) : null,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 26,
              height: 26,
              child: Checkbox(
                value: valor,
                onChanged: habilitado ? (v) => onChanged(v ?? false) : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  etiqueta,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: cs.onSurface.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog modal con el documento completo.
class _DocumentoDialog extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final List<({String titulo, String cuerpo})> secciones;

  const _DocumentoDialog({
    required this.titulo,
    required this.subtitulo,
    required this.secciones,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final esMovil = ResponsiveHelper.isMobile(context);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 720,
          maxHeight: MediaQuery.of(context).size.height * (esMovil ? 0.88 : 0.82),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Cabecera ──
            Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 14),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          titulo,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: cs.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitulo,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: cs.onPrimaryContainer
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // ── Cuerpo ──
            Flexible(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                itemCount: secciones.length,
                itemBuilder: (_, i) {
                  final s = secciones[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.titulo,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: cs.primary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          s.cuerpo,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.55,
                            color: cs.onSurface.withValues(alpha: 0.88),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ── Pie ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                  ),
                  child: const Text(
                    'Entendido',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}