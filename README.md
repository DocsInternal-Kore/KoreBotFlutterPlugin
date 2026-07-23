# Kore Bot Flutter Plugin Integration

This plugin opens the Kore bot chat window from a Flutter app through the
method channel `kore.botsdk/chatbot`.

## 1. Add The Plugin

Add the plugin to your Flutter app `pubspec.yaml`.

```yaml
dependencies:
  flutter:
    sdk: flutter

  korebotplugin:
    path: ../KoreBotFlutterPlugin
```

Then run:

```sh
flutter pub get
```

## 2. Create The Bot Config

Create the method channel and pass the bot configuration when opening the chat
window. Do not call `getChatWindow` without config on the first launch.

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BotLauncher {
  static const platform = MethodChannel('kore.botsdk/chatbot');

  static final Map<String, dynamic> botConfig = {
    'clientId': '<CLIENT_ID>',
    'clientSecret': '<CLIENT_SECRET>',
    'botId': '<BOT_ID>',
    'chatBotName': '<BOT_NAME>',
    'identity': '<USER_IDENTITY>',
    'jwt_server_url': '<JWT_SERVER_URL>',
    'server_url': 'https://platform.kore.ai',
    'preferredLanguage': 'en',
    'callHistory': false,
  };

  static Future<void> openBot() async {
    platform.setMethodCallHandler((handler) async {
      if (handler.method == 'Callbacks') {
        debugPrint('Event from native ${handler.arguments}');
      }
    });

    try {
      await platform.invokeMethod('getChatWindow', botConfig);
    } on PlatformException catch (error) {
      debugPrint('Unable to open bot: $error');
    }
  }
}
```

Call it from any Flutter action:

```dart
ElevatedButton(
  onPressed: BotLauncher.openBot,
  child: const Text('Bot Connect'),
)
```

## 3. Supported Config Keys

Required keys:

| Key | Description |
| --- | --- |
| `clientId` | Kore SDK client id. |
| `clientSecret` | Kore SDK client secret. |
| `botId` | Bot id from Kore Bot Builder. |
| `chatBotName` | Fallback bot title until branding is loaded. |
| `identity` | Unique user identity. |
| `jwt_server_url` | Complete STS/JWT endpoint used as-is by the SDK (for example, `https://example.com/dev/users/sts`). |
| `server_url` | Kore platform server URL. |

Optional keys:

| Key | Description |
| --- | --- |
| `callHistory` | Enables or disables initial history loading. |
| `preferredLanguage` / `preferred_language` | Interactive language tag, such as `en` or `ar`. Defaults to `en`; RTL layout is enabled for RTL languages. A response payload `lang` value overrides the layout direction for that response. |
| `customData` | Map sent with bot messages. |
| `queryParams` | Android query parameters map. |
| `queryParameters` | iOS query parameters array. |
| `jwtToken` | Android custom JWT token. |
| `customJWToken` | iOS custom JWT token. |
| `branding_url` / `brandingUrl` | Android branding endpoint override. |
| `isAnonymous` | iOS anonymous-user flag. |
| `isWebhookEnabled` | iOS webhook flag. |
| `isWebHook` / `is_webhook` | Android webhook flag. |
| `showAttachment` | Android attachment visibility override. |
| `showMicrophone` / `showASRMicroPhone` | Android microphone visibility override. |
| `showHamburgerMenu` | Android hamburger menu visibility override. |
| `showTextToSpeech` | Android text-to-speech visibility override. |
| `showHeader` | Android header visibility override. |
| `showActionBar` | Android action bar visibility override. |
| `footerHintText` | Android footer placeholder override. |
| `botIconUrl` | Android bot icon override. |
| `agentIconUrl` | Android agent icon override. |

The most common integration should pass only the required keys and
`callHistory`.

## 4. Native Methods

| Method | Arguments | Notes |
| --- | --- | --- |
| `getChatWindow` | Bot config map | Configures the SDK and opens the chat window. |
| `initialize` | Bot config map | Initializes the SDK without opening chat. iOS can use this before search. |
| `getSearchResults` | `{ 'searchQuery': '<query>' }` | iOS returns search callbacks. Android currently returns a callback message that search callbacks are unavailable in the latest native SDK. |

## 5. Callbacks

Callbacks are delivered to Flutter through the same method channel with method
name `Callbacks`.

```dart
platform.setMethodCallHandler((handler) async {
  if (handler.method == 'Callbacks') {
    debugPrint('Event from native ${handler.arguments}');
  }
});
```

Common callback payloads:

```json
{"eventCode":"Error_STS","eventMessage":"STS call failed"}
```

```json
{"eventCode":"Error_Socket","eventMessage":"Socket connection failed"}
```

```json
{"eventCode":"BotConnected","eventMessage":"Bot connected successfully"}
```

```json
{"eventCode":"BotClosed","eventMessage":"Bot closed by the user"}
```

## 6. Android Setup

The Android SDK requires API 23 or later and Java 17 compatibility.

In `android/settings.gradle`, keep the plugin native modules included when using
this local plugin:

```gradle
include ':app'
include ':korebotplugin:korebot'
include ':korebotplugin:korebotsdklib'
```

In `android/app/build.gradle`, enable data binding and multidex:

```gradle
android {
    buildFeatures {
        dataBinding true
    }

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }

    defaultConfig {
        minSdkVersion 23
        multiDexEnabled true
    }

    packagingOptions {
        resources {
            excludes += [
                'META-INF/DEPENDENCIES',
                'META-INF/LICENSE',
                'META-INF/LICENSE.txt',
                'META-INF/license.txt',
                'META-INF/NOTICE',
                'META-INF/NOTICE.txt',
                'META-INF/notice.txt',
                'META-INF/ASL2.0',
                'META-INF/*.kotlin_module'
            ]
        }
    }
}
```

In `android/gradle.properties`, make sure AndroidX and Jetifier are enabled:

```properties
android.useAndroidX=true
android.enableJetifier=true
```

If the manifest merger reports label/icon/name conflicts, add the Android tools
namespace and replacement attributes to your app manifest:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">

    <application
        tools:replace="android:label, android:name, android:icon"
        tools:overrideLibrary="com.korebot.botkoresdk">
        ...
    </application>
</manifest>
```

The plugin contributes the required Android permissions and native chat
activities from its own manifest.

## 7. iOS Setup

Set the minimum iOS version to 13.0 or later.

Add the required usage descriptions to `ios/Runner/Info.plist` if your app uses
voice input, attachments, camera, or photo upload:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>Allow access to microphone.</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>Speech recognition is used to convert spoken input to text.</string>
<key>NSCameraUsageDescription</key>
<string>Allow access to camera.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Allow access to photo library.</string>
```

Register the method channel and callback bridge in `ios/Runner/AppDelegate.swift`:

```swift
import UIKit
import Flutter
import korebotplugin

@main
@objc class AppDelegate: FlutterAppDelegate {
    var flutterMethodChannel: FlutterMethodChannel?
    let koreBotConnect = KoreBotConnect()

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name(rawValue: "CallbacksNotification"),
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.callbacksMethod),
            name: NSNotification.Name(rawValue: "CallbacksNotification"),
            object: nil
        )

        let controller = window?.rootViewController as! FlutterViewController
        flutterMethodChannel = FlutterMethodChannel(
            name: "kore.botsdk/chatbot",
            binaryMessenger: controller.binaryMessenger
        )

        flutterMethodChannel?.setMethodCallHandler { call, result in
            self.koreBotConnect.connect(
                methodName: call.method,
                callArguments: (call.arguments as? [String: Any]) ?? [:]
            )
            result("OK")
        }

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    @objc func callbacksMethod(notification: Notification) {
        let dataString = notification.object as! String
        if let eventDic = Utilities.jsonObjectFromString(jsonString: dataString) {
            flutterMethodChannel?.invokeMethod("Callbacks", arguments: eventDic)
        }
    }
}
```

After changing iOS dependencies, run from the app `ios` folder:

```sh
pod install
```

## 8. Verify The Integration

From the Flutter app folder:

```sh
flutter pub get
flutter build apk --debug
flutter build ios --simulator
```

Use the example app in `example/` as the reference implementation for the
Flutter config map, Android manifest, Android Gradle setup, iOS `Info.plist`,
and iOS `AppDelegate.swift`.
