import 'package:flutter/material.dart';
import 'package:kore_bot_sdk/kore_bot_sdk.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kore Bot SDK Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3F51B5)),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  /// Same config keys as Flutter Public New MethodChannel `getChatWindow`.
  static final Map<String, dynamic> botConfig = {
    'clientId': 'cs-59c81eb8-fc6b-5413-9411-6249e2db25b2',
    'clientSecret': 'UuJ+N7EOFEPzlH+IlWWPHJPAQVZ06Smevy0kZTlRUIk=',
    'botId': 'st-c2a341ba-5612-5ab2-a5b3-d4a81f6a42ea',

    // 'clientId': 'cs-1e845b00-81ad-5757-a1e7-d0f6fea227e9',
    // 'clientSecret': '5OcBSQtH/k6Q/S6A3bseYfOee02YjjLLTNoT1qZDBso=',
    // 'botId': 'st-b9889c46-218c-58f7-838f-73ae9203488c',

    // 'clientId': 'cs-1b1ed162-2c62-543f-9bdd-d56cc7a89b4a', /all templates
    // 'clientSecret': 'd/DK0fQrA7Ab/6jGIgGB6sVZxjGWJKC17QNRmtFq0go=',
    // 'botId': 'st-0c3be6e0-3f7c-5134-97f9-2d14d7ca922c',

    // 'clientId': 'cs-8dbe60f4-bc93-5559-a617-2ef173d5e827',
    // 'clientSecret': '+gyZIjtPUyQukO4bkfooQ52c/HNSekY8iULhfcJy4kw=',
    // 'botId': 'st-6b9d6fb9-e7ea-571c-b2cd-a6184e10af2a',
    'chatBotName': 'SDK Demo',
    'identity': 'ka@ka.com',
    'jwt_server_url': 'https://mk2r2rmj21.execute-api.us-east-1.amazonaws.com/dev/',
    'server_url': 'https://platform.kore.ai',
    // Simulator / proxy TLS workaround for CERTIFICATE_VERIFY_FAILED.
    'allowBadCertificates': true,
    'callHistory': false,
    'showAttachment': true,
    'showMicrophone': true,
    'showTextToSpeech': true,
    'showIcon': true,
    // Optional: 'botIconUrl': 'https://...',
    // Optional: 'branding_url': 'https://platform.kore.ai',
  };

  Future<void> _openBot(BuildContext context) async {
    await KoreBotChat.open(
      context,
      botConfig: botConfig,
      onEvent: (code, message) {
        debugPrint('Bot event: $code — $message');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => _openBot(context),
          child: const Text('Bot Connect'),
        ),
      ),
    );
  }
}
