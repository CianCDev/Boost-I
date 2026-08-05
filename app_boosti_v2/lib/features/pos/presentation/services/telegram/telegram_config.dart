class TelegramConfig {
  final String botToken;
  final String chatId;
  final bool enabled;

  const TelegramConfig({
    required this.botToken,
    required this.chatId,
    this.enabled = true,
  });

  bool get isValid => botToken.isNotEmpty && chatId.isNotEmpty && enabled;

  factory TelegramConfig.fromJson(Map<String, dynamic> json) {
    return TelegramConfig(
      botToken: json['telegramBotToken'] ?? '',
      chatId: json['telegramChatId']?.toString() ?? '',
      enabled: json['telegramEnabled'] ?? true,
    );
  }
}