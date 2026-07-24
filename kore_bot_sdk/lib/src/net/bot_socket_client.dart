import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'bot_socket_connect_stub.dart'
    if (dart.library.io) 'bot_socket_connect_io.dart' as ws_connect;

typedef BotSocketMessageHandler = void Function(Map<String, dynamic> message);
typedef BotSocketStatusHandler = void Function();

/// Thin WebSocket wrapper around the RTM URL from `/api/rtm/start`.
class BotSocketClient {
  BotSocketClient({this.allowBadCertificates = false});

  final bool allowBadCertificates;

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  BotSocketMessageHandler? onMessage;
  BotSocketStatusHandler? onOpen;
  BotSocketStatusHandler? onClose;
  void Function(Object error)? onError;

  bool get isConnected => _channel != null;

  Future<void> connect(String url) async {
    await disconnect();
    final channel = ws_connect.connectWebSocket(
      url,
      allowBadCertificates: allowBadCertificates,
    );
    _channel = channel;
    onOpen?.call();

    _subscription = channel.stream.listen(
      (event) {
        if (event is! String) return;
        try {
          final decoded = jsonDecode(event);
          if (decoded is Map<String, dynamic>) {
            onMessage?.call(decoded);
          } else if (decoded is Map) {
            onMessage?.call(Map<String, dynamic>.from(decoded));
          }
        } catch (error) {
          onError?.call(error);
        }
      },
      onError: (Object error) {
        debugPrint('[KoreBot] socket error: $error');
        onError?.call(error);
      },
      onDone: () {
        _channel = null;
        onClose?.call();
      },
      cancelOnError: false,
    );
  }

  void sendJson(Map<String, dynamic> payload) {
    final channel = _channel;
    if (channel == null) {
      throw StateError('WebSocket is not connected');
    }
    channel.sink.add(jsonEncode(payload));
  }

  Future<void> disconnect() async {
    await _subscription?.cancel();
    _subscription = null;
    await _channel?.sink.close();
    _channel = null;
  }
}
