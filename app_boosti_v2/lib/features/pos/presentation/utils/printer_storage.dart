import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/printer_models.dart';

class PrinterStorage {
  static const String _key = 'selected_printer';

  static Future<void> savePrinter(PrinterDevice printer) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(printer.toJson());
    await prefs.setString(_key, jsonString);
  }

  static Future<PrinterDevice?> loadPrinter() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_key);
    if (jsonString == null) return null;
    try {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return PrinterDevice.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  static Future<void> clearPrinter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}