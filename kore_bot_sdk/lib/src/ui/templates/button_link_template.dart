import 'package:flutter/material.dart';

import '../../models/template_payload.dart';
import '../theme/bot_chat_theme.dart';
import 'template_helpers.dart';

/// SPM `ButtonLinkNBubbleView` / `buttonLinkTemplate`.
///
/// Layout: optional bot-bubble text header, then themed link rows (52pt)
/// with external-link / deeplink icon + title (matches ButtonLinkNCell).
class ButtonLinkTemplate extends StatelessWidget {
  const ButtonLinkTemplate({
    super.key,
    required this.template,
    required this.theme,
    required this.onButton,
  });

  final TemplatePayload template;
  final BotChatTheme theme;
  final TemplateAction onButton;

  static const double _rowHeight = 52;
  static const String _bgAsset = 'assets/button_link_bg.png';
  static const String _bgPackage = 'kore_bot_sdk';

  List<_LinkItem> get _items {
    if (template.elements.isNotEmpty) {
      return template.elements.map(_fromElement).whereType<_LinkItem>().toList();
    }
    return template.buttons
        .where((b) => b.title.isNotEmpty)
        .map(
          (b) => _LinkItem(
            title: b.title,
            type: b.type,
            payload: b.payload,
            url: b.url,
            isSamePageNavigation: false,
          ),
        )
        .toList();
  }

  _LinkItem? _fromElement(BotElement e) {
    final title = e.title?.trim() ?? '';
    if (title.isEmpty) return null;
    final raw = e.raw;
    final type = raw['type']?.toString() ??
        raw['elementType']?.toString() ??
        e.defaultAction?.type ??
        'postback';
    final url = raw['url']?.toString() ??
        raw['elementUrl']?.toString() ??
        e.defaultAction?.url;
    final samePage = raw['isSamePageNavigation'] == true;
    return _LinkItem(
      title: title,
      type: type,
      payload: e.value ?? e.defaultAction?.payload ?? title,
      url: url,
      isSamePageNavigation: samePage,
    );
  }

  Future<void> _onTap(_LinkItem item) async {
    final button = BotButton(
      title: item.title,
      type: item.type,
      payload: item.payload,
      url: item.url,
    );
    await handleTemplateButton(button, onButton);
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    final text = template.text?.trim() ?? '';
    final hasText = text.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasText) _HeaderBubble(text: text, theme: theme),
        if (items.isNotEmpty)
          Transform.translate(
            // SPM: tableView sits with -5pt overlap under the text bubble.
            offset: Offset(0, hasText ? -5 : 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0) const SizedBox(height: 0),
                  _LinkRow(
                    item: items[i],
                    theme: theme,
                    bgAsset: _bgAsset,
                    bgPackage: _bgPackage,
                    height: _rowHeight,
                    onTap: () => _onTap(items[i]),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _LinkItem {
  const _LinkItem({
    required this.title,
    required this.type,
    required this.isSamePageNavigation,
    this.payload,
    this.url,
  });

  final String title;
  final String type;
  final String? payload;
  final String? url;
  final bool isSamePageNavigation;

  bool get isExternalLink {
    final t = type.toLowerCase();
    return t == 'web_url' || t == 'url';
  }
}

/// SPM `tileBgv` + `titleLbl` — bot-bubble colored header.
class _HeaderBubble extends StatelessWidget {
  const _HeaderBubble({required this.text, required this.theme});

  final String text;
  final BotChatTheme theme;

  @override
  Widget build(BuildContext context) {
    final radius = theme.isSquareBubble ? 4.0 : 10.0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: theme.botBubbleColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(radius),
          topRight: Radius.circular(radius),
          bottomRight: Radius.circular(radius),
          // SPM speech-bubble: flat bottom-left against the tail side.
          bottomLeft: Radius.circular(theme.isSquareBubble ? 4 : 4),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: theme.botTextColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 1.35,
        ),
      ),
    );
  }
}

/// SPM `ButtonLinkNCell` — themed bg image + icon + title row.
class _LinkRow extends StatelessWidget {
  const _LinkRow({
    required this.item,
    required this.theme,
    required this.bgAsset,
    required this.bgPackage,
    required this.height,
    required this.onTap,
  });

  final _LinkItem item;
  final BotChatTheme theme;
  final String bgAsset;
  final String bgPackage;
  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = theme.buttonColor;
    final icon = item.isSamePageNavigation
        ? Icons.link
        : (item.isExternalLink ? Icons.open_in_new : Icons.link);

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // SPM `imagV`: buttonLink asset tinted with themeColor.
          ColorFiltered(
            colorFilter: ColorFilter.mode(accent, BlendMode.srcATop),
            child: Image.asset(
              bgAsset,
              package: bgPackage,
              fit: BoxFit.fill,
              errorBuilder: (_, __, ___) => DecoratedBox(
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                // SPM titleEdgeInsets left: 15 after icon.
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Icon(icon, size: 22, color: Colors.white),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
