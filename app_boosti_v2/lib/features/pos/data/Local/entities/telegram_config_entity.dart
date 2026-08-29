// lib/features/pos/data/Local/entities/telegram_config_entity.dart
import 'package:isar/isar.dart';

part 'telegram_config_entity.g.dart';

@Collection()
class TelegramConfigEntity {
  Id id = Isar.autoIncrement;

  String? supabaseId; // UUID de Supabase

  String botToken = '';
  String chatId = '';
  String? nombreChat;

  bool enabled = true;
  bool notificarStockBajo = true;
  bool notificarVentas = false;
  bool notificarPedidos = false;

  // Guardamos los comandos permitidos como JSON (lista de strings)
  List<String> comandosPermitidos = ['/ventas', '/stock', '/ayuda'];

  bool sincronizado = false;
  DateTime? fechaSincronizacion;
  DateTime? createdAt;
  DateTime? updatedAt;
}