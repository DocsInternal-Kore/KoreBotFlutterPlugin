import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controller/bot_chat_controller.dart';
import '../../models/chat_message.dart';
import '../../models/template_payload.dart';
import '../theme/bot_chat_theme.dart';
import '../widgets/bot_avatar.dart';
import 'button_link_template.dart';
import 'button_template.dart';
import 'carousel_stacked_template.dart';
import 'carousel_template.dart';
import 'chart_templates.dart';
import 'feedback_templates.dart';
import 'form_select_templates.dart';
import 'list_template.dart';
import 'list_variants.dart';
import 'media_card_templates.dart';
import 'misc_templates.dart';
import 'quick_replies_template.dart';
import 'table_templates.dart';
import 'template_helpers.dart';
import 'text_bubble.dart';
import 'audio_template.dart';
import 'bot_template_registry.dart';
import 'video_template.dart';

class MessageBubble extends StatefulWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.theme,
    required this.controller,
    this.templateRegistry,
  });

  final ChatMessage message;
  final BotChatTheme theme;
  final BotChatController controller;
  final BotTemplateRegistry? templateRegistry;

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
    with AutomaticKeepAliveClientMixin {
  /// Keep interactive template state (checkbox / radio / form / feedback)
  /// alive while the chat list scrolls.
  @override
  bool get wantKeepAlive => true;

  ChatMessage get message => widget.message;
  BotChatTheme get theme => widget.theme;
  BotChatController get controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (message.author == MessageAuthor.system ||
        message.template?.isSystem == true) {
      final text = (message.text ?? message.template?.text ?? '').trim();
      if (text.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
      );
    }

    final isUser = message.isUser;
    final alignment = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final bubbleColor = isUser ? theme.userBubbleColor : theme.botBubbleColor;
    final textColor = isUser ? theme.userTextColor : theme.botTextColor;
    final showIcon = !isUser && theme.showIcon;
    // Tables stretch toward the user-bubble edge (near full chat width).
    final isWideTable = !isUser &&
        (message.template?.isTable == true ||
            message.template?.isTableList == true ||
            message.template?.isMiniTable == true);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final maxBubbleWidth =
        isWideTable ? screenWidth - 8 : screenWidth * 0.88;

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxBubbleWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isWideTable ? 8 : 12,
            vertical: 4,
          ),
          child: Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            // Top-align so bot icon appears with the template.
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showIcon) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: BotAvatar(
                    key: ValueKey(
                      'avatar_${message.iconUrl ?? theme.botIconUrl ?? 'fallback'}',
                    ),
                    iconUrl: message.iconUrl ?? theme.botIconUrl,
                    backgroundColor: theme.headerColor,
                    allowBadCertificates: theme.allowBadCertificates,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Column(
                  crossAxisAlignment: isUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    if (message.createdAt != null)
                      Padding(
                        padding:
                            const EdgeInsets.only(bottom: 4, left: 2, right: 2),
                        child: Text(
                          _formatTimestamp(message.createdAt!),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 11,
                            height: 1.2,
                          ),
                        ),
                      ),
                    if (isUser && message.attachment != null) ...[
                      _UserAttachmentPreview(
                        attachment: message.attachment!,
                        bubbleColor: bubbleColor,
                        textColor: textColor,
                        square: theme.isSquareBubble,
                      ),
                      Builder(
                        builder: (context) {
                          final caption = _userAttachmentCaption(message);
                          if (caption == null || caption.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: TextBubble(
                              text: caption,
                              background: bubbleColor,
                              textColor: textColor,
                              isUser: true,
                              square: theme.isSquareBubble,
                            ),
                          );
                        },
                      ),
                    ] else if (isUser ||
                        message.template == null ||
                        _isPlainText(message))
                      TextBubble(
                        text: message.text ?? message.template?.text ?? '',
                        background: bubbleColor,
                        textColor: textColor,
                        isUser: isUser,
                        square: theme.isSquareBubble,
                      )
                    else
                      _wrapHistoryTemplate(
                        _buildTemplate(context, message.template!),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime time) {
    return DateFormat("EE, MMM dd yyyy 'at' hh:mm:ss a").format(time.toLocal());
  }

  bool _isPlainText(ChatMessage message) {
    final t = message.template;
    if (t == null) return true;
    if (t.isSystem || t.isLiveAgent) return true;
    if (t.isText) return true;
    if (t.isQuickReplies) return true;
    return false;
  }

  /// Caption only (SPM body is `caption\n emoji fileName`).
  String? _userAttachmentCaption(ChatMessage message) {
    final text = message.text?.trim();
    if (text == null || text.isEmpty) return null;
    final newline = text.indexOf('\n');
    if (newline < 0) return text;
    final caption = text.substring(0, newline).trim();
    return caption.isEmpty ? null : caption;
  }

  /// SPM: history templates are not selectable / submittable.
  Widget _wrapHistoryTemplate(Widget child) {
    if (!message.fromHistory) return child;
    return AbsorbPointer(
      absorbing: true,
      child: child,
    );
  }

  Widget _buildTemplate(BuildContext context, TemplatePayload template) {
    Future<void> onButton(BotButton button) async {
      if (message.fromHistory) return;
      final type = button.type.toLowerCase();
      if ((type == 'url' || type == 'web_url') &&
          (button.url != null || button.payload != null)) {
        final uri = Uri.tryParse(button.url ?? button.payload ?? '');
        if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return;
        }
      }
      await controller.handleButton(button);
    }

    Future<void> onSubmit({required String payload, String? displayText}) async {
      if (message.fromHistory) return;
      try {
        await controller.sendPayload(
          payload: payload,
          displayText: displayText,
        );
      } catch (error, stack) {
        debugPrint('[KoreBot] template submit failed: $error\n$stack');
      }
    }

    // Host registry: new types + overrides of built-in types.
    final custom = widget.templateRegistry?.build(
      context,
      BotTemplateContext(
        template: template,
        message: message,
        theme: theme,
        controller: controller,
        onButton: onButton,
        onSubmit: onSubmit,
      ),
    );
    if (custom != null) return custom;

    if (template.isButton) {
      return ButtonTemplate(template: template, theme: theme, onButton: onButton);
    }
    if (template.isButtonLink) {
      return ButtonLinkTemplate(template: template, theme: theme, onButton: onButton);
    }
    if (template.isCarouselStacked) {
      return CarouselStackedTemplate(
          template: template, theme: theme, onButton: onButton);
    }
    if (template.isCarousel) {
      return CarouselTemplate(template: template, theme: theme, onButton: onButton);
    }
    if (template.isListView) {
      return ListViewTemplate(template: template, theme: theme, onButton: onButton);
    }
    if (template.isListWidget) {
      return ListWidgetTemplate(template: template, theme: theme, onButton: onButton);
    }
    if (template.isAdvancedList) {
      return AdvancedListTemplate(
          template: template, theme: theme, onButton: onButton);
    }
    if (template.isList) {
      return ListTemplate(template: template, theme: theme, onButton: onButton);
    }
    if (template.isPieChart) {
      return PieChartTemplate(template: template, theme: theme);
    }
    if (template.isLineChart) {
      return LineChartTemplate(template: template, theme: theme);
    }
    if (template.isBarChart) {
      return BarChartTemplate(template: template, theme: theme);
    }
    if (template.isMiniTable) {
      return MiniTableTemplate(template: template, theme: theme);
    }
    if (template.isTableList) {
      return TableListTemplate(
          template: template, theme: theme, onButton: onButton);
    }
    if (template.isTable) {
      return TableTemplate(
        template: template,
        theme: theme,
        responsive: template.isTableResponsive,
      );
    }
    if (template.isForm) {
      return FormTemplate(template: template, theme: theme, onSubmit: onSubmit);
    }
    if (template.isMultiSelect) {
      return MultiSelectTemplate(
          template: template, theme: theme, onSubmit: onSubmit);
    }
    if (template.isAdvanceMultiSelect) {
      return AdvanceMultiSelectTemplate(
          template: template, theme: theme, onSubmit: onSubmit);
    }
    if (template.isRadioOptions) {
      return RadioOptionsTemplate(
          template: template, theme: theme, onSubmit: onSubmit);
    }
    if (template.isDropdown) {
      return DropdownTemplate(
          template: template, theme: theme, onSubmit: onSubmit);
    }
    if (template.isFeedback) {
      return FeedbackTemplate(
          template: template, theme: theme, onSubmit: onSubmit);
    }
    if (template.isBankingFeedback) {
      return BankingFeedbackTemplate(
          template: template, theme: theme, onSubmit: onSubmit);
    }
    if (template.isCard) {
      return CardTemplate(template: template, theme: theme, onButton: onButton);
    }
    if (template.isContactCard) {
      return ContactCardTemplate(template: template, theme: theme);
    }
    if (template.isVideo) {
      return VideoTemplate(template: template, theme: theme);
    }
    if (template.isAudio) {
      return AudioTemplate(template: template, theme: theme);
    }
    if (template.isMedia) {
      return MediaTemplate(template: template, theme: theme);
    }
    if (template.isLink) {
      return LinkTemplate(template: template, theme: theme);
    }
    if (template.isPdf) {
      return PdfTemplate(template: template, theme: theme);
    }
    if (template.isDatePicker) {
      return DatePickerTemplate(
          template: template, theme: theme, onSubmit: onSubmit);
    }
    if (template.isClock) {
      return ClockTemplate(
          template: template, theme: theme, onSubmit: onSubmit);
    }
    if (template.isResults) {
      return ResultsTemplate(template: template, theme: theme);
    }
    if (template.isBeneficiary) {
      return BeneficiaryTemplate(
          template: template, theme: theme, onButton: onButton);
    }
    if (template.isAgentTransfer) {
      return AgentTransferTemplate(
          template: template, theme: theme, onButton: onButton);
    }
    if (template.isQuickReplies) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if ((template.text ?? template.heading ?? template.title) != null)
          TextBubble(
            text: template.text ?? template.heading ?? template.title ?? '',
            background: theme.botBubbleColor,
            textColor: theme.botTextColor,
            isUser: false,
            square: theme.isSquareBubble,
          ),
        if (template.buttons.isNotEmpty)
          ButtonTemplate(template: template, theme: theme, onButton: onButton),
        if (template.elements.isNotEmpty)
          ListTemplate(template: template, theme: theme, onButton: onButton),
        if (template.buttons.isEmpty &&
            template.elements.isEmpty &&
            template.listItems.isEmpty &&
            template.cards.isEmpty &&
            (template.text == null || template.text!.isEmpty))
          templateCard(
            child: Text(
              '[${template.templateType}]',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ),
      ],
    );
  }
}

class _UserAttachmentPreview extends StatelessWidget {
  const _UserAttachmentPreview({
    required this.attachment,
    required this.bubbleColor,
    required this.textColor,
    required this.square,
  });

  final ChatAttachment attachment;
  final Color bubbleColor;
  final Color textColor;
  final bool square;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(square ? 4 : 14);
    if (attachment.isImage) {
      Widget image;
      if (attachment.localPath != null &&
          File(attachment.localPath!).existsSync()) {
        image = Image.file(
          File(attachment.localPath!),
          fit: BoxFit.cover,
          width: 180,
          height: 140,
        );
      } else if (attachment.bytes != null) {
        image = Image.memory(
          attachment.bytes!,
          fit: BoxFit.cover,
          width: 180,
          height: 140,
        );
      } else {
        return const SizedBox.shrink();
      }
      return ClipRRect(
        borderRadius: radius,
        child: image,
      );
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 220),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: radius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            attachment.isVideo ? Icons.videocam : Icons.insert_drive_file,
            color: textColor,
            size: 22,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              attachment.fileName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: textColor, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class QuickReplyBar extends StatelessWidget {
  const QuickReplyBar({
    super.key,
    required this.replies,
    required this.theme,
    required this.onSelected,
  });

  final List<BotButton> replies;
  final BotChatTheme theme;
  final Future<void> Function(BotButton button) onSelected;

  @override
  Widget build(BuildContext context) {
    if (replies.isEmpty) return const SizedBox.shrink();
    return QuickRepliesTemplate(
      replies: replies,
      theme: theme,
      onSelected: onSelected,
    );
  }
}
