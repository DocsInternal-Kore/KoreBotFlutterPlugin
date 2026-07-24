import 'package:flutter/material.dart';

/// Host-provided font configuration for the chat UI.
///
/// Register custom fonts in the host app's `pubspec.yaml`, then pass the
/// family name here so the SDK applies it across messages, headers, and input.
///
/// ```yaml
/// # host app pubspec.yaml
/// flutter:
///   fonts:
///     - family: BrandSans
///       fonts:
///         - asset: assets/fonts/BrandSans-Regular.ttf
///         - asset: assets/fonts/BrandSans-Bold.ttf
///           weight: 700
/// ```
///
/// ```dart
/// KoreBotChat.open(
///   context,
///   botConfig: botConfig,
///   fonts: const BotChatFonts(family: 'BrandSans'),
/// );
/// ```
class BotChatFonts {
  const BotChatFonts({
    this.family,
    this.monospaceFamily,
    this.textTheme,
  });

  /// Primary UI font family (must match a family registered by the host app).
  final String? family;

  /// Optional monospace family for markdown/code blocks.
  final String? monospaceFamily;

  /// Optional text theme merged on top of SDK defaults.
  final TextTheme? textTheme;

  bool get isEmpty =>
      (family == null || family!.trim().isEmpty) &&
      (monospaceFamily == null || monospaceFamily!.trim().isEmpty) &&
      textTheme == null;

  BotChatFonts merge(BotChatFonts? overrides) {
    if (overrides == null || overrides.isEmpty) return this;
    return BotChatFonts(
      family: overrides.family ?? family,
      monospaceFamily: overrides.monospaceFamily ?? monospaceFamily,
      textTheme: overrides.textTheme ?? textTheme,
    );
  }

  /// Resolves SDK/theme font config to a Flutter font family.
  ///
  /// `System` and empty values use the platform UI font (`null` family).
  static String? resolveFontFamily(String? configured) {
    final normalized = configured?.trim();
    if (normalized == null || normalized.isEmpty) return null;
    if (normalized.toLowerCase() == 'system') return null;
    return normalized;
  }
}

/// Carries monospace family through [ThemeData.extensions].
@immutable
class BotChatFontsExtension extends ThemeExtension<BotChatFontsExtension> {
  const BotChatFontsExtension({this.monospaceFamily});

  final String? monospaceFamily;

  static String monospaceOf(BuildContext context) {
    final fromExt =
        Theme.of(context).extension<BotChatFontsExtension>()?.monospaceFamily;
    final resolved = BotChatFonts.resolveFontFamily(fromExt);
    if (resolved != null) return resolved;
    return 'monospace';
  }

  @override
  BotChatFontsExtension copyWith({String? monospaceFamily}) {
    return BotChatFontsExtension(
      monospaceFamily: monospaceFamily ?? this.monospaceFamily,
    );
  }

  @override
  BotChatFontsExtension lerp(
    ThemeExtension<BotChatFontsExtension>? other,
    double t,
  ) {
    if (other is! BotChatFontsExtension) return this;
    return t < 0.5 ? this : other;
  }
}
