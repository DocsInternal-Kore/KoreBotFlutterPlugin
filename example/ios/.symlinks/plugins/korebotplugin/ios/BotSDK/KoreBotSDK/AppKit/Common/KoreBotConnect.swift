//
//  KoreBot.swift
//  korebotplugin
//
//  Created by Pagidimarri Kartheek on 23/07/24.
//

import UIKit
public class KoreBotConnect: NSObject {
    
    let searchConnect = SearchConnect()
    
    public override init() {
        super.init()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func connect(methodName:String, callArguments:[String:Any]){
        let flutterDic = callArguments
        switch (methodName) {
        case "getChatWindow":
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "TokenExpiryNotification"), object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.tokenExpiry), name: NSNotification.Name(rawValue: "TokenExpiryNotification"), object: nil)
            
            //Set Korebot Config
            self.searchConnect.botConnect(botConfig: flutterDic)
            
        case "sendMessage":
            if let message = flutterDic["message"] as? String{
            // MARK: Send message to bot
                if let msg_data = flutterDic["msg_data"] as? [String:Any]{
                    self.searchConnect.sendMessage(message, options: [:], messageData: msg_data)
                }else{
                    self.searchConnect.sendMessage(message, options: [:], messageData: [:])
                }
               
            }
            
        case "initialize":
            //Set Search Config
            self.searchConnect.getJwTokenWithClientId(botConfig: flutterDic, success: {  (jwToken) in
                print(jwToken ?? "")
            }, failure: { (error) in
                print(error)
            })
            
        case "getSearchResults":
            guard let serachTxt = flutterDic["searchQuery"] as? String else{
                return
            }
            let context_data = flutterDic["context_data"] as? [String:Any]
            var context_data_String = ""
            for (key, value) in context_data ?? [:] {
                context_data_String.append(" \(key):\(value)")
            }
            self.searchConnect.classifyQueryApi(serachTxt,context_data_String) { resultDic in
                let jsonString = Utilities.stringFromJSONObject(object: resultDic)
                NotificationCenter.default.post(name: Notification.Name(callbacksNotification), object: jsonString)
            } failure: { error in
                print(error)
                let jsonString = "No Search can be performed on the query provided"
                NotificationCenter.default.post(name: Notification.Name(callbacksNotification), object: jsonString)
            }

        case "getHistoryResults":
            guard let offset = flutterDic["offset"] as? Int else{
                return
            }
            guard let limit = flutterDic["limit"] as? Int else{
                return
            }
            // MARK: chat history
            self.searchConnect.getChatHistory(offset: offset, limit: limit)
            
        case "closeBot":
            // MARK: Close the bot
            self.searchConnect.closeBot()
            
        case "isSocketConnected":
            let dic = ["event_code": "BotConnectStatus", "event_message": botConnectStatus] as [String : Any]
            let jsonString = Utilities.stringFromJSONObject(object: dic)
            NotificationCenter.default.post(name: Notification.Name(callbacksNotification), object: jsonString)
            
        case "updateCustomData":
            // MARK: Update customData
            if let custom_data = flutterDic["custom_data"] as? [String:Any]{
                self.searchConnect.updateCustomData(customData: custom_data)
            }
        default:
            break
        }
    }
    
    @objc func tokenExpiry(notification:Notification){
        let jsonString: String = notification.object as! String
        NotificationCenter.default.post(name: Notification.Name(callbacksNotification), object: jsonString)
    }

}
