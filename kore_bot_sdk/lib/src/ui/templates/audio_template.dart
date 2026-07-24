import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../../models/template_payload.dart';
import '../theme/bot_chat_theme.dart';
import 'template_helpers.dart';
import 'text_bubble.dart';

/// Inline audio player for Kore `message` / `audio` payloads with `audioUrl`.
class AudioTemplate extends StatefulWidget {
  const AudioTemplate({
    super.key,
    required this.template,
    required this.theme,
  });

  final TemplatePayload template;
  final BotChatTheme theme;

  @override
  State<AudioTemplate> createState() => _AudioTemplateState();
}

class _AudioTemplateState extends State<AudioTemplate> {
  VideoPlayerController? _controller;
  bool _initializing = true;
  String? _error;

  String? get _url {
    final raw = widget.template.url ??
        widget.template.raw['audioUrl']?.toString() ??
        widget.template.raw['url']?.toString();
    final trimmed = raw?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  @override
  void didUpdateWidget(covariant AudioTemplate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.template.url != widget.template.url ||
        oldWidget.template.raw['audioUrl'] != widget.template.raw['audioUrl']) {
      _disposeController();
      _initPlayer();
    }
  }

  Future<void> _initPlayer() async {
    final url = _url;
    if (url == null) {
      setState(() {
        _initializing = false;
        _error = 'Audio URL missing';
      });
      return;
    }

    setState(() {
      _initializing = true;
      _error = null;
    });

    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    _controller = controller;
    try {
      await controller.initialize();
      controller.addListener(_onTick);
      if (!mounted) return;
      setState(() => _initializing = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _error = 'Unable to load audio';
      });
    }
  }

  void _onTick() {
    if (mounted) setState(() {});
  }

  void _disposeController() {
    _controller?.removeListener(_onTick);
    _controller?.dispose();
    _controller = null;
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  Future<void> _openExternal() async {
    final url = _url;
    if (url == null) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  String _format(Duration d) {
    final total = d.inSeconds;
    final m = (total ~/ 60).toString().padLeft(2, '0');
    final s = (total % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final title = (widget.template.text ?? '').trim();
    final controller = _controller;
    final ready = controller != null && controller.value.isInitialized;
    final position = ready ? controller.value.position : Duration.zero;
    final duration = ready ? controller.value.duration : Duration.zero;
    final playing = ready && controller.value.isPlaying;
    final maxMs = duration.inMilliseconds <= 0
        ? 1.0
        : duration.inMilliseconds.toDouble();
    final valueMs = position.inMilliseconds.clamp(0, maxMs.toInt()).toDouble();

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
          padding: const EdgeInsets.fromLTRB(12, 12, 8, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(
                      Icons.audiotrack_rounded,
                      color: Colors.black87,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title.isNotEmpty ? title : 'Audio',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: widget.theme.botTextColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Open externally',
                    onPressed: _openExternal,
                    icon: const Icon(Icons.open_in_new, size: 18),
                    color: Colors.black87,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_initializing)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              else if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: widget.theme.botTextColor.withValues(alpha: 0.7),
                      fontSize: 13,
                    ),
                  ),
                )
              else ...[
                Row(
                  children: [
                    IconButton(
                      onPressed: ready
                          ? () {
                              if (playing) {
                                controller.pause();
                              } else {
                                controller.play();
                              }
                            }
                          : null,
                      icon: Icon(
                        playing
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled,
                        size: 40,
                        color: Colors.black,
                      ),
                    ),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 7,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 14,
                          ),
                          activeTrackColor: Colors.black,
                          inactiveTrackColor:
                              Colors.black.withValues(alpha: 0.25),
                          thumbColor: Colors.black,
                          overlayColor: Colors.black.withValues(alpha: 0.12),
                        ),
                        child: Slider(
                          min: 0,
                          max: maxMs,
                          value: valueMs,
                          onChanged: ready
                              ? (v) {
                                  controller.seekTo(
                                    Duration(milliseconds: v.round()),
                                  );
                                }
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12, right: 8, bottom: 4),
                  child: Row(
                    children: [
                      Text(
                        _format(position),
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _format(duration),
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
