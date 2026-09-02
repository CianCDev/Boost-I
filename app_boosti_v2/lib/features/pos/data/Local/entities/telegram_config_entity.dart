// lib/features/pos/data/Local/entities/telegram_config_entity.dart
import 'package:isar/isar.dart';

part 'telegram_config_entity.g.dart';

@Collection()
class TelegramConfigEntity {
  Id id = Isar.autoIncrement;

  String? supabaseId; // UUID de Supabase

  @Index()
  late int usuarioId; // ID del usuario en Isar

  String botToken = '';
  String chatId = '';
  String? nombreChat;

  bool enabled = true;
  bool notificarStockBajo = true;
  bool notificarVentas = false;
  bool notificarPedidos = false;

  // Guardamos los comandos permitidos como lista de strings
  List<String> comandosPermitidos = ['/ventas', '/stock', '/ayuda'];

  bool sincronizado = false;
  DateTime? fechaSincronizacion;
  DateTime? createdAt;
  DateTime? updatedAt;

  TelegramConfigEntity();

  // ──────────────── Convertir a JSON para Supabase ────────────────
  Map<String, dynamic> toSupabaseJson() {
    return {
      'id': supabaseId,
      'id_isar': id,
      'usuario_id': usuarioId,
      'bot_token': botToken,
      'chat_id': chatId,
      'nombre_chat': nombreChat,
      'enabled': enabled,
      'notificar_stock_bajo': notificarStockBajo,
      'notificar_ventas': notificarVentas,
      'notificar_pedidos': notificarPedidos,
      'comandos_permitidos': comandosPermitidos,
      'sincronizado': sincronizado,
      'fecha_sincronizacion': fechaSincronizacion?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // ──────────────── Crear desde JSON de Supabase ────────────────
  factory TelegramConfigEntity.fromSupabase(Map<String, dynamic> json) {
    return TelegramConfigEntity()
      ..id = json['id_isar'] as int? ?? Isar.autoIncrement
      ..usuarioId = json['usuario_id'] as int
      ..supabaseId = json['id'] as String?
      ..botToken = json['bot_token'] as String? ?? ''
      ..chatId = json['chat_id'] as String? ?? ''
      ..nombreChat = json['nombre_chat'] as String?
      ..enabled = json['enabled'] ?? true
      ..notificarStockBajo = json['notificar_stock_bajo'] ?? true
      ..notificarVentas = json['notificar_ventas'] ?? false
      ..notificarPedidos = json['notificar_pedidos'] ?? false
      ..comandosPermitidos = json['comandos_permitidos'] is List
          ? List<String>.from(json['comandos_permitidos'])
          : ['/ventas', '/stock', '/ayuda']
      ..sincronizado = json['sincronizado'] ?? false
      ..fechaSincronizacion = json['fecha_sincronizacion'] != null
          ? DateTime.parse(json['fecha_sincronizacion'] as String)
          : null
      ..createdAt = json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null
      ..updatedAt = json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null;
  }
}