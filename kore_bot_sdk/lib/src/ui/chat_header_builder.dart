import 'package:flutter/material.dart';

import 'theme/bot_chat_theme.dart';
import 'widgets/default_chat_header.dart';

/// Context passed to a custom chat header builder.
class BotChatHeaderContext {
  const BotChatHeaderContext({
    required this.title,
    required this.theme,
    required this.onClose,
    this.botIconUrl,
  });

  final String title;
  final BotChatTheme theme;
  final String? botIconUrl;
  final VoidCallback onClose;
}

/// Builds the chat window header.
///
/// Return any widget tree. Use [buildDefaultChatHeader] to reuse the SDK header.
typedef BotChatHeaderBuilder = Widget Function(
  BuildContext context,
  BotChatHeaderContext header,
);

/// Returns the built-in SDK header.
Widget buildDefaultChatHeader(
  BuildContext context,
  BotChatHeaderContext header,
) {
  return DefaultChatHeader(
    title: header.title,
    theme: header.theme,
    botIconUrl: header.botIconUrl,
    onClose: header.onClose,
  );
}
