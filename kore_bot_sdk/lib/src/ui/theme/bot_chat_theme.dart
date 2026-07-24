import 'package:flutter/material.dart';

/// Visual tokens matching classic Android Kore bot chat + branding API.
class BotChatTheme {
  const BotChatTheme({
    this.headerColor = const Color(0xFF3F51B5),
    this.headerTextColor = Colors.white,
    this.backgroundColor = Colors.white,
    this.botBubbleColor = const Color(0xFFEBEBEB),
    this.userBubbleColor = const Color(0xFF0076FF),
    this.botTextColor = const Color(0xFF444444),
    this.userTextColor = Colors.white,
    this.buttonColor = const Color(0xFF0076FF),
    this.buttonTextColor = Colors.white,
    this.buttonBorderColor = const Color(0xFF0076FF),
    this.footerColor = Colors.white,
    this.footerBorderColor = const Color(0xFFE4E5E7),
    this.footerHintColor = const Color(0xFF767688),
    this.sendButtonColor = const Color(0xFF0076FF),
    this.botName,
    this.botIconUrl,
    this.footerHintText,
    this.bubbleStyle = 'rounded',
    this.showAttachment = true,
    this.showMicrophone = true,
    this.showTextToSpeech = false,
    this.showIcon = true,
    this.allowBadCertificates = false,
  });

  final Color headerColor;
  final Color headerTextColor;
  final Color backgroundColor;
  final Color botBubbleColor;
  final Color userBubbleColor;
  final Color botTextColor;
  final Color userTextColor;
  final Color buttonColor;
  final Color buttonTextColor;
  final Color buttonBorderColor;
  final Color footerColor;
  final Color footerBorderColor;
  final Color footerHintColor;
  final Color sendButtonColor;
  final String? botName;
  final String? botIconUrl;
  final String? footerHintText;
  final String bubbleStyle;
  final bool showAttachment;
  final bool showMicrophone;
  final bool showTextToSpeech;
  final bool showIcon;
  final bool allowBadCertificates;

  bool get isSquareBubble => bubbleStyle.toLowerCase() == 'square';

  /// Flutter [ThemeData] derived from branding colors.
  ThemeData toThemeData({Brightness brightness = Brightness.light}) {
    final scheme = ColorScheme.fromSeed(
      seedColor: headerColor,
      brightness: brightness,
      primary: userBubbleColor,
      secondary: buttonColor,
      surface: backgroundColor,
      onPrimary: userTextColor,
      onSecondary: buttonTextColor,
      onSurface: botTextColor,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: headerColor,
        foregroundColor: headerTextColor,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: buttonTextColor,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: buttonColor,
          side: BorderSide(color: buttonBorderColor),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white,
        selectedColor: buttonColor.withValues(alpha: 0.15),
        side: BorderSide(color: buttonBorderColor),
        labelStyle: TextStyle(color: buttonColor),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: footerHintColor),
      ),
    );
  }

  BotChatTheme copyWith({
    Color? headerColor,
    Color? headerTextColor,
    Color? backgroundColor,
    Color? botBubbleColor,
    Color? userBubbleColor,
    Color? botTextColor,
    Color? userTextColor,
    Color? buttonColor,
    Color? buttonTextColor,
    Color? buttonBorderColor,
    Color? footerColor,
    Color? footerBorderColor,
    Color? footerHintColor,
    Color? sendButtonColor,
    String? botName,
    String? botIconUrl,
    String? footerHintText,
    String? bubbleStyle,
    bool? showAttachment,
    bool? showMicrophone,
    bool? showTextToSpeech,
    bool? showIcon,
    bool? allowBadCertificates,
  }) {
    return BotChatTheme(
      headerColor: headerColor ?? this.headerColor,
      headerTextColor: headerTextColor ?? this.headerTextColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      botBubbleColor: botBubbleColor ?? this.botBubbleColor,
      userBubbleColor: userBubbleColor ?? this.userBubbleColor,
      botTextColor: botTextColor ?? this.botTextColor,
      userTextColor: userTextColor ?? this.userTextColor,
      buttonColor: buttonColor ?? this.buttonColor,
      buttonTextColor: buttonTextColor ?? this.buttonTextColor,
      buttonBorderColor: buttonBorderColor ?? this.buttonBorderColor,
      footerColor: footerColor ?? this.footerColor,
      footerBorderColor: footerBorderColor ?? this.footerBorderColor,
      footerHintColor: footerHintColor ?? this.footerHintColor,
      sendButtonColor: sendButtonColor ?? this.sendButtonColor,
      botName: botName ?? this.botName,
      botIconUrl: botIconUrl ?? this.botIconUrl,
      footerHintText: footerHintText ?? this.footerHintText,
      bubbleStyle: bubbleStyle ?? this.bubbleStyle,
      showAttachment: showAttachment ?? this.showAttachment,
      showMicrophone: showMicrophone ?? this.showMicrophone,
      showTextToSpeech: showTextToSpeech ?? this.showTextToSpeech,
      showIcon: showIcon ?? this.showIcon,
      allowBadCertificates:
          allowBadCertificates ?? this.allowBadCertificates,
    );
  }

  /// Parses `#RGB`, `#RRGGBB`, or `#AARRGGBB`.
  /// Bubble/chrome colors default to fully opaque so they never look blurred.
  static Color? tryParseColor(String? value, {bool opaque = true}) {
    if (value == null || value.isEmpty) return null;
    var hex = value.trim();
    if (hex.startsWith('#')) hex = hex.substring(1);
    if (hex.length == 3) {
      hex = hex.split('').map((c) => '$c$c').join();
    }
    if (hex.length == 6) hex = 'FF$hex';
    if (hex.length == 8) {
      final parsed = int.tryParse(hex, radix: 16);
      if (parsed == null) return null;
      final color = Color(parsed);
      return opaque ? color.withValues(alpha: 1.0) : color;
    }
    return null;
  }
}
