import 'package:flutter/material.dart';
import 'package:kore_bot_sdk/kore_bot_sdk.dart';

/// Example custom footer injected into the SDK via [BotChatFooterBuilder].
class CustomChatFooter extends StatelessWidget {
  const CustomChatFooter({super.key, required this.footer});

  final BotChatFooterContext footer;

  bool get _canSend =>
      footer.enabled &&
      (footer.controller.text.trim().isNotEmpty ||
          footer.hasPendingAttachment);

  @override
  Widget build(BuildContext context) {
    final theme = footer.theme;
    return ColoredBox(
      color: theme.footerColor,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: ListenableBuilder(
            listenable: footer.controller,
            builder: (context, _) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (footer.showAttachment)
                    IconButton(
                      onPressed: footer.enabled ? footer.onAttachment : null,
                      icon: Icon(
                        Icons.attach_file,
                        color: theme.sendButtonColor,
                      ),
                      tooltip: 'Attachment',
                    ),
                  Expanded(
                    child: TextField(
                      controller: footer.controller,
                      enabled: footer.enabled,
                      style: TextStyle(color: theme.botTextColor, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: footer.hintText,
                        hintStyle: TextStyle(color: theme.footerHintColor),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: theme.footerBorderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: theme.footerBorderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: theme.sendButtonColor,
                            width: 1.5,
                          ),
                        ),
                      ),
                      maxLines: 4,
                      minLines: 1,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _canSend ? (_) => footer.onSend() : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: _canSend
                        ? theme.sendButtonColor
                        : theme.sendButtonColor.withValues(alpha: 0.35),
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: _canSend ? footer.onSend : null,
                      customBorder: const CircleBorder(),
                      child: SizedBox(
                        width: 44,
                        height: 44,
                        child: Icon(
                          Icons.send_rounded,
                          size: 20,
                          color: theme.userTextColor,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

BotChatFooterBuilder buildCustomChatFooter() {
  return (context, footer) => CustomChatFooter(footer: footer);
}
