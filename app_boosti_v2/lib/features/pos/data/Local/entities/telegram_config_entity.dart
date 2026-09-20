import 'package:isar/isar.dart';
import 'json_utils.dart';

// ✅ CORREGIDO: Se añadieron comillas y se arregló el typo "enitity" -> "entity"
part 'telegram_config_entity.g.dart';

@Collection()
class TelegramConfigEntity {
  Id id = Isar.autoIncrement;
  String? supabaseId;
  int usuarioId = 0;

  // ✅ NUEVOS
  String? tenantId; // UUID del local/tenant
  String syncStatus = 'pending';

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

  // ───── JSON para Supabase ─────
  Map<String, dynamic> toSupabaseJson() {
    return {
      if (supabaseId != null) 'id': supabaseId,
      'id_isar': id,
      'usuario_id': usuarioId,
      if (tenantId != null) 'tenant_id': tenantId,
      'bot_token': botToken,
      'chat_id': chatId,
      'nombre_chat': nombreChat,
      'enabled': enabled,
      'notificar_stock_bajo': notificarStockBajo,
      'notificar_ventas': notificarVentas,
      'notificar_pedidos': notificarPedidos,
      'comandos_permitidos': comandosPermitidos,
      'sincronizado': sincronizado,
      'sync_status': syncStatus,
      'fecha_sincronizacion': fechaSincronizacion?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory TelegramConfigEntity.fromSupabase(Map<String, dynamic> json) {
    return TelegramConfigEntity()
      ..id = safeInt(json['id_isar']) ?? Isar.autoIncrement
      ..usuarioId = safeInt(json['usuario_id']) ?? 0
      ..supabaseId = json['id'] as String?
      ..tenantId = json['tenant_id'] as String?
      ..syncStatus = json['sync_status'] as String? ?? 'pending'
      ..botToken = json['bot_token'] as String? ?? ''
      ..chatId = json['chat_id'] as String? ?? ''
      ..nombreChat = json['nombre_chat'] as String?
      ..enabled = json['enabled'] as bool? ?? true
      ..notificarStockBajo = json['notificar_stock_bajo'] as bool? ?? true
      ..notificarVentas = json['notificar_ventas'] as bool? ?? false
      ..notificarPedidos = json['notificar_pedidos'] as bool? ?? false
      ..comandosPermitidos = json['comandos_permitidos'] is List
          ? List<String>.from(json['comandos_permitidos'])
          : const ['/ventas', '/stock', '/ayuda']
      ..sincronizado = json['sincronizado'] as bool? ?? false
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
