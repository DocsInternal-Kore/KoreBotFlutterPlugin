import 'package:http/http.dart' as http;

http.Client createBotHttpClient({bool allowBadCertificates = false}) {
  return http.Client();
}
