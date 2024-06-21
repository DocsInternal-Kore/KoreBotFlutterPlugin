import UIKit
import Flutter
import korebotplugin

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    let botConnect = BotConnect()
    var flutterMethodChannel: FlutterMethodChannel? = nil
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        flutterMethodChannel = FlutterMethodChannel(name: "kore.botsdk/chatbot",
                                                    binaryMessenger: controller.binaryMessenger)
        flutterMethodChannel?.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            // This method is invoked on the UI thread.
            
            if call.method == "getChatWindow"{
                guard let botConfig = call.arguments else {
                return
                }
                let configDetails = botConfig as? [String: Any]
                guard let clientId = configDetails?["clientId"] as? String else{
                   return
                }
                guard let clientSecret = configDetails?["clientSecret"] as? String else{
                   return
                }
                guard let botId = configDetails?["botId"] as? String else{
                   return
                }
                guard let chatBotName = configDetails?["chatBotName"] as? String else{
                   return
                }
                guard let identity = configDetails?["identity"] as? String else{
                   return
                }
                guard let jwtServerUrl = configDetails?["jwt_server_url"] as? String else{
                    return
                 }
                guard let botServerUrl = configDetails?["server_url"] as? String else{
                    return
                 }
                guard let isCallHistory = configDetails?["callHistory"] as? Bool else{
                    return
                 }
                //Set Korebot Config
                self.setBotConfig(clientId: clientId, clientSecret: clientSecret, botId: botId, chatBotName: chatBotName, identity: identity, JWT_SERVER: jwtServerUrl, BOT_SERVER: botServerUrl, isCallHistory: isCallHistory)
                
                // Show the Bot Window by calling the below method call
                self.showBotWindow()
                
                // Callbacks from chatbotVC
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "CallbacksNotification"), object: nil)
                
                NotificationCenter.default.addObserver(self, selector: #selector(self.callbacksMethod), name: NSNotification.Name(rawValue: "CallbacksNotification"), object: nil)
            }
            
        })
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func setBotConfig(clientId:String, clientSecret:String, botId:String, chatBotName:String, identity:String, JWT_SERVER:String, BOT_SERVER:String, isCallHistory: Bool){
        
        let clientId = clientId; // Copy this value from Bot Builder SDK Settings ex. cs-5250bdc9-6bfe-5ece-92c9-ab54aa2d4285
        
        let clientSecret = clientSecret; // Copy this value from Bot Builder SDK Settings ex. Wibn3ULagYyq0J10LCndswYycHGLuIWbwHvTRSfLwhs=
        
        let botId = botId; // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. st-acecd91f-b009-5f3f-9c15-7249186d827d
        
        let chatBotName = chatBotName; // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. "Demo Bot"
        
        let identity = identity;// This should represent the subject for JWT token. This can be an email or phone number, in case of known user, and in case of anonymous user, this can be a randomly generated unique id.
        
        let isAnonymous = true; // This should be either true (in case of known-user) or false (in-case of anonymous user).
        
        let JWT_SERVER = JWT_SERVER; // Replace it with the actual JWT server URL, if required. Refer to developer documentation for instructions on hosting JWT Server.
        
        let BOT_SERVER = BOT_SERVER;
        
//        let clientId = "cs-1e845b00-81ad-5757-a1e7-d0f6fea227e9"; // Copy this value from Bot Builder SDK Settings ex. cs-5250bdc9-6bfe-5ece-92c9-ab54aa2d4285
//        
//        let clientSecret = "5OcBSQtH/k6Q/S6A3bseYfOee02YjjLLTNoT1qZDBso="; // Copy this value from Bot Builder SDK Settings ex. Wibn3ULagYyq0J10LCndswYycHGLuIWbwHvTRSfLwhs=
//        
//        let botId = "st-b9889c46-218c-58f7-838f-73ae9203488c"; // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. st-acecd91f-b009-5f3f-9c15-7249186d827d
//        
//        let chatBotName = "SDKBot"; // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. "Demo Bot"
//        
//        let identity = "rajasekhar.balla@kore.com";// This should represent the subject for JWT token. This can be an email or phone number, in case of known user, and in case of anonymous user, this can be a randomly generated unique id.
//        
//        let isAnonymous = true; // This should be either true (in case of known-user) or false (in-case of anonymous user).
//        
//        let JWT_SERVER = "https://mk2r2rmj21.execute-api.us-east-1.amazonaws.com/dev/"; // Replace it with the actual JWT server URL, if required. Refer to developer documentation for instructions on hosting JWT Server.
//        
//        let BOT_SERVER = "https://bots.kore.ai";
        
        botConnect.initialize(clientId, clientSecret: clientSecret, botId: botId, chatBotName: chatBotName, identity: identity, isAnonymous: isAnonymous, JWTServerUrl: JWT_SERVER, BOTServerUrl: BOT_SERVER, isCallHistory: isCallHistory);
    }
    
    func showBotWindow(){
        botConnect.show()
    }
    
    @objc func callbacksMethod(notification:Notification) {
        let dataString: String = notification.object as! String
        //print("\(dataString)")
        if let eventDic = convertStringToDictionary(text: dataString){
            if flutterMethodChannel != nil{
                flutterMethodChannel?.invokeMethod("Callbacks", arguments: eventDic)
            }
        }
    }
    
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
}
