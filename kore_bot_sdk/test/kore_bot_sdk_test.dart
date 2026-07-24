import 'package:flutter_test/flutter_test.dart';
import 'package:kore_bot_sdk/kore_bot_sdk.dart';
import 'package:kore_bot_sdk/src/ui/templates/kore_markdown.dart';

void main() {
  test('BotConfig.fromMap reads legacy plugin keys', () {
    final config = BotConfig.fromMap({
      'clientId': 'c',
      'clientSecret': 's',
      'botId': 'b',
      'chatBotName': 'Bot',
      'identity': 'user@test.com',
      'jwt_server_url': 'https://jwt.example/',
      'server_url': 'https://bots.example',
      'callHistory': true,
    });

    expect(config.clientId, 'c');
    expect(config.callHistory, isTrue);
    expect(config.botInfo['taskBotId'], 'b');
    expect(config.normalizedServerUrl, 'https://bots.example');
  });

  test('ChatMessage parses button template frame', () {
    final message = ChatMessage.fromBotFrame({
      'messageId': 'm1',
      'timestamp': 1710000000000,
      'message': [
        {
          'component': {
            'payload': {
              'type': 'template',
              'payload': {
                'template_type': 'button',
                'text': 'Choose one',
                'buttons': [
                  {'type': 'postback', 'title': 'Yes', 'payload': 'yes'},
                  {'type': 'postback', 'title': 'No', 'payload': 'no'},
                ],
              },
            },
          },
        },
      ],
    });

    expect(message.isBot, isTrue);
    expect(message.template?.isButton, isTrue);
    expect(message.template?.buttons.length, 2);
    expect(message.template?.text, 'Choose one');
  });

  test('TemplatePayload recognizes all major template types', () {
    const types = {
      'button': 'isButton',
      'buttonLinkTemplate': 'isButtonLink',
      'list': 'isList',
      'listView': 'isListView',
      'listWidget': 'isListWidget',
      'advancedListTemplate': 'isAdvancedList',
      'carousel': 'isCarousel',
      'piechart': 'isPieChart',
      'linechart': 'isLineChart',
      'barchart': 'isBarChart',
      'table': 'isTable',
      'mini_table': 'isMiniTable',
      'tableList': 'isTableList',
      'form_template': 'isForm',
      'multi_select': 'isMultiSelect',
      'advanced_multi_select': 'isAdvanceMultiSelect',
      'radioOptionTemplate': 'isRadioOptions',
      'dropdown_template': 'isDropdown',
      'feedbackTemplate': 'isFeedback',
      'bankingFeedbackTemplate': 'isBankingFeedback',
      'cardTemplate': 'isCard',
      'contactCardTemplate': 'isContactCard',
      'image': 'isMedia',
      'link': 'isLink',
      'pdfdownload': 'isPdf',
      'clockTemplate': 'isClock',
      'dateTemplate': 'isDatePicker',
      'daterange': 'isDateRange',
      'search': 'isResults',
      'beneficiaryTemplate': 'isBeneficiary',
      'Notification': 'isAgentTransfer',
      'SYSTEM': 'isSystem',
      'live_agent': 'isLiveAgent',
      'stacked': 'isCarouselStacked',
      'quick_replies': 'isQuickReplies',
    };

    for (final entry in types.entries) {
      final payload = TemplatePayload.fromJson({'template_type': entry.key});
      final flag = switch (entry.value) {
        'isButton' => payload.isButton,
        'isButtonLink' => payload.isButtonLink,
        'isList' => payload.isList,
        'isListView' => payload.isListView,
        'isListWidget' => payload.isListWidget,
        'isAdvancedList' => payload.isAdvancedList,
        'isCarousel' => payload.isCarousel,
        'isCarouselStacked' => payload.isCarouselStacked,
        'isPieChart' => payload.isPieChart,
        'isLineChart' => payload.isLineChart,
        'isBarChart' => payload.isBarChart,
        'isTable' => payload.isTable,
        'isMiniTable' => payload.isMiniTable,
        'isTableList' => payload.isTableList,
        'isForm' => payload.isForm,
        'isMultiSelect' => payload.isMultiSelect,
        'isAdvanceMultiSelect' => payload.isAdvanceMultiSelect,
        'isRadioOptions' => payload.isRadioOptions,
        'isDropdown' => payload.isDropdown,
        'isFeedback' => payload.isFeedback,
        'isBankingFeedback' => payload.isBankingFeedback,
        'isCard' => payload.isCard,
        'isContactCard' => payload.isContactCard,
        'isMedia' => payload.isMedia,
        'isLink' => payload.isLink,
        'isPdf' => payload.isPdf,
        'isClock' => payload.isClock,
        'isDatePicker' => payload.isDatePicker,
        'isDateRange' => payload.isDateRange,
        'isResults' => payload.isResults,
        'isBeneficiary' => payload.isBeneficiary,
        'isAgentTransfer' => payload.isAgentTransfer,
        'isSystem' => payload.isSystem,
        'isLiveAgent' => payload.isLiveAgent,
        'isQuickReplies' => payload.isQuickReplies,
        _ => false,
      };
      expect(flag, isTrue, reason: '${entry.key} should set ${entry.value}');
    }
  });

  test('ChatMessage parses image media component', () {
    final message = ChatMessage.fromBotFrame({
      'messageId': 'img1',
      'message': [
        {
          'component': {
            'type': 'image',
            'payload': {
              'type': 'image',
              'text': 'Photo',
              'url': 'https://example.com/a.png',
            },
          },
        },
      ],
    });
    expect(message.template?.isMedia, isTrue);
    expect(message.template?.url, 'https://example.com/a.png');
  });

  test('ChatMessage parses message+videoUrl as video attachment', () {
    final message = ChatMessage.fromBotFrame({
      'messageId': 'vid1',
      'message': [
        {
          'component': {
            'type': 'message',
            'payload': {
              'type': 'message',
              'text': '',
              'videoUrl': 'https://example.com/clip.mp4',
            },
          },
        },
      ],
    });
    expect(message.template?.isVideo, isTrue);
    expect(message.template?.url, 'https://example.com/clip.mp4');
  });

  test('ChatMessage parses link download attachment', () {
    final message = ChatMessage.fromBotFrame({
      'messageId': 'link1',
      'message': [
        {
          'component': {
            'type': 'link',
            'payload': {
              'url': 'https://example.com/file.pdf',
              'fileName': 'report.pdf',
            },
          },
        },
      ],
    });
    expect(message.template?.isLink, isTrue);
    expect(message.template?.raw['fileName'], 'report.pdf');
  });

  test('ChatMessage parses dateTemplate', () {
    final message = ChatMessage.fromBotFrame({
      'messageId': 'date1',
      'message': [
        {
          'component': {
            'type': 'template',
            'payload': {
              'type': 'template',
              'payload': {
                'template_type': 'dateTemplate',
                'title': 'Pick a day',
                'format': 'MM-DD-YYYY',
              },
            },
          },
        },
      ],
    });
    expect(message.template?.isDatePicker, isTrue);
  });

  test('ChatMessage parses nested template message videoUrl payload', () {
    final message = ChatMessage.fromBotFrame({
      'messageId': 'ms-4df9116f-3d04-5deb-b33d-ed0ef278816f',
      'timestamp': 1784792674588,
      'message': [
        {
          'type': 'text',
          'component': {
            'type': 'template',
            'payload': {
              'type': 'message',
              'payload': {
                'color': '#009dab',
                'text': 'My video',
                'videoUrl': 'https://www.w3schools.com/tags/mov_bbb.mp4',
              },
            },
          },
        },
      ],
    });

    expect(message.template?.isVideo, isTrue);
    expect(message.template?.text, 'My video');
    expect(
      message.template?.url,
      'https://www.w3schools.com/tags/mov_bbb.mp4',
    );
    expect(message.template?.raw['color'], '#009dab');
  });

  test('ChatMessage parses nested template message audioUrl payload', () {
    final message = ChatMessage.fromBotFrame({
      'messageId': 'ms-3b10e2d6-0bdd-5350-b3da-5a7f9f117e37',
      'timestamp': 1784792674588,
      'message': [
        {
          'type': 'text',
          'component': {
            'type': 'template',
            'payload': {
              'type': 'message',
              'payload': {
                'text': 'My Audio',
                'audioUrl': 'https://www.w3schools.com/html/horse.mp3',
              },
            },
          },
        },
      ],
    });

    expect(message.template?.isAudio, isTrue);
    expect(message.template?.text, 'My Audio');
    expect(
      message.template?.url,
      'https://www.w3schools.com/html/horse.mp3',
    );
  });

  test('ChatMessage parses SYSTEM template as centered system message', () {
    final message = ChatMessage.fromBotFrame({
      'messageId': 'sys1',
      'message': [
        {
          'type': 'text',
          'component': {
            'type': 'template',
            'payload': {
              'type': 'template',
              'payload': {
                'template_type': 'SYSTEM',
                'text': 'John Doe has joined the chat',
              },
            },
          },
        },
      ],
    });

    expect(message.author, MessageAuthor.system);
    expect(message.template?.isSystem, isTrue);
    expect(message.text, 'John Doe has joined the chat');
  });

  test('ChatMessage parses live_agent template as agent text', () {
    final message = ChatMessage.fromBotFrame({
      'messageId': 'agent1',
      'message': [
        {
          'type': 'text',
          'component': {
            'type': 'template',
            'payload': {
              'type': 'template',
              'payload': {
                'template_type': 'live_agent',
                'text': 'How can I help you today?',
              },
            },
          },
        },
      ],
    });

    expect(message.author, MessageAuthor.bot);
    expect(message.fromAgent, isTrue);
    expect(message.template?.isLiveAgent, isTrue);
    expect(message.text, 'How can I help you today?');
  });

  test('ChatMessage parses Notification agent transfer card', () {
    final message = ChatMessage.fromBotFrame({
      'messageId': 'notif1',
      'message': [
        {
          'type': 'text',
          'component': {
            'type': 'template',
            'payload': {
              'type': 'template',
              'payload': {
                'template_type': 'Notification',
                'text': 'I am here to answer your questions',
                'title': 'Kevin Peterson',
                'subtitle': 'Support Agent',
                'image_url': 'https://example.com/agent.png',
              },
            },
          },
        },
      ],
    });

    expect(message.template?.isAgentTransfer, isTrue);
    expect(message.template?.title, 'Kevin Peterson');
    expect(message.template?.subtitle, 'Support Agent');
    expect(message.template?.raw['image_url'], 'https://example.com/agent.png');
  });

  test('ChatMessage parses form_template with formFields', () {
    final message = ChatMessage.fromBotFrame({
      'messageId': 'form1',
      'message': [
        {
          'component': {
            'type': 'template',
            'payload': {
              'type': 'template',
              'payload': {
                'template_type': 'form_template',
                'heading': 'Login',
                'formFields': [
                  {
                    'label': 'Username',
                    'type': 'text',
                    'placeholder': 'Enter name',
                  },
                  {
                    'label': 'Password',
                    'type': 'password',
                    'fieldButton': {'title': 'Sign in'},
                  },
                ],
              },
            },
          },
        },
      ],
    });

    expect(message.template?.isForm, isTrue);
    expect(message.template?.heading, 'Login');
    expect(message.template?.elements.length, 2);
    expect(message.template?.elements.first.title, 'Username');
  });

  test('ChatMessage parses dropdown_template', () {
    final message = ChatMessage.fromBotFrame({
      'messageId': 'dd1',
      'message': [
        {
          'component': {
            'type': 'template',
            'payload': {
              'type': 'template',
              'payload': {
                'template_type': 'dropdown_template',
                'heading': 'Pick one',
                'label': 'City',
                'placeholder': 'Select',
                'elements': [
                  {'title': 'Hyderabad', 'value': 'hyd'},
                  {'title': 'Chennai', 'value': 'maa'},
                ],
              },
            },
          },
        },
      ],
    });

    expect(message.template?.isDropdown, isTrue);
    expect(message.template?.elements.length, 2);
    expect(message.template?.label, 'City');
  });

  test('ChatMessage parses radioOptionTemplate', () {
    final message = ChatMessage.fromBotFrame({
      'messageId': 'radio1',
      'message': [
        {
          'component': {
            'type': 'template',
            'payload': {
              'type': 'template',
              'payload': {
                'template_type': 'radioOptionTemplate',
                'heading': 'Choose plan',
                'radioOptions': [
                  {
                    'title': 'Basic',
                    'value': 'basic',
                    'postback': {'title': 'Basic plan', 'value': 'basic_pb'},
                  },
                ],
              },
            },
          },
        },
      ],
    });

    expect(message.template?.isRadioOptions, isTrue);
    expect(message.template?.radioOptions.length, 1);
  });

  test('ChatMessage parses advanced_multi_select', () {
    final message = ChatMessage.fromBotFrame({
      'messageId': 'ams1',
      'message': [
        {
          'component': {
            'type': 'template',
            'payload': {
              'type': 'template',
              'payload': {
                'template_type': 'advanced_multi_select',
                'heading': 'Select items',
                'limit': 1,
                'elements': [
                  {
                    'collectionTitle': 'Fruits',
                    'collection': [
                      {'title': 'Apple', 'value': 'apple'},
                      {'title': 'Mango', 'value': 'mango'},
                    ],
                  },
                ],
                'buttons': [
                  {'title': 'Done', 'type': 'postback'},
                ],
              },
            },
          },
        },
      ],
    });

    expect(message.template?.isAdvanceMultiSelect, isTrue);
    expect(message.template?.elements.length, 1);
    expect(message.template?.raw['limit'], 1);
  });

  test('ChatMessage parses buttonLinkTemplate from elements', () {
    final message = ChatMessage.fromBotFrame({
      'messageId': 'bl1',
      'message': [
        {
          'component': {
            'type': 'template',
            'payload': {
              'type': 'template',
              'payload': {
                'template_type': 'buttonLinkTemplate',
                'text': 'Useful links',
                'elements': [
                  {
                    'title': 'Open site',
                    'type': 'web_url',
                    'url': 'https://example.com',
                  },
                  {'title': 'Continue', 'type': 'postback', 'value': 'go'},
                ],
              },
            },
          },
        },
      ],
    });

    expect(message.template?.isButtonLink, isTrue);
    expect(message.template?.buttons.length, 2);
    expect(message.template?.buttons.first.isUrl, isTrue);
  });

  test('ChatMessage parses stacked carousel template_type', () {
    final message = ChatMessage.fromBotFrame({
      'messageId': 'stack1',
      'message': [
        {
          'component': {
            'type': 'template',
            'payload': {
              'type': 'template',
              'payload': {
                'template_type': 'stacked',
                'text': 'Offers',
                'elements': [
                  {
                    'topSection': {
                      'title': 'Card 1',
                      'image_url': 'https://example.com/a.png',
                    },
                    'middleSection': {'description': 'Details'},
                    'bottomSection': {'title': 'Footer'},
                    'buttons': [
                      {
                        'title': 'Select',
                        'type': 'postback',
                        'payload': 'card1',
                      },
                    ],
                  },
                ],
              },
            },
          },
        },
      ],
    });

    expect(message.template?.isCarouselStacked, isTrue);
    expect(message.template?.elements.length, 1);
  });

  test('ChatMessage parses carousel with carousel_type stacked', () {
    final message = ChatMessage.fromBotFrame({
      'messageId': 'stack2',
      'message': [
        {
          'component': {
            'type': 'template',
            'payload': {
              'type': 'template',
              'payload': {
                'template_type': 'carousel',
                'carousel_type': 'stacked',
                'elements': [
                  {
                    'topSection': {'title': 'A'},
                    'middleSection': {'descrip': 'B'},
                  },
                ],
              },
            },
          },
        },
      ],
    });

    expect(message.template?.isCarouselStacked, isTrue);
  });

  test('ChatMessage parses nested type=text payload with markdown body', () {
    final message = ChatMessage.fromBotFrame({
      'type': 'bot_response',
      'from': 'bot',
      'messageId': 'ms-b91e58ab-abe7-5131-ae42-136359245d40',
      'message': [
        {
          'type': 'text',
          'component': {
            'type': 'template',
            'payload': {
              'type': 'text',
              'payload': {
                'text':
                    '<p>p tag example</p>. \n Here is an example of *bold text* and valid *bold text* \n*bold text* example. \n Here is an example of ~italic text~. \n#h2Heading2 is an example of  Heading2. \n * This is an example of an unordered list Bullet 1. \n Here is an example of ```preformatting```',
              },
            },
          },
        },
      ],
    });

    expect(message.text, contains('p tag example'));
    expect(message.template?.isText, isTrue);
    expect(message.template?.text, contains('*bold text*'));
  });

  test('normalizeKoreMarkdown converts Kore dialect markers', () {
    const raw =
        '<p>p tag example</p>. \n*bold text*\n~italic text~\n#h2Heading2 here\n```preformatting```';
    final out = normalizeKoreMarkdown(raw);
    expect(out, contains('p tag example'));
    expect(out, isNot(contains('<p>')));
    expect(out, contains('_italic text_'));
    expect(out, contains('## Heading2'));
    expect(out, contains('`preformatting`'));
    expect(out, isNot(contains('```')));
  });
}
