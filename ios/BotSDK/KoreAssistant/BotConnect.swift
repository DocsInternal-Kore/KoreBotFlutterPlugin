//
//  BotConnect.swift
//  KoreBotSDKFrameWork
//
//  Created by Kartheek.Pagidimarri on 17/05/21.
//  Copyright © 2021 Kartheek.Pagidimarri. All rights reserved.
//

import UIKit
import Alamofire
import korebotplugin
import CoreData
import Foundation

public class BotConnect: NSObject {
    
    let sessionManager: Session = {
        let configuration = URLSessionConfiguration.af.default
        configuration.timeoutIntervalForRequest = 30
        return Session(configuration: configuration)
    }()
    var kaBotClient = KABotClient()
    let botClient = BotClient()
    var user: KREUser?
    //let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController
    var searchJwtToken = ""
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    public func initialize(_ clientId: String, clientSecret: String, botId: String, chatBotName: String, identity: String, isAnonymous: Bool, JWTServerUrl: String, BOTServerUrl: String, isCallHistory: Bool){
        
        SDKConfiguration.botConfig.clientId = clientId as String
        SDKConfiguration.botConfig.clientSecret = clientSecret as String
        SDKConfiguration.botConfig.botId = botId as String
        SDKConfiguration.botConfig.chatBotName = chatBotName as String
        SDKConfiguration.botConfig.identity = identity as String
        SDKConfiguration.botConfig.isAnonymous =  isAnonymous as Bool
        SDKConfiguration.serverConfig.JWT_SERVER = JWTServerUrl as String
        SDKConfiguration.serverConfig.BOT_SERVER = BOTServerUrl as String
        SDKConfiguration.serverConfig.Branding_SERVER = String(format: "\(BOTServerUrl)/")
        SDKConfiguration.botConfig.tenantId = "620415a603ee27d50d2a47fa"
        isCallChatHistory = isCallHistory
    }
    
    @objc public func show(){
        
        guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
            return
        }
        
        load29LTBukraFonts(fontName: "29LTBukra")
        loadCustomFontNames()

        let botViewController = ChatMessagesViewController()
        let navigationController = UINavigationController(rootViewController: botViewController)
        navigationController.isNavigationBarHidden = true
        navigationController.modalPresentationStyle = .fullScreen
        botViewController.title = SDKConfiguration.botConfig.chatBotName
        botViewController.modalPresentationStyle = .fullScreen
        rootViewController.present(navigationController, animated: false)
    }
    
    func loadCustomFontNames(){
        regularCustomFont = "29LTBukra-Regular"
        mediumCustomFont = "29LTBukra-Medium"
        boldCustomFont =   "29LTBukra-Bold"
        semiBoldCustomFont = "29LTBukra-Semibold"
        italicCustomFont =  "29LTBukra-BoldSlanted"
    }

    func load29LTBukraFonts(fontName:String){
        let bundleName = fontName
        guard let bundleUrl = Bundle(for: Self.self).url(forResource: bundleName, withExtension: "bundle"),
            let bundle = Bundle(url: bundleUrl),
            let urls = bundle.urls(forResourcesWithExtension: "ttf", subdirectory: nil) else {
                return
        }
        for url in urls {
            loadFontFile(from: url)
        }
    }

    func loadFontFile(from fontUrl: URL) {
        debugPrint(fontUrl)
        guard let fontData = try? Data(contentsOf: fontUrl) else {
            return
        }
        guard let cfData = fontData as? CFData, let provider = CGDataProvider(data: cfData), let cgFont = CGFont(provider) else {
            return
        }
        var error: Unmanaged<CFError>?
        if !CTFontManagerRegisterGraphicsFont(cgFont, &error) {
            debugPrint("KREFontLoader : error loading Font")
        }
    }
    
    // MARK: get JWT token request
    public func getJwTokenWithClientId(_ clientId: String!, clientSecret: String!, identity: String!, isAnonymous: Bool!, success:((_ jwToken: String?) -> Void)?, failure:((_ error: Error) -> Void)?) {
        
        let urlString = SDKConfiguration.serverConfig.koreJwtUrl()
        let headers: HTTPHeaders = [
            "Keep-Alive": "Connection",
            "Accept": "application/json",
            "alg": "RS256",
            "typ": "JWT"
        ]
        
        let parameters: [String: Any] = ["clientId": clientId as String,
                                         "clientSecret": clientSecret as String,
                                         "identity": identity as String,
                                         "aud": "https://idproxy.kore.com/authorize",
                                         "isAnonymous": isAnonymous as Bool]
        let dataRequest = sessionManager.request(urlString, method: .post, parameters: parameters, headers: headers)
        dataRequest.validate().responseJSON { (response) in
            if let _ = response.error {
                let error: NSError = NSError(domain: "bot", code: 100, userInfo: [:])
                failure?(error)
                self.searchJwtToken = ""
                return
            }
            if let dictionary = response.value as? [String: Any],
               let jwToken = dictionary["jwt"] as? String {
                self.searchJwtToken = jwToken
                    success?(jwToken)
            } else {
                let error: NSError = NSError(domain: "bot", code: 100, userInfo: [:])
                failure?(error)
                self.searchJwtToken = ""
            }
        }
    }
    
    public func getSearchResults(_ text: String!, success:((_ dictionary: [String: Any]) -> Void)?, failure:((_ error: Error) -> Void)?) {
        let urlString: String = "\(SDKConfiguration.serverConfig.BOT_SERVER)/api/public/stream/\(SDKConfiguration.botConfig.botId)/advancedSearch"
        //let urlString: String = "\(SDKConfiguration.serverConfig.BOT_SERVER)/chatbot/v2/webhook/\(SDKConfiguration.botConfig.botId)"
        let authorizationStr = "\(self.searchJwtToken)"
        let headers: HTTPHeaders = [
            "Keep-Alive": "Connection",
            "Content-Type": "application/json",
            "auth": authorizationStr
        ]
        let parameters: [String: Any]  = ["query": text ?? ""]
        
        let dataRequest = sessionManager.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
        dataRequest.validate().responseJSON { (response) in
            if let _ = response.error {
                let error: NSError = NSError(domain: "bot", code: 100, userInfo: [:])
                failure?(error)
                return
            }
            
            if let dictionary = response.value as? [String: Any]{
                    success?(dictionary)
            } else {
                let error: NSError = NSError(domain: "bot", code: 100, userInfo: [:])
                    failure?(error)
            }
        }
    }

}

