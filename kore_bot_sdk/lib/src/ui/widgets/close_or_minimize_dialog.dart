import 'package:flutter/material.dart';

/// SPM-style Close / Minimize / Cancel confirmation (ChatMessagesViewController).
enum CloseOrMinimizeAction { cancel, close, minimize }

class CloseOrMinimizeDialog extends StatelessWidget {
  const CloseOrMinimizeDialog({
    super.key,
    this.message =
        'Would you like to close the conversation or minimize.',
    this.cancelLabel = 'Cancel',
    this.closeLabel = 'Close',
    this.minimizeLabel = 'Minimize',
  });

  final String message;
  final String cancelLabel;
  final String closeLabel;
  final String minimizeLabel;

  static Future<CloseOrMinimizeAction?> show(
    BuildContext context, {
    String message =
        'Would you like to close the conversation or minimize.',
    String cancelLabel = 'Cancel',
    String closeLabel = 'Close',
    String minimizeLabel = 'Minimize',
  }) {
    return showDialog<CloseOrMinimizeAction>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => CloseOrMinimizeDialog(
        message: message,
        cancelLabel: cancelLabel,
        closeLabel: closeLabel,
        minimizeLabel: minimizeLabel,
      ),
    );
  }

  static const Color _accent = Color(0xFF5B8DEF); // SPM lightRoyalBlue-ish
  static const Color _sep = Color(0xFFE0E0E0);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 8,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF333333),
                  height: 1.35,
                ),
              ),
            ),
            const Divider(height: 0.5, thickness: 0.5, color: _sep),
            SizedBox(
              height: 48,
              child: Row(
                children: [
                  _ActionButton(
                    label: cancelLabel,
                    onTap: () => Navigator.pop(
                      context,
                      CloseOrMinimizeAction.cancel,
                    ),
                  ),
                  const VerticalDivider(width: 0.5, thickness: 0.5, color: _sep),
                  _ActionButton(
                    label: closeLabel,
                    onTap: () => Navigator.pop(
                      context,
                      CloseOrMinimizeAction.close,
                    ),
                  ),
                  const VerticalDivider(width: 0.5, thickness: 0.5, color: _sep),
                  _ActionButton(
                    label: minimizeLabel,
                    onTap: () => Navigator.pop(
                      context,
                      CloseOrMinimizeAction.minimize,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: CloseOrMinimizeDialog._accent,
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          shape: const RoundedRectangleBorder(),
        ),
        child: Text(label),
      ),
    );
  }
}
