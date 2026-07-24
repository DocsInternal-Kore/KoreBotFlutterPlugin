import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

http.Client createBotHttpClient({bool allowBadCertificates = false}) {
  final client = HttpClient();
  if (allowBadCertificates) {
    client.badCertificateCallback = (cert, host, port) => true;
  }
  return IOClient(client);
}
