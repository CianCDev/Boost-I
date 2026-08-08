import 'package:permission_handler/permission_handler.dart';

Future<bool> requestAllPermissions() async {
  List<Permission> permissions = [
    Permission.location,
    Permission.bluetooth,
    Permission.bluetoothScan,
    Permission.bluetoothConnect,
  ];

  Map<Permission, PermissionStatus> statuses = await permissions.request();
  
  bool allGranted = statuses.values.every((status) => status.isGranted);
  
  if (!allGranted) {
    if (statuses[Permission.location]?.isPermanentlyDenied == true ||
        statuses[Permission.bluetooth]?.isPermanentlyDenied == true) {
      openAppSettings();
    }
  }
  return allGranted;
}