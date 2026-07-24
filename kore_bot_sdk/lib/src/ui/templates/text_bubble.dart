import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'kore_markdown.dart';

class TextBubble extends StatelessWidget {
  const TextBubble({
    super.key,
    required this.text,
    required this.background,
    required this.textColor,
    required this.isUser,
    this.square = false,
  });

  final String text;
  final Color background;
  final Color textColor;
  final bool isUser;
  final bool square;

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) return const SizedBox.shrink();
    final radius = square ? 4.0 : 16.0;
    final baseStyle = TextStyle(color: textColor, fontSize: 15, height: 1.35);
    final markdown = normalizeKoreMarkdown(text);

    // Size to text content (not full row width), with a bounded max width so
    // MarkdownBody can lay out wrapped lines correctly.
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final parentMax = constraints.maxWidth;
          final screenCap = MediaQuery.sizeOf(context).width * 0.78;
          final maxWidth = parentMax.isFinite && parentMax > 0
              ? parentMax.clamp(0.0, screenCap)
              : screenCap;

          return ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(radius),
                  topRight: Radius.circular(radius),
                  bottomLeft:
                      Radius.circular(isUser ? radius : (square ? 4 : 4)),
                  bottomRight:
                      Radius.circular(isUser ? (square ? 4 : 4) : radius),
                ),
              ),
              child: MarkdownBody(
                data: markdown,
                selectable: true,
                softLineBreak: true,
                shrinkWrap: true,
                fitContent: true,
                styleSheet: MarkdownStyleSheet(
                  p: baseStyle,
                  pPadding: EdgeInsets.zero,
                  h1: baseStyle.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                  h2: baseStyle.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  h3: baseStyle.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  strong: baseStyle.copyWith(fontWeight: FontWeight.w700),
                  em: baseStyle.copyWith(fontStyle: FontStyle.italic),
                  del: baseStyle.copyWith(
                    decoration: TextDecoration.lineThrough,
                  ),
                  listBullet: baseStyle,
                  a: baseStyle.copyWith(
                    color: isUser ? textColor : const Color(0xFF1565C0),
                    decoration: TextDecoration.underline,
                  ),
                  code: baseStyle.copyWith(
                    fontFamily: 'monospace',
                    backgroundColor: Colors.black.withValues(alpha: 0.08),
                    fontSize: 13,
                  ),
                  codeblockDecoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  codeblockPadding: const EdgeInsets.all(8),
                  blockquote: baseStyle.copyWith(
                    color: textColor.withValues(alpha: 0.85),
                  ),
                  blockquoteDecoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: textColor.withValues(alpha: 0.35),
                        width: 3,
                      ),
                    ),
                  ),
                  tableBody: baseStyle.copyWith(fontSize: 13),
                  tableHead: baseStyle.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onTapLink: (label, href, title) async {
                  if (href == null || href.isEmpty) return;
                  final uri = Uri.tryParse(href);
                  if (uri == null) return;
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
