import 'package:flutter/material.dart';

/// WhatsApp-style slim banner shown when the device has no network.
///
/// Placed directly below the chat header (Artemis-style).
class NoInternetBanner extends StatelessWidget {
  const NoInternetBanner({
    super.key,
    required this.visible,
    this.message = 'No internet connection',
  });

  final bool visible;
  final String message;

  static const _bannerColor = Color(0xFF323739);
  static const _textColor = Color(0xFFE9EDEF);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        heightFactor: visible ? 1 : 0,
        alignment: Alignment.topCenter,
        child: Material(
          color: _bannerColor,
          elevation: 0,
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                  letterSpacing: 0.1,
                  fontFamily:
                      Theme.of(context).textTheme.bodyMedium?.fontFamily,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
