// lib/features/pos/presentation/widgets/wholesale/all_payment_methods_dialog.dart
import 'package:flutter/material.dart';

/// Método de pago secundario.
class PaymentMethodOption {
  final String key;
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;

  const PaymentMethodOption({
    required this.key,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

/// Lista completa de métodos de pago secundarios.
const List<PaymentMethodOption> kSecondaryPaymentMethods = [
  PaymentMethodOption(
    key: 'transferencia_bs',
    label: 'Transferencia bancaria',
    subtitle: 'Pago en bolívares',
    icon: Icons.account_balance_rounded,
    color: Color(0xFF3B82F6),
  ),
  PaymentMethodOption(
    key: 'binance_pay',
    label: 'Binance Pay',
    subtitle: 'Pago en USDT',
    icon: Icons.currency_bitcoin_rounded,
    color: Color(0xFFF0B90B),
  ),
  PaymentMethodOption(
    key: 'transferencia_usdt',
    label: 'Transferencia USDT',
    subtitle: 'TRC20 / ERC20',
    icon: Icons.swap_horiz_rounded,
    color: Color(0xFF26A17B),
  ),
  PaymentMethodOption(
    key: 'zelle',
    label: 'Zelle',
    subtitle: 'Transferencia USD',
    icon: Icons.attach_money_rounded,
    color: Color(0xFF8B5CF6),
  ),
  PaymentMethodOption(
    key: 'paypal',
    label: 'PayPal',
    subtitle: 'Pago en USD',
    icon: Icons.payment_rounded,
    color: Color(0xFF0070BA),
  ),
  PaymentMethodOption(
    key: 'otros',
    label: 'Otros',
    subtitle: 'Método personalizado',
    icon: Icons.more_horiz_rounded,
    color: Color(0xFF64748B),
  ),
];

/// Diálogo con la lista completa de métodos de pago secundarios.
///
/// Devuelve la `key` del método seleccionado o `null` si se cancela.
class AllPaymentMethodsDialog extends StatefulWidget {
  const AllPaymentMethodsDialog({super.key});

  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (_) => const AllPaymentMethodsDialog(),
    );
  }

  @override
  State<AllPaymentMethodsDialog> createState() =>
      _AllPaymentMethodsDialogState();
}

class _AllPaymentMethodsDialogState extends State<AllPaymentMethodsDialog> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cs = theme.colorScheme;

    final filtrados = kSecondaryPaymentMethods.where((m) {
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return m.label.toLowerCase().contains(q) ||
          m.subtitle.toLowerCase().contains(q);
    }).toList();

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 640),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.08),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 24,
              spreadRadius: -4,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.payments_rounded,
                      size: 22,
                      color: Color(0xFF3B82F6),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Todos los métodos',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, size: 22),
                    color: cs.onSurfaceVariant,
                  ),
                ],
              ),
            ),

            // ── Search ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'Buscar método…',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.03),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: cs.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: cs.primary, width: 1.5),
                  ),
                ),
              ),
            ),

            Divider(
              height: 1,
              color: cs.outlineVariant.withValues(alpha: 0.3),
            ),

            // ── Lista ──
            Flexible(
              child: filtrados.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(40),
                      child: Text(
                        'Sin resultados',
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      itemCount: filtrados.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 6),
                      itemBuilder: (_, i) {
                        final m = filtrados[i];
                        return _buildMetodoTile(m, isDark, cs);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetodoTile(
    PaymentMethodOption m,
    bool isDark,
    ColorScheme cs,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.of(context).pop(m.key),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.03)
                : Colors.black.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: m.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(m.icon, size: 20, color: m.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      m.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      m.subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: cs.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}