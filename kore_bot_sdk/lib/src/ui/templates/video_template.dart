import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../../models/template_payload.dart';
import '../theme/bot_chat_theme.dart';
import 'template_helpers.dart';
import 'text_bubble.dart';

/// Inline video player for Kore `message` / `video` payloads with `videoUrl`.
class VideoTemplate extends StatefulWidget {
  const VideoTemplate({
    super.key,
    required this.template,
    required this.theme,
  });

  final TemplatePayload template;
  final BotChatTheme theme;

  @override
  State<VideoTemplate> createState() => _VideoTemplateState();
}

class _VideoTemplateState extends State<VideoTemplate> {
  VideoPlayerController? _controller;
  bool _initializing = true;
  String? _error;

  String? get _url {
    final raw = widget.template.url ??
        widget.template.raw['videoUrl']?.toString() ??
        widget.template.raw['url']?.toString();
    final trimmed = raw?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  Color get _accent {
    final hex = widget.template.raw['color']?.toString();
    if (hex == null || hex.isEmpty) return widget.theme.buttonColor;
    final cleaned = hex.replaceFirst('#', '');
    if (cleaned.length == 6) {
      final value = int.tryParse(cleaned, radix: 16);
      if (value != null) return Color(0xFF000000 | value);
    }
    return widget.theme.buttonColor;
  }

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    final url = _url;
    if (url == null) {
      setState(() {
        _initializing = false;
        _error = 'Video URL missing';
      });
      return;
    }

    final uri = Uri.tryParse(url);
    if (uri == null) {
      setState(() {
        _initializing = false;
        _error = 'Invalid video URL';
      });
      return;
    }

    final controller = VideoPlayerController.networkUrl(uri);
    _controller = controller;
    try {
      await controller.initialize();
      controller.setLooping(false);
      if (!mounted) return;
      setState(() => _initializing = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _error = 'Unable to load video';
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (controller.value.isPlaying) {
      await controller.pause();
    } else {
      await controller.play();
    }
    if (mounted) setState(() {});
  }

  Future<void> _openExternal() async {
    final url = _url;
    if (url == null) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final h = d.inHours;
    if (h > 0) return '$h:$m:$s';
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final title = (widget.template.text ?? '').trim();
    final controller = _controller;
    final accent = _accent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          TextBubble(
            text: title,
            background: widget.theme.botBubbleColor,
            textColor: widget.theme.botTextColor,
            isUser: false,
            square: widget.theme.isSquareBubble,
          ),
        templateCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: controller != null &&
                        controller.value.isInitialized &&
                        controller.value.aspectRatio > 0
                    ? controller.value.aspectRatio
                    : 16 / 9,
                child: ColoredBox(
                  color: Colors.black,
                  child: _buildPlayerSurface(controller, accent),
                ),
              ),
              if (controller != null && controller.value.isInitialized)
                _VideoControls(
                  controller: controller,
                  onTogglePlay: _togglePlay,
                  onOpenExternal: _openExternal,
                  formatDuration: _formatDuration,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerSurface(VideoPlayerController? controller, Color accent) {
    if (_initializing) {
      return Center(child: CircularProgressIndicator(color: accent));
    }
    if (_error != null || controller == null || !controller.value.isInitialized) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.videocam_off, color: Colors.white70, size: 36),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Video unavailable',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _openExternal,
              icon: const Icon(Icons.open_in_new, color: Colors.white),
              label: const Text('Open', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        VideoPlayer(controller),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _togglePlay,
            child: AnimatedOpacity(
              opacity: controller.value.isPlaying ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(12),
                child: Icon(
                  controller.value.isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                  color: Colors.white,
                  size: 48,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _VideoControls extends StatelessWidget {
  const _VideoControls({
    required this.controller,
    required this.onTogglePlay,
    required this.onOpenExternal,
    required this.formatDuration,
  });

  final VideoPlayerController controller;
  final VoidCallback onTogglePlay;
  final VoidCallback onOpenExternal;
  final String Function(Duration) formatDuration;

  static const Color _controlColor = Colors.black;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final position = value.position;
        final duration = value.duration;
        final progress = duration.inMilliseconds == 0
            ? 0.0
            : (position.inMilliseconds / duration.inMilliseconds)
                .clamp(0.0, 1.0);

        return Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
          child: Row(
            children: [
              IconButton(
                onPressed: onTogglePlay,
                icon: Icon(
                  value.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: _controlColor,
                ),
                tooltip: value.isPlaying ? 'Pause' : 'Play',
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape:
                        const RoundSliderOverlayShape(overlayRadius: 12),
                    activeTrackColor: _controlColor,
                    inactiveTrackColor: _controlColor.withValues(alpha: 0.25),
                    thumbColor: _controlColor,
                  ),
                  child: Slider(
                    value: progress,
                    onChanged: (v) {
                      final ms = (duration.inMilliseconds * v).round();
                      controller.seekTo(Duration(milliseconds: ms));
                    },
                  ),
                ),
              ),
              Text(
                '${formatDuration(position)} / ${formatDuration(duration)}',
                style: const TextStyle(fontSize: 11, color: _controlColor),
              ),
              IconButton(
                onPressed: onOpenExternal,
                icon: const Icon(
                  Icons.open_in_new,
                  color: _controlColor,
                  size: 20,
                ),
                tooltip: 'Open externally',
              ),
            ],
          ),
        );
      },
    );
  }
}
