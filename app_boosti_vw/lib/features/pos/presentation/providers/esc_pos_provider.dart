import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/printer_models.dart';

@immutable
class SelectedPrinter {
  final PrinterDevice device;
  final PrinterType type;

  const SelectedPrinter({
    required this.device,
    required this.type,
  });

  SelectedPrinter copyWith({
    PrinterDevice? device,
    PrinterType? type,
  }) {
    return SelectedPrinter(
      device: device ?? this.device,
      type: type ?? this.type,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SelectedPrinter &&
          runtimeType == other.runtimeType &&
          device == other.device &&
          type == other.type;

  @override
  int get hashCode => device.hashCode ^ type.hashCode;
}

class PrinterStateNotifier extends StateNotifier<SelectedPrinter?> {
  PrinterStateNotifier() : super(null);

  void seleccionarImpresora(PrinterDevice device, PrinterType type) {
    state = SelectedPrinter(device: device, type: type);
  }

  void deseleccionarImpresora() {
    state = null;
  }

  bool get hayImpresora => state != null;
}

final printerProvider =
    StateNotifierProvider<PrinterStateNotifier, SelectedPrinter?>(
  (ref) => PrinterStateNotifier(),
);