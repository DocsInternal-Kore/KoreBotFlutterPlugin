import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/template_payload.dart';
import '../theme/bot_chat_theme.dart';
import 'text_bubble.dart';

typedef TemplateAction = Future<void> Function(BotButton button);
typedef TemplatePayloadAction = Future<void> Function({
  required String payload,
  String? displayText,
});

Future<void> handleTemplateButton(
  BotButton button,
  TemplateAction onButton,
) async {
  if (button.isUrl && button.url != null) {
    final uri = Uri.tryParse(button.url!);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return;
  }
  await onButton(button);
}

Widget templateShell({
  required BotChatTheme theme,
  String? text,
  required List<Widget> children,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (text != null && text.isNotEmpty)
        TextBubble(
          text: text,
          background: theme.botBubbleColor,
          textColor: theme.botTextColor,
          isUser: false,
        ),
      ...children,
    ],
  );
}

Widget templateCard({
  required Widget child,
  EdgeInsetsGeometry padding = const EdgeInsets.all(12),
}) {
  // Use Material (not DecoratedBox) so ListTile ink/splashes stay visible.
  return Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: padding,
        child: child,
      ),
    ),
  );
}

Widget primaryActionButton({
  required String label,
  required VoidCallback onPressed,
  required BotChatTheme theme,
}) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.buttonColor,
        foregroundColor: theme.buttonTextColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      onPressed: onPressed,
      child: Text(label),
    ),
  );
}

Widget outlinedActionButton({
  required String label,
  required VoidCallback onPressed,
  required BotChatTheme theme,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 2),
    child: OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: theme.buttonColor,
        side: BorderSide(color: theme.buttonColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(vertical: 10),
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: onPressed,
      child: Text(label),
    ),
  );
}

String mapString(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    final text = displayCell(value);
    if (text.isNotEmpty) return text;
  }
  return '';
}

/// Renders payload cells without the literal `"null"` string.
String displayCell(dynamic value) {
  if (value == null) return '';
  final text = value.toString().trim();
  if (text.isEmpty || text.toLowerCase() == 'null') return '';
  return value.toString();
}
