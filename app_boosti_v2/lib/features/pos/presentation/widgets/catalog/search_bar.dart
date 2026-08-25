// lib/features/pos/presentation/widgets/catalog/search_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/catalog_provider.dart';
import '../../utils/responsive_helper.dart';
import '../../utils/input_decoration_helper.dart';

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
    // ignore: unused_local_variable
    final isTablet = ResponsiveHelper.isTablet(context);
    // ignore: unused_local_variable
    final busqueda = ref.watch(catalogProvider).busqueda;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        focusNode: focusNode,
        onChanged: (value) => ref.read(catalogProvider.notifier).setBusqueda(value),
        enableInteractiveSelection: false,
        enableIMEPersonalizedLearning: false,
        autofillHints: const <String>[],
        enableSuggestions: false,
        autocorrect: false,
        decoration: InputDecorationHelper.build(
          context: context,
          label: '',
          hintText: 'Buscar por nombre / código (F2)...',
          prefixIcon: null, // lo manejamos manualmente abajo
          isDark: isDark,
        ).copyWith(
          prefixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  icon: Icon(Icons.qr_code_scanner_rounded, size: 28, color: colorScheme.onSurfaceVariant),
                  tooltip: 'Escanear código de barras',
                  constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                  padding: EdgeInsets.zero,
                  onPressed: onScanPressed,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.search, size: 22, color: colorScheme.onSurfaceVariant),
            ],
          ),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear, size: 18, color: colorScheme.onSurfaceVariant),
            onPressed: () => ref.read(catalogProvider.notifier).setBusqueda(''),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 14),
          filled: true,
          fillColor: colorScheme.surface,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: colorScheme.outline.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: colorScheme.primary.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
        ),
        onSubmitted: (value) {},
      ),
    );
  }
}