import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/bot_config.dart';
import '../models/branding_theme.dart';
import 'http_client_factory.dart';

class BrandingService {
  BrandingService(this.config, {http.Client? httpClient})
      : _http = httpClient ??
            createBotHttpClient(
              allowBadCertificates: config.allowBadCertificates,
            );

  final BotConfig config;
  final http.Client _http;

  String get _base =>
      (config.brandingUrl != null && config.brandingUrl!.isNotEmpty)
          ? BotConfig.stripTrailingSlash(config.brandingUrl!)
          : config.normalizedServerUrl;

  Future<BrandingTheme?> fetch(String accessToken) async {
    final uri = Uri.parse('$_base/api/websdkthemes/${config.botId}/activetheme');
    try {
      final response = await _http.get(
        uri,
        headers: {
          'Authorization': 'bearer $accessToken',
          'state': 'published',
          'Accepts-version': '1',
          'Accept-Language': 'en_US',
          'botid': config.botId,
          'Accept': 'application/json',
        },
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return BrandingTheme.fromJson(decoded);
      }
      if (decoded is Map) {
        return BrandingTheme.fromJson(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {
      return null;
    }
    return null;
  }
}
