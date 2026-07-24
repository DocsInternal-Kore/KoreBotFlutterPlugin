import '../ui/theme/bot_chat_theme.dart';

/// Parsed branding theme from Kore websdkthemes API.
class BrandingTheme {
  const BrandingTheme({
    this.botName,
    this.botIconUrl,
    this.botBubbleColor,
    this.botTextColor,
    this.userBubbleColor,
    this.userTextColor,
    this.buttonColor,
    this.buttonTextColor,
    this.buttonBorderColor,
    this.headerColor,
    this.headerTextColor,
    this.bodyColor,
    this.footerColor,
    this.footerBorderColor,
    this.footerHintColor,
    this.footerHintText,
    this.bubbleStyle,
    this.showAttachment,
    this.showMicrophone,
    this.showTextToSpeech,
  });

  final String? botName;
  final String? botIconUrl;
  final String? botBubbleColor;
  final String? botTextColor;
  final String? userBubbleColor;
  final String? userTextColor;
  final String? buttonColor;
  final String? buttonTextColor;
  final String? buttonBorderColor;
  final String? headerColor;
  final String? headerTextColor;
  final String? bodyColor;
  final String? footerColor;
  final String? footerBorderColor;
  final String? footerHintColor;
  final String? footerHintText;
  final String? bubbleStyle;
  final bool? showAttachment;
  final bool? showMicrophone;
  final bool? showTextToSpeech;

  BotChatTheme applyTo(BotChatTheme base) {
    return base.copyWith(
      botName: botName,
      botIconUrl: botIconUrl,
      botBubbleColor: BotChatTheme.tryParseColor(botBubbleColor),
      botTextColor: BotChatTheme.tryParseColor(botTextColor),
      userBubbleColor: BotChatTheme.tryParseColor(userBubbleColor),
      userTextColor: BotChatTheme.tryParseColor(userTextColor),
      buttonColor: BotChatTheme.tryParseColor(buttonColor),
      buttonTextColor: BotChatTheme.tryParseColor(buttonTextColor),
      buttonBorderColor: BotChatTheme.tryParseColor(buttonBorderColor),
      headerColor: BotChatTheme.tryParseColor(headerColor),
      headerTextColor: BotChatTheme.tryParseColor(headerTextColor),
      backgroundColor: BotChatTheme.tryParseColor(bodyColor),
      footerColor: BotChatTheme.tryParseColor(footerColor),
      footerBorderColor: BotChatTheme.tryParseColor(footerBorderColor),
      footerHintColor: BotChatTheme.tryParseColor(footerHintColor),
      sendButtonColor: BotChatTheme.tryParseColor(userBubbleColor) ??
          BotChatTheme.tryParseColor(buttonColor),
      footerHintText: footerHintText,
      bubbleStyle: bubbleStyle,
      showAttachment: showAttachment,
      showMicrophone: showMicrophone,
      showTextToSpeech: showTextToSpeech,
    );
  }

  /// Parses legacy flat theme OR v3 branding JSON.
  factory BrandingTheme.fromJson(Map<String, dynamic> json) {
    if (json['v3'] is Map) {
      return BrandingTheme._fromV3(Map<String, dynamic>.from(json['v3'] as Map));
    }
    if (json['botMessage'] is Map || json['widgetHeader'] is Map) {
      return BrandingTheme._fromLegacy(json);
    }
    // Sometimes the API wraps as { "v3": {...} } already handled;
    // also accept direct v3-shaped root.
    if (json['body'] is Map && json['header'] is Map) {
      return BrandingTheme._fromV3(json);
    }
    return const BrandingTheme();
  }

  factory BrandingTheme._fromLegacy(Map<String, dynamic> json) {
    Map<String, dynamic>? asMap(dynamic v) =>
        v is Map ? Map<String, dynamic>.from(v) : null;

    final botMessage = asMap(json['botMessage']);
    final userMessage = asMap(json['userMessage']);
    final buttons = asMap(json['buttons']);
    final widgetBody = asMap(json['widgetBody']);
    final widgetHeader = asMap(json['widgetHeader']);
    final widgetFooter = asMap(json['widgetFooter']);
    final general = asMap(json['generalAttributes']);

    return BrandingTheme(
      botBubbleColor: botMessage?['bubbleColor']?.toString(),
      botTextColor: botMessage?['fontColor']?.toString(),
      userBubbleColor: userMessage?['bubbleColor']?.toString(),
      userTextColor: userMessage?['fontColor']?.toString(),
      buttonColor: buttons?['defaultButtonColor']?.toString(),
      buttonTextColor: buttons?['defaultFontColor']?.toString(),
      buttonBorderColor: buttons?['borderColor']?.toString(),
      bodyColor: widgetBody?['backgroundColor']?.toString(),
      headerColor: widgetHeader?['backgroundColor']?.toString(),
      headerTextColor: widgetHeader?['fontColor']?.toString(),
      footerColor: widgetFooter?['backgroundColor']?.toString(),
      footerBorderColor: widgetFooter?['borderColor']?.toString(),
      footerHintColor: widgetFooter?['placeHolderColor']?.toString() ??
          widgetFooter?['placeHolder']?.toString(),
      bubbleStyle: general?['bubbleShape']?.toString(),
    );
  }

  factory BrandingTheme._fromV3(Map<String, dynamic> v3) {
    Map<String, dynamic>? asMap(dynamic v) =>
        v is Map ? Map<String, dynamic>.from(v) : null;

    final body = asMap(v3['body']);
    final header = asMap(v3['header']);
    final footer = asMap(v3['footer']);
    final chatBubble = asMap(v3['chat_bubble']);
    final general = asMap(v3['general']);

    final botMessage = asMap(body?['bot_message']);
    final userMessage = asMap(body?['user_message']);
    final background = asMap(body?['background']);
    final title = asMap(header?['title']);
    final icon = asMap(header?['icon']);
    final logo = asMap(header?['logo']);
    final composeBar = asMap(footer?['compose_bar']);
    final footerButtons = asMap(footer?['buttons']);
    final mic = asMap(footerButtons?['microphone']);
    final attachment = asMap(footerButtons?['attachment']);
    final speaker = asMap(footerButtons?['speaker']);
    final colors = asMap(general?['colors']);

    var theme = BrandingTheme(
      botName: title?['name']?.toString(),
      botIconUrl: icon?['icon_url']?.toString() ??
          icon?['url']?.toString() ??
          logo?['icon_url']?.toString() ??
          logo?['url']?.toString() ??
          header?['icon_url']?.toString(),
      botBubbleColor: botMessage?['bg_color']?.toString(),
      botTextColor: botMessage?['color']?.toString(),
      userBubbleColor: userMessage?['bg_color']?.toString(),
      userTextColor: userMessage?['color']?.toString(),
      buttonColor: userMessage?['bg_color']?.toString(),
      buttonTextColor: userMessage?['color']?.toString(),
      bodyColor: background?['color']?.toString(),
      headerColor: header?['bg_color']?.toString(),
      headerTextColor: title?['color']?.toString(),
      footerColor: footer?['bg_color']?.toString(),
      footerBorderColor: composeBar?['outline_color']?.toString(),
      footerHintColor: composeBar?['outline_color']?.toString(),
      footerHintText: composeBar?['placeholder']?.toString(),
      bubbleStyle: chatBubble?['style']?.toString(),
      showMicrophone: mic?['show'] as bool?,
      showAttachment: attachment?['show'] as bool?,
      showTextToSpeech: speaker?['show'] as bool?,
    );

    if (colors != null && colors['useColorPaletteOnly'] == true) {
      theme = BrandingTheme(
        botName: theme.botName,
        botIconUrl: theme.botIconUrl,
        botBubbleColor: colors['secondary']?.toString(),
        botTextColor: colors['primary_text']?.toString(),
        userBubbleColor: colors['primary']?.toString(),
        userTextColor: colors['secondary_text']?.toString(),
        buttonColor: colors['primary']?.toString(),
        buttonTextColor: colors['secondary_text']?.toString(),
        headerColor: colors['secondary']?.toString(),
        headerTextColor: colors['primary_text']?.toString(),
        footerColor: colors['secondary']?.toString(),
        bodyColor: theme.bodyColor,
        footerBorderColor: theme.footerBorderColor,
        footerHintColor: theme.footerHintColor,
        footerHintText: theme.footerHintText,
        bubbleStyle: theme.bubbleStyle,
        showMicrophone: theme.showMicrophone,
        showAttachment: theme.showAttachment,
        showTextToSpeech: theme.showTextToSpeech,
      );
    }

    return theme;
  }
}
