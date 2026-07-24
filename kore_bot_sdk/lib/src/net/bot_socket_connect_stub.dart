import 'package:web_socket_channel/web_socket_channel.dart';

WebSocketChannel connectWebSocket(
  String url, {
  bool allowBadCertificates = false,
}) {
  return WebSocketChannel.connect(Uri.parse(url));
}
