//
//  KoreBot.swift
//  korebotplugin
//
//  Created by Pagidimarri Kartheek on 23/07/24.
//

import UIKit
public class KoreBotConnect: NSObject {
    
    let botConnect = BotConnect()
    var isCallSearchApi = false
    
    public override init() {
        super.init()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func connect(methodName:String, callArguments:[String:Any]){
        let flutterDic = callArguments
        switch (methodName) {
        case "initialize":
            let configDetails = flutterDic as? [String: Any]
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
            let isCallHistory = configDetails?["callHistory"] as? Bool ?? true
            let customData = configDetails?["customData"] as? [String: Any] ?? [:]
            let queryParameters = configDetails?["queryParameters"] as? [[String: Any]] ?? []
            let customJWToken = configDetails?["customJWToken"] as? String ?? ""
            isCallSearchApi = configDetails?["isSearch"] as? Bool ?? false
            let isAnonymous = configDetails?["isAnonymous"] as? Bool ?? false
            let isWebhookEnabled = configDetails?["isWebhookEnabled"] as? Bool ?? false
            
            //Set Korebot Config
            self.setBotConfig(clientId: clientId, clientSecret: clientSecret, botId: botId, chatBotName: chatBotName, identity: identity, JWT_SERVER: jwtServerUrl, BOT_SERVER: botServerUrl, isCallHistory: isCallHistory, customData: customData, queryParameters: queryParameters, customJWToken: customJWToken, isAnonymous: isAnonymous, isWebhookEnabled: isWebhookEnabled)
            
            if isCallSearchApi{
                self.searchConnect(clientId: clientId, clientSecret: clientSecret, botId: botId, chatBotName: chatBotName, identity: identity)
            }
            break
        case "getChatWindow":
            // Show the Bot Window by calling the below method call
            self.showBotWindow()
            break
        case "getSearchResults":
            if isCallSearchApi{
                guard let serachTxt = flutterDic["searchQuery"] as? String else{
                    return
                }
                self.sendQuery(text: serachTxt)
            }else{
                let errorDic = ["event_code": "Search", "event_message": "Please send true flag for isSearch in initialize method"]
                let jsonString = Utilities.stringFromJSONObject(object: errorDic)
                NotificationCenter.default.post(name: Notification.Name(CallbacksNotification), object: jsonString)
            }
            break
        case "closeBot":
            // MARK: Close the bot
            self.botConnect.socketDisconnect()
            break
        default:
            break
        }
    }
    
    func setBotConfig(clientId:String, clientSecret:String, botId:String, chatBotName:String, identity:String, JWT_SERVER:String, BOT_SERVER:String, isCallHistory: Bool, customData: [String: Any], queryParameters: [[String: Any]], customJWToken: String,isAnonymous : Bool, isWebhookEnabled: Bool){
        
        botConnect.history_enable = isCallHistory
        
        botConnect.initialize(clientId, clientSecret: clientSecret, botId: botId, chatBotName: chatBotName, identity: identity, isAnonymous: isAnonymous, isWebhookEnabled: isWebhookEnabled, JWTServerUrl: JWT_SERVER, BOTServerUrl: BOT_SERVER, BrandingUrl: BOT_SERVER, customData: customData, queryParameters: queryParameters, customJWToken: customJWToken);
    }
    
    func showBotWindow(){
        botConnect.show()
    }
    
    func searchConnect(clientId:String, clientSecret:String, botId:String, chatBotName:String, identity:String){
        let clientId: String = clientId
        let clientSecret: String = clientSecret
        let isAnonymous: Bool = false
        let identity =  identity
        
        botConnect.getJwTokenWithClientId(clientId, clientSecret: clientSecret, identity: identity, isAnonymous: isAnonymous, success: {  (jwToken) in
            //print(jwToken)
        }, failure: { (error) in
            print(error)
        })
    }
    
    func sendQuery(text:String){
        self.botConnect.getSearchResults(text) { resultDic in
            // print(resultDic)
            let jsonString = Utilities.stringFromJSONObject(object: resultDic)
            NotificationCenter.default.post(name: Notification.Name(CallbacksNotification), object: jsonString)
            
        } failure: { (error) in
            print(error)
        }
    }
}
