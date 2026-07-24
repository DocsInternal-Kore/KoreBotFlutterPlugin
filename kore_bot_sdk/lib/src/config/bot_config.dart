/// Bot configuration — mirrors Flutter Public New MethodChannel keys.
class BotConfig {
  const BotConfig({
    required this.clientId,
    required this.clientSecret,
    required this.botId,
    required this.chatBotName,
    required this.identity,
    required this.jwtServerUrl,
    required this.serverUrl,
    this.jwtToken,
    this.callHistory = false,
    this.customData,
    this.queryParams,
    this.showHeader = true,
    this.showAttachment = true,
    this.showMicrophone = true,
    this.showTextToSpeech = false,
    this.showIcon = true,
    this.footerHintText = 'Type your message...',
    this.botIconUrl,
    this.brandingUrl,
    this.isWebHook = false,
    this.allowBadCertificates = false,
  });

  /// Builds from the same map shape used by the legacy native plugin.
  factory BotConfig.fromMap(Map<String, dynamic> map) {
    return BotConfig(
      clientId: map['clientId'] as String? ?? '',
      clientSecret: map['clientSecret'] as String? ?? '',
      botId: map['botId'] as String? ?? '',
      chatBotName: map['chatBotName'] as String? ?? 'Bot',
      identity: map['identity'] as String? ?? '',
      jwtServerUrl: map['jwt_server_url'] as String? ?? '',
      serverUrl: map['server_url'] as String? ?? '',
      jwtToken: map['jwtToken'] as String? ?? map['customJWToken'] as String?,
      callHistory: map['callHistory'] as bool? ?? false,
      customData: _asStringKeyedMap(map['customData']),
      queryParams: _asStringKeyedMap(map['queryParams']),
      showHeader: map['showHeader'] as bool? ?? true,
      showAttachment: map['showAttachment'] as bool? ?? true,
      showMicrophone:
          map['showMicrophone'] as bool? ?? map['showASRMicroPhone'] as bool? ?? true,
      showTextToSpeech: map['showTextToSpeech'] as bool? ?? false,
      showIcon: map['showIcon'] as bool? ?? true,
      footerHintText: map['footerHintText'] as String? ?? 'Type your message...',
      botIconUrl: map['botIconUrl'] as String?,
      brandingUrl: map['branding_url'] as String? ?? map['brandingUrl'] as String?,
      isWebHook: map['isWebHook'] as bool? ?? map['is_webhook'] as bool? ?? false,
      allowBadCertificates: map['allowBadCertificates'] as bool? ??
          map['bypassSsl'] as bool? ??
          false,
    );
  }

  final String clientId;
  final String clientSecret;
  final String botId;
  final String chatBotName;
  final String identity;
  final String jwtServerUrl;
  final String serverUrl;
  final String? jwtToken;
  final bool callHistory;
  final Map<String, dynamic>? customData;
  final Map<String, dynamic>? queryParams;
  final bool showHeader;
  final bool showAttachment;
  final bool showMicrophone;
  final bool showTextToSpeech;
  final bool showIcon;
  final String footerHintText;
  final String? botIconUrl;
  final String? brandingUrl;
  final bool isWebHook;
  /// Dev-only: accept invalid/self-signed TLS certs (simulator / proxy).
  final bool allowBadCertificates;

  String get normalizedServerUrl => stripTrailingSlash(serverUrl);

  String get normalizedJwtServerUrl {
    final url = jwtServerUrl.trim();
    return url.endsWith('/') ? url : '$url/';
  }

  Map<String, dynamic> get botInfo => {
        'chatBot': chatBotName,
        'taskBotId': botId,
        'channelClient': 'Flutter',
        if (customData != null) 'customData': customData,
      };

  static String stripTrailingSlash(String url) {
    if (url.endsWith('/')) return url.substring(0, url.length - 1);
    return url;
  }

  static Map<String, dynamic>? _asStringKeyedMap(dynamic value) {
    if (value is Map) {
      return value.map((k, v) => MapEntry(k.toString(), v));
    }
    return null;
  }
}
