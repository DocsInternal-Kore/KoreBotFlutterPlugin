import 'package:flutter/material.dart';
import 'package:kore_bot_sdk/kore_bot_sdk.dart';

// import 'custom_chat_footer.dart';
// import 'custom_chat_header.dart';
// import 'custom_templates.dart';

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
    'clientId': '<CLIENT_ID>',
    'clientSecret': '<CLIENT_SECRET>',
    'botId': '<BOT_ID>',
    'chatBotName': '<BOT_NAME>',
    'identity': '<USER_IDENTITY>',
    'jwt_server_url': '<JWT_SERVER_URL>',
    'server_url': 'https://platform.kore.ai',
    // Simulator / proxy TLS workaround for CERTIFICATE_VERIFY_FAILED.
    'allowBadCertificates': true,
    'callHistory': false,
    'showAttachment': true,
    'showMicrophone': true,
    'showTextToSpeech': true,
    'showIcon': true,
    // Passed on jwtgrant / rtm and every outbound message (message.customData + botInfo).
    //'customData': {'userId': 'ka@ka.com', 'firstName': 'Example', 'lastName': 'User', 'email': 'ka@ka.com'},
    // Optional: 'botIconUrl': 'https://...',
  };

  Future<void> _openBot(BuildContext context) async {
    await KoreBotChat.open(
      context,
      botConfig: botConfig,
      // Register family in example/pubspec.yaml first, then inject:
      // fonts: const BotChatFonts(
      //   family: '29LTBukra',
      //   // monospaceFamily: 'JetBrainsMono', // optional, for code blocks
      // ),
      // headerBuilder: buildCustomChatHeader(),
      // footerBuilder: buildCustomChatFooter(),
      // templateRegistry: buildCustomTemplateRegistry(),
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
