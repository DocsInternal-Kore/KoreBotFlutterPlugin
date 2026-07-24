import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/template_payload.dart';
import '../theme/bot_chat_theme.dart';
import 'template_helpers.dart';

class CardTemplate extends StatelessWidget {
  const CardTemplate({
    super.key,
    required this.template,
    required this.theme,
    required this.onButton,
  });

  final TemplatePayload template;
  final BotChatTheme theme;
  final TemplateAction onButton;

  @override
  Widget build(BuildContext context) {
    return templateShell(
      theme: theme,
      text: template.text,
      children: template.cards.map((card) {
        final heading = card['cardHeading'];
        String title = '';
        String description = '';
        if (heading is Map) {
          title = heading['title']?.toString() ?? '';
          description = heading['description']?.toString() ?? '';
        }
        final buttons = <BotButton>[];
        final rawButtons = card['buttons'];
        if (rawButtons is List) {
          for (final b in rawButtons) {
            if (b is Map) buttons.add(BotButton.fromJson(Map<String, dynamic>.from(b)));
          }
        }
        final descriptions = card['cardDescription'];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: templateCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title.isNotEmpty)
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                if (description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(description),
                  ),
                if (descriptions is List)
                  ...descriptions.map((d) {
                    if (d is Map) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(d['description']?.toString() ?? d['title']?.toString() ?? ''),
                      );
                    }
                    return Text(d.toString());
                  }),
                ...buttons.map(
                  (b) => outlinedActionButton(
                    label: b.title,
                    theme: theme,
                    onPressed: () => handleTemplateButton(b, onButton),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class ContactCardTemplate extends StatelessWidget {
  const ContactCardTemplate({
    super.key,
    required this.template,
    required this.theme,
  });

  final TemplatePayload template;
  final BotChatTheme theme;

  @override
  Widget build(BuildContext context) {
    return templateShell(
      theme: theme,
      text: template.title ?? template.text,
      children: [
        templateCard(
          child: Column(
            children: template.cards.map((card) {
              final name = mapString(card, ['userName', 'title', 'name']);
              final phone = mapString(card, ['userContactNumber', 'phone']);
              final email = mapString(card, ['userEmailId', 'email']);
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: theme.buttonColor.withValues(alpha: 0.15),
                  child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?'),
                ),
                title: Text(name),
                subtitle: Text([phone, email].where((e) => e.isNotEmpty).join('\n')),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class MediaTemplate extends StatelessWidget {
  const MediaTemplate({
    super.key,
    required this.template,
    required this.theme,
  });

  final TemplatePayload template;
  final BotChatTheme theme;

  @override
  Widget build(BuildContext context) {
    final type = template.templateType;
    final url = template.url ??
        template.raw['url']?.toString() ??
        template.raw['videoUrl']?.toString() ??
        template.raw['audioUrl']?.toString();
    final label = (template.text ?? '').trim();

    return templateShell(
      theme: theme,
      text: label.isEmpty ? null : label,
      children: [
        templateCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (type == 'image' && url != null && url.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    url,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const SizedBox(
                        height: 160,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    },
                    errorBuilder: (_, __, ___) => const SizedBox(
                      height: 120,
                      child: Center(child: Icon(Icons.broken_image)),
                    ),
                  ),
                )
              else if ((type == 'audio' || type == 'video') &&
                  url != null &&
                  url.isNotEmpty)
                ListTile(
                  leading: Icon(
                    type == 'audio'
                        ? Icons.audiotrack
                        : Icons.play_circle_fill,
                    color: theme.buttonColor,
                    size: 40,
                  ),
                  title: Text(
                    type == 'audio' ? 'Play audio' : 'Play video',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    url,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Icon(Icons.open_in_new, color: theme.buttonColor),
                  onTap: () async {
                    final uri = Uri.tryParse(url);
                    if (uri != null) {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                )
              else
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'Media unavailable',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class LinkTemplate extends StatelessWidget {
  const LinkTemplate({
    super.key,
    required this.template,
    required this.theme,
  });

  final TemplatePayload template;
  final BotChatTheme theme;

  @override
  Widget build(BuildContext context) {
    final name = template.raw['fileName']?.toString() ??
        template.raw['name']?.toString() ??
        template.title ??
        template.text ??
        'Download';
    final url = template.url ?? template.raw['url']?.toString();

    return templateShell(
      theme: theme,
      text: null,
      children: [
        templateCard(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(_fileIcon(name), color: theme.buttonColor),
            title: Text(name),
            subtitle: url == null
                ? null
                : Text(url, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: const Icon(Icons.download),
            onTap: url == null
                ? null
                : () async {
                    final uri = Uri.tryParse(url);
                    if (uri != null) {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
          ),
        ),
      ],
    );
  }

  IconData _fileIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.pdf')) return Icons.picture_as_pdf;
    if (lower.endsWith('.doc') || lower.endsWith('.docx')) {
      return Icons.description;
    }
    if (lower.endsWith('.xls') || lower.endsWith('.xlsx')) {
      return Icons.table_chart;
    }
    if (lower.endsWith('.zip') || lower.endsWith('.rar')) {
      return Icons.folder_zip;
    }
    return Icons.insert_drive_file;
  }
}

class PdfTemplate extends StatelessWidget {
  const PdfTemplate({
    super.key,
    required this.template,
    required this.theme,
  });

  final TemplatePayload template;
  final BotChatTheme theme;

  @override
  Widget build(BuildContext context) {
    final items = <Map<String, dynamic>>[
      ...template.pdfItems,
      if (template.pdfItems.isEmpty)
        ...template.elements.map((e) => e.raw),
    ];
    if (items.isEmpty &&
        (template.url != null || template.raw['url'] != null)) {
      items.add({
        'title': template.title ?? template.text ?? 'Download',
        'url': template.url ?? template.raw['url'],
      });
    }

    return templateShell(
      theme: theme,
      text: template.text,
      children: [
        templateCard(
          child: Column(
            children: items.isEmpty
                ? [
                    Text(
                      'No downloadable files',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ]
                : items.map((item) {
                    final title =
                        mapString(item, ['title', 'name', 'fileName']);
                    final url = mapString(item, ['url']);
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.picture_as_pdf,
                        color: theme.buttonColor,
                      ),
                      title: Text(title.isEmpty ? 'Download file' : title),
                      trailing: const Icon(Icons.open_in_new),
                      onTap: url.isEmpty
                          ? null
                          : () async {
                              final uri = Uri.tryParse(url);
                              if (uri != null) {
                                await launchUrl(
                                  uri,
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                            },
                    );
                  }).toList(),
          ),
        ),
      ],
    );
  }
}

class DatePickerTemplate extends StatefulWidget {
  const DatePickerTemplate({
    super.key,
    required this.template,
    required this.theme,
    required this.onSubmit,
  });

  final TemplatePayload template;
  final BotChatTheme theme;
  final TemplatePayloadAction onSubmit;

  @override
  State<DatePickerTemplate> createState() => _DatePickerTemplateState();
}

class _DatePickerTemplateState extends State<DatePickerTemplate> {
  DateTime? _start;
  DateTime? _end;

  bool get _isRange => widget.template.isDateRange;

  String get _format {
    final raw = widget.template.raw['format']?.toString() ?? 'MM-dd-yyyy';
    // Normalize common Kore formats to DateFormat patterns.
    return raw
        .replaceAll('YYYY', 'yyyy')
        .replaceAll('DD', 'dd')
        .replaceAll('MM', 'MM');
  }

  String _formatDate(DateTime date) {
    try {
      return DateFormat(_format).format(date);
    } catch (_) {
      return DateFormat('MM-dd-yyyy').format(date);
    }
  }

  Future<void> _pick() async {
    final now = DateTime.now();
    final first = DateTime(now.year - 5);
    final last = DateTime(now.year + 5);

    if (_isRange) {
      final range = await showDateRangePicker(
        context: context,
        firstDate: first,
        lastDate: last,
        initialDateRange: _start != null && _end != null
            ? DateTimeRange(start: _start!, end: _end!)
            : null,
      );
      if (range == null) return;
      setState(() {
        _start = range.start;
        _end = range.end;
      });
    } else {
      final picked = await showDatePicker(
        context: context,
        initialDate: _start ?? now,
        firstDate: first,
        lastDate: last,
      );
      if (picked == null) return;
      setState(() {
        _start = picked;
        _end = null;
      });
    }
  }

  Future<void> _confirm() async {
    if (_start == null) return;
    final payload = _isRange && _end != null
        ? '${_formatDate(_start!)} - ${_formatDate(_end!)}'
        : _formatDate(_start!);
    await widget.onSubmit(payload: payload, displayText: payload);
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.template.title ??
        widget.template.raw['text_message']?.toString() ??
        widget.template.text ??
        (_isRange ? 'Select date range' : 'Select a date');
    final selected = _start == null
        ? 'No date selected'
        : _isRange && _end != null
            ? '${_formatDate(_start!)} → ${_formatDate(_end!)}'
            : _formatDate(_start!);

    return templateShell(
      theme: widget.theme,
      text: title,
      children: [
        templateCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                selected,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              outlinedActionButton(
                label: _isRange ? 'Pick date range' : 'Pick date',
                theme: widget.theme,
                onPressed: _pick,
              ),
              if (_start != null)
                primaryActionButton(
                  label: 'Confirm',
                  theme: widget.theme,
                  onPressed: _confirm,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class ClockTemplate extends StatefulWidget {
  const ClockTemplate({
    super.key,
    required this.template,
    required this.theme,
    required this.onSubmit,
  });

  final TemplatePayload template;
  final BotChatTheme theme;
  final TemplatePayloadAction onSubmit;

  @override
  State<ClockTemplate> createState() => _ClockTemplateState();
}

class _ClockTemplateState extends State<ClockTemplate> {
  double _hour = 10;
  double _minute = 0;
  bool _isAm = true;

  @override
  Widget build(BuildContext context) {
    final hour = _hour.round().clamp(1, 12);
    final minute = _minute.round().clamp(0, 59);
    final label =
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} ${_isAm ? 'AM' : 'PM'}';

    return templateShell(
      theme: widget.theme,
      text: widget.template.text ?? 'Select time',
      children: [
        templateCard(
          child: Column(
            children: [
              Text(label, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text('Hour'),
              Slider(
                value: _hour,
                min: 1,
                max: 12,
                divisions: 11,
                label: '$hour',
                onChanged: (v) => setState(() => _hour = v),
              ),
              const Text('Minute'),
              Slider(
                value: _minute,
                min: 0,
                max: 59,
                divisions: 59,
                label: '$minute',
                onChanged: (v) => setState(() => _minute = v),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: const Text('AM'),
                    selected: _isAm,
                    onSelected: (_) => setState(() => _isAm = true),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('PM'),
                    selected: !_isAm,
                    onSelected: (_) => setState(() => _isAm = false),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              primaryActionButton(
                label: 'Confirm',
                theme: widget.theme,
                onPressed: () => widget.onSubmit(payload: label, displayText: label),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
