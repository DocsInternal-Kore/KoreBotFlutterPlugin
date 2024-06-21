import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  static const platform = MethodChannel('kore.botsdk/chatbot');
  final myController = TextEditingController();

  var botConfig = {
    "clientId": "cs-47e5f4e6-0621-563d-a3fb-2d1f3ab94750",
    "clientSecret": "TvctzsjB/iewjdddKi2Ber4PPrYr0LoTi1WUasiMceM=",
    "botId": "st-953e931b-1fe5-5bcc-9bb7-1b9bd4226947",
    "chatBotName": "SDKBot",
    "identity": "example@kore.com",
    "jwt_server_url":
        "https://mk2r2rmj21.execute-api.us-east-1.amazonaws.com/dev/",
    "server_url": "https://platform.kore.ai",
    "callHistory": false
  };

  Future<void> _callNativemethod() async {
    platform.setMethodCallHandler((handler) async {
      if (handler.method == 'Callbacks') {
        // Do your logic here.
        debugPrint("Event from native ${handler.arguments}");
      }
    });

    try {
      final String config =
          await platform.invokeMethod('getChatWindow', botConfig);
    } on PlatformException catch (e) {}
  }

  Future<void> botInitialize() async {
    platform.setMethodCallHandler((handler) async {
      if (handler.method == 'Callbacks') {
        // Do your logic here.
        debugPrint("Event from native ${handler.arguments}");
      }
    });

    try {
      final String config =
          await platform.invokeMethod('initialize', botConfig);
    } on PlatformException catch (e) {}
  }

  Future<void> getSearchResults(searchQuery) async {
    platform.setMethodCallHandler((handler) async {
      if (handler.method == 'Callbacks') {
        // Do your logic here.
        debugPrint("Event from native ${handler.arguments}");
      }
    });

    try {
      final String config = await platform
          .invokeMethod('getSearchResults', {"searchQuery": searchQuery});
    } on PlatformException catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    botInitialize();

    return Material(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              child: ElevatedButton(
                onPressed: _callNativemethod,
                child: const Text('Bot Connect'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextFormField(
                controller: myController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Enter your message',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: ElevatedButton(
                  onPressed: () => {getSearchResults(myController.text)},
                  child: const Text('Search Query')),
            ),
          ],
        ),
      ),
    );
  }
}
