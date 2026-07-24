import 'package:http/http.dart' as http;

import 'http_client_factory_stub.dart'
    if (dart.library.io) 'http_client_factory_io.dart' as impl;

/// Shared HTTP client for STS / jwtgrant / history / upload / branding.
http.Client createBotHttpClient({bool allowBadCertificates = false}) {
  return impl.createBotHttpClient(allowBadCertificates: allowBadCertificates);
}
