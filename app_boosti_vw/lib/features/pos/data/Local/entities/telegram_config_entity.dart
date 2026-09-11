// lib/features/pos/data/Local/entities/telegram_config_entity.dart

class TelegramConfigEntity {
  int id = 0;
  String? supabaseId;
  int usuarioId = 0;

  String botToken = '';
  String chatId = '';
  String? nombreChat;

  bool enabled = true;
  bool notificarStockBajo = true;
  bool notificarVentas = false;
  bool notificarPedidos = false;

  List<String> comandosPermitidos = ['/ventas', '/stock', '/ayuda'];

  bool sincronizado = false;
  DateTime? fechaSincronizacion;
  DateTime? createdAt;
  DateTime? updatedAt;

  TelegramConfigEntity();

  // ✅ Para Sembast
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'supabaseId': supabaseId,
      'usuarioId': usuarioId,
      'botToken': botToken,
      'chatId': chatId,
      'nombreChat': nombreChat,
      'enabled': enabled,
      'notificarStockBajo': notificarStockBajo,
      'notificarVentas': notificarVentas,
      'notificarPedidos': notificarPedidos,
      'comandosPermitidos': comandosPermitidos,
      'sincronizado': sincronizado,
      'fechaSincronizacion': fechaSincronizacion?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory TelegramConfigEntity.fromMap(Map<String, dynamic> map) {
    return TelegramConfigEntity()
      ..id = (map['id'] as int?) ?? 0
      ..supabaseId = map['supabaseId'] as String?
      ..usuarioId = (map['usuarioId'] as int?) ?? 0
      ..botToken = (map['botToken'] as String?) ?? ''
      ..chatId = (map['chatId'] as String?) ?? ''
      ..nombreChat = map['nombreChat'] as String?
      ..enabled = (map['enabled'] as bool?) ?? true
      ..notificarStockBajo = (map['notificarStockBajo'] as bool?) ?? true
      ..notificarVentas = (map['notificarVentas'] as bool?) ?? false
      ..notificarPedidos = (map['notificarPedidos'] as bool?) ?? false
      ..comandosPermitidos = map['comandosPermitidos'] is List
          ? List<String>.from(map['comandosPermitidos'])
          : ['/ventas', '/stock', '/ayuda']
      ..sincronizado = (map['sincronizado'] as bool?) ?? false
      ..fechaSincronizacion = map['fechaSincronizacion'] != null ? DateTime.tryParse(map['fechaSincronizacion'] as String) : null
      ..createdAt = map['createdAt'] != null ? DateTime.tryParse(map['createdAt'] as String) : null
      ..updatedAt = map['updatedAt'] != null ? DateTime.tryParse(map['updatedAt'] as String) : null;
  }

  // Métodos originales de Supabase
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

  factory TelegramConfigEntity.fromSupabase(Map<String, dynamic> json) {
    return TelegramConfigEntity()
      ..id = (json['id_isar'] as int?) ?? 0
      ..usuarioId = (json['usuario_id'] as int?) ?? 0
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
      ..fechaSincronizacion = json['fecha_sincronizacion'] != null ? DateTime.parse(json['fecha_sincronizacion'] as String) : null
      ..createdAt = json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null
      ..updatedAt = json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null;
  }
}