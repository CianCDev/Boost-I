// lib/features/pos/presentation/providers/telegram_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/telegram_config_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/services/telegram/telegram_service.dart';

final isarServiceProvider = Provider<IsarService>((ref) => IsarService());

// Provider para obtener la configuración de Telegram
final telegramConfigProvider = FutureProvider<TelegramConfigEntity?>((ref) async {
  final isar = ref.read(isarServiceProvider);
  return await isar.obtenerTelegramConfig();
});

// Provider para guardar la configuración
final guardarTelegramConfigProvider = FutureProvider.family<void, TelegramConfigEntity>((ref, config) async {
  final isar = ref.read(isarServiceProvider);
  await isar.guardarTelegramConfig(config);
  
  // Actualizar el servicio de Telegram
  final telegramService = TelegramService();
  await telegramService.actualizarConfig(config);
});

// Provider para el servicio de Telegram (singleton)
final telegramServiceProvider = Provider<TelegramService>((ref) {
  return TelegramService();
});