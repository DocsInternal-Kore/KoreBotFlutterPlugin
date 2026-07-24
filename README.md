# Kore Bot Flutter SDK (Pure Flutter)

Pure Flutter replacement for the native Android/iOS chat UI previously opened
through MethodChannel `kore.botsdk/chatbot` in **Flutter Public New**.

## Features

- Pure Flutter chat UI (Android + iOS)
- Classic Kore auth: STS → jwtgrant → RTM WebSocket
- Branding theme (`GET /api/websdkthemes/{botId}/activetheme`) → Flutter `ThemeData`
- Bot icon in header + message bubbles (`botIconUrl` / branding / message `icon`)
- Attachments: camera / gallery / documents → Kore file upload → WebSocket `fileId`
- Speech-to-text (device ASR, auto-send final result)
- Text-to-speech (device TTS speaker toggle)
- Full template set (buttons, lists, carousels, charts, tables, forms, …)


---

## Project layout

```
Flutter_Code_Bot_SDK/
├── kore_bot_sdk/     # Flutter package (UI + networking)
└── example/          # Demo host app (“Bot Connect”)
```

---

## Quick start

### 1. Add dependency

```yaml
dependencies:
  kore_bot_sdk:
    path: ../kore_bot_sdk
```

### 2. Open chat (replaces `platform.invokeMethod('getChatWindow', …)`)

```dart
import 'package:kore_bot_sdk/kore_bot_sdk.dart';

await KoreBotChat.open(
  context,
  botConfig: {
    'clientId': '<CLIENT_ID>',
    'clientSecret': '<CLIENT_SECRET>',
    'botId': '<BOT_ID>',
    'chatBotName': '<BOT_NAME>',
    'identity': '<USER_IDENTITY>',
    'jwt_server_url': '<JWT_SERVER_URL>',
    'server_url': 'https://platform.kore.ai',
    'callHistory': false,
  },
  onEvent: (code, message) {
    debugPrint('$code: $message');
  },
);
```

### 3. Run the example

```sh
cd example
# Edit lib/main.dart with your bot credentials
flutter pub get
flutter run
```

---

## Migration from Flutter Public New

| Before (native bridge) | After (pure Flutter) |
| --- | --- |
| `MethodChannel('kore.botsdk/chatbot')` | `KoreBotChat.open(...)` |
| `invokeMethod('getChatWindow', botConfig)` | same `botConfig` map |
| Android `NewBotChatActivity` | `BotChatScreen` |
| iOS `ChatMessagesViewController` | same Flutter UI |
| Native `Callbacks` | `onEvent` callback |

You can remove the `android/korebot`, `android/korebotsdklib`, and
`ios/BotSDK` modules from host apps once you switch to this package.

---

## Supported templates

Parity with Flutter Public New Android ViewHolders:

| Template | Status |
| --- | --- |
| text | Supported |
| button / buttonLinkTemplate | Supported |
| quick_replies / quick_replies_welcome | Supported |
| list / listView / listWidget / advancedListTemplate | Supported |
| carousel / carousel stacked | Supported |
| piechart / linechart / barchart | Supported |
| table / responsive table / mini_table / tableList | Supported |
| form_template | Supported |
| multi_select / advanced_multi_select | Supported |
| radioOptionTemplate / dropdown_template | Supported |
| feedbackTemplate / bankingFeedbackTemplate | Supported |
| cardTemplate / contactCardTemplate | Supported |
| image / audio / video / link / pdfdownload | Supported |
| clockTemplate | Supported |
| search (results) | Supported |
| beneficiaryTemplate | Supported |
| Notification (agent transfer) | Supported |

---

## Architecture

```
Host App
   │
   ▼
KoreBotChat.open / BotChatScreen
   │
   ▼
BotChatController
   ├── BotRestClient   (STS, jwtgrant, rtm/start, history)
   └── BotSocketClient (WebSocket messaging)
   │
   ▼
Kore Platform (HTTPS + WSS)
```

---

## License

See package LICENSE.
