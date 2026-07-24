import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../net/http_client_factory.dart';

/// Circular bot avatar. Loads [iconUrl] via the SDK HTTP client so
/// `allowBadCertificates` applies (Flutter [Image.network] ignores that flag).
class BotAvatar extends StatefulWidget {
  const BotAvatar({
    super.key,
    this.iconUrl,
    this.size = 32,
    this.backgroundColor = const Color(0xFF3F51B5),
    this.allowBadCertificates = false,
  });

  final String? iconUrl;
  final double size;
  final Color backgroundColor;
  final bool allowBadCertificates;

  @override
  State<BotAvatar> createState() => _BotAvatarState();
}

class _BotAvatarState extends State<BotAvatar> {
  Uint8List? _bytes;
  bool _loading = false;
  String? _requestedUrl;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant BotAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.iconUrl != widget.iconUrl ||
        oldWidget.allowBadCertificates != widget.allowBadCertificates) {
      _load();
    }
  }

  Future<void> _load() async {
    final raw = widget.iconUrl?.trim();
    if (raw == null || raw.isEmpty || raw.toLowerCase() == 'agent') {
      setState(() {
        _bytes = null;
        _loading = false;
        _requestedUrl = raw;
      });
      return;
    }

    // Kore URLs may include literal `$$` query tokens — keep as-is.
    final url = raw;
    _requestedUrl = url;
    setState(() {
      _loading = true;
      _bytes = null;
    });

    try {
      final client = createBotHttpClient(
        allowBadCertificates: widget.allowBadCertificates,
      );
      try {
        final uri = Uri.tryParse(url);
        if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
          if (!mounted || _requestedUrl != url) return;
          setState(() {
            _loading = false;
          });
          return;
        }

        final response = await client.get(uri);
        if (!mounted || _requestedUrl != url) return;

        if (response.statusCode >= 200 &&
            response.statusCode < 300 &&
            response.bodyBytes.isNotEmpty) {
          setState(() {
            _bytes = response.bodyBytes;
            _loading = false;
          });
        } else {
          setState(() {
            _loading = false;
          });
        }
      } finally {
        client.close();
      }
    } catch (_) {
      if (!mounted || _requestedUrl != url) return;
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_bytes != null) {
      return ClipOval(
        child: Image.memory(
          _bytes!,
          width: widget.size,
          height: widget.size,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          filterQuality: FilterQuality.medium,
          errorBuilder: (_, __, ___) => _fallback(),
        ),
      );
    }

    if (_loading) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            _fallback(),
            SizedBox(
              width: widget.size * 0.45,
              height: widget.size * 0.45,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: widget.backgroundColor,
              ),
            ),
          ],
        ),
      );
    }

    return _fallback();
  }

  Widget _fallback() {
    final isAgent = widget.iconUrl?.trim().toLowerCase() == 'agent';
    return CircleAvatar(
      radius: widget.size / 2,
      backgroundColor: widget.backgroundColor,
      child: Icon(
        isAgent ? Icons.support_agent : Icons.smart_toy,
        color: Colors.white,
        size: widget.size * 0.55,
      ),
    );
  }
}
