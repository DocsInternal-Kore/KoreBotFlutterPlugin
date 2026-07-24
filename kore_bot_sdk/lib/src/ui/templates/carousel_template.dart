import 'package:flutter/material.dart';

import '../../models/template_payload.dart';
import '../theme/bot_chat_theme.dart';
import 'template_helpers.dart';
import 'text_bubble.dart';

class CarouselTemplate extends StatelessWidget {
  const CarouselTemplate({
    super.key,
    required this.template,
    required this.theme,
    required this.onButton,
  });

  final TemplatePayload template;
  final BotChatTheme theme;
  final TemplateAction onButton;

  static const double _cardWidth = 220;
  static const double _contentWidth = 200; // card width minus horizontal padding

  @override
  Widget build(BuildContext context) {
    final height = _carouselHeight(template.elements);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (template.text != null && template.text!.isNotEmpty)
          TextBubble(
            text: template.text!,
            background: theme.botBubbleColor,
            textColor: theme.botTextColor,
            isUser: false,
          ),
        SizedBox(
          height: height,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: template.elements.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final element = template.elements[index];
              return _CarouselCard(
                element: element,
                theme: theme,
                onButton: onButton,
                height: height,
                width: _cardWidth,
              );
            },
          ),
        ),
      ],
    );
  }

  double _carouselHeight(List<BotElement> elements) {
    if (elements.isEmpty) return 120;
    var maxHeight = 0.0;
    for (final el in elements) {
      final h = _cardHeight(el);
      if (h > maxHeight) maxHeight = h;
    }
    // Buffer for TextPainter vs rendered Text differences.
    return maxHeight + 8;
  }

  double _cardHeight(BotElement element) {
    var height = 0.0;

    if (element.imageUrl != null && element.imageUrl!.isNotEmpty) {
      height += 110;
    }

    // Content padding: top 10 + bottom 6
    height += 16;

    if (element.title != null && element.title!.trim().isNotEmpty) {
      height += _measureText(
        element.title!,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          height: 1.25,
        ),
        maxLines: 2,
        maxWidth: _contentWidth,
      );
    }

    final subtitle = element.subtitle ?? element.text;
    if (subtitle != null && subtitle.trim().isNotEmpty) {
      height += 4;
      height += _measureText(
        subtitle,
        style: const TextStyle(fontSize: 12, height: 1.3),
        maxLines: 3,
        maxWidth: _contentWidth,
      );
    }

    final buttonCount = element.buttons.take(2).length;
    height += buttonCount * 40; // 4 top gap + 36 button

    return height;
  }

  double _measureText(
    String text, {
    required TextStyle style,
    required int maxLines,
    required double maxWidth,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: maxLines,
      ellipsis: '…',
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);
    return painter.size.height;
  }
}

class _CarouselCard extends StatelessWidget {
  const _CarouselCard({
    required this.element,
    required this.theme,
    required this.onButton,
    required this.height,
    required this.width,
  });

  final BotElement element;
  final BotChatTheme theme;
  final TemplateAction onButton;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: element.defaultAction != null
          ? () => handleTemplateButton(element.defaultAction!, onButton)
          : null,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (element.imageUrl != null && element.imageUrl!.isNotEmpty)
              Image.network(
                element.imageUrl!,
                height: 110,
                width: width,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 110,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (element.title != null &&
                                element.title!.trim().isNotEmpty)
                              Text(
                                element.title!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  height: 1.25,
                                ),
                              ),
                            if (element.subtitle != null ||
                                element.text != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  element.subtitle ?? element.text ?? '',
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 12,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    ...element.buttons.take(2).map(
                          (b) => Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: SizedBox(
                              width: double.infinity,
                              height: 36,
                              child: ElevatedButton(
                                onPressed: () =>
                                    handleTemplateButton(b, onButton),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.userBubbleColor,
                                  foregroundColor: theme.userTextColor,
                                  elevation: 0,
                                  padding: EdgeInsets.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: Text(b.title, maxLines: 1),
                              ),
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
