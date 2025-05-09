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

<img width="1440" alt="Screenshot 2025-04-17 at 4 34 54 PM" src="https://github.com/user-attachments/assets/51a36b8c-84c8-48d2-a11f-d0d4553ae441" />

``` 
 //Callbacks from chatbotVC
NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "CallbacksNotification"), object: nil)
        
NotificationCenter.default.addObserver(self, selector: #selector(self.callbacksMethod), name: NSNotification.Name(rawValue: "CallbacksNotification"), object: nil)
        
let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        flutterMethodChannel = FlutterMethodChannel(name: "kore.botsdk/chatbot",
                                                    binaryMessenger: controller.binaryMessenger)
        flutterMethodChannel?.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            // This method is invoked on the UI thread.
            self.koreBotConnect.connect(methodName: call.method, callArguments: (call.arguments as? [String: Any]) ?? [:])
        })
```
```
@objc func callbacksMethod(notification:Notification) {
        let dataString: String = notification.object as! String
        if let eventDic = Utilities.jsonObjectFromString(jsonString: dataString){
            if flutterMethodChannel != nil{
                flutterMethodChannel?.invokeMethod("Callbacks", arguments: eventDic)
            }
        }
    }
```
