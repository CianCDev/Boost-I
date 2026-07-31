import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/sync_service.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  final service = SyncService();
  service.iniciarMonitoreo();
  
  ref.onDispose(() {
    service.detenerMonitoreo();
  });

  return service;
});