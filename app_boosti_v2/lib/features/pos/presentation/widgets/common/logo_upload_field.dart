// lib/features/pos/presentation/widgets/common/logo_upload_field.dart
//
// Campo de subida de logo para el local y para las marcas.
//
// Guarda el PATH del objeto en el bucket, nunca una URL firmada: una
// signed URL caduca en 1 hora y, si se persiste, el objeto queda
// huérfano. Ver la regla de Storage en `AGENTS.MD`.
//
// ⚠️ El bucket tiene que existir Y tener policies de RLS por tenant.
//    Crear el bucket en el dashboard no alcanza: sin policies el upload
//    falla con "row-level security violation", que acá se traduce en un
//    Snackbar genérico.
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Selector y previsualizador de un logo almacenado en Supabase Storage.
///
/// El path siempre empieza con el tenant_id, que es contra lo que
/// evalúan las policies del bucket:
///     {tenant_id}/logo_123.png
class LogoUploadField extends ConsumerStatefulWidget {
  const LogoUploadField({
    super.key,
    required this.pathActual,
    required this.onPathChanged,
    required this.bucket,
    required this.tenantId,
  });

  /// Path guardado actualmente, o null si no hay logo.
  final String? pathActual;

  /// Se dispara con el path nuevo, o con null si se quitó el logo.
  ///
  /// NO sube ni borra nada: solo informa. Quien llama decide cuándo
  /// persistir.
  final ValueChanged<String?> onPathChanged;

  final String bucket;

  final String tenantId;

  @override
  ConsumerState<LogoUploadField> createState() => _LogoUploadFieldState();
}

class _LogoUploadFieldState extends ConsumerState<LogoUploadField> {
  bool _ocupado = false;

  /// Tope de bytes del archivo original, antes de redimensionar.
  static const _maxBytes = 2 * 1024 * 1024;

  /// Lado máximo del logo. 1024 es suficiente para cualquier impresión y
  /// evita subir fotos de 12 MP de un teléfono.
  static const _maxLado = 1024;

  static const _extensionesOk = {'png', 'jpg', 'jpeg'};

  static const _colorPrimary = Color(0xFF8B5CF6);
  static const _colorDanger = Color(0xFFEF4444);

  Future<void> _seleccionarYSubir() async {
    if (_ocupado) return;

    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: _maxLado.toDouble(),
      maxHeight: _maxLado.toDouble(),
      imageQuality: 90,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    if (!mounted) return;

    if (bytes.length > _maxBytes) {
      _avisar('La imagen supera los 2 MB.');
      return;
    }

    final extension = (picked.name.split('.').last).toLowerCase();
    if (!_extensionesOk.contains(extension)) {
      _avisar('Formato no soportado. Usá PNG o JPG.');
      return;
    }

    setState(() => _ocupado = true);
    try {
      final bytesFinales = await _redimensionarSiHaceFalta(bytes);
      if (bytesFinales == null) {
        if (mounted) setState(() => _ocupado = false);
        return;
      }

      final path =
          '${widget.tenantId}/logo_${DateTime.now().millisecondsSinceEpoch}.png';

      await Supabase.instance.client.storage
          .from(widget.bucket)
          .uploadBinary(
            path,
            bytesFinales,
            fileOptions: const FileOptions(
              contentType: 'image/png',
              upsert: false,
            ),
          );

      widget.onPathChanged(path);
    } catch (e) {
      // Un fallo de RLS (bucket sin policies) llega acá y sin el nombre
      // del bucket es indistinguible de un problema de red.
      _avisar(
        'No se pudo subir el logo. Si el bucket "${widget.bucket}" no tiene '
        'policies de RLS, el Storage lo rechaza.\n$e',
      );
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  /// Devuelve los bytes a subir, redimensionados si superan `_maxLado`.
  ///
  /// El redimensionado va en bytes de imagen, no en un widget: si se
  /// subiera la imagen original, la impresora térmica recibiría una
  /// bitmap de 4000 px donde entran 512.
  Future<Uint8List?> _redimensionarSiHaceFalta(Uint8List bytes) async {
    final decodificada = img.decodeImage(bytes);
    if (decodificada == null) {
      _avisar('No se pudo procesar la imagen. Puede estar corrupta.');
      return null;
    }

    if (decodificada.width <= _maxLado && decodificada.height <= _maxLado) {
      return bytes;
    }

    // Un solo lado: el que exceda. `copyResize` preserva el aspect ratio.
    final redimensionada = img.copyResize(
      decodificada,
      width: decodificada.width > decodificada.height ? _maxLado : null,
      height: decodificada.height >= decodificada.width ? _maxLado : null,
      interpolation: img.Interpolation.average,
    );
    // PNG, no JPG: el upload declara `contentType: 'image/png'` y el path
    // termina en `.png`. Subir bytes JPEG con esa declaracion deja un
    // objeto que se ve bien en el preview pero miente sobre su formato.
    return Uint8List.fromList(img.encodePng(redimensionada));
  }

  void _avisar(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mensaje),
      backgroundColor: _colorDanger,
    ));
  }

  void _quitar() {
    widget.onPathChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    final path = widget.pathActual;
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _preview(path),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Logo del local',
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 2),
                  Text(
                    path ?? 'Se imprime en los tickets y comprobantes.',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _boton(
                        texto: path == null ? 'Subir logo' : 'Cambiar',
                        icono: Icons.add_photo_alternate_outlined,
                        onTap: _ocupado ? null : _seleccionarYSubir,
                        primario: true,
                      ),
                      if (path != null)
                        _boton(
                          texto: 'Quitar',
                          icono: Icons.delete_outline,
                          onTap: _ocupado ? null : _quitar,
                          primario: false,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        if (_ocupado) ...[
          const SizedBox(height: 8),
          const LinearProgressIndicator(minHeight: 2),
        ],
      ],
    );
  }

  Widget _preview(String? path) {
    const lado = 64.0;
    return Container(
      width: lado,
      height: lado,
      decoration: BoxDecoration(
        color: _colorPrimary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _colorPrimary.withValues(alpha: 0.25)),
      ),
      clipBehavior: Clip.antiAlias,
      child: path == null
          ? Icon(Icons.image_outlined, color: _colorPrimary, size: 26)
          : FutureBuilder<String>(
              future: _SignedUrlCache.obtener(path, widget.bucket),
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }
                if (!snap.hasData || snap.hasError || snap.data == null) {
                  return Icon(Icons.broken_image_outlined,
                      color: _colorDanger, size: 22);
                }
                return Image.network(
                  snap.data!,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(Icons.broken_image_outlined,
                      color: _colorDanger, size: 22),
                );
              },
            ),
    );
  }

  Widget _boton({
    required String texto,
    required IconData icono,
    required VoidCallback? onTap,
    required bool primario,
  }) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icono, size: 16),
      label: Text(texto),
      style: TextButton.styleFrom(
        foregroundColor: primario ? Colors.white : null,
        backgroundColor: primario ? _colorPrimary : null,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

/// Cache de signed URLs por path, con expiración propia.
///
/// Sin esto, cada rebuild firmaba una URL nueva para cada preview y el
/// Storage recibe una request por frame. La entrada se descarta 5 min antes
/// de la expiración real: servir una URL a punto de morir produce una
/// imagen rota.
class _SignedUrlCache {
  static final Map<String, _UrlFirmada> _cache = {};
  static const Duration _margen = Duration(minutes: 5);

  static Future<String> obtener(String path, String bucket) async {
    final clave = '$bucket/$path';
    final hit = _cache[clave];
    final ahora = DateTime.now();
    if (hit != null && hit.expira.isAfter(ahora)) return hit.url;

    final url = await Supabase.instance.client.storage
        .from(bucket)
        .createSignedUrl(path, 3600);

    _cache[clave] = _UrlFirmada(
      url,
      ahora.add(const Duration(hours: 1)).subtract(_margen),
    );
    return url;
  }
}

class _UrlFirmada {
  const _UrlFirmada(this.url, this.expira);

  final String url;
  final DateTime expira;
}