import 'dart:typed_data';

import 'template_payload.dart';

enum MessageAuthor { user, bot, system }

/// Local / outbound file attached to a user chat bubble (SPM-style preview).
class ChatAttachment {
  const ChatAttachment({
    required this.fileName,
    required this.fileType,
    this.localPath,
    this.bytes,
    this.fileId,
  });

  final String fileName;
  final String fileType;
  final String? localPath;
  final Uint8List? bytes;
  final String? fileId;

  bool get isImage => fileType == 'image';
  bool get isVideo => fileType == 'video';
}

class ChatMessage {
  ChatMessage({
    required this.id,
    required this.author,
    this.text,
    this.template,
    this.attachment,
    this.iconUrl,
    this.createdAt,
    this.isStreaming = false,
    this.fromAgent = false,
    this.fromHistory = false,
    this.raw,
  });

  final String id;
  final MessageAuthor author;
  final String? text;
  final TemplatePayload? template;
  final ChatAttachment? attachment;
  final String? iconUrl;
  final DateTime? createdAt;
  final bool isStreaming;
  /// True when the message is from a live agent (`live_agent` / `fromAgent`).
  final bool fromAgent;
  /// True when restored from chat history (templates must not be selectable).
  final bool fromHistory;
  final Map<String, dynamic>? raw;

  bool get isUser => author == MessageAuthor.user;
  bool get isBot => author == MessageAuthor.bot;
  bool get isSystem => author == MessageAuthor.system;

  ChatMessage copyWith({
    String? text,
    TemplatePayload? template,
    ChatAttachment? attachment,
    String? iconUrl,
    bool? isStreaming,
    bool? fromAgent,
    bool? fromHistory,
  }) {
    return ChatMessage(
      id: id,
      author: author,
      text: text ?? this.text,
      template: template ?? this.template,
      attachment: attachment ?? this.attachment,
      iconUrl: iconUrl ?? this.iconUrl,
      createdAt: createdAt,
      isStreaming: isStreaming ?? this.isStreaming,
      fromAgent: fromAgent ?? this.fromAgent,
      fromHistory: fromHistory ?? this.fromHistory,
      raw: raw,
    );
  }

  /// Parses an incoming RTM WebSocket bot frame.
  factory ChatMessage.fromBotFrame(Map<String, dynamic> map) {
    final messageId = map['messageId']?.toString() ??
        map['id']?.toString() ??
        DateTime.now().millisecondsSinceEpoch.toString();

    final messages = map['message'];
    Map<String, dynamic>? outer;
    String? componentType;
    if (messages is List && messages.isNotEmpty) {
      final first = messages.first;
      if (first is Map) {
        final component = first['component'];
        if (component is Map) {
          componentType = component['type']?.toString().toLowerCase();
          final payload = component['payload'];
          if (payload is Map) {
            outer = Map<String, dynamic>.from(payload);
          }
        }
      }
    }

    String? displayText;
    TemplatePayload? template;

    if (outer != null) {
      displayText = outer['text'] as String? ?? outer['text_message'] as String?;
      final outerType =
          (outer['type'] as String?)?.toLowerCase() ?? componentType;

      // Nested escaped JSON in text (classic Kore format).
      final nested = tryParseEscapedJson(displayText);
      if (nested != null) {
        if (nested['payload'] is Map || nested['template_type'] != null) {
          outer = nested.containsKey('payload') || nested.containsKey('type')
              ? nested
              : {'payload': nested, 'text': nested['text']};
          displayText = outer['text'] as String? ??
              outer['text_message'] as String? ??
              displayText;
        }
      }

      final innerRaw = outer['payload'];
      Map<String, dynamic>? inner;
      if (innerRaw is Map) {
        inner = Map<String, dynamic>.from(innerRaw);
      } else if (innerRaw is String) {
        inner = tryParseEscapedJson(innerRaw);
      }

      if (inner != null) {
        template = TemplatePayload.fromJson(inner);
        if (template.text != null && template.text!.trim().isNotEmpty) {
          displayText = template.text;
        } else if (_looksLikeJsonBlob(displayText)) {
          displayText = null;
        }
      }

      // Classic Kore `type: "text"` envelope puts body in nested payload.text
      // (outer often has no top-level `text` field).
      if (outerType == 'text') {
        final nestedText = inner?['text']?.toString() ??
            outer['text']?.toString() ??
            displayText;
        if (nestedText != null && nestedText.trim().isNotEmpty) {
          displayText = nestedText;
          template = TemplatePayload(
            templateType: 'text',
            text: nestedText,
            raw: {
              if (inner != null) ...inner,
              'text': nestedText,
            },
          );
        }
      }

      // Attachment / media: component type image|audio|video|link, or
      // type "message" carrying videoUrl / audioUrl / media url.
      // Merge outer+inner so nested message payloads (videoUrl inside
      // payload.payload) are detected.
      final mediaSource = <String, dynamic>{
        ...outer,
        if (inner != null) ...inner,
        if (template != null) ...template.raw,
      };
      final mediaType = _resolveMediaType(
        componentType: componentType,
        outerType: outerType,
        payload: mediaSource,
        existing: template,
      );
      if (mediaType != null) {
        final mediaJson = Map<String, dynamic>.from(mediaSource);
        mediaJson['template_type'] = mediaType;
        mediaJson['url'] = mediaJson['url'] ??
            mediaJson['videoUrl'] ??
            mediaJson['audioUrl'];
        template = TemplatePayload.fromJson(mediaJson, fallbackType: mediaType);
        displayText = template.text ?? displayText;
      }

      // Plain text component without inner payload / media.
      if (template == null &&
          (outerType == 'text' || outerType == null || outerType == 'message') &&
          displayText != null &&
          displayText.trim().isNotEmpty &&
          !_looksLikeJsonBlob(displayText)) {
        template = TemplatePayload(templateType: 'text', text: displayText);
      }

      // Error component
      if (template == null && outerType == 'error') {
        template = TemplatePayload(
          templateType: 'text',
          text: outer['text']?.toString() ?? 'Error',
        );
        displayText = template.text;
      }
    }

    final ts = map['timestamp'];
    DateTime? createdAt;
    if (ts is num) {
      createdAt = DateTime.fromMillisecondsSinceEpoch(ts.toInt());
    }

    final isSystemTemplate = template?.isSystem == true;
    final fromAgent = template?.isLiveAgent == true ||
        map['fromAgent'] == true ||
        map['from_agent'] == true;

    return ChatMessage(
      id: messageId,
      author: isSystemTemplate ? MessageAuthor.system : MessageAuthor.bot,
      text: displayText,
      template: template,
      iconUrl: _readIconUrl(map),
      createdAt: createdAt ?? DateTime.now(),
      isStreaming: map['endChunk'] == false || map['sM'] == true,
      fromAgent: fromAgent,
      raw: map,
    );
  }

  factory ChatMessage.user({
    required String id,
    required String text,
    ChatAttachment? attachment,
  }) {
    return ChatMessage(
      id: id,
      author: MessageAuthor.user,
      text: text,
      attachment: attachment,
      createdAt: DateTime.now(),
    );
  }

  factory ChatMessage.system(String text) {
    return ChatMessage(
      id: 'sys_${DateTime.now().millisecondsSinceEpoch}',
      author: MessageAuthor.system,
      text: text,
      createdAt: DateTime.now(),
    );
  }
}

/// Detect image / audio / video / link attachment payloads.
String? _resolveMediaType({
  String? componentType,
  String? outerType,
  required Map<String, dynamic> payload,
  TemplatePayload? existing,
}) {
  // Prefer an already-recognized rich template (button, table, …).
  if (existing != null &&
      !existing.isText &&
      !existing.isMedia &&
      !existing.isLink) {
    return null;
  }

  const mediaTypes = {'image', 'audio', 'video', 'link'};
  for (final candidate in [componentType, outerType, existing?.templateType]) {
    if (candidate != null && mediaTypes.contains(candidate.toLowerCase())) {
      return candidate.toLowerCase();
    }
  }

  final videoUrl = payload['videoUrl']?.toString();
  if (videoUrl != null && videoUrl.trim().isNotEmpty) return 'video';

  final audioUrl = payload['audioUrl']?.toString();
  if (audioUrl != null && audioUrl.trim().isNotEmpty) return 'audio';

  final url = payload['url']?.toString();
  if (url != null && url.trim().isNotEmpty) {
    final lower = url.toLowerCase();
    if (_hasAny(lower, const [
      '.gif',
      '.png',
      '.jpg',
      '.jpeg',
      '.webp',
      '.bmp',
    ])) {
      return 'image';
    }
    if (_hasAny(lower, const ['.mp4', '.mov', '.3gp', '.flv', '.webm'])) {
      return 'video';
    }
    if (_hasAny(lower, const ['.mp3', '.wav', '.m4a', '.aac', '.amr'])) {
      return 'audio';
    }
    // Bare file URL with fileName → download/link attachment.
    if (payload['fileName'] != null || payload['name'] != null) {
      return 'link';
    }
  }
  return null;
}

bool _hasAny(String value, List<String> needles) {
  for (final n in needles) {
    if (value.contains(n)) return true;
  }
  return false;
}

String? _readIconUrl(Map<String, dynamic> map) {
  final direct = map['icon']?.toString();
  if (direct != null && direct.trim().isNotEmpty) return direct.trim();

  // Some payloads nest icon under botInfo.
  final botInfo = map['botInfo'];
  if (botInfo is Map) {
    final nested = botInfo['icon']?.toString() ?? botInfo['iconUrl']?.toString();
    if (nested != null && nested.trim().isNotEmpty) return nested.trim();
  }
  return null;
}

bool _looksLikeJsonBlob(String? text) {
  if (text == null) return false;
  final trimmed = text.trimLeft();
  return trimmed.startsWith('{') ||
      trimmed.startsWith('[') ||
      text.contains('&quot') ||
      text.contains('template_type');
}
