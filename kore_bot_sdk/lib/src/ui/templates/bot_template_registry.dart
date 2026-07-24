import 'package:flutter/material.dart';

import '../../controller/bot_chat_controller.dart';
import '../../models/chat_message.dart';
import '../../models/template_payload.dart';
import '../theme/bot_chat_theme.dart';
import 'template_helpers.dart';

/// Built-in `template_type` keys (values are lowercased to match parsing).
abstract final class BotTemplateTypes {
  static const text = 'text';
  static const button = 'button';
  static const buttonLink = 'buttonlinktemplate';
  static const quickReplies = 'quick_replies';
  static const list = 'list';
  static const listView = 'listview';
  static const listWidget = 'listwidget';
  static const advancedList = 'advancedlisttemplate';
  static const carousel = 'carousel';
  static const stacked = 'stacked';
  static const pieChart = 'piechart';
  static const lineChart = 'linechart';
  static const barChart = 'barchart';
  static const table = 'table';
  static const miniTable = 'mini_table';
  static const tableList = 'tablelist';
  static const form = 'form_template';
  static const multiSelect = 'multi_select';
  static const advancedMultiSelect = 'advanced_multi_select';
  static const radioOptions = 'radiooptiontemplate';
  static const dropdown = 'dropdown_template';
  static const feedback = 'feedbacktemplate';
  static const bankingFeedback = 'bankingfeedbacktemplate';
  static const card = 'cardtemplate';
  static const contactCard = 'contactcardtemplate';
  static const image = 'image';
  static const audio = 'audio';
  static const video = 'video';
  static const link = 'link';
  static const pdfDownload = 'pdfdownload';
  static const clock = 'clocktemplate';
  static const date = 'datetemplate';
  static const search = 'search';
  static const beneficiary = 'beneficiarytemplate';
  static const notification = 'notification';
}

/// Context passed to every custom / override template builder.
class BotTemplateContext {
  const BotTemplateContext({
    required this.template,
    required this.message,
    required this.theme,
    required this.controller,
    required this.onButton,
    required this.onSubmit,
  });

  final TemplatePayload template;
  final ChatMessage message;
  final BotChatTheme theme;
  final BotChatController controller;
  final TemplateAction onButton;
  final TemplatePayloadAction onSubmit;

  bool get fromHistory => message.fromHistory;

  /// Raw payload map from the bot (useful for custom template fields).
  Map<String, dynamic> get raw => template.raw;
}

/// Builds a widget for a given [template_type].
typedef BotTemplateBuilder = Widget Function(
  BuildContext context,
  BotTemplateContext templateContext,
);

/// Registry for custom and override template renderers.
///
/// Host apps can:
/// - **Add** a new type (not in the SDK) with [register]
/// - **Override** an existing SDK type with [register] (`override: true`)
///
/// Pass the registry to [KoreBotChat.open] / [BotChatScreen].
class BotTemplateRegistry {
  final Map<String, BotTemplateBuilder> _builders = {};

  /// Registers a builder for [type] (`template_type`, case-insensitive).
  ///
  /// Throws if [type] is already registered unless [override] is `true`.
  void register(
    String type,
    BotTemplateBuilder builder, {
    bool override = false,
  }) {
    final key = _normalize(type);
    if (_builders.containsKey(key) && !override) {
      throw ArgumentError(
        'Builder for "$key" is already registered. '
        'Pass override: true to replace it.',
      );
    }
    _builders[key] = builder;
  }

  bool contains(String type) => _builders.containsKey(_normalize(type));

  /// Returns the registered builder for [type], or `null`.
  BotTemplateBuilder? builderFor(String type) => _builders[_normalize(type)];

  /// Builds the widget if a builder is registered for [ctx.template.templateType].
  Widget? build(BuildContext context, BotTemplateContext ctx) {
    final builder = builderFor(ctx.template.templateType);
    if (builder == null) return null;
    return builder(context, ctx);
  }

  /// Copy of this registry with [other] additions/overrides applied.
  BotTemplateRegistry mergedWith(BotTemplateRegistry? other) {
    if (other == null) return copy();
    final merged = copy();
    other._builders.forEach((type, builder) {
      merged._builders[type] = builder;
    });
    return merged;
  }

  BotTemplateRegistry copy() {
    final copy = BotTemplateRegistry();
    copy._builders.addAll(_builders);
    return copy;
  }

  static String _normalize(String type) => type.trim().toLowerCase();
}
