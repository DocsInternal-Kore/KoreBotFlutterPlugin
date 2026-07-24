import 'package:flutter/material.dart';

import '../../models/template_payload.dart';
import '../theme/bot_chat_theme.dart';
import 'template_helpers.dart';

class TableTemplate extends StatelessWidget {
  const TableTemplate({
    super.key,
    required this.template,
    required this.theme,
    this.responsive = false,
  });

  final TemplatePayload template;
  final BotChatTheme theme;
  final bool responsive;

  @override
  Widget build(BuildContext context) {
    final headers = template.columns.map((c) {
      if (c.isEmpty) return '';
      final first = c.first;
      if (first.trim().isEmpty || first.toLowerCase() == 'null') return '';
      return first;
    }).toList();
    final rows = template.elements.map((e) {
      if (e.tableValues.isNotEmpty) return e.tableValues;
      final values = e.raw['Values'] ?? e.raw['values'];
      if (values is List) return values.map(displayCell).toList();
      return <String>[
        if (e.title != null && displayCell(e.title).isNotEmpty) displayCell(e.title),
        if (e.value != null && displayCell(e.value).isNotEmpty) displayCell(e.value),
      ];
    }).where((r) => r.isNotEmpty).toList();

    final preview = rows.take(3).toList();
    final colCount = headers.isNotEmpty
        ? headers.length
        : (rows.isEmpty ? 1 : rows.map((r) => r.length).reduce((a, b) => a > b ? a : b));
    final effectiveHeaders = headers.isNotEmpty
        ? headers
        : List.generate(colCount, (i) => 'Col ${i + 1}');

    return templateShell(
      theme: theme,
      text: template.text,
      children: [
        SizedBox(
          width: double.infinity,
          child: templateCard(
            padding: const EdgeInsets.all(8),
            child: rows.isEmpty
                ? Text(
                    'No table data',
                    style: TextStyle(color: Colors.grey.shade600),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTable(effectiveHeaders, preview, responsive),
                      if (rows.length > 3)
                        TextButton(
                          onPressed: () {
                            showDialog<void>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Table'),
                                content: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: _buildTable(
                                    effectiveHeaders,
                                    rows,
                                    responsive,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Close'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: const Text('Show more'),
                        ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildTable(List<String> headers, List<List<String>> rows, bool compact) {
    if (compact) {
      return Column(
        children: rows.map((row) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  for (var i = 0; i < row.length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              i < headers.length ? headers[i] : 'Col ${i + 1}',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          Expanded(child: Text(row[i])),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              columns: [
                for (final h in headers) DataColumn(label: Text(h)),
                if (headers.isEmpty) const DataColumn(label: Text('Value')),
              ],
              rows: [
                for (final row in rows)
                  DataRow(
                    cells: [
                      for (var i = 0;
                          i < (headers.isEmpty ? row.length : headers.length);
                          i++)
                        DataCell(Text(i < row.length ? row[i] : '')),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class MiniTableTemplate extends StatelessWidget {
  const MiniTableTemplate({
    super.key,
    required this.template,
    required this.theme,
  });

  final TemplatePayload template;
  final BotChatTheme theme;

  @override
  Widget build(BuildContext context) {
    final cells = template.elements;
    return templateShell(
      theme: theme,
      text: template.text,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            // Leave a slice of the viewport for the next card to peek.
            const gap = 10.0;
            final available = constraints.maxWidth - gap;
            final cardWidth = cells.length <= 1
                ? constraints.maxWidth
                : available * 0.9;
            final height = _estimateHeight(cells);

            return SizedBox(
              height: height,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                itemCount: cells.length,
                separatorBuilder: (_, __) => const SizedBox(width: gap),
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: cardWidth,
                    child: _MiniTableCell(
                      element: cells[index],
                      theme: theme,
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  double _estimateHeight(List<BotElement> cells) {
    var maxRows = 0;
    for (final el in cells) {
      final additional = el.raw['additional'];
      if (additional is List && additional.length > maxRows) {
        maxRows = additional.length;
      }
    }
    // Header + rows + card padding.
    return (48 + (maxRows.clamp(1, 8) * 36) + 24).toDouble();
  }
}

class _MiniTableCell extends StatelessWidget {
  const _MiniTableCell({
    required this.element,
    required this.theme,
  });

  final BotElement element;
  final BotChatTheme theme;

  @override
  Widget build(BuildContext context) {
    final primary = element.raw['primary'];
    final additional = element.raw['additional'];
    final headers = <String>[];
    if (primary is List) {
      for (final p in primary) {
        if (p is List && p.isNotEmpty) {
          headers.add(displayCell(p.first));
        } else {
          headers.add(displayCell(p));
        }
      }
    }
    final rows = <List<String>>[];
    if (additional is List) {
      for (final r in additional) {
        if (r is List) {
          rows.add(r.map(displayCell).toList());
        }
      }
    }

    return templateCard(
      padding: const EdgeInsets.all(8),
      child: SingleChildScrollView(
        child: DataTable(
          columnSpacing: 16,
          horizontalMargin: 8,
          headingRowHeight: 36,
          dataRowMinHeight: 32,
          dataRowMaxHeight: 40,
          columns: [
            for (final h in headers)
              DataColumn(
                label: Text(h, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            if (headers.isEmpty) const DataColumn(label: Text('Data')),
          ],
          rows: [
            for (final row in rows)
              DataRow(
                cells: [
                  for (var i = 0;
                      i < (headers.isEmpty ? row.length : headers.length);
                      i++)
                    DataCell(
                      Text(
                        i < row.length ? row[i] : '',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class TableListTemplate extends StatelessWidget {
  const TableListTemplate({
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
      children: [
        templateCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: template.elements.map((section) {
              final header = section.raw['sectionHeader']?.toString() ?? section.title ?? '';
              final desc = section.raw['sectionHeaderDesc']?.toString() ?? '';
              final rowItems = section.raw['rowItems'];
              final rows = <Widget>[];
              if (header.isNotEmpty) {
                rows.add(Text(header, style: const TextStyle(fontWeight: FontWeight.w700)));
              }
              if (desc.isNotEmpty) {
                rows.add(Text(desc, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)));
              }
              if (rowItems is List) {
                for (final item in rowItems) {
                  if (item is! Map) continue;
                  final map = Map<String, dynamic>.from(item);
                  final titleMap = map['title'];
                  final valueMap = map['value'];
                  String left = '';
                  String right = '';
                  if (titleMap is Map) {
                    final text = titleMap['text'];
                    if (text is Map) {
                      left = text['title']?.toString() ?? '';
                      if (text['subtitle'] != null) {
                        left = '$left\n${text['subtitle']}';
                      }
                    } else {
                      left = titleMap['title']?.toString() ?? mapString(Map<String, dynamic>.from(titleMap), ['title', 'text']);
                    }
                  }
                  if (valueMap is Map) {
                    right = valueMap['text']?.toString() ?? valueMap['title']?.toString() ?? '';
                  }
                  final action = map['default_action'];
                  rows.add(
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(left),
                      trailing: Text(right, style: TextStyle(color: theme.buttonColor)),
                      onTap: action is Map
                          ? () => handleTemplateButton(
                                BotButton.fromJson(Map<String, dynamic>.from(action)),
                                onButton,
                              )
                          : null,
                    ),
                  );
                }
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
