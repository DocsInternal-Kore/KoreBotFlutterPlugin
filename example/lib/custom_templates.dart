import 'package:flutter/material.dart';
import 'package:kore_bot_sdk/kore_bot_sdk.dart';

/// Custom template type key — include this in bot message `template_type`.
const promoCardTemplateType = 'promo_card';

/// Host registry with one **override** (existing SDK type) and one **new** type.
BotTemplateRegistry buildCustomTemplateRegistry() {
  final registry = BotTemplateRegistry();

  // Override the built-in `button` template.
  registry.register(
    BotTemplateTypes.button,
    (context, ctx) => CustomButtonTemplate(templateContext: ctx),
    override: true,
  );

  // New template type not shipped in the SDK.
  registry.register(
    promoCardTemplateType,
    (context, ctx) => CustomPromoCardTemplate(templateContext: ctx),
  );

  return registry;
}

/// Example override of the SDK `button` template.
class CustomButtonTemplate extends StatelessWidget {
  const CustomButtonTemplate({super.key, required this.templateContext});

  final BotTemplateContext templateContext;

  @override
  Widget build(BuildContext context) {
    final template = templateContext.template;
    final theme = templateContext.theme;
    final label = template.text ?? template.heading ?? template.title;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null && label.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: theme.botBubbleColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              label,
              style: TextStyle(color: theme.botTextColor, fontSize: 15),
            ),
          ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final button in template.buttons)
              Material(
                color: theme.buttonColor,
                borderRadius: BorderRadius.circular(22),
                elevation: 1,
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: () => templateContext.onButton(button),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.touch_app,
                          size: 16,
                          color: theme.buttonTextColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          button.title,
                          style: TextStyle(
                            color: theme.buttonTextColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.only(top: 6),
          child: Text(
            'Custom button override',
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}

/// Example brand-new template (`template_type: promo_card`).
class CustomPromoCardTemplate extends StatelessWidget {
  const CustomPromoCardTemplate({super.key, required this.templateContext});

  final BotTemplateContext templateContext;

  @override
  Widget build(BuildContext context) {
    final raw = templateContext.raw;
    final theme = templateContext.theme;
    final title = raw['title']?.toString() ??
        templateContext.template.title ??
        'Promotion';
    final subtitle = raw['subtitle']?.toString() ??
        templateContext.template.subtitle ??
        '';
    final cta = raw['cta']?.toString() ??
        (templateContext.template.buttons.isNotEmpty
            ? templateContext.template.buttons.first.title
            : '');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.buttonColor,
            theme.buttonColor.withValues(alpha: 0.75),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 14,
              ),
            ),
          ],
          if (cta.isNotEmpty) ...[
            const SizedBox(height: 12),
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Text(
                  cta,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.buttonColor,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
