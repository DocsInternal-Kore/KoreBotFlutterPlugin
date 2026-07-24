import 'package:flutter/material.dart';

import '../../models/template_payload.dart';
import '../theme/bot_chat_theme.dart';
import 'template_helpers.dart';

/// Inline form — `form_template` (fields from `elements` or `formFields`).
class FormTemplate extends StatefulWidget {
  const FormTemplate({
    super.key,
    required this.template,
    required this.theme,
    required this.onSubmit,
  });

  final TemplatePayload template;
  final BotChatTheme theme;
  final TemplatePayloadAction onSubmit;

  @override
  State<FormTemplate> createState() => _FormTemplateState();
}

class _FormTemplateState extends State<FormTemplate>
    with AutomaticKeepAliveClientMixin {
  late final List<TextEditingController> _controllers;
  bool _submitted = false;

  @override
  bool get wantKeepAlive => true;

  List<BotElement> get _fields => widget.template.elements;

  String get _submitLabel {
    final top = widget.template.raw['fieldButton'];
    if (top is Map && top['title'] != null) return top['title'].toString();
    if (_fields.isNotEmpty) {
      final fieldBtn = _fields.first.raw['fieldButton'];
      if (fieldBtn is Map && fieldBtn['title'] != null) {
        return fieldBtn['title'].toString();
      }
    }
    return 'Submit';
  }

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_fields.length, (_) => TextEditingController());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitted || _fields.isEmpty) return;
    for (final c in _controllers) {
      if (c.text.trim().isEmpty) return;
    }

    final values = <String>[];
    final display = <String>[];
    for (var i = 0; i < _fields.length; i++) {
      final text = _controllers[i].text.trim();
      values.add(text);
      final type = _fields[i].raw['type']?.toString().toLowerCase();
      if (type == 'password') {
        display.add('•' * text.length.clamp(1, 12));
      } else {
        display.add(text);
      }
    }

    setState(() => _submitted = true);
    await widget.onSubmit(
      payload: values.join(' '),
      displayText: display.join(' '),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final heading =
        widget.template.heading ?? widget.template.text ?? widget.template.title;

    return templateShell(
      theme: widget.theme,
      text: heading,
      children: [
        templateCard(
          child: AbsorbPointer(
            absorbing: _submitted,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < _fields.length; i++) ...[
                    if (i > 0) const SizedBox(height: 10),
                    Text(
                      _fields[i].title ?? 'Field ${i + 1}',
                      style: TextStyle(
                        color: widget.theme.botTextColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _controllers[i],
                      obscureText:
                          _fields[i].raw['password'] == true ||
                          _fields[i].raw['type']?.toString().toLowerCase() ==
                              'password',
                      decoration: InputDecoration(
                        hintText:
                            _fields[i].raw['placeholder']?.toString() ?? '',
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        isDense: true,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  primaryActionButton(
                    label: _submitLabel,
                    theme: widget.theme,
                    onPressed: _submit,
                  ),
                ],
              ),
          ),
        ),
      ],
    );
  }
}

class MultiSelectTemplate extends StatefulWidget {
  const MultiSelectTemplate({
    super.key,
    required this.template,
    required this.theme,
    required this.onSubmit,
  });

  final TemplatePayload template;
  final BotChatTheme theme;
  final TemplatePayloadAction onSubmit;

  @override
  State<MultiSelectTemplate> createState() => _MultiSelectTemplateState();
}

class _MultiSelectTemplateState extends State<MultiSelectTemplate>
    with AutomaticKeepAliveClientMixin {
  final _selected = <int>{};
  bool _submitted = false;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final options = widget.template.elements;
    final actionButtons = widget.template.buttons;

    return templateShell(
      theme: widget.theme,
      text: widget.template.text ?? widget.template.heading,
      children: [
        templateCard(
          child: AbsorbPointer(
            absorbing: _submitted,
            child: Column(
                children: [
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Select all'),
                    value:
                        _selected.length == options.length && options.isNotEmpty,
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: widget.theme.buttonColor,
                    onChanged: (v) {
                      setState(() {
                        _selected.clear();
                        if (v == true) {
                          _selected.addAll(
                            List.generate(options.length, (i) => i),
                          );
                        }
                      });
                    },
                  ),
                  ...List.generate(options.length, (i) {
                    final el = options[i];
                    return CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(el.title ?? ''),
                      value: _selected.contains(i),
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: widget.theme.buttonColor,
                      onChanged: (v) {
                        setState(() {
                          if (v == true) {
                            _selected.add(i);
                          } else {
                            _selected.remove(i);
                          }
                        });
                      },
                    );
                  }),
                  primaryActionButton(
                    label: actionButtons.isNotEmpty
                        ? actionButtons.first.title
                        : 'Submit',
                    theme: widget.theme,
                    onPressed: () async {
                      if (_selected.isEmpty) return;
                      final titles =
                          _selected.map((i) => options[i].title ?? '').join(', ');
                      final values = _selected
                          .map((i) => options[i].value ?? options[i].title ?? '')
                          .join(', ');
                      setState(() => _submitted = true);
                      await widget.onSubmit(payload: values, displayText: titles);
                    },
                  ),
                ],
              ),
          ),
        ),
      ],
    );
  }
}

/// Grouped multi-select — `advanced_multi_select`.
class AdvanceMultiSelectTemplate extends StatefulWidget {
  const AdvanceMultiSelectTemplate({
    super.key,
    required this.template,
    required this.theme,
    required this.onSubmit,
  });

  final TemplatePayload template;
  final BotChatTheme theme;
  final TemplatePayloadAction onSubmit;

  @override
  State<AdvanceMultiSelectTemplate> createState() =>
      _AdvanceMultiSelectTemplateState();
}

class _AdvanceMultiSelectTemplateState extends State<AdvanceMultiSelectTemplate>
    with AutomaticKeepAliveClientMixin {
  final _selectedValues = <String>{};
  final _selectedTitles = <String>{};
  final _headerChecked = <int>{};
  bool _showAll = false;
  bool _submitted = false;

  @override
  bool get wantKeepAlive => true;

  int get _limit {
    final raw = widget.template.raw['limit'];
    if (raw is num) return raw.toInt().clamp(1, 999);
    return 1;
  }

  String get _doneLabel {
    if (widget.template.buttons.isNotEmpty) {
      return widget.template.buttons.first.title;
    }
    return 'Done';
  }

  List<_AdvItem> _itemsForGroup(BotElement group) {
    final collection = group.raw['collection'];
    final items = <_AdvItem>[];
    if (collection is List) {
      for (final item in collection) {
        if (item is! Map) continue;
        final map = Map<String, dynamic>.from(item);
        final title = mapString(map, ['title']);
        final value = mapString(map, ['value']).isEmpty
            ? title
            : mapString(map, ['value']);
        items.add(
          _AdvItem(
            title: title,
            value: value,
            description: map['description']?.toString(),
            imageUrl: map['image_url']?.toString(),
          ),
        );
      }
    }
    return items;
  }

  void _toggleItem(_AdvItem item) {
    setState(() {
      if (_selectedValues.contains(item.value)) {
        _selectedValues.remove(item.value);
        _selectedTitles.remove(item.title);
      } else {
        _selectedValues.add(item.value);
        _selectedTitles.add(item.title);
      }
    });
  }

  void _toggleSection(int section, List<_AdvItem> items) {
    setState(() {
      final allSelected = items.every((e) => _selectedValues.contains(e.value));
      if (allSelected) {
        _headerChecked.remove(section);
        for (final item in items) {
          _selectedValues.remove(item.value);
          _selectedTitles.remove(item.title);
        }
      } else {
        _headerChecked.add(section);
        for (final item in items) {
          _selectedValues.add(item.value);
          _selectedTitles.add(item.title);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final groups = widget.template.elements;
    final visibleCount =
        _showAll ? groups.length : _limit.clamp(0, groups.length);
    final canShowMore = !_showAll && groups.length > visibleCount;

    return templateShell(
      theme: widget.theme,
      text: widget.template.heading ?? widget.template.text,
      children: [
        templateCard(
          child: AbsorbPointer(
            absorbing: _submitted,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var s = 0; s < visibleCount; s++) ...[
                    if (s > 0) const Divider(height: 20),
                    Builder(
                      builder: (context) {
                        final group = groups[s];
                        final collectionTitle =
                            group.raw['collectionTitle']?.toString() ??
                            group.title ??
                            '';
                        final items = _itemsForGroup(group);
                        final allSelected = items.isNotEmpty &&
                            items.every(
                              (e) => _selectedValues.contains(e.value),
                            );
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (collectionTitle.isNotEmpty)
                              Text(
                                collectionTitle,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            if (items.length > 1)
                              CheckboxListTile(
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                                title: const Text('Select all'),
                                value: allSelected,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                activeColor: widget.theme.buttonColor,
                                onChanged: (_) => _toggleSection(s, items),
                              ),
                            for (final item in items)
                              CheckboxListTile(
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                                secondary: item.imageUrl != null &&
                                        item.imageUrl!.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: Image.network(
                                          item.imageUrl!,
                                          width: 36,
                                          height: 36,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const SizedBox(width: 36),
                                        ),
                                      )
                                    : null,
                                title: Text(item.title),
                                subtitle: item.description != null
                                    ? Text(item.description!)
                                    : null,
                                value: _selectedValues.contains(item.value),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                activeColor: widget.theme.buttonColor,
                                onChanged: (_) => _toggleItem(item),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (canShowMore)
                        OutlinedButton(
                          onPressed: () => setState(() => _showAll = true),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: widget.theme.buttonColor,
                            side: BorderSide(color: widget.theme.buttonColor),
                          ),
                          child: const Text('View more'),
                        ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () async {
                          if (_selectedValues.isEmpty) return;
                          final joinedValues = _selectedValues.join(', ');
                          final joinedTitles = _selectedTitles.join(', ');
                          setState(() => _submitted = true);
                          await widget.onSubmit(
                            payload: joinedValues,
                            displayText:
                                'Here are selected items: $joinedTitles',
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.theme.buttonColor,
                          foregroundColor: widget.theme.buttonTextColor,
                        ),
                        child: Text(_doneLabel),
                      ),
                    ],
                  ),
                ],
              ),
          ),
        ),
      ],
    );
  }
}

class _AdvItem {
  const _AdvItem({
    required this.title,
    required this.value,
    this.description,
    this.imageUrl,
  });

  final String title;
  final String value;
  final String? description;
  final String? imageUrl;
}

/// Radio list — `radioOptionTemplate`.
class RadioOptionsTemplate extends StatefulWidget {
  const RadioOptionsTemplate({
    super.key,
    required this.template,
    required this.theme,
    required this.onSubmit,
  });

  final TemplatePayload template;
  final BotChatTheme theme;
  final TemplatePayloadAction onSubmit;

  @override
  State<RadioOptionsTemplate> createState() => _RadioOptionsTemplateState();
}

class _RadioOptionsTemplateState extends State<RadioOptionsTemplate>
    with AutomaticKeepAliveClientMixin {
  int? _selected;
  bool _submitted = false;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final options = widget.template.radioOptions;

    return templateShell(
      theme: widget.theme,
      text: widget.template.heading ?? widget.template.text,
      children: [
        templateCard(
          child: AbsorbPointer(
            absorbing: _submitted,
            child: Column(
                children: [
                  ...List.generate(options.length, (i) {
                    final opt = options[i];
                    final title = mapString(opt, ['title']);
                    final value = mapString(opt, ['value']);
                    final selected = _selected == i;
                    return InkWell(
                      onTap: () => setState(() => _selected = i),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              selected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              color: selected
                                  ? widget.theme.buttonColor
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                value.isNotEmpty ? '$title\n$value' : title,
                                style: TextStyle(
                                  color: widget.theme.botTextColor,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  primaryActionButton(
                    label: 'Confirm',
                    theme: widget.theme,
                    onPressed: () async {
                      if (_selected == null) return;
                      final opt = options[_selected!];
                      final postback = opt['postback'];
                      String title = mapString(opt, ['title']);
                      String value = mapString(opt, ['value']);
                      if (postback is Map) {
                        title = postback['title']?.toString() ?? title;
                        value = postback['value']?.toString() ?? value;
                      }
                      if (value.isEmpty) value = title;
                      setState(() => _submitted = true);
                      await widget.onSubmit(payload: value, displayText: title);
                    },
                  ),
                ],
              ),
          ),
        ),
      ],
    );
  }
}

/// Dropdown picker — `dropdown_template`.
class DropdownTemplate extends StatefulWidget {
  const DropdownTemplate({
    super.key,
    required this.template,
    required this.theme,
    required this.onSubmit,
  });

  final TemplatePayload template;
  final BotChatTheme theme;
  final TemplatePayloadAction onSubmit;

  @override
  State<DropdownTemplate> createState() => _DropdownTemplateState();
}

class _DropdownTemplateState extends State<DropdownTemplate>
    with AutomaticKeepAliveClientMixin {
  int? _selected;
  bool _submitted = false;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final options = widget.template.elements;
    final placeholder = widget.template.placeholder ?? 'Select';
    final heading = widget.template.heading;
    final label = widget.template.label;
    final header = [
      if (heading != null && heading.isNotEmpty) heading,
      if (label != null && label.isNotEmpty) label,
    ].join('\n\n');

    return templateShell(
      theme: widget.theme,
      text: header.isNotEmpty ? header : widget.template.text,
      children: [
        templateCard(
          child: AbsorbPointer(
            absorbing: _submitted,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<int>(
                    initialValue: _selected,
                    isExpanded: true,
                    hint: Text(
                      placeholder,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      isDense: true,
                    ),
                    selectedItemBuilder: (context) {
                      return [
                        for (final option in options)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              option.title ?? option.value ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ];
                    },
                    items: [
                      for (var i = 0; i < options.length; i++)
                        DropdownMenuItem(
                          value: i,
                          child: Text(
                            options[i].title ?? options[i].value ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: (v) => setState(() => _selected = v),
                  ),
                  const SizedBox(height: 12),
                  primaryActionButton(
                    label: 'Submit',
                    theme: widget.theme,
                    onPressed: () async {
                      if (_selected == null || _submitted) return;
                      final el = options[_selected!];
                      final title = (el.title ?? el.value ?? '').trim();
                      final value = (el.value ?? el.title ?? '').trim();
                      if (title.isEmpty && value.isEmpty) return;
                      setState(() => _submitted = true);
                      // Native SDK posts the selected option as a chat utterance.
                      await widget.onSubmit(
                        payload: value.isNotEmpty ? value : title,
                        displayText: title.isNotEmpty ? title : value,
                      );
                    },
                  ),
                ],
              ),
          ),
        ),
      ],
    );
  }
}
