import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/scale_service.dart';

final scaleServiceProvider = Provider<ScaleService>((ref) {
  final service = ScaleService();
  ref.onDispose(service.dispose);
  return service;
});
