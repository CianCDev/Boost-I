import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/catalog_provider.dart';
import '../../utils/responsive_helper.dart';

class CatalogSearchBar extends ConsumerWidget {
  final FocusNode focusNode;
  final VoidCallback onScanPressed;

  const CatalogSearchBar({
    super.key,
    required this.focusNode,
    required this.onScanPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTablet = ResponsiveHelper.isTablet(context);
    final busqueda = ref.watch(catalogProvider).busqueda;

    return SizedBox(
      height: 46,
      child: TextField(
        focusNode: focusNode,
        onChanged: (value) => ref.read(catalogProvider.notifier).setBusqueda(value),
        decoration: InputDecoration(
          hintText: 'Buscar por nombre / código (F2)...',
          hintStyle: TextStyle(
            fontSize: isTablet ? 18 : 14,
            color: const Color(0xFF94A3B8),
          ),
          prefixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.qr_code_scanner_rounded, size: 28, color: Color(0xFF475569)),
                  tooltip: 'Escanear código de barras',
                  constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                  padding: EdgeInsets.zero,
                  onPressed: onScanPressed,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.search, size: 22, color: Color(0xFF64748B)),
            ],
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear, size: 18),
            onPressed: () => ref.read(catalogProvider.notifier).setBusqueda(''),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 14),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: const Color(0xFFCBD5E1),
              width: isTablet ? 2.5 : 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
          ),
        ),
        onSubmitted: (value) {
          // Si solo hay un producto filtrado, abrir modal de cantidad
          final state = ref.read(catalogProvider);
          if (state.productosFiltrados.length == 1) {
            // Necesitamos un callback desde el padre para abrir el modal
            // Podemos usar un GlobalKey o un provider, pero lo dejamos como callback
            // Por ahora, lo manejamos con un FocusNode y escuchamos en el widget padre
          }
        },
      ),
    );
  }
}