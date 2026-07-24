import 'package:flutter/material.dart';

import '../config/bot_config.dart';
import '../controller/bot_chat_controller.dart';
import 'bot_chat_screen.dart';
import 'chat_footer_builder.dart';
import 'chat_header_builder.dart';
import 'templates/bot_template_registry.dart';
import 'theme/bot_chat_fonts.dart';
import 'theme/bot_chat_theme.dart';

/// One-line launcher that replaces MethodChannel `getChatWindow`.
class KoreBotChat {
  KoreBotChat._();

  /// Opens the pure Flutter chat screen (pushes a new route).
  ///
  /// Config keys match the legacy native plugin:
  /// `clientId`, `clientSecret`, `botId`, `chatBotName`, `identity`,
  /// `jwt_server_url`, `server_url`, plus optional flags.
  ///
  /// Pass [headerBuilder] / [footerBuilder] to inject custom chrome, or omit
  /// them to use the built-in header and compose footer.
  ///
  /// Pass [templateRegistry] to add new template types or override built-ins.
  ///
  /// Pass [fonts] after registering the family in the host `pubspec.yaml`.
  static Future<T?> open<T>(
    BuildContext context, {
    required Map<String, dynamic> botConfig,
    BotChatTheme theme = const BotChatTheme(),
    BotEventCallback? onEvent,
    BotChatHeaderBuilder? headerBuilder,
    BotChatFooterBuilder? footerBuilder,
    BotTemplateRegistry? templateRegistry,
    BotChatFonts? fonts,
    bool fullscreenDialog = false,
  }) {
    final config = BotConfig.fromMap(botConfig);
    return Navigator.of(context).push<T>(
      MaterialPageRoute(
        fullscreenDialog: fullscreenDialog,
        builder: (_) => BotChatScreen(
          config: config,
          theme: theme.applyFonts(fonts),
          onEvent: onEvent,
          headerBuilder: headerBuilder,
          footerBuilder: footerBuilder,
          templateRegistry: templateRegistry,
          fonts: fonts,
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
    BotChatHeaderBuilder? headerBuilder,
    BotChatFooterBuilder? footerBuilder,
    BotTemplateRegistry? templateRegistry,
    BotChatFonts? fonts,
    bool fullscreenDialog = false,
  }) {
    return Navigator.of(context).push<T>(
      MaterialPageRoute(
        fullscreenDialog: fullscreenDialog,
        builder: (_) => BotChatScreen(
          config: config,
          theme: theme.applyFonts(fonts),
          onEvent: onEvent,
          headerBuilder: headerBuilder,
          footerBuilder: footerBuilder,
          templateRegistry: templateRegistry,
          fonts: fonts,
        ),
      ),
    );
  }
}
