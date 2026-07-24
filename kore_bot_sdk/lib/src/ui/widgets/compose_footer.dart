import 'package:flutter/material.dart';

import '../theme/bot_chat_theme.dart';

class ComposeFooter extends StatelessWidget {
  const ComposeFooter({
    super.key,
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
  /// When true, Send is available even if the text field is empty (SPM).
  final bool hasPendingAttachment;
  final VoidCallback? onAttachment;
  final VoidCallback? onMic;
  final VoidCallback? onToggleTts;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(4, 8, 8, 8),
        decoration: BoxDecoration(
          color: theme.footerColor,
          border: Border(top: BorderSide(color: theme.footerBorderColor)),
        ),
        child: Row(
          children: [
            if (showAttachment)
              IconButton(
                onPressed: enabled ? onAttachment : null,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints.tightFor(width: 36, height: 40),
                icon: Icon(Icons.attach_file, color: theme.sendButtonColor),
                tooltip: 'Attachment',
              ),
            if (showTextToSpeech)
              IconButton(
                onPressed: enabled ? onToggleTts : null,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints.tightFor(width: 36, height: 40),
                icon: Icon(
                  ttsEnabled ? Icons.volume_up : Icons.volume_off,
                  color: ttsEnabled
                      ? theme.userBubbleColor
                      : theme.sendButtonColor,
                ),
                tooltip: ttsEnabled ? 'TTS on' : 'TTS off',
              ),
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled,
                minLines: 1,
                maxLines: 4,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.2,
                  fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) {
                  if (!enabled) return;
                  if (controller.text.trim().isNotEmpty ||
                      hasPendingAttachment) {
                    onSend();
                  }
                },
                decoration: InputDecoration(
                  isDense: true,
                  hintText: hintText,
                  hintStyle: TextStyle(
                    color: theme.footerHintColor,
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF3F3F5),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Empty field → mic (when enabled); has text or pending file → send.
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, _) {
                final canSend = value.text.trim().isNotEmpty ||
                    hasPendingAttachment;
                if (canSend) {
                  return _CircleActionButton(
                    background:
                        enabled ? theme.sendButtonColor : Colors.grey.shade400,
                    onPressed: enabled ? onSend : null,
                    icon: Icons.send,
                    iconColor: theme.userTextColor,
                    iconSize: 18,
                    tooltip: 'Send',
                  );
                }
                if (showMicrophone) {
                  return _CircleActionButton(
                    background: isListening
                        ? theme.sendButtonColor
                        : theme.sendButtonColor.withValues(alpha: 0.15),
                    onPressed: enabled ? onMic : null,
                    icon: isListening ? Icons.mic : Icons.mic_none,
                    iconColor: isListening
                        ? theme.userTextColor
                        : theme.sendButtonColor,
                    iconSize: 18,
                    tooltip: isListening ? 'Listening…' : 'Speech to text',
                  );
                }
                return _CircleActionButton(
                  background: Colors.grey.shade400,
                  onPressed: null,
                  icon: Icons.send,
                  iconColor: theme.userTextColor,
                  iconSize: 18,
                  tooltip: 'Send',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  const _CircleActionButton({
    required this.background,
    required this.onPressed,
    required this.icon,
    required this.iconColor,
    required this.tooltip,
    this.iconSize = 18,
  });

  final Color background;
  final VoidCallback? onPressed;
  final IconData icon;
  final Color iconColor;
  final String tooltip;
  final double iconSize;

  static const double _size = 36;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      shape: const CircleBorder(),
      child: SizedBox(
        width: _size,
        height: _size,
        child: IconButton(
          onPressed: onPressed,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(width: _size, height: _size),
          icon: Icon(icon, color: iconColor, size: iconSize),
          tooltip: tooltip,
        ),
      ),
    );
  }
}
