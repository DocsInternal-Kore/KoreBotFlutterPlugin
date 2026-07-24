import 'package:flutter/material.dart';

import '../../models/template_payload.dart';
import '../theme/bot_chat_theme.dart';

class QuickRepliesTemplate extends StatelessWidget {
  const QuickRepliesTemplate({
    super.key,
    required this.replies,
    required this.theme,
    required this.onSelected,
  });

  final List<BotButton> replies;
  final BotChatTheme theme;
  final Future<void> Function(BotButton button) onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        scrollDirection: Axis.horizontal,
        itemCount: replies.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final reply = replies[index];
          return ActionChip(
            label: Text(reply.title),
            backgroundColor: Colors.white,
            side: BorderSide(color: theme.buttonColor),
            labelStyle: TextStyle(color: theme.buttonColor),
            onPressed: () => onSelected(reply),
          );
        },
      ),
    );
  }
}
