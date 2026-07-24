import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../config/bot_config.dart';
import '../controller/bot_chat_controller.dart';
import '../models/chat_message.dart';
import '../models/template_payload.dart';
import '../net/bot_connection_state.dart';
import '../services/speech_services.dart';
import '../session/bot_chat_session_state.dart';
import 'templates/message_bubble.dart';
import 'templates/bot_template_registry.dart';
import 'theme/bot_chat_fonts.dart';
import 'theme/bot_chat_theme.dart';
import 'chat_footer_builder.dart';
import 'chat_header_builder.dart';
import 'widgets/attachment_preview_bar.dart';
import 'widgets/close_or_minimize_dialog.dart';
import 'widgets/typing_indicator.dart';

class BotChatScreen extends StatefulWidget {
  const BotChatScreen({
    super.key,
    required this.config,
    this.theme = const BotChatTheme(),
    this.onEvent,
    this.controller,
    this.headerBuilder,
    this.footerBuilder,
    this.templateRegistry,
    this.fonts,
  });

  final BotConfig config;
  final BotChatTheme theme;
  final BotEventCallback? onEvent;
  final BotChatController? controller;
  final BotChatHeaderBuilder? headerBuilder;
  final BotChatFooterBuilder? footerBuilder;
  final BotTemplateRegistry? templateRegistry;
  final BotChatFonts? fonts;

  @override
  State<BotChatScreen> createState() => _BotChatScreenState();
}

class _BotChatScreenState extends State<BotChatScreen> {
  late final BotChatController _controller;
  late final bool _ownsController;
  final _scrollController = ScrollController();
  final _inputController = TextEditingController();
  final _subscriptions = <StreamSubscription>[];
  final _stt = SpeechToTextService();
  final _imagePicker = ImagePicker();

  List<ChatMessage> _messages = const [];
  List<BotButton> _quickReplies = const [];
  BotConnectionState _state = BotConnectionState.idle;
  late BotChatTheme _theme;
  bool _typing = false;
  bool _listening = false;
  bool _ttsEnabled = false;
  bool _uploading = false;
  bool _isClosing = false;
  bool _allowPop = false;
  PendingAttachment? _pendingAttachment;
  int _sttSession = 0;
  String? _error;
  String? _lastTailMessageId;

  @override
  void initState() {
    super.initState();
    _theme = widget.theme.applyFonts(widget.fonts).copyWith(
      botName: widget.config.chatBotName,
      botIconUrl: widget.config.botIconUrl,
      footerHintText: widget.config.footerHintText,
      showAttachment: widget.config.showAttachment,
      showMicrophone: widget.config.showMicrophone,
      showTextToSpeech: widget.config.showTextToSpeech,
      showIcon: widget.config.showIcon,
      allowBadCertificates: widget.config.allowBadCertificates,
    );

    _ownsController = widget.controller == null;
    _controller = widget.controller ??
        BotChatController(
          config: widget.config,
          onEvent: widget.onEvent,
          initialTheme: _theme,
        );

    _messages = _controller.messages;
    _state = _controller.state;
    _theme = _controller.theme;

    _subscriptions.addAll([
      _controller.messagesStream.listen((messages) {
        if (!mounted) return;
        final newTail = messages.isEmpty ? null : messages.last.id;
        // Only auto-scroll when a newer message is appended (not history prepend).
        final shouldScrollToBottom =
            newTail != null && newTail != _lastTailMessageId;
        _lastTailMessageId = newTail;
        setState(() => _messages = messages);
        if (shouldScrollToBottom) _scrollToBottom();
      }),
      _controller.stateStream.listen((state) {
        if (!mounted) return;
        setState(() => _state = state);
      }),
      _controller.quickRepliesStream.listen((replies) {
        if (!mounted) return;
        setState(() => _quickReplies = replies);
      }),
      _controller.typingStream.listen((typing) {
        if (!mounted) return;
        setState(() => _typing = typing);
        _scrollToBottom();
      }),
      _controller.themeStream.listen((theme) {
        if (!mounted) return;
        setState(() => _theme = theme);
      }),
    ]);

    _connect();
  }

  Future<void> _connect() async {
    try {
      await _controller.connect();
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  /// SPM-style pull-to-refresh → history API with
  /// `offset` = currently displayed message count.
  Future<void> _onPullToRefreshHistory() async {
    if (!_state.isConnected || _controller.isHistoryLoading) return;
    if (!_controller.hasMoreHistory) return;

    final beforeMax = _scrollController.hasClients
        ? _scrollController.position.maxScrollExtent
        : 0.0;
    final beforePixels =
        _scrollController.hasClients ? _scrollController.position.pixels : 0.0;

    final added = await _controller.loadMoreHistory();
    if (!mounted || added <= 0) return;

    await Future<void>.delayed(Duration.zero);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final afterMax = _scrollController.position.maxScrollExtent;
      final delta = afterMax - beforeMax;
      if (delta > 0) {
        _scrollController.jumpTo(beforePixels + delta);
      }
    });
  }

  Future<void> _stopSpeechRecognition({bool clearField = false}) async {
    _sttSession++;
    if (_listening || _stt.isListening) {
      await _stt.cancel();
    }
    if (!mounted) return;
    setState(() => _listening = false);
    if (clearField) {
      _inputController.clear();
    }
  }

  Future<void> _send() async {
    final text = _inputController.text.trim();
    final pending = _pendingAttachment;

    // Stop ASR first so late partial/final results cannot restore text.
    await _stopSpeechRecognition(clearField: true);

    // SPM: if an attachment is staged, upload+send on Send (caption optional).
    if (pending != null) {
      setState(() {
        _pendingAttachment = null;
        _uploading = true;
      });
      try {
        await _controller.sendAttachment(
          fileName: pending.fileName,
          bytes: pending.bytes,
          localPath: pending.localPath,
          mimeType: pending.mimeType,
          caption: text,
        );
      } catch (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Attachment failed: $error')),
        );
      } finally {
        if (mounted) setState(() => _uploading = false);
      }
      return;
    }

    if (text.isEmpty) return;

    try {
      await _controller.sendMessage(text);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to send: $error')),
      );
    }
  }

  Future<void> _toggleMic() async {
    if (_listening) {
      await _stopSpeechRecognition();
      return;
    }
    try {
      final session = ++_sttSession;
      setState(() => _listening = true);
      await _stt.start(
        onPartial: (text) {
          if (!mounted || session != _sttSession) return;
          _inputController.value = TextEditingValue(
            text: text,
            selection: TextSelection.collapsed(offset: text.length),
          );
        },
        onFinal: (text) async {
          if (!mounted || session != _sttSession) return;
          // End this listen session and clear field before sending.
          await _stopSpeechRecognition(clearField: true);
          if (text.trim().isNotEmpty) {
            await _controller.sendMessage(text);
          }
        },
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _listening = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Microphone error: $error')),
      );
    }
  }

  Future<void> _toggleTts() async {
    final next = !_ttsEnabled;
    await _controller.setTtsEnabled(next);
    setState(() => _ttsEnabled = next);
  }

  Future<void> _pickAttachment() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, 'gallery'),
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file),
              title: const Text('Document'),
              onTap: () => Navigator.pop(context, 'file'),
            ),
          ],
        ),
      ),
    );
    if (choice == null || !mounted) return;

    try {
      // SPM: stage locally for preview; upload happens on Send.
      if (choice == 'camera' || choice == 'gallery') {
        final source =
            choice == 'camera' ? ImageSource.camera : ImageSource.gallery;
        final file =
            await _imagePicker.pickImage(source: source, imageQuality: 85);
        if (file == null || !mounted) return;
        final bytes = await file.readAsBytes();
        setState(() {
          _pendingAttachment = PendingAttachment(
            fileName: file.name,
            bytes: bytes,
            localPath: file.path,
            mimeType: file.mimeType,
          );
        });
      } else {
        final result = await FilePicker.platform.pickFiles(
          withData: true,
          type: FileType.custom,
          allowedExtensions: const [
            'pdf',
            'doc',
            'docx',
            'xls',
            'xlsx',
            'ppt',
            'pptx',
            'txt',
            'rtf',
            'mp3',
            'wav',
            'mp4',
            'mov',
            'png',
            'jpg',
            'jpeg',
          ],
        );
        if (result == null || result.files.isEmpty || !mounted) return;
        final f = result.files.first;
        final bytes = f.bytes ??
            (f.path != null ? await File(f.path!).readAsBytes() : null);
        if (bytes == null) {
          throw Exception('Unable to read selected file');
        }
        setState(() {
          _pendingAttachment = PendingAttachment(
            fileName: f.name,
            bytes: bytes,
            localPath: f.path,
          );
        });
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Attachment failed: $error')),
      );
    }
  }

  Future<void> _onClosePressed() async {
    // Prevent PopScope re-entry after Close/Minimize disconnects the socket.
    if (_isClosing || _allowPop) return;
    _isClosing = true;

    try {
      await _stopSpeechRecognition();
      if (!mounted) return;

      // SPM: only skip the dialog when the connection-error mask is shown.
      if (_error != null || _state == BotConnectionState.error) {
        // Still end session restore so reopen does not continue a prior chat.
        BotChatSessionState.markClosed();
        widget.onEvent?.call('BotClosed', 'Bot connection error');
        await _controller.disconnect(emitClosed: false);
        await _popChat();
        return;
      }

      final action = await CloseOrMinimizeDialog.show(context);
      if (!mounted ||
          action == null ||
          action == CloseOrMinimizeAction.cancel) {
        return;
      }

      await _controller.closeByUser(
        minimized: action == CloseOrMinimizeAction.minimize,
      );
      await _popChat();
    } finally {
      if (mounted && !_allowPop) {
        _isClosing = false;
      }
    }
  }

  Future<void> _popChat() async {
    if (!mounted) return;
    setState(() => _allowPop = true);
    // Allow PopScope to rebuild with canPop:true before popping.
    await Future<void>.delayed(Duration.zero);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _stt.cancel();
    _scrollController.dispose();
    _inputController.dispose();
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = _theme;
    final config = widget.config;
    final title = theme.botName ?? config.chatBotName;
    final hint = theme.footerHintText ?? config.footerHintText;

    return Theme(
      data: theme.toThemeData(),
      child: PopScope(
        canPop: _allowPop,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop || _allowPop || _isClosing) return;
          await _onClosePressed();
        },
        child: Scaffold(
          backgroundColor: theme.backgroundColor,
          body: Column(
            children: [
              if (widget.headerBuilder != null || config.showHeader)
                _buildHeader(title, theme),
              if (_state == BotConnectionState.connecting || _uploading)
                LinearProgressIndicator(
                  minHeight: 2,
                  color: theme.headerColor,
                  backgroundColor: theme.headerColor.withValues(alpha: 0.15),
                ),
              if (_error != null)
                MaterialBanner(
                  content: Text(_error!),
                  actions: [
                    TextButton(
                      onPressed: () {
                        setState(() => _error = null);
                        _connect();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              Expanded(
                child: RefreshIndicator(
                  color: theme.headerColor,
                  onRefresh: _onPullToRefreshHistory,
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    addAutomaticKeepAlives: true,
                    itemCount: _messages.length + (_typing ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_typing && index == _messages.length) {
                        return TypingIndicator(
                          key: const ValueKey('typing'),
                          color: theme.botBubbleColor,
                        );
                      }
                      final message = _messages[index];
                      return MessageBubble(
                        key: ValueKey(message.id),
                        message: message,
                        theme: theme,
                        controller: _controller,
                        templateRegistry: widget.templateRegistry,
                      );
                    },
                  ),
                ),
              ),
              QuickReplyBar(
                replies: _quickReplies,
                theme: theme,
                onSelected: _controller.handleButton,
              ),
              if (_pendingAttachment != null)
                AttachmentPreviewBar(
                  attachment: _pendingAttachment!,
                  theme: theme,
                  onClear: () => setState(() => _pendingAttachment = null),
                ),
              _buildFooter(hint, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String title, BotChatTheme theme) {
    final headerContext = BotChatHeaderContext(
      title: title,
      theme: theme,
      botIconUrl: theme.botIconUrl ?? widget.config.botIconUrl,
      onClose: _onClosePressed,
    );
    final builder = widget.headerBuilder ?? buildDefaultChatHeader;
    return builder(context, headerContext);
  }

  Widget _buildFooter(String hint, BotChatTheme theme) {
    final footerContext = BotChatFooterContext(
      controller: _inputController,
      enabled: _state.isConnected && !_uploading,
      hintText: hint,
      theme: theme,
      showAttachment: theme.showAttachment,
      showMicrophone: theme.showMicrophone,
      showTextToSpeech: theme.showTextToSpeech,
      isListening: _listening,
      ttsEnabled: _ttsEnabled,
      hasPendingAttachment: _pendingAttachment != null,
      onSend: _send,
      onAttachment: _pickAttachment,
      onMic: _toggleMic,
      onToggleTts: _toggleTts,
    );
    final builder = widget.footerBuilder ?? buildDefaultChatFooter;
    return builder(context, footerContext);
  }
}
