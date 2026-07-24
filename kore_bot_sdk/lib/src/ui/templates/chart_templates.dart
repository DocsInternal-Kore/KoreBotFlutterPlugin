import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../models/template_payload.dart';
import '../theme/bot_chat_theme.dart';
import 'template_helpers.dart';

const _palette = [
  Color(0xFF0076FF),
  Color(0xFF3F51B5),
  Color(0xFF26A69A),
  Color(0xFFFFA726),
  Color(0xFFEF5350),
  Color(0xFFAB47BC),
  Color(0xFF66BB6A),
  Color(0xFF5C6BC0),
];

class PieChartTemplate extends StatelessWidget {
  const PieChartTemplate({
    super.key,
    required this.template,
    required this.theme,
  });

  final TemplatePayload template;
  final BotChatTheme theme;

  @override
  Widget build(BuildContext context) {
    final sections = <PieChartSectionData>[];
    for (var i = 0; i < template.elements.length; i++) {
      final el = template.elements[i];
      sections.add(
        PieChartSectionData(
          value: el.numericValue == 0 && el.values.isNotEmpty
              ? el.values.first
              : el.numericValue,
          title: el.title ?? '',
          color: _palette[i % _palette.length],
          radius: template.pieType?.toLowerCase() == 'donut' ? 40 : 55,
          titleStyle: const TextStyle(fontSize: 10, color: Colors.white),
        ),
      );
    }

    return templateShell(
      theme: theme,
      text: template.text,
      children: [
        templateCard(
          child: Column(
            children: [
              SizedBox(
                height: 180,
                child: PieChart(
                  PieChartData(
                    sections: sections,
                    centerSpaceRadius:
                        template.pieType?.toLowerCase() == 'donut' ? 36 : 0,
                    sectionsSpace: 2,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ...List.generate(template.elements.length, (i) {
                final el = template.elements[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        color: _palette[i % _palette.length],
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(el.title ?? '')),
                      Text(el.displayValues.isNotEmpty
                          ? el.displayValues.first
                          : el.value ?? ''),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

class LineChartTemplate extends StatelessWidget {
  const LineChartTemplate({
    super.key,
    required this.template,
    required this.theme,
  });

  final TemplatePayload template;
  final BotChatTheme theme;

  @override
  Widget build(BuildContext context) {
    final lines = <LineChartBarData>[];
    for (var i = 0; i < template.elements.length; i++) {
      final el = template.elements[i];
      final spots = <FlSpot>[];
      for (var j = 0; j < el.values.length; j++) {
        spots.add(FlSpot(j.toDouble(), el.values[j]));
      }
      lines.add(
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: _palette[i % _palette.length],
          barWidth: 3,
          dotData: const FlDotData(show: true),
        ),
      );
    }

    return templateShell(
      theme: theme,
      text: template.text,
      children: [
        templateCard(
          child: SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                lineBarsData: lines,
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= template.xAxis.length) {
                          return const SizedBox.shrink();
                        }
                        return Text(template.xAxis[i], style: const TextStyle(fontSize: 10));
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: true),
              ),
            ),
          ),
        ),
        ...template.elements.asMap().entries.map((e) {
          return Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Container(width: 10, height: 10, color: _palette[e.key % _palette.length]),
                const SizedBox(width: 6),
                Text(e.value.title ?? 'Series ${e.key + 1}'),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class BarChartTemplate extends StatelessWidget {
  const BarChartTemplate({
    super.key,
    required this.template,
    required this.theme,
  });

  final TemplatePayload template;
  final BotChatTheme theme;

  @override
  Widget build(BuildContext context) {
    final groups = <BarChartGroupData>[];
    final maxLen = template.elements.isEmpty
        ? 0
        : template.elements.map((e) => e.values.length).reduce((a, b) => a > b ? a : b);

    for (var x = 0; x < maxLen; x++) {
      final rods = <BarChartRodData>[];
      for (var s = 0; s < template.elements.length; s++) {
        final values = template.elements[s].values;
        final y = x < values.length ? values[x] : 0.0;
        rods.add(
          BarChartRodData(
            toY: y,
            color: _palette[s % _palette.length],
            width: template.stacked ? 14 : 8,
          ),
        );
      }
      groups.add(BarChartGroupData(x: x, barRods: rods, barsSpace: 2));
    }

    return templateShell(
      theme: theme,
      text: template.text,
      children: [
        templateCard(
          child: SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                barGroups: groups,
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= template.xAxis.length) {
                          return const SizedBox.shrink();
                        }
                        return Text(template.xAxis[i], style: const TextStyle(fontSize: 10));
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: true),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
