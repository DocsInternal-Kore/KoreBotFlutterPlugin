import 'package:flutter/material.dart';

import '../theme/bot_chat_theme.dart';

/// Built-in chat header used by [buildDefaultChatHeader].
class DefaultChatHeader extends StatelessWidget {
  const DefaultChatHeader({
    super.key,
    required this.title,
    required this.theme,
    required this.onClose,
    this.botIconUrl,
  });

  final String title;
  final BotChatTheme theme;
  final String? botIconUrl;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: theme.headerColor,
      elevation: 2,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: kToolbarHeight,
          child: NavigationToolbar(
            leading: IconButton(
              icon: Icon(Icons.close, color: theme.headerTextColor),
              onPressed: onClose,
              tooltip: 'Close',
            ),
            middle: Text(
              title,
              style: TextStyle(
                color: theme.headerTextColor,
                fontWeight: FontWeight.w600,
                fontSize: 18,
                fontFamily: theme.fontFamily,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            centerMiddle: false,
          ),
        ),
      ),
    );
  }
}
