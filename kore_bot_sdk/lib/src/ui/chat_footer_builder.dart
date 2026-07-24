import 'package:flutter/material.dart';

import 'theme/bot_chat_theme.dart';
import 'widgets/compose_footer.dart';

/// Context passed to a custom chat footer builder.
class BotChatFooterContext {
  const BotChatFooterContext({
    required this.controller,
    required this.enabled,
    required this.hintText,
    required this.theme,
    required this.onSend,
    this.showAttachment = false,
    this.showMicrophone = false,
    this.showTextToSpeech = false,
    this.isListening = false,
    this.ttsEnabled = false,
    this.hasPendingAttachment = false,
    this.onAttachment,
    this.onMic,
    this.onToggleTts,
  });

  final TextEditingController controller;
  final bool enabled;
  final String hintText;
  final BotChatTheme theme;
  final VoidCallback onSend;
  final bool showAttachment;
  final bool showMicrophone;
  final bool showTextToSpeech;
  final bool isListening;
  final bool ttsEnabled;
  final bool hasPendingAttachment;
  final VoidCallback? onAttachment;
  final VoidCallback? onMic;
  final VoidCallback? onToggleTts;
}

/// Builds the chat window footer (compose / input area).
///
/// Return any widget tree. Use [buildDefaultChatFooter] to reuse the SDK footer.
typedef BotChatFooterBuilder = Widget Function(
  BuildContext context,
  BotChatFooterContext footer,
);

/// Returns the built-in SDK footer.
Widget buildDefaultChatFooter(
  BuildContext context,
  BotChatFooterContext footer,
) {
  return ComposeFooter(
    controller: footer.controller,
    enabled: footer.enabled,
    hintText: footer.hintText,
    theme: footer.theme,
    showAttachment: footer.showAttachment,
    showMicrophone: footer.showMicrophone,
    showTextToSpeech: footer.showTextToSpeech,
    isListening: footer.isListening,
    ttsEnabled: footer.ttsEnabled,
    hasPendingAttachment: footer.hasPendingAttachment,
    onSend: footer.onSend,
    onAttachment: footer.onAttachment,
    onMic: footer.onMic,
    onToggleTts: footer.onToggleTts,
  );
}
