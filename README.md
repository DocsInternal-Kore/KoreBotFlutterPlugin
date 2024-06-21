# Flutter Plugin integration

Assuming flutter application is available

## Update pubspec file 

Add below snippet into flutter app pubspec.yaml “path” is where plugin is copied after that need to run “flutter pub get”
```
dependencies:
  flutter:
    sdk: flutter


  korebotplugin:
     # the parent directory to use the current plugin's version.
    path: ../ 
```
Create a “Method channel” with channel name as below
```
static const platform = MethodChannel('kore.botsdk/chatbot');
```
Create a method which invokes the chat window as below here the method name is
```
“_callNativemethod” can be changed as per requirement.
Future<void> _callNativemethod() async {
  platform.setMethodCallHandler((handler) async {
    if (handler.method == 'Callbacks') {
      // Do your logic here.
        debugPrint("Event from native ${handler.arguments}");
      }
    });
  try {
    final String result = await platform.invokeMethod('getChatWindow');
  } on PlatformException catch (e) {}
}

```
On button press the above mentioned method can be called to open the chat window as below
```
 children: [
          ElevatedButton(
            onPressed: _callNativemethod,
            child: const Text('Bot Connect'),
          ),
        ],
```

All the callbacks from native to the flutter application happens in the below snippet. Users can implement their own logics as per requirement.
```
platform.setMethodCallHandler((handler) async {
    if (handler.method == 'Callbacks') {
      // Do your logic here.
        debugPrint("Event from native ${handler.arguments}");
      }
    });

```
Callbacks received are in below json format which can be consumed by the clients and implemented as per requirement.

When fails in fetching jwt token
```
{"eventCode":"Error_STS","eventMessage":"STS call failed"}

```
When fails in Socket(Bot) Connection
```
{"eventCode":"Error_Socket","eventMessage":"Socket connection failed"}

```
When Bot connected successfully
```
{"eventCode":"BotConnected","eventMessage":"Bot connected successfully"}

```
When User clicks the back button on the chat window in IOS or hardware back button in android.
```
{"eventCode":"BotClosed","eventMessage":"Bot closed by the user"}
```
# For iOS:
Add below lines in AppDelegate.swift

<img width="597" alt="image" src="https://github.com/SudheerJa-Kore/KoreBotflutterplugin/assets/64408292/fb33b51c-1795-48af-933b-cae0bf0bbe69">

``` 
 //Callbacks from chatbotVC
  NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "CallbacksNotification"), object: nil)
  NotificationCenter.default.addObserver(self, selector: #selector(self.callbacksMethod), name: 
  NSNotification.Name(rawValue: "CallbacksNotification"), object: nil)
```
```
@objc func callbacksMethod(notification:Notification) {
        let dataString: String = notification.object as! String
                if let eventDic = convertStringToDictionary(text: dataString){
            if flutterMethodChannel != nil{
                flutterMethodChannel?.invokeMethod("Callbacks", arguments: eventDic)
            }
        }
    }
```
```
  func convertStringToDictionary(text: String) -> [String: Any]? {
      if let data = text.data(using: .utf8) {
          do {
              return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
          } catch {
              print(error.localizedDescription)
          }
      }
      return nil
  }
  ```
  <img width="607" alt="image" src="https://github.com/SudheerJa-Kore/KoreBotflutterplugin/assets/64408292/7a6b82c6-c0f3-4d1c-af1f-e7fbedbbb6d4">
