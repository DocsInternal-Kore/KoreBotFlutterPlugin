import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/template_payload.dart';
import '../theme/bot_chat_theme.dart';
import 'template_helpers.dart';

class ResultsTemplate extends StatelessWidget {
  const ResultsTemplate({
    super.key,
    required this.template,
    required this.theme,
  });

  final TemplatePayload template;
  final BotChatTheme theme;

  @override
  Widget build(BuildContext context) {
    final center = <Map<String, dynamic>>[];
    final web = <Map<String, dynamic>>[];

    final graph = template.raw['graph_answer'];
    if (graph is Map) {
      final payload = graph['payload'];
      if (payload is Map) {
        final panel = payload['center_panel'];
        if (panel is Map && panel['data'] is List) {
          for (final item in panel['data'] as List) {
            if (item is Map) center.add(Map<String, dynamic>.from(item));
          }
        }
      }
    }

    final results = template.raw['results'];
    if (results is Map) {
      final webNode = results['web'];
      if (webNode is Map && webNode['data'] is List) {
        for (final item in webNode['data'] as List) {
          if (item is Map) web.add(Map<String, dynamic>.from(item));
        }
      }
    }

    // Fallback to elements if structured search payload is absent.
    if (center.isEmpty && web.isEmpty) {
      for (final el in template.elements) {
        web.add({
          'title': el.title,
          'url': el.defaultAction?.url ?? el.value,
          'snippet': el.subtitle ?? el.text,
        });
      }
    }

    return templateShell(
      theme: theme,
      text: template.text,
      children: [
        if (center.isNotEmpty)
          templateCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: center.map((item) {
                final title = mapString(item, ['snippet_title', 'title']);
                final content = mapString(item, ['snippet_content', 'content']);
                final url = mapString(item, ['url']);
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(content),
                  onTap: url.isEmpty
                      ? null
                      : () async {
                          final uri = Uri.tryParse(url);
                          if (uri != null) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        },
                );
              }).toList(),
            ),
          ),
        if (web.isNotEmpty)
          templateCard(
            child: Column(
              children: web.take(8).map((item) {
                final title = mapString(item, ['title', 'snippet_title']);
                final url = mapString(item, ['url']);
                final snippet = mapString(item, ['snippet', 'description', 'snippet_content']);
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.search, color: theme.buttonColor),
                  title: Text(title),
                  subtitle: snippet.isEmpty ? null : Text(snippet, maxLines: 2),
                  onTap: url.isEmpty
                      ? null
                      : () async {
                          final uri = Uri.tryParse(url);
                          if (uri != null) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        },
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

class BeneficiaryTemplate extends StatelessWidget {
  const BeneficiaryTemplate({
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
    final items = template.beneficiaryItems.isNotEmpty
        ? template.beneficiaryItems
        : template.elements.map((e) => e.raw).toList();
    final moreCount = template.raw['moreCount'];
    final limit = moreCount is num ? moreCount.toInt() : items.length;
    final visible = items.take(limit).toList();

    return templateShell(
      theme: theme,
      text: template.text,
      children: [
        templateCard(
          child: Column(
            children: [
              ...visible.map((item) {
                final title = mapString(item, ['title', 'name']);
                final desc = mapString(item, ['description', 'subtitle']);
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: theme.buttonColor.withValues(alpha: 0.12),
                    child: Text(title.isNotEmpty ? title[0].toUpperCase() : 'B'),
                  ),
                  title: Text(title),
                  subtitle: desc.isEmpty ? null : Text(desc),
                );
              }),
              if (items.length > visible.length)
                TextButton(
                  onPressed: () {
                    showModalBottomSheet<void>(
                      context: context,
                      builder: (_) => SafeArea(
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: items.map((item) {
                            return ListTile(
                              title: Text(mapString(item, ['title', 'name'])),
                              subtitle: Text(mapString(item, ['description'])),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                  child: const Text('Show more'),
                ),
              ...template.buttons.map(
                (b) => outlinedActionButton(
                  label: b.title,
                  theme: theme,
                  onPressed: () => handleTemplateButton(b, onButton),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AgentTransferTemplate extends StatelessWidget {
  const AgentTransferTemplate({
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
    if (template.buttons.isNotEmpty || template.quickReplies.isNotEmpty) {
      final actions =
          template.buttons.isNotEmpty ? template.buttons : template.quickReplies;
      return templateShell(
        theme: theme,
        text: template.text ?? template.title,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: actions.map((b) {
              return ActionChip(
                label: Text(b.title),
                onPressed: () => handleTemplateButton(b, onButton),
              );
            }).toList(),
          ),
        ],
      );
    }

    final heading = (template.text ?? '').trim();
    final name = (template.title ?? '').trim();
    final role = (template.subtitle ?? '').trim();
    final imageUrl = template.raw['image_url']?.toString().trim();
    final cardColor = theme.buttonColor;

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Material(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (heading.isNotEmpty)
                Text(
                  heading,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.buttonTextColor,
                    fontSize: 15,
                    height: 1.35,
                  ),
                ),
              if (heading.isNotEmpty && (name.isNotEmpty || role.isNotEmpty)) ...[
                const SizedBox(height: 15),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: theme.buttonTextColor.withValues(alpha: 0.35),
                ),
                const SizedBox(height: 15),
              ],
              if (name.isNotEmpty ||
                  role.isNotEmpty ||
                  (imageUrl != null && imageUrl.isNotEmpty))
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (imageUrl != null && imageUrl.isNotEmpty) ...[
                      ClipOval(
                        child: Image.network(
                          imageUrl,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => CircleAvatar(
                            radius: 24,
                            backgroundColor:
                                theme.buttonTextColor.withValues(alpha: 0.2),
                            child: Icon(
                              Icons.support_agent,
                              color: theme.buttonTextColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ] else ...[
                      CircleAvatar(
                        radius: 24,
                        backgroundColor:
                            theme.buttonTextColor.withValues(alpha: 0.2),
                        child: Icon(
                          Icons.support_agent,
                          color: theme.buttonTextColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (name.isNotEmpty)
                            Text(
                              name,
                              style: TextStyle(
                                color: theme.buttonTextColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          if (role.isNotEmpty)
                            Text(
                              role,
                              style: TextStyle(
                                color: theme.buttonTextColor
                                    .withValues(alpha: 0.75),
                                fontSize: 13,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
