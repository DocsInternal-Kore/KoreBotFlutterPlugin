import 'package:flutter/material.dart';
import 'package:kore_bot_sdk/kore_bot_sdk.dart';

/// Example custom header injected into the SDK via [BotChatHeaderBuilder].
class CustomChatHeader extends StatelessWidget {
  const CustomChatHeader({super.key, required this.header});

  final BotChatHeaderContext header;

  @override
  Widget build(BuildContext context) {
    final theme = header.theme;
    return ColoredBox(
      color: theme.headerColor,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 64,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.headerTextColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.support_agent,
                    color: theme.headerTextColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        header.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.headerTextColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Powered by Example App',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.headerTextColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  icon: Icon(Icons.close, color: theme.headerTextColor),
                  onPressed: header.onClose,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

BotChatHeaderBuilder buildCustomChatHeader() {
  return (context, header) => CustomChatHeader(header: header);
}
