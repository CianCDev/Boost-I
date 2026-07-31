import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectedPrinter {
  final PrinterDevice device;
  final PrinterType type;

  SelectedPrinter({required this.device, required this.type});
}

class PrinterStateNotifier extends StateNotifier<SelectedPrinter?> {
  PrinterStateNotifier() : super(null);

  void seleccionarImpresora(PrinterDevice device, PrinterType type) {
    state = SelectedPrinter(device: device, type: type);
  }

  void deseleccionarImpresora() {
    state = null;
  }
}

final printerProvider = StateNotifierProvider<PrinterStateNotifier, SelectedPrinter?>((ref) {
  return PrinterStateNotifier();
});