import 'package:flutter/material.dart';

import '../../models/template_payload.dart';
import '../theme/bot_chat_theme.dart';
import 'template_helpers.dart';
import 'text_bubble.dart';

class ListTemplate extends StatelessWidget {
  const ListTemplate({
    super.key,
    required this.template,
    required this.theme,
    required this.onButton,
  });

  final TemplatePayload template;
  final BotChatTheme theme;
  final TemplateAction onButton;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (template.text != null && template.text!.isNotEmpty)
          TextBubble(
            text: template.text!,
            background: theme.botBubbleColor,
            textColor: theme.botTextColor,
            isUser: false,
          ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Material(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var i = 0; i < template.elements.length; i++) ...[
                  if (i > 0) Divider(height: 1, color: Colors.grey.shade300),
                  _ListRow(
                    element: template.elements[i],
                    theme: theme,
                    onButton: onButton,
                  ),
                ],
                if (template.buttons.isNotEmpty) ...[
                  Divider(height: 1, color: Colors.grey.shade300),
                  ...template.buttons.map(
                    (b) => ListTile(
                      dense: true,
                      title: Text(
                        b.title,
                        style: TextStyle(
                          color: theme.buttonColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onTap: () => handleTemplateButton(b, onButton),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ListRow extends StatelessWidget {
  const _ListRow({
    required this.element,
    required this.theme,
    required this.onButton,
  });

  final BotElement element;
  final BotChatTheme theme;
  final TemplateAction onButton;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: element.defaultAction != null
          ? () => handleTemplateButton(element.defaultAction!, onButton)
          : element.buttons.isNotEmpty
              ? () => handleTemplateButton(element.buttons.first, onButton)
              : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            if (element.imageUrl != null && element.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  element.imageUrl!,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox(width: 48),
                ),
              ),
            if (element.imageUrl != null) const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (element.title != null)
                    Text(
                      element.title!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  if (element.subtitle != null || element.text != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        element.subtitle ?? element.text ?? '',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (element.value != null)
              Text(
                element.value!,
                style: TextStyle(
                  color: theme.buttonColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
