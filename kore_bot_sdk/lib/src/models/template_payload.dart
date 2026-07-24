import 'dart:convert';

/// Parsed rich template payload from classic Kore Bot messages.
class TemplatePayload {
  const TemplatePayload({
    required this.templateType,
    this.text,
    this.heading,
    this.title,
    this.subtitle,
    this.description,
    this.label,
    this.placeholder,
    this.url,
    this.view,
    this.tableDesign,
    this.carouselType,
    this.pieType,
    this.direction,
    this.stacked = false,
    this.sliderView = false,
    this.buttons = const [],
    this.elements = const [],
    this.quickReplies = const [],
    this.listItems = const [],
    this.cards = const [],
    this.radioOptions = const [],
    this.columns = const [],
    this.xAxis = const [],
    this.pdfItems = const [],
    this.beneficiaryItems = const [],
    this.raw = const {},
  });

  factory TemplatePayload.fromJson(Map<String, dynamic>? json, {String? fallbackType}) {
    if (json == null) {
      return TemplatePayload(templateType: fallbackType ?? 'text');
    }

    final type = ((json['template_type'] as String?) ?? fallbackType ?? 'text')
        .toLowerCase();

    final buttons = <BotButton>[];
    _readButtons(json['buttons'], buttons);
    // buttonLinkTemplate stores buttons in elements
    if (type == 'buttonlinktemplate') {
      _readButtons(json['elements'], buttons);
    }

    final elements = <BotElement>[];
    final rawElements = json['elements'] ?? json['formFields'];
    if (rawElements is List) {
      for (final item in rawElements) {
        if (item is Map) {
          elements.add(BotElement.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    final quickReplies = <BotButton>[];
    final rawQr = json['quick_replies'] ?? json['replies'];
    if (rawQr is List) {
      for (final item in rawQr) {
        if (item is Map) {
          quickReplies.add(BotButton.fromJson(Map<String, dynamic>.from(item)));
        } else if (item is String) {
          quickReplies.add(BotButton(title: item, payload: item, type: 'postback'));
        }
      }
    }

    final listItems = <Map<String, dynamic>>[];
    final rawListItems = json['listItems'];
    if (rawListItems is List) {
      for (final item in rawListItems) {
        if (item is Map) listItems.add(Map<String, dynamic>.from(item));
      }
    }

    final cards = <Map<String, dynamic>>[];
    final rawCards = json['cards'];
    if (rawCards is List) {
      for (final item in rawCards) {
        if (item is Map) cards.add(Map<String, dynamic>.from(item));
      }
    }

    final radioOptions = <Map<String, dynamic>>[];
    final rawRadios = json['radioOptions'];
    if (rawRadios is List) {
      for (final item in rawRadios) {
        if (item is Map) radioOptions.add(Map<String, dynamic>.from(item));
      }
    }

    final columns = <List<String>>[];
    final rawColumns = json['columns'];
    if (rawColumns is List) {
      for (final col in rawColumns) {
        if (col is List) {
          columns.add(col.map((e) {
            if (e == null) return '';
            final text = e.toString();
            return text.toLowerCase() == 'null' ? '' : text;
          }).toList());
        } else if (col is String) {
          columns.add([col.toLowerCase() == 'null' ? '' : col]);
        }
      }
    }

    final xAxis = <String>[];
    final rawX = json['X_axis'] ?? json['x_axis'];
    if (rawX is List) {
      for (final x in rawX) {
        xAxis.add(x.toString());
      }
    }

    final pdfItems = <Map<String, dynamic>>[];
    final rawPdf = json['pdfDownloadModels'] ?? json['pdfdownloadModels'];
    if (rawPdf is List) {
      for (final item in rawPdf) {
        if (item is Map) pdfItems.add(Map<String, dynamic>.from(item));
      }
    }

    final beneficiaryItems = <Map<String, dynamic>>[];
    final rawBen = json['botBeneficiaryModels'] ?? json['beneficiaryModels'];
    if (rawBen is List) {
      for (final item in rawBen) {
        if (item is Map) beneficiaryItems.add(Map<String, dynamic>.from(item));
      }
    }

    return TemplatePayload(
      templateType: type,
      text: json['text']?.toString(),
      heading: json['heading']?.toString(),
      title: json['title']?.toString(),
      subtitle: json['subtitle']?.toString(),
      description: json['description']?.toString(),
      label: json['label']?.toString(),
      placeholder: json['placeholder']?.toString(),
      url: json['url'] as String? ??
          json['videoUrl'] as String? ??
          json['audioUrl'] as String?,
      view: json['view'] as String?,
      tableDesign: json['table_design'] as String? ?? json['tableDesign'] as String?,
      carouselType: json['carousel_type'] as String?,
      pieType: json['pie_type'] as String?,
      direction: json['direction'] as String?,
      stacked: json['stacked'] == true,
      sliderView: json['sliderView'] == true,
      buttons: buttons,
      elements: elements,
      quickReplies: quickReplies,
      listItems: listItems,
      cards: cards,
      radioOptions: radioOptions,
      columns: columns,
      xAxis: xAxis,
      pdfItems: pdfItems,
      beneficiaryItems: beneficiaryItems,
      raw: json,
    );
  }

  static void _readButtons(dynamic raw, List<BotButton> out) {
    if (raw is! List) return;
    for (final item in raw) {
      if (item is Map) {
        out.add(BotButton.fromJson(Map<String, dynamic>.from(item)));
      }
    }
  }

  final String templateType;
  final String? text;
  final String? heading;
  final String? title;
  final String? subtitle;
  final String? description;
  final String? label;
  final String? placeholder;
  final String? url;
  final String? view;
  final String? tableDesign;
  final String? carouselType;
  final String? pieType;
  final String? direction;
  final bool stacked;
  final bool sliderView;
  final List<BotButton> buttons;
  final List<BotElement> elements;
  final List<BotButton> quickReplies;
  final List<Map<String, dynamic>> listItems;
  final List<Map<String, dynamic>> cards;
  final List<Map<String, dynamic>> radioOptions;
  final List<List<String>> columns;
  final List<String> xAxis;
  final List<Map<String, dynamic>> pdfItems;
  final List<Map<String, dynamic>> beneficiaryItems;
  final Map<String, dynamic> raw;

  bool get isButton => templateType == 'button';
  bool get isButtonLink => templateType == 'buttonlinktemplate';
  bool get isList => templateType == 'list';
  bool get isListView => templateType == 'listview';
  bool get isListWidget =>
      templateType == 'listwidget' || templateType == 'list_widget';
  bool get isAdvancedList => templateType == 'advancedlisttemplate';
  bool get isCarousel =>
      templateType == 'carousel' ||
      templateType == 'carouseladv' ||
      templateType == 'kora_carousel' ||
      templateType == 'kora_welcome_carousel' ||
      templateType == 'stacked';
  bool get isCarouselStacked =>
      templateType == 'stacked' ||
      (carouselType?.toLowerCase() == 'stacked');
  bool get isQuickReplies =>
      templateType == 'quick_replies' || templateType == 'quick_replies_welcome';
  bool get isPieChart => templateType == 'piechart';
  bool get isLineChart => templateType == 'linechart';
  bool get isBarChart => templateType == 'barchart';
  bool get isTable => templateType == 'table' || templateType == 'custom_table';
  bool get isTableResponsive =>
      isTable && (tableDesign?.toLowerCase() == 'responsive');
  bool get isMiniTable => templateType == 'mini_table';
  bool get isTableList => templateType == 'tablelist';
  bool get isForm => templateType == 'form_template';
  bool get isMultiSelect => templateType == 'multi_select';
  bool get isAdvanceMultiSelect => templateType == 'advanced_multi_select';
  bool get isRadioOptions => templateType == 'radiooptiontemplate';
  bool get isDropdown => templateType == 'dropdown_template';
  bool get isFeedback => templateType == 'feedbacktemplate';
  bool get isBankingFeedback => templateType == 'bankingfeedbacktemplate';
  bool get isCard => templateType == 'cardtemplate';
  bool get isContactCard => templateType == 'contactcardtemplate';
  bool get isMedia =>
      templateType == 'image' ||
      templateType == 'audio' ||
      templateType == 'video';
  bool get isImage => templateType == 'image';
  bool get isAudio => templateType == 'audio';
  bool get isVideo => templateType == 'video';
  bool get isLink => templateType == 'link';
  bool get isPdf => templateType == 'pdfdownload';
  bool get isClock => templateType == 'clocktemplate';
  bool get isDatePicker =>
      templateType == 'datetemplate' || templateType == 'daterange';
  bool get isDateRange => templateType == 'daterange';
  bool get isResults => templateType == 'search';
  bool get isBeneficiary => templateType == 'beneficiarytemplate';
  bool get isAgentTransfer =>
      templateType == 'notification' || templateType == 'agent_transfer';
  /// Centered system notice (agent joined / left, etc.).
  bool get isSystem => templateType == 'system';
  /// Live-agent chat text (rendered as a normal bot/agent bubble).
  bool get isLiveAgent => templateType == 'live_agent';
  bool get isText =>
      templateType == 'text' ||
      templateType.isEmpty ||
      isSystem ||
      isLiveAgent;
}

class BotButton {
  const BotButton({
    required this.title,
    this.type = 'postback',
    this.payload,
    this.url,
    this.imageUrl,
  });

  factory BotButton.fromJson(Map<String, dynamic> json) {
    return BotButton(
      title: json['title'] as String? ?? json['name'] as String? ?? '',
      type: json['type'] as String? ??
          json['elementType'] as String? ??
          'postback',
      payload: json['payload']?.toString() ?? json['value']?.toString(),
      url: json['url'] as String? ?? json['elementUrl'] as String?,
      imageUrl: json['image_url'] as String?,
    );
  }

  final String title;
  final String type;
  final String? payload;
  final String? url;
  final String? imageUrl;

  String get actionValue => payload ?? url ?? title;

  bool get isUrl =>
      type.toLowerCase() == 'url' || type.toLowerCase() == 'web_url';
}

class BotElement {
  const BotElement({
    this.title,
    this.subtitle,
    this.imageUrl,
    this.text,
    this.value,
    this.color,
    this.values = const [],
    this.displayValues = const [],
    this.tableValues = const [],
    this.buttons = const [],
    this.defaultAction,
    this.raw = const {},
  });

  factory BotElement.fromJson(Map<String, dynamic> json) {
    final buttons = <BotButton>[];
    final rawButtons = json['buttons'];
    if (rawButtons is List) {
      for (final item in rawButtons) {
        if (item is Map) {
          buttons.add(BotButton.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    BotButton? defaultAction;
    final rawAction = json['default_action'] ?? json['defaultAction'];
    if (rawAction is Map) {
      defaultAction = BotButton.fromJson(Map<String, dynamic>.from(rawAction));
    }

    final values = <double>[];
    final rawValues = json['values'];
    if (rawValues is List) {
      for (final v in rawValues) {
        if (v is num) {
          values.add(v.toDouble());
        } else {
          values.add(double.tryParse(v.toString()) ?? 0);
        }
      }
    }

    final displayValues = <String>[];
    final rawDisplay = json['displayValues'];
    if (rawDisplay is List) {
      for (final v in rawDisplay) {
        displayValues.add(v.toString());
      }
    }

    final tableValues = <String>[];
    final rawTable = json['Values'] ?? json['values'];
    if (rawTable is List) {
      for (final v in rawTable) {
        if (v == null) {
          tableValues.add('');
          continue;
        }
        final text = v.toString();
        tableValues.add(text.toLowerCase() == 'null' ? '' : text);
      }
    }

    // Chart single value
    final chartValue = json['value'];
    double? singleValue;
    if (chartValue is num) {
      singleValue = chartValue.toDouble();
    } else if (chartValue != null) {
      singleValue = double.tryParse(chartValue.toString());
    }

    return BotElement(
      title: json['title'] as String? ??
          json['name'] as String? ??
          json['label'] as String?,
      subtitle: json['subtitle'] as String?,
      imageUrl: json['image_url'] as String? ??
          json['image_url_src'] as String? ??
          json['icon'] as String?,
      text: json['text'] as String? ?? json['description'] as String?,
      value: singleValue?.toString() ?? json['value']?.toString(),
      color: json['color'] as String?,
      values: values,
      displayValues: displayValues,
      tableValues: tableValues,
      buttons: buttons,
      defaultAction: defaultAction,
      raw: json,
    );
  }

  final String? title;
  final String? subtitle;
  final String? imageUrl;
  final String? text;
  final String? value;
  final String? color;
  final List<double> values;
  final List<String> displayValues;
  final List<String> tableValues;
  final List<BotButton> buttons;
  final BotButton? defaultAction;
  final Map<String, dynamic> raw;

  double get numericValue => double.tryParse(value ?? '') ?? 0;
}

/// Unescapes Kore nested JSON that arrives as HTML-escaped text.
Map<String, dynamic>? tryParseEscapedJson(String? text) {
  if (text == null || text.isEmpty) return null;
  if (!text.contains('{') && !text.contains('&quot')) return null;
  try {
    final cleaned = text
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');
    final decoded = jsonDecode(cleaned);
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
  } catch (_) {}
  return null;
}
