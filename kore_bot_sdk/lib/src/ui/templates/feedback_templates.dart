import 'dart:convert';

import 'package:flutter/material.dart';

import '../../models/template_payload.dart';
import '../theme/bot_chat_theme.dart';
import 'template_helpers.dart';

class FeedbackTemplate extends StatefulWidget {
  const FeedbackTemplate({
    super.key,
    required this.template,
    required this.theme,
    required this.onSubmit,
  });

  final TemplatePayload template;
  final BotChatTheme theme;
  final TemplatePayloadAction onSubmit;

  @override
  State<FeedbackTemplate> createState() => _FeedbackTemplateState();
}

class _FeedbackTemplateState extends State<FeedbackTemplate>
    with AutomaticKeepAliveClientMixin {
  int? _rating;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final view = (widget.template.view ?? 'star').toLowerCase();

    return templateShell(
      theme: widget.theme,
      text: widget.template.text,
      children: [
        templateCard(
          child: Column(
            children: [
              if (view == 'nps') _buildNps(),
              if (view == 'csat') _buildCsat(),
              if (view == 'thumbsupdown') _buildThumbs(),
              if (view == 'star' ||
                  (view != 'nps' && view != 'csat' && view != 'thumbsupdown'))
                _buildStars(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final value = i + 1;
        return IconButton(
          padding: const EdgeInsets.all(6),
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          iconSize: 40,
          onPressed: () {
            setState(() => _rating = value);
            widget.onSubmit(payload: '$value', displayText: '$value');
          },
          icon: Icon(
            value <= (_rating ?? 0) ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 40,
          ),
        );
      }),
    );
  }

  Widget _buildNps() {
    final entries = _npsEntries();
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final entry in entries)
          _NpsCell(
            label: entry.label,
            color: entry.color,
            selectedColor: widget.theme.buttonColor,
            selected: _rating == entry.value,
            onTap: () {
              setState(() => _rating = entry.value);
              widget.onSubmit(
                payload: entry.payload,
                displayText: entry.label,
              );
            },
          ),
      ],
    );
  }

  /// Prefer payload `numbersArrays` colors (e.g. `#DD3646`); fall back to 0–10 defaults.
  List<_NpsEntry> _npsEntries() {
    final raw = widget.template.raw['numbersArrays'];
    if (raw is List && raw.isNotEmpty) {
      final entries = <_NpsEntry>[];
      for (final item in raw) {
        if (item is! Map) continue;
        final map = Map<String, dynamic>.from(item);
        final id = map['numberId'];
        final valueStr = map['value']?.toString() ?? id?.toString() ?? '';
        final value = int.tryParse(valueStr) ??
            (id is int ? id : int.tryParse(id?.toString() ?? ''));
        if (value == null) continue;
        final color = BotChatTheme.tryParseColor(map['color']?.toString()) ??
            _defaultNpsColor(value);
        entries.add(
          _NpsEntry(
            value: value,
            label: id?.toString() ?? valueStr,
            payload: valueStr.isNotEmpty ? valueStr : '$value',
            color: color,
          ),
        );
      }
      if (entries.isNotEmpty) return entries;
    }

    return List.generate(11, (i) {
      return _NpsEntry(
        value: i,
        label: '$i',
        payload: '$i',
        color: _defaultNpsColor(i),
      );
    });
  }

  Color _defaultNpsColor(int value) {
    if (value <= 5) return const Color(0xFFDD3646);
    if (value <= 8) return const Color(0xFFFB8460);
    return const Color(0xFF28A745);
  }

  Widget _buildCsat() {
    const icons = [
      Icons.sentiment_very_dissatisfied,
      Icons.sentiment_dissatisfied,
      Icons.sentiment_neutral,
      Icons.sentiment_satisfied,
      Icons.sentiment_very_satisfied,
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(icons.length, (i) {
        final value = i + 1;
        return IconButton(
          onPressed: () {
            setState(() => _rating = value);
            widget.onSubmit(payload: '$value', displayText: '$value');
          },
          icon: Icon(
            icons[i],
            color: _rating == value ? widget.theme.buttonColor : Colors.grey,
            size: 32,
          ),
        );
      }),
    );
  }

  Widget _buildThumbs() {
    final elements = widget.template.elements;
    if (elements.isEmpty) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.thumb_up_alt_outlined),
            onPressed: () => widget.onSubmit(payload: 'thumbsUp', displayText: '👍'),
          ),
          IconButton(
            icon: const Icon(Icons.thumb_down_alt_outlined),
            onPressed: () => widget.onSubmit(payload: 'thumbsDown', displayText: '👎'),
          ),
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: elements.map((el) {
        final value = el.value ?? el.title ?? '';
        final isUp = value.toLowerCase().contains('up');
        return IconButton(
          icon: Icon(isUp ? Icons.thumb_up : Icons.thumb_down),
          onPressed: () => widget.onSubmit(payload: value, displayText: value),
        );
      }).toList(),
    );
  }
}

class BankingFeedbackTemplate extends StatefulWidget {
  const BankingFeedbackTemplate({
    super.key,
    required this.template,
    required this.theme,
    required this.onSubmit,
  });

  final TemplatePayload template;
  final BotChatTheme theme;
  final TemplatePayloadAction onSubmit;

  @override
  State<BankingFeedbackTemplate> createState() => _BankingFeedbackTemplateState();
}

class _BankingFeedbackTemplateState extends State<BankingFeedbackTemplate>
    with AutomaticKeepAliveClientMixin {
  Map<String, dynamic>? _experience;
  final _feedback = <String, Map<String, dynamic>>{};
  final _suggestion = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _suggestion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final experiences = widget.template.raw['experienceContent'];
    final feedbackList = widget.template.raw['feedbackList'];
    final buttons = widget.template.buttons;

    return templateShell(
      theme: widget.theme,
      text: widget.template.heading ?? widget.template.text,
      children: [
        templateCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (experiences is List) ...[
                const Text('Experience', style: TextStyle(fontWeight: FontWeight.w700)),
                ...experiences.whereType<Map>().map((e) {
                  final map = Map<String, dynamic>.from(e);
                  final id = map['id']?.toString() ?? map['value']?.toString() ?? '';
                  final selected = _experience?['id']?.toString() == id;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      selected ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: widget.theme.buttonColor,
                    ),
                    title: Text(map['value']?.toString() ?? ''),
                    onTap: () => setState(() => _experience = map),
                  );
                }),
                if (_experience?['empathyMessage'] != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      _experience!['empathyMessage'].toString(),
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ),
              ],
              if (feedbackList is List) ...[
                const Text('Feedback', style: TextStyle(fontWeight: FontWeight.w700)),
                Wrap(
                  spacing: 8,
                  children: feedbackList.whereType<Map>().map((e) {
                    final map = Map<String, dynamic>.from(e);
                    final id = map['id']?.toString() ?? map['value']?.toString() ?? '';
                    final selected = _feedback.containsKey(id);
                    return FilterChip(
                      label: Text(map['value']?.toString() ?? ''),
                      selected: selected,
                      onSelected: (v) {
                        setState(() {
                          if (v) {
                            _feedback[id] = map;
                          } else {
                            _feedback.remove(id);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 8),
              TextField(
                controller: _suggestion,
                decoration: const InputDecoration(
                  labelText: 'Suggestion',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              primaryActionButton(
                label: buttons.isNotEmpty ? buttons.first.title : 'Submit',
                theme: widget.theme,
                onPressed: () {
                  final payload = jsonEncode({
                    'selectedFeedback': _feedback.values.toList(),
                    'selectedExperience': _experience,
                    'userSuggestion': _suggestion.text,
                  });
                  widget.onSubmit(payload: payload, displayText: 'Feedback submitted');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NpsEntry {
  const _NpsEntry({
    required this.value,
    required this.label,
    required this.payload,
    required this.color,
  });

  final int value;
  final String label;
  final String payload;
  final Color color;
}

/// SPM `FeedbackCell` for NPS — colored label background from `numbersArrays.color`.
class _NpsCell extends StatelessWidget {
  const _NpsCell({
    required this.label,
    required this.color,
    required this.selectedColor,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color color;
  final Color selectedColor;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? selectedColor : color;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(5),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
