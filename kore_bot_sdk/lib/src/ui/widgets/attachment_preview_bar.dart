import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../theme/bot_chat_theme.dart';

/// Pending local file shown above the compose bar (SPM attachment strip).
class PendingAttachment {
  const PendingAttachment({
    required this.fileName,
    required this.bytes,
    this.localPath,
    this.mimeType,
  });

  final String fileName;
  final Uint8List bytes;
  final String? localPath;
  final String? mimeType;

  bool get isImage {
    final m = (mimeType ?? '').toLowerCase();
    if (m.startsWith('image/')) return true;
    final lower = fileName.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.bmp');
  }
}

class AttachmentPreviewBar extends StatelessWidget {
  const AttachmentPreviewBar({
    super.key,
    required this.attachment,
    required this.theme,
    required this.onClear,
  });

  final PendingAttachment attachment;
  final BotChatTheme theme;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      decoration: BoxDecoration(
        color: theme.footerColor,
        border: Border(top: BorderSide(color: theme.footerBorderColor)),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F3F5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.footerBorderColor),
              ),
              clipBehavior: Clip.antiAlias,
              child: attachment.isImage
                  ? _imagePreview(attachment)
                  : _filePreview(attachment),
            ),
            Positioned(
              top: -6,
              right: -6,
              child: Material(
                color: Colors.black87,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onClear,
                  child: const SizedBox(
                    width: 22,
                    height: 22,
                    child: Icon(Icons.close, size: 14, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePreview(PendingAttachment attachment) {
    if (attachment.localPath != null &&
        File(attachment.localPath!).existsSync()) {
      return Image.file(
        File(attachment.localPath!),
        fit: BoxFit.cover,
        width: 74,
        height: 74,
      );
    }
    return Image.memory(
      attachment.bytes,
      fit: BoxFit.cover,
      width: 74,
      height: 74,
    );
  }

  Widget _filePreview(PendingAttachment attachment) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.insert_drive_file, color: theme.sendButtonColor, size: 28),
          const SizedBox(height: 4),
          Text(
            attachment.fileName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, height: 1.1),
          ),
        ],
      ),
    );
  }
}
