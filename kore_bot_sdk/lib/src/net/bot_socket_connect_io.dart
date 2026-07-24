import 'dart:io';

import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

WebSocketChannel connectWebSocket(
  String url, {
  bool allowBadCertificates = false,
}) {
  if (!allowBadCertificates) {
    return WebSocketChannel.connect(Uri.parse(url));
  }
  final client = HttpClient()
    ..badCertificateCallback = (cert, host, port) => true;
  return IOWebSocketChannel.connect(Uri.parse(url), customClient: client);
}
