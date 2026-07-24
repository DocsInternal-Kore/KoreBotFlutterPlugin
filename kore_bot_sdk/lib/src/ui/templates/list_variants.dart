import 'package:flutter/material.dart';

import '../../models/template_payload.dart';
import '../theme/bot_chat_theme.dart';
import 'list_template.dart';
import 'template_helpers.dart';

class ListViewTemplate extends StatelessWidget {
  const ListViewTemplate({
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
    final moreCount = template.raw['moreCount'];
    final limit = moreCount is num ? moreCount.toInt() : template.elements.length;
    final visible = template.elements.take(limit).toList();
    final hasMore = template.elements.length > visible.length ||
        template.raw['moreData'] != null;

    return templateShell(
      theme: theme,
      text: template.text ?? template.heading,
      children: [
        if (template.heading != null && template.text != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              template.heading!,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ListTemplate(
          template: TemplatePayload(
            templateType: 'list',
            elements: visible,
            buttons: template.buttons,
            raw: template.raw,
          ),
          theme: theme,
          onButton: onButton,
        ),
        if (hasMore)
          TextButton(
            onPressed: () {
              showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (_) => SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ListTemplate(
                      template: template,
                      theme: theme,
                      onButton: onButton,
                    ),
                  ),
                ),
              );
            },
            child: Text('Show more', style: TextStyle(color: theme.buttonColor)),
          ),
      ],
    );
  }
}

class ListWidgetTemplate extends StatelessWidget {
  const ListWidgetTemplate({
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
    return templateShell(
      theme: theme,
      text: template.text,
      children: [
        templateCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (template.title != null)
                Text(template.title!,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              if (template.description != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 8),
                  child: Text(template.description!,
                      style: TextStyle(color: Colors.grey.shade700)),
                ),
              ...template.elements.map((el) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: el.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            el.imageUrl!,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.widgets_outlined),
                          ),
                        )
                      : Icon(Icons.widgets_outlined, color: theme.buttonColor),
                  title: Text(el.title ?? ''),
                  subtitle: Text(el.subtitle ?? el.text ?? el.value ?? ''),
                  onTap: el.defaultAction != null
                      ? () => handleTemplateButton(el.defaultAction!, onButton)
                      : el.buttons.isNotEmpty
                          ? () => handleTemplateButton(el.buttons.first, onButton)
                          : null,
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

class AdvancedListTemplate extends StatelessWidget {
  const AdvancedListTemplate({
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
    final displayCount = template.raw['listItemDisplayCount'];
    final limit = displayCount is num ? displayCount.toInt() : template.listItems.length;
    final items = template.listItems.take(limit).toList();
    final seeMore = template.raw['seeMoreTitle']?.toString() ?? 'See more';

    return templateShell(
      theme: theme,
      text: null,
      children: [
        templateCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (template.title != null)
                Text(template.title!,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              if (template.description != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 8),
                  child: Text(template.description!),
                ),
              ...items.map((item) {
                final title = mapString(item, ['title']);
                final desc = mapString(item, ['description']);
                final payload = mapString(item, ['payload']);
                final type = mapString(item, ['type']).isEmpty
                    ? 'postback'
                    : mapString(item, ['type']);
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: item['icon'] != null
                      ? const Icon(Icons.folder_open)
                      : null,
                  title: Text(title),
                  subtitle: desc.isEmpty ? null : Text(desc),
                  onTap: payload.isEmpty && title.isEmpty
                      ? null
                      : () => handleTemplateButton(
                            BotButton(
                              title: title,
                              payload: payload.isEmpty ? title : payload,
                              type: type,
                            ),
                            onButton,
                          ),
                );
              }),
              if (template.listItems.length > items.length)
                TextButton(
                  onPressed: () {
                    showModalBottomSheet<void>(
                      context: context,
                      builder: (_) => SafeArea(
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: template.listItems.map((item) {
                            final title = mapString(item, ['title']);
                            final payload = mapString(item, ['payload']);
                            return ListTile(
                              title: Text(title),
                              onTap: () {
                                Navigator.pop(context);
                                handleTemplateButton(
                                  BotButton(
                                    title: title,
                                    payload: payload.isEmpty ? title : payload,
                                  ),
                                  onButton,
                                );
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                  child: Text(seeMore),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
