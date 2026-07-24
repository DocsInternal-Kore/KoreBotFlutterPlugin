import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/bot_config.dart';
import 'http_client_factory.dart';

class BotAuthSession {
  const BotAuthSession({
    required this.jwt,
    required this.accessToken,
    required this.botUserId,
  });

  final String jwt;
  final String accessToken;
  final String? botUserId;
}

class BotRestClient {
  BotRestClient(this.config, {http.Client? httpClient})
      : _http = httpClient ??
            createBotHttpClient(
              allowBadCertificates: config.allowBadCertificates,
            );

  final BotConfig config;
  final http.Client _http;

  Future<String> fetchStsJwt() async {
    final uri = Uri.parse('${config.normalizedJwtServerUrl}users/sts');
    final response = await _http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'alg': 'RS256',
        'typ': 'JWT',
      },
      body: jsonEncode({
        'clientId': config.clientId,
        'clientSecret': config.clientSecret,
        'identity': config.identity,
        'aud': 'https://idproxy.kore.com/authorize',
        'isAnonymous': false,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw BotRestException(
        'STS call failed (${response.statusCode}): ${response.body}',
        code: 'Error_STS',
      );
    }

    final body = jsonDecode(response.body);
    if (body is! Map || body['jwt'] == null) {
      throw const BotRestException('STS response missing jwt', code: 'Error_STS');
    }
    return body['jwt'] as String;
  }

  Future<BotAuthSession> jwtGrant(String jwt) async {
    final uri = Uri.parse('${config.normalizedServerUrl}/api/oAuth/token/jwtgrant');
    final response = await _http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'assertion': jwt,
        'botInfo': config.botInfo,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw BotRestException(
        'jwtgrant failed (${response.statusCode}): ${response.body}',
        code: 'Error_STS',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final authorization = body['authorization'] as Map<String, dynamic>?;
    final userInfo = body['userInfo'] as Map<String, dynamic>?;
    final accessToken = authorization?['accessToken'] as String?;
    if (accessToken == null || accessToken.isEmpty) {
      throw const BotRestException('jwtgrant missing accessToken', code: 'Error_STS');
    }

    return BotAuthSession(
      jwt: jwt,
      accessToken: accessToken,
      botUserId: userInfo?['userId'] as String?,
    );
  }

  Future<String> startRtm(String accessToken, {bool isReconnect = false}) async {
    // Match SPM: rtm/start itself is a plain POST; reconnect is applied on the
    // returned WebSocket URL as `&isReconnect=true`.
    final uri = Uri.parse('${config.normalizedServerUrl}/api/rtm/start');

    final response = await _http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'bearer $accessToken',
      },
      body: jsonEncode({'botInfo': config.botInfo}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw BotRestException(
        'rtm/start failed (${response.statusCode}): ${response.body}',
        code: 'Error_Socket',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final url = body['url'] as String?;
    if (url == null || url.isEmpty) {
      throw const BotRestException('rtm/start missing url', code: 'Error_Socket');
    }
    var socketUrl = _appendQueryParams(url);
    if (isReconnect) {
      socketUrl = _appendIsReconnect(socketUrl);
    }
    return socketUrl;
  }

  /// SPM `RTMPersistentConnection.start` appends `&isReconnect=true` when reconnecting.
  String _appendIsReconnect(String url) {
    if (url.contains('isReconnect=')) return url;
    final sep = url.contains('?') ? '&' : '?';
    return '$url${sep}isReconnect=true';
  }

  Future<Map<String, dynamic>> fetchHistory({
    required String accessToken,
    int offset = 0,
    int limit = 10,
  }) async {
    // Match SPM HTTPRequestManager.getHistory: direction=0, offset, limit.
    final uri = Uri.parse('${config.normalizedServerUrl}/api/1.1/botmessages/rtm')
        .replace(queryParameters: {
      'botId': config.botId,
      'limit': '$limit',
      'offset': '$offset',
      'direction': '0',
    });

    final response = await _http.get(
      uri,
      headers: {'Authorization': 'bearer $accessToken'},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw BotRestException(
        'history failed (${response.statusCode}): ${response.body}',
        code: 'Error_History',
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  String _appendQueryParams(String url) {
    final params = config.queryParams;
    if (params == null || params.isEmpty) return url;

    final buffer = StringBuffer(url);
    final hasQuery = url.contains('?');
    var first = !hasQuery;
    params.forEach((key, value) {
      buffer.write(first ? '?' : '&');
      first = false;
      buffer.write('${Uri.encodeQueryComponent(key)}='
          '${Uri.encodeQueryComponent(value.toString())}');
    });
    return buffer.toString();
  }

  void close() => _http.close();
}

class BotRestException implements Exception {
  const BotRestException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'BotRestException($code): $message';
}
