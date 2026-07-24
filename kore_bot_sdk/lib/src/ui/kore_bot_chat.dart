import 'package:flutter/material.dart';

import '../config/bot_config.dart';
import '../controller/bot_chat_controller.dart';
import 'bot_chat_screen.dart';
import 'theme/bot_chat_theme.dart';

/// One-line launcher that replaces MethodChannel `getChatWindow`.
class KoreBotChat {
  KoreBotChat._();

  /// Opens the pure Flutter chat screen (pushes a new route).
  ///
  /// Config keys match the legacy native plugin:
  /// `clientId`, `clientSecret`, `botId`, `chatBotName`, `identity`,
  /// `jwt_server_url`, `server_url`, plus optional flags.
  static Future<T?> open<T>(
    BuildContext context, {
    required Map<String, dynamic> botConfig,
    BotChatTheme theme = const BotChatTheme(),
    BotEventCallback? onEvent,
    bool fullscreenDialog = false,
  }) {
    final config = BotConfig.fromMap(botConfig);
    return Navigator.of(context).push<T>(
      MaterialPageRoute(
        fullscreenDialog: fullscreenDialog,
        builder: (_) => BotChatScreen(
          config: config,
          theme: theme,
          onEvent: onEvent,
        ),
      ),
    );
  }

  /// Opens chat with a typed [BotConfig].
  static Future<T?> openWithConfig<T>(
    BuildContext context, {
    required BotConfig config,
    BotChatTheme theme = const BotChatTheme(),
    BotEventCallback? onEvent,
    bool fullscreenDialog = false,
  }) {
    return Navigator.of(context).push<T>(
      MaterialPageRoute(
        fullscreenDialog: fullscreenDialog,
        builder: (_) => BotChatScreen(
          config: config,
          theme: theme,
          onEvent: onEvent,
        ),
      ),
    );
  }
}
