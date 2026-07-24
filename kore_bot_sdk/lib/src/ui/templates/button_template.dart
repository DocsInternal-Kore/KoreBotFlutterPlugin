import 'package:flutter/material.dart';

import '../../models/template_payload.dart';
import '../theme/bot_chat_theme.dart';
import 'template_helpers.dart';

/// SPM `QuickReplyWelcomeBubbleView` for `template_type: button`.
///
/// Supported payload flags:
/// - `variation`: `""` / missing → same as `backgroundInverted`; also `plain`, `textInverted`, `backgroundInverted`
/// - `fullWidth`: true → each button stretches full width (also stacks vertically)
/// - `stackedButtons`: true → vertical list (compact unless fullWidth)
///
/// After one button is tapped, further taps are ignored (SPM `maskview`).
class ButtonTemplate extends StatefulWidget {
  const ButtonTemplate({
    super.key,
    required this.template,
    required this.theme,
    required this.onButton,
  });

  final TemplatePayload template;
  final BotChatTheme theme;
  final TemplateAction onButton;

  @override
  State<ButtonTemplate> createState() => _ButtonTemplateState();
}

class _ButtonTemplateState extends State<ButtonTemplate>
    with AutomaticKeepAliveClientMixin {
  static const double _buttonHeight = 40;
  static const double _spacing = 10;
  static const double _cornerRadius = 5;

  bool _selected = false;

  @override
  bool get wantKeepAlive => true;

  String get _variation {
    final raw = widget.template.raw['variation']?.toString().trim() ?? '';
    return raw.toLowerCase();
  }

  bool get _fullWidth => widget.template.raw['fullWidth'] == true;

  /// Vertical list when stacked or when each button is full-width.
  bool get _stacked {
    if (widget.template.raw['stackedButtons'] == true) return true;
    if (_variation == 'stackedbuttons') return true;
    if (_fullWidth) return true;
    return false;
  }

  Future<void> _onPressed(BotButton button) async {
    if (_selected) return;
    setState(() => _selected = true);
    await handleTemplateButton(button, widget.onButton);
  }

  _ButtonStyleTokens _tokensFor(String variation) {
    const defaultBg = Color(0xFFF3F3F5);

    switch (variation) {
      case 'plain':
        // Platform/web: white fill, light gray outline, bot text.
        return _ButtonStyleTokens(
          background: Colors.white,
          foreground: widget.theme.botTextColor,
          border: const Color(0xFFD0D0D0),
        );
      case 'textinverted':
        // Platform: light gray fill + accent text (inverse of backgroundInverted).
        return _ButtonStyleTokens(
          background: defaultBg,
          foreground: widget.theme.buttonColor,
          border: defaultBg,
        );
      case 'backgroundinverted':
        // Solid accent fill + light text (inverted from default chips).
        return _ButtonStyleTokens(
          background: widget.theme.buttonColor,
          foreground: widget.theme.buttonTextColor,
          border: widget.theme.buttonColor,
        );
      case 'stackedbuttons':
        // Full-width outlined accent buttons (legacy Flutter + SPM stacked feel).
        return _ButtonStyleTokens(
          background: Colors.white,
          foreground: widget.theme.buttonColor,
          border: widget.theme.buttonColor,
        );
      default:
        // No variation → same as backgroundInverted.
        return _ButtonStyleTokens(
          background: widget.theme.buttonColor,
          foreground: widget.theme.buttonTextColor,
          border: widget.theme.buttonColor,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final buttons = widget.template.buttons;
    if (buttons.isEmpty) {
      return templateShell(
        theme: widget.theme,
        text: widget.template.text,
        children: const [],
      );
    }

    final variation = _variation;
    final tokens = _tokensFor(variation);
    final fullWidth = _fullWidth;
    final stacked = _stacked;

    return templateShell(
      theme: widget.theme,
      text: widget.template.text,
      children: [
        AbsorbPointer(
          absorbing: _selected,
          child: stacked
              // Vertical stack; width only stretches when fullWidth is true.
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final button in buttons)
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 4,
                          bottom: _spacing - 4,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _ButtonChip(
                            label: button.title,
                            tokens: tokens,
                            height: _buttonHeight,
                            cornerRadius: _cornerRadius,
                            fullWidth: fullWidth,
                            onPressed: _selected
                                ? null
                                : () => _onPressed(button),
                          ),
                        ),
                      ),
                  ],
                )
              // Flow left-to-right, wrapping to the next row when needed.
              : Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Wrap(
                    spacing: _spacing,
                    runSpacing: _spacing,
                    children: [
                      for (final button in buttons)
                        _ButtonChip(
                          label: button.title,
                          tokens: tokens,
                          height: _buttonHeight,
                          cornerRadius: _cornerRadius,
                          fullWidth: false,
                          onPressed:
                              _selected ? null : () => _onPressed(button),
                        ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

class _ButtonStyleTokens {
  const _ButtonStyleTokens({
    required this.background,
    required this.foreground,
    required this.border,
  });

  final Color background;
  final Color foreground;
  final Color border;
}

/// SPM `ButtonLinkCell` styling for button / quick-reply-welcome chips.
class _ButtonChip extends StatelessWidget {
  const _ButtonChip({
    required this.label,
    required this.tokens,
    required this.height,
    required this.cornerRadius,
    required this.fullWidth,
    required this.onPressed,
  });

  final String label;
  final _ButtonStyleTokens tokens;
  final double height;
  final double cornerRadius;
  final bool fullWidth;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final child = Material(
      color: tokens.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cornerRadius),
        side: BorderSide(color: tokens.border, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          height: height,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: tokens.foreground,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
        ),
      ),
    );

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: child);
    }
    return IntrinsicWidth(child: child);
  }
}
