// lib/features/pos/presentation/widgets/cash_closing/closing_button.dart
import 'package:flutter/material.dart';

class ClosingButton extends StatefulWidget {
  final bool isSyncing;
  final double total;
  final VoidCallback onPress;
  final bool isMobile;
  final bool isTablet;

  const ClosingButton({
    super.key,
    required this.isSyncing,
    required this.total,
    required this.onPress,
    required this.isMobile,
    required this.isTablet,
  });

  @override
  State<ClosingButton> createState() => _ClosingButtonState();
}

class _ClosingButtonState extends State<ClosingButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return SizedBox(
          height: widget.isMobile ? 50 : 60,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFF9100),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
              shadowColor: Color(0xFFFF9100).withValues(alpha: 0.4),
              padding: const EdgeInsets.symmetric(horizontal: 24),
            ),
            onPressed: widget.isSyncing ? null : widget.onPress,
            icon: widget.isSyncing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(
                    Icons.lock_rounded,
                    size: widget.isMobile ? 20 : 28,
                  ),
            label: Text(
              widget.isSyncing
                  ? 'Cerrando caja...'
                  : 'Cerrar Caja',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: widget.isMobile ? 14 : 18,
              ),
            ),
          ),
        );
      },
    );
  }
}