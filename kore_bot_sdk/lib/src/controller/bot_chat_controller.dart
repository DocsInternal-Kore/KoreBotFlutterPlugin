import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../config/bot_config.dart';
import '../models/chat_message.dart';
import '../models/template_payload.dart';
import '../net/bot_connection_state.dart';
import '../net/bot_rest_client.dart';
import '../net/bot_socket_client.dart';
import '../net/branding_service.dart';
import '../net/file_upload_service.dart';
import '../services/speech_services.dart';
import '../session/bot_chat_session_state.dart';
import '../ui/theme/bot_chat_theme.dart';

typedef BotEventCallback = void Function(String eventCode, String eventMessage);

/// Orchestrates STS → jwtgrant → rtm/start → WebSocket and message state.
class BotChatController {
  BotChatController({
    required this.config,
    this.onEvent,
    BotChatTheme? initialTheme,
    BotRestClient? restClient,
    BotSocketClient? socketClient,
    BrandingService? brandingService,
    FileUploadService? fileUploadService,
    TextToSpeechService? ttsService,
  })  : _rest = restClient ?? BotRestClient(config),
        _socket = socketClient ??
            BotSocketClient(allowBadCertificates: config.allowBadCertificates),
        _branding = brandingService ?? BrandingService(config),
        _uploader = fileUploadService ?? FileUploadService(config),
        tts = ttsService ?? TextToSpeechService(),
        _theme = (initialTheme ?? const BotChatTheme()).copyWith(
          botName: config.chatBotName,
          botIconUrl: config.botIconUrl,
          footerHintText: config.footerHintText,
          showAttachment: config.showAttachment,
          showMicrophone: config.showMicrophone,
          showTextToSpeech: config.showTextToSpeech,
          showIcon: config.showIcon,
          allowBadCertificates: config.allowBadCertificates,
        );

  final BotConfig config;
  final BotEventCallback? onEvent;
  final TextToSpeechService tts;

  final BotRestClient _rest;
  final BotSocketClient _socket;
  final BrandingService _branding;
  final FileUploadService _uploader;

  final List<ChatMessage> _messages = [];
  final _messagesController = StreamController<List<ChatMessage>>.broadcast();
  final _stateController = StreamController<BotConnectionState>.broadcast();
  final _quickRepliesController = StreamController<List<BotButton>>.broadcast();
  final _typingController = StreamController<bool>.broadcast();
  final _themeController = StreamController<BotChatTheme>.broadcast();

  BotAuthSession? _session;
  BotConnectionState _state = BotConnectionState.idle;
  List<BotButton> _quickReplies = const [];
  BotChatTheme _theme;
  bool _disposed = false;
  /// True after a live-agent message (SPM `isAgentConnect`).
  bool _agentConnected = false;
  bool _historyLoading = false;
  bool _hasMoreHistory = true;
  /// SPM `historyLimit` — live session messages only (excludes pull-to-refresh history).
  int _sessionHistoryLimit = 0;
  static const int defaultHistoryBatchSize = 20;
  static const String closeAgentChatEvent = 'close_agent_chat';
  static const String closeButtonEvent = 'close_button_event';
  static const String minimizeButtonEvent = 'minimize_button_event';

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  BotConnectionState get state => _state;
  List<BotButton> get quickReplies => List.unmodifiable(_quickReplies);
  BotChatTheme get theme => _theme;
  bool get hasMoreHistory => _hasMoreHistory;
  bool get isHistoryLoading => _historyLoading;
  String? get accessToken => _session?.accessToken;
  String? get botUserId => _session?.botUserId;
  String? get botIconUrl => _theme.botIconUrl;

  Stream<List<ChatMessage>> get messagesStream => _messagesController.stream;
  Stream<BotConnectionState> get stateStream => _stateController.stream;
  Stream<List<BotButton>> get quickRepliesStream => _quickRepliesController.stream;
  Stream<bool> get typingStream => _typingController.stream;
  Stream<BotChatTheme> get themeStream => _themeController.stream;

  Future<void> connect() async {
    if (_disposed) return;
    _setState(BotConnectionState.connecting);

    try {
      final jwt = (config.jwtToken != null && config.jwtToken!.isNotEmpty)
          ? config.jwtToken!
          : await _rest.fetchStsJwt();

      final session = await _rest.jwtGrant(jwt);
      _session = session;

      // SPM: Minimize → isReconnect=true (continue session).
      // Close / first open → isReconnect=false (new session + welcome).
      final nextOpen = BotChatSessionState.nextOpen;
      final isReconnect = nextOpen == BotChatNextOpen.afterMinimize;
      debugPrint(
        '[KoreBot] rtm connect isReconnect=$isReconnect '
        '(nextOpen=$nextOpen, historyLimit=${BotChatSessionState.historyMessageLimit})',
      );

      if (!isReconnect) {
        // Ensure Close / fresh never resumes prior in-memory messages.
        _clearSessionState();
      }

      final rtmUrl = await _rest.startRtm(
        session.accessToken,
        isReconnect: isReconnect,
      );
      await _openSocket(rtmUrl);

      _setState(BotConnectionState.connected);
      _emitEvent('BotConnected', 'Bot connected successfully');

      // Branding first so theme/icon apply before history messages render.
      await _loadBranding(session.accessToken);

      if (isReconnect) {
        // Continue previous session: restore live-session message count only.
        final limit = BotChatSessionState.historyMessageLimit;
        _sessionHistoryLimit = limit;
        if (limit > 0) {
          await loadHistory(limit: limit);
        }
      } else if (nextOpen == BotChatNextOpen.fresh && config.callHistory) {
        // First open only — Close never loads history.
        await loadHistory();
      }
      // afterClose: new session, welcome via isReconnect=false, no history.
    } catch (error) {
      final code = error is BotRestException ? error.code ?? 'Error_STS' : 'Error_Socket';
      _setState(BotConnectionState.error);
      _emitEvent(code, error.toString());
      rethrow;
    }
  }

  Future<void> _loadBranding(String accessToken) async {
    try {
      final branding = await _branding.fetch(accessToken);
      if (branding == null || _disposed) return;
      final existingIcon = _theme.botIconUrl;
      var next = branding.applyTo(_theme);
      // Prefer an already-configured / previously shown icon; otherwise take
      // branding icon when available.
      if (existingIcon != null && existingIcon.isNotEmpty) {
        next = next.copyWith(botIconUrl: existingIcon);
      } else if (branding.botIconUrl != null && branding.botIconUrl!.isNotEmpty) {
        next = next.copyWith(botIconUrl: branding.botIconUrl);
      }
      _setTheme(next);
      if (_theme.showTextToSpeech) {
        await tts.init();
      }
    } catch (_) {}
  }

  Future<void> _openSocket(String url) async {
    _socket.onMessage = _handleSocketMessage;
    _socket.onError = (error) {
      _setState(BotConnectionState.error);
      _emitEvent('Error_Socket', error.toString());
    };
    _socket.onClose = () {
      if (_state == BotConnectionState.connected) {
        _setState(BotConnectionState.disconnected);
      }
    };
    await _socket.connect(url);
  }

  void _handleSocketMessage(Map<String, dynamic> map) {
    if (map.containsKey('replyto') && map['message'] == null) {
      return;
    }

    final messages = map['message'];
    if (messages is! List || messages.isEmpty) {
      return;
    }

    final chatMessage = ChatMessage.fromBotFrame(map);

    // Cache the first bot icon into theme for messages that omit `icon`.
    final icon = chatMessage.iconUrl;
    if ((_theme.botIconUrl == null || _theme.botIconUrl!.isEmpty) &&
        icon != null &&
        icon.isNotEmpty) {
      _setTheme(_theme.copyWith(botIconUrl: icon));
    }

    final hasText = chatMessage.text != null && chatMessage.text!.trim().isNotEmpty;
    final hasTemplate = chatMessage.template != null &&
        chatMessage.template!.templateType.isNotEmpty &&
        chatMessage.template!.templateType != 'text';
    if (!hasText &&
        !hasTemplate &&
        !(chatMessage.template?.buttons.isNotEmpty ?? false) &&
        !(chatMessage.template?.elements.isNotEmpty ?? false)) {
      return;
    }

    if (!chatMessage.isStreaming &&
        chatMessage.id.isNotEmpty &&
        _messages.any((m) => m.isBot && m.id == chatMessage.id && !m.isStreaming)) {
      return;
    }

    if (chatMessage.isStreaming &&
        _messages.isNotEmpty &&
        _messages.last.isBot &&
        _messages.last.isStreaming) {
      final last = _messages.last;
      final mergedText = '${last.text ?? ''}${chatMessage.text ?? ''}';
      _messages[_messages.length - 1] = last.copyWith(
        text: mergedText,
        isStreaming: true,
      );
    } else if (!chatMessage.isStreaming &&
        _messages.isNotEmpty &&
        _messages.last.isBot &&
        _messages.last.isStreaming &&
        (_messages.last.id == chatMessage.id || chatMessage.id.isEmpty)) {
      _messages[_messages.length - 1] = chatMessage.copyWith(isStreaming: false);
    } else {
      _messages.add(chatMessage);
      // SPM: historyLimit++ only for live messages, not history API inserts.
      _sessionHistoryLimit++;
    }

    _logInbound(chatMessage, map);
    _publishMessages();

    if (chatMessage.fromAgent || chatMessage.template?.isLiveAgent == true) {
      _agentConnected = true;
    }

    final qr = chatMessage.template?.quickReplies ?? const <BotButton>[];
    if (chatMessage.template?.isQuickReplies == true || qr.isNotEmpty) {
      _setQuickReplies(qr.isNotEmpty ? qr : chatMessage.template?.buttons ?? const []);
    } else if (chatMessage.template?.buttons.isNotEmpty == true &&
        chatMessage.template?.isButton == true) {
      _setQuickReplies(const []);
    }

    _typingController.add(false);

    if (!chatMessage.isStreaming) {
      final speakText = chatMessage.text ?? chatMessage.template?.text;
      if (speakText != null && speakText.isNotEmpty) {
        unawaited(tts.speak(speakText));
      }
    }
  }

  Future<void> loadHistory({int offset = 0, int limit = defaultHistoryBatchSize}) async {
    await _fetchAndMergeHistory(offset: offset, limit: limit);
  }

  /// Pull-to-refresh / load older page (SPM `fetchMessages`).
  ///
  /// History API `offset` = number of messages currently displayed in the chat
  /// (SPM: `getMessagesCount` → `offset`).
  /// Returns how many **new** messages were prepended.
  Future<int> loadMoreHistory({int limit = defaultHistoryBatchSize}) async {
    if (_disposed || !_hasMoreHistory) return 0;
    final displayCount = _messages.length;
    return _fetchAndMergeHistory(offset: displayCount, limit: limit);
  }

  Future<int> _fetchAndMergeHistory({
    required int offset,
    required int limit,
  }) async {
    final token = _session?.accessToken;
    if (token == null || _historyLoading) return 0;
    _historyLoading = true;

    try {
      final data = await _rest.fetchHistory(
        accessToken: token,
        offset: offset,
        limit: limit,
      );

      // SPM: history response root `icon` → botHistoryIcon for chat avatars.
      final historyIcon = data['icon']?.toString().trim();
      if (historyIcon != null && historyIcon.isNotEmpty) {
        _setTheme(_theme.copyWith(botIconUrl: historyIcon));
      }
      final fallbackIcon = (historyIcon != null && historyIcon.isNotEmpty)
          ? historyIcon
          : _theme.botIconUrl;

      final list = data['messages'];
      if (list is! List) {
        _hasMoreHistory = false;
        return 0;
      }

      final history = <ChatMessage>[];
      for (final item in list) {
        if (item is! Map) continue;
        final parsed = _parseHistoryItem(
          Map<String, dynamic>.from(item),
          fallbackIconUrl: fallbackIcon,
        );
        if (parsed != null) history.add(parsed);
      }

      if (list.length < limit) {
        _hasMoreHistory = false;
      }

      if (history.isEmpty) return 0;

      history.sort((a, b) {
        final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return aTime.compareTo(bTime);
      });

      final existingIds = _messages.map((m) => m.id).toSet();
      final fresh =
          history.where((m) => !existingIds.contains(m.id)).toList();
      if (fresh.isEmpty) return 0;

      if (_messages.isEmpty) {
        _messages.addAll(fresh);
      } else {
        _messages.insertAll(0, fresh);
      }
      _publishMessages();
      return fresh.length;
    } catch (error) {
      debugPrint('[KoreBot] history load failed: $error');
      return 0;
    } finally {
      _historyLoading = false;
    }
  }

  ChatMessage? _parseHistoryItem(
    Map<String, dynamic> map, {
    String? fallbackIconUrl,
  }) {
    final type = map['type'] as String?;
    final components = map['components'];
    String? text;
    TemplatePayload? template;

    if (components is List && components.isNotEmpty) {
      final first = components.first;
      if (first is Map) {
        final dataMap = first['data'];
        if (dataMap is Map) {
          final rawText = dataMap['text']?.toString();
          text = rawText;
          final nested = tryParseEscapedJson(rawText);
          if (nested != null) {
            final inner = nested['payload'];
            if (inner is Map) {
              template = TemplatePayload.fromJson(
                Map<String, dynamic>.from(inner),
              );
              text = template.text ?? nested['text'] as String? ?? text;
            } else if (nested['template_type'] != null) {
              template = TemplatePayload.fromJson(nested);
              text = template.text ?? text;
            }
          }
        }
      }
    }

    // SPM: prefer tags.altText[0].value (display label) over raw payload text.
    // e.g. text="payload1", altText=[{value:"Button Four", name:"label"}]
    if (template == null) {
      final alt = _historyAltTextLabel(map);
      if (alt != null && alt.isNotEmpty) {
        text = alt;
      }
    }

    final id = map['_id']?.toString() ??
        DateTime.now().millisecondsSinceEpoch.toString();
    final createdOn = map['createdOn'] as String?;
    DateTime? createdAt;
    if (createdOn != null) {
      createdAt = DateTime.tryParse(createdOn);
    }

    if (type == 'outgoing') {
      final perMessageIcon = map['icon']?.toString().trim();
      final iconUrl = (perMessageIcon != null && perMessageIcon.isNotEmpty)
          ? perMessageIcon
          : fallbackIconUrl;
      return ChatMessage(
        id: id,
        author: MessageAuthor.bot,
        text: text,
        template: template,
        iconUrl: iconUrl,
        createdAt: createdAt,
        fromHistory: true,
        raw: map,
      );
    }
    return ChatMessage(
      id: id,
      author: MessageAuthor.user,
      text: text,
      createdAt: createdAt,
      fromHistory: true,
      raw: map,
    );
  }

  /// History `tags.altText` display label (prefer `name: label`, else first value).
  String? _historyAltTextLabel(Map<String, dynamic> map) {
    final tags = map['tags'];
    if (tags is! Map) return null;
    final altText = tags['altText'];
    if (altText is! List || altText.isEmpty) return null;

    String? firstValue;
    for (final item in altText) {
      if (item is! Map) continue;
      final value = item['value']?.toString().trim();
      if (value == null || value.isEmpty) continue;
      firstValue ??= value;
      final name = item['name']?.toString().toLowerCase();
      if (name == 'label') return value;
    }
    return firstValue;
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    if (!await _ensureConnectedForSend()) return;

    final id = DateTime.now().millisecondsSinceEpoch;
    _messages.add(ChatMessage.user(id: '$id', text: trimmed));
    _sessionHistoryLimit++;
    _publishMessages();
    _setQuickReplies(const []);
    _typingController.add(true);

    final outbound = _buildOutbound(
      id: id,
      body: trimmed,
      attachments: const [],
    );
    _logOutbound('text', outbound);
    _socket.sendJson(outbound);
  }

  Future<void> sendPayload({
    required String payload,
    String? displayText,
  }) async {
    final body = payload.trim();
    final shown = (displayText ?? payload).trim();
    if (body.isEmpty && shown.isEmpty) return;
    if (!await _ensureConnectedForSend()) return;

    final id = DateTime.now().millisecondsSinceEpoch;
    final outboundBody = body.isNotEmpty ? body : shown;
    if (shown.isNotEmpty) {
      _messages.add(ChatMessage.user(id: '$id', text: shown));
      _sessionHistoryLimit++;
      _publishMessages();
    }
    _setQuickReplies(const []);
    _typingController.add(true);

    final outbound = _buildOutbound(
      id: id,
      body: outboundBody,
      renderMsg: displayText,
      attachments: const [],
    );
    _logOutbound('payload', outbound);
    _socket.sendJson(outbound);
  }

  /// Ensures the RTM socket is usable before an outbound send.
  /// Reopens the socket when the auth session is still valid.
  Future<bool> _ensureConnectedForSend() async {
    if (_disposed) return false;
    if (_session != null && _socket.isConnected) return true;

    final session = _session;
    if (session == null) {
      _emitEvent('Error_Send', 'Bot is not connected');
      return false;
    }

    try {
      _setState(BotConnectionState.reconnecting);
      final rtmUrl = await _rest.startRtm(
        session.accessToken,
        isReconnect: _messages.isNotEmpty ||
            BotChatSessionState.nextOpen == BotChatNextOpen.afterMinimize,
      );
      await _openSocket(rtmUrl);
      _setState(BotConnectionState.connected);
      return _socket.isConnected;
    } catch (error) {
      _setState(BotConnectionState.disconnected);
      _emitEvent('Error_Send', 'Bot is not connected: $error');
      return false;
    }
  }

  Future<void> sendAttachment({
    required String fileName,
    required Uint8List bytes,
    String? localPath,
    String? mimeType,
    String caption = '',
  }) async {
    if (!await _ensureConnectedForSend()) {
      throw StateError('Bot is not connected');
    }
    final userId = _session!.botUserId;
    if (userId == null || userId.isEmpty) {
      throw StateError('Bot user id unavailable for upload');
    }

    final uploaded = await _uploader.upload(
      accessToken: _session!.accessToken,
      botUserId: userId,
      fileName: fileName,
      bytes: bytes,
      localPath: localPath,
      mimeType: mimeType,
    );

    final id = DateTime.now().millisecondsSinceEpoch;
    final body = buildAttachmentMessageBody(
      fileName: uploaded.fileName,
      fileType: uploaded.fileType,
      caption: caption,
    );
    _messages.add(
      ChatMessage.user(
        id: '$id',
        text: body,
        attachment: ChatAttachment(
          fileName: uploaded.fileName,
          fileType: uploaded.fileType,
          localPath: localPath,
          bytes: bytes,
          fileId: uploaded.fileId,
        ),
      ),
    );
    _sessionHistoryLimit++;
    _publishMessages();
    _setQuickReplies(const []);
    _typingController.add(true);

    final outbound = _buildOutbound(
      id: id,
      body: body,
      attachments: [uploaded.toJson()],
    );
    _logOutbound('attachment', outbound);
    _socket.sendJson(outbound);
  }

  Map<String, dynamic> _buildOutbound({
    required int id,
    required String body,
    String? renderMsg,
    required List<Map<String, dynamic>> attachments,
  }) {
    final customData = <String, dynamic>{
      'botToken': _session!.accessToken,
      if (config.customData != null) ...config.customData!,
    };
    return {
      'message': {
        'body': body,
        if (renderMsg != null) 'renderMsg': renderMsg,
        'customData': customData,
        'attachments': attachments,
      },
      'resourceid': '/bot.message',
      'botInfo': {
        'chatBot': config.chatBotName,
        'taskBotId': config.botId,
        'channelClient': 'Flutter',
        if (config.customData != null) 'customData': config.customData,
      },
      'clientMessageId': id,
      'id': id,
      'meta': {
        'timezone': DateTime.now().timeZoneName,
        'locale': 'eng',
      },
      'client': 'Flutter',
    };
  }

  Future<void> handleButton(BotButton button) async {
    final type = button.type.toLowerCase();
    if (type == 'url' || type == 'web_url') {
      return;
    }
    // Button template / postback: send payload (fallback title) as body;
    // show button title in the chat bubble via renderMsg.
    debugPrint(
      '[KoreBot] button tap → title="${button.title}" '
      'type="${button.type}" payload="${button.payload}" '
      'actionValue="${button.actionValue}"',
    );
    await sendPayload(
      payload: button.actionValue,
      displayText: button.title,
    );
  }

  void _logOutbound(String kind, Map<String, dynamic> outbound) {
    final message = outbound['message'];
    final body = message is Map ? message['body'] : null;
    final renderMsg = message is Map ? message['renderMsg'] : null;
    // Redact token before logging the frame.
    final safe = jsonDecode(jsonEncode(outbound)) as Map<String, dynamic>;
    final safeMessage = safe['message'];
    if (safeMessage is Map && safeMessage['customData'] is Map) {
      final custom = Map<String, dynamic>.from(safeMessage['customData'] as Map);
      if (custom.containsKey('botToken')) {
        custom['botToken'] = '***';
      }
      safeMessage['customData'] = custom;
    }
    final summary =
        'kind=$kind body="$body" renderMsg="$renderMsg" frame=${jsonEncode(safe)}';
    debugPrint('[KoreBot] send → $summary');
    _emitEvent('BotOutbound', summary);
  }

  void _logInbound(ChatMessage chatMessage, Map<String, dynamic> frame) {
    final template = chatMessage.template;
    final buttonTitles = template?.buttons.map((b) => b.title).toList() ?? const [];
    final buttonPayloads =
        template?.buttons.map((b) => b.payload ?? b.actionValue).toList() ??
            const [];
    final summary = [
      'id=${chatMessage.id}',
      'streaming=${chatMessage.isStreaming}',
      'text="${chatMessage.text ?? ''}"',
      'templateType="${template?.templateType ?? ''}"',
      'templateText="${template?.text ?? ''}"',
      'buttons=$buttonTitles',
      'payloads=$buttonPayloads',
      'frame=${jsonEncode(frame)}',
    ].join(' ');
    debugPrint('[KoreBot] recv ← $summary');
    _emitEvent('BotInbound', summary);
  }

  Future<void> setTtsEnabled(bool enabled) => tts.setEnabled(enabled);

  /// SPM `sendEventToAgentChat` — outbound WS frame with `event` set.
  void sendAgentEvent(String eventName) {
    if (_disposed || _session == null || !_socket.isConnected) return;
    final id = DateTime.now().millisecondsSinceEpoch;
    final customData = <String, dynamic>{
      'botToken': _session!.accessToken,
      if (config.customData != null) ...config.customData!,
    };
    final payload = <String, dynamic>{
      'message': {
        'body': '',
        'attachments': <dynamic>[],
        'customData': customData,
      },
      'resourceid': '/bot.message',
      'botInfo': {
        'chatBot': config.chatBotName,
        'taskBotId': config.botId,
        'channelClient': 'Flutter',
        if (config.customData != null) 'customData': config.customData,
      },
      'clientMessageId': id,
      'id': id,
      'meta': {
        'timezone': DateTime.now().timeZoneName,
        'locale': 'eng',
      },
      'client': 'Flutter',
      'event': eventName,
    };
    _logOutbound('agentEvent:$eventName', payload);
    _socket.sendJson(payload);
  }

  /// SPM `closeChatWindow` / `minimiseChatWindow`.
  /// Sends agent event, notifies host, waits briefly, then disconnects.
  Future<void> closeByUser({required bool minimized}) async {
    if (_disposed) return;

    if (minimized) {
      // SPM historyLimit: live session only — exclude pull-to-refresh history.
      BotChatSessionState.markMinimized(_sessionHistoryLimit);
      debugPrint(
        '[KoreBot] minimize sessionHistoryLimit=$_sessionHistoryLimit '
        '(onScreen=${_messages.length})',
      );
      _emitEvent('BotMinimized', 'Bot Minimized by the user');
      sendAgentEvent(minimizeButtonEvent);
      _agentConnected = false;
    } else {
      // Close ends the bot session — next open is a fresh conversation.
      BotChatSessionState.markClosed();
      _emitEvent('BotClosed', 'Bot closed by the user');
      sendAgentEvent(
        _agentConnected ? closeAgentChatEvent : closeButtonEvent,
      );
      _clearSessionState();
    }

    await Future<void>.delayed(const Duration(milliseconds: 500));
    await disconnect(emitClosed: false);
    if (!minimized) {
      _session = null;
    }
  }

  /// Drops in-memory chat so Close cannot resume the previous session.
  void _clearSessionState() {
    _agentConnected = false;
    _sessionHistoryLimit = 0;
    _historyLoading = false;
    _hasMoreHistory = true;
    _messages.clear();
    _quickReplies = const [];
    _publishMessages();
    _setQuickReplies(const []);
    _typingController.add(false);
  }

  Future<void> disconnect({bool emitClosed = true}) async {
    await tts.stop();
    await _socket.disconnect();
    if (_state != BotConnectionState.disconnected) {
      _setState(BotConnectionState.disconnected);
    }
    if (emitClosed) {
      _emitEvent('BotClosed', 'Bot closed by the user');
    }
  }

  void _setQuickReplies(List<BotButton> replies) {
    _quickReplies = replies;
    if (!_quickRepliesController.isClosed) {
      _quickRepliesController.add(replies);
    }
  }

  void _publishMessages() {
    if (!_messagesController.isClosed) {
      _messagesController.add(List.unmodifiable(_messages));
    }
  }

  void _setState(BotConnectionState state) {
    _state = state;
    if (!_stateController.isClosed) {
      _stateController.add(state);
    }
  }

  void _setTheme(BotChatTheme theme) {
    _theme = theme;
    if (!_themeController.isClosed) {
      _themeController.add(theme);
    }
  }

  void _emitEvent(String code, String message) {
    onEvent?.call(code, message);
  }

  Future<void> dispose() async {
    _disposed = true;
    await disconnect(emitClosed: false);
    _rest.close();
    await _messagesController.close();
    await _stateController.close();
    await _quickRepliesController.close();
    await _typingController.close();
    await _themeController.close();
  }

  void debugInjectRawMessage(String rawJson) {
    final decoded = jsonDecode(rawJson);
    if (decoded is Map<String, dynamic>) {
      _handleSocketMessage(decoded);
    } else if (decoded is Map) {
      _handleSocketMessage(Map<String, dynamic>.from(decoded));
    }
  }
}
