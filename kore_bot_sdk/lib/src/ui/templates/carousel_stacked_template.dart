import 'package:flutter/material.dart';

import '../../models/template_payload.dart';
import '../theme/bot_chat_theme.dart';
import 'template_helpers.dart';

/// Zoom/snap stacked carousel — `template_type: stacked` or
/// `carousel` + `carousel_type: stacked`.
///
/// Mirrors iOS `ZoomAndSnapFlowLayout` (center cell zooms while scrolling).
class CarouselStackedTemplate extends StatefulWidget {
  const CarouselStackedTemplate({
    super.key,
    required this.template,
    required this.theme,
    required this.onButton,
  });

  final TemplatePayload template;
  final BotChatTheme theme;
  final TemplateAction onButton;

  @override
  State<CarouselStackedTemplate> createState() =>
      _CarouselStackedTemplateState();
}

class _CarouselStackedTemplateState extends State<CarouselStackedTemplate> {
  static const double _viewportFraction = 0.58;
  static const double _zoomFactor = 0.25;
  static const double _maxScale = 1 + _zoomFactor;

  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: _viewportFraction);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Unscaled card height (content + buttons).
  double _baseCardHeight(List<BotElement> elements) {
    var hasImage = false;
    var maxButtons = 0;
    for (final el in elements) {
      final top = el.raw['topSection'];
      if (top is Map &&
          (top['image_url']?.toString().trim().isNotEmpty ?? false)) {
        hasImage = true;
      }
      if (el.buttons.length > maxButtons) maxButtons = el.buttons.length;
    }
    final content = hasImage ? 175.0 : 110.0;
    return content + (maxButtons * 40.0) + 16;
  }

  double _scaleFor(int index) {
    if (!_controller.hasClients || !_controller.position.haveDimensions) {
      return index == 0 ? _maxScale : 1.0;
    }
    final page = _controller.page ?? _controller.initialPage.toDouble();
    final distance = (page - index).abs().clamp(0.0, 1.0);
    // Same curve as ZoomAndSnapFlowLayout:
    // zoom = 1 + zoomFactor * (1 - normalizedDistance)
    return 1 + _zoomFactor * (1 - distance);
  }

  @override
  Widget build(BuildContext context) {
    final elements = widget.template.elements;
    if (elements.isEmpty) return const SizedBox.shrink();

    final cardHeight = _baseCardHeight(elements);
    // Viewport must fit the fully zoomed center card so top/bottom are not clipped.
    final viewportHeight = cardHeight * _maxScale + 8;

    return templateShell(
      theme: widget.theme,
      text: widget.template.text,
      children: [
        SizedBox(
          height: viewportHeight,
          child: PageView.builder(
            controller: _controller,
            padEnds: true,
            clipBehavior: Clip.none,
            itemCount: elements.length,
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final scale = _scaleFor(index);
                  final focus = ((scale - 1) / _zoomFactor).clamp(0.0, 1.0);
                  return Center(
                    child: Transform.scale(
                      scale: scale,
                      alignment: Alignment.center,
                      filterQuality: FilterQuality.medium,
                      child: Material(
                        color: Colors.transparent,
                        elevation: 1.5 + focus * 4,
                        shadowColor: Colors.black38,
                        borderRadius: BorderRadius.circular(10),
                        child: child,
                      ),
                    ),
                  );
                },
                child: SizedBox(
                  height: cardHeight,
                  child: _StackedCard(
                    element: elements[index],
                    theme: widget.theme,
                    onButton: widget.onButton,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StackedCard extends StatelessWidget {
  const _StackedCard({
    required this.element,
    required this.theme,
    required this.onButton,
  });

  final BotElement element;
  final BotChatTheme theme;
  final TemplateAction onButton;

  @override
  Widget build(BuildContext context) {
    final raw = element.raw;
    final top = raw['topSection'] is Map
        ? Map<String, dynamic>.from(raw['topSection'] as Map)
        : null;
    final middle = raw['middleSection'] is Map
        ? Map<String, dynamic>.from(raw['middleSection'] as Map)
        : null;
    final bottom = raw['bottomSection'] is Map
        ? Map<String, dynamic>.from(raw['bottomSection'] as Map)
        : null;
    final imageUrl = top?['image_url']?.toString().trim();
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: theme.botBubbleColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (hasImage)
              SizedBox(
                height: 90,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => ColoredBox(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image_not_supported),
                  ),
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      top?['title']?.toString() ?? element.title ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: theme.botTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        middle?['description']?.toString() ??
                            middle?['descrip']?.toString() ??
                            element.subtitle ??
                            element.text ??
                            '',
                        maxLines: hasImage ? 3 : 5,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: theme.botTextColor.withValues(alpha: 0.8),
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                    ),
                    if (bottom != null) ...[
                      Text(
                        bottom['title']?.toString() ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: theme.botTextColor,
                        ),
                      ),
                      if (bottom['description'] != null ||
                          bottom['descrip'] != null)
                        Text(
                          (bottom['description'] ?? bottom['descrip'])
                              .toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
            ...element.buttons.map(
              (b) => Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 6),
                child: SizedBox(
                  width: double.infinity,
                  height: 34,
                  child: ElevatedButton(
                    onPressed: () => handleTemplateButton(b, onButton),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.userBubbleColor,
                      foregroundColor: theme.userTextColor,
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                    child: Text(
                      b.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ),
            ),
            if (element.buttons.isEmpty) const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}
