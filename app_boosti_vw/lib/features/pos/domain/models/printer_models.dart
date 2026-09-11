/// Modelos para la gestión de impresoras POS
enum PrinterType {
  bluetooth,
  network,
  // usb, // Si lo necesitas en el futuro
}

class PrinterDevice {
  final String name;
  final String address; // MAC para Bluetooth, IP para Network
  final PrinterType type;
  final int? port; // Puerto para red (generalmente 9100)

  PrinterDevice({
    required this.name,
    required this.address,
    required this.type,
    this.port = 9100,
  });

  @override
  String toString() => '$name (${type.name})';

  // Para guardar en SharedPreferences
  Map<String, dynamic> toJson() => {
        'name': name,
        'address': address,
        'type': type.name,
        'port': port,
      };

  factory PrinterDevice.fromJson(Map<String, dynamic> json) {
    return PrinterDevice(
      name: json['name'],
      address: json['address'],
      type: PrinterType.values.firstWhere((e) => e.name == json['type']),
      port: json['port'],
    );
  }
}