//
//  SDKConfiguration.swift
//  KoreBotSDKDemo
//
//  Created by developer@kore.com on 12/16/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit
import korebotplugin

class SDKConfiguration: NSObject {
    
    struct dataStoreConfig {
        static let resetDataStoreOnConnect = true // This should be either true or false. Conversation with the bot will be persisted, if it is false.
    }
    
    struct botConfig {
        public static var clientId = "<client-id>" // Copy this value from Bot Builder SDK Settings ex. cs-5250bdc9-6bfe-5ece-92c9-ab54aa2d4285
        
        public static var clientSecret = "<client-secret>" // Copy this value from Bot Builder SDK Settings ex. Wibn3ULagYyq0J10LCndswYycHGLuIWbwHvTRSfLwhs=
        
        public static var botId =  "<bot-id>" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. st-acecd91f-b009-5f3f-9c15-7249186d827d

        public static var chatBotName = "bot-name" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. "Demo Bot"
        
        public static var identity = "<identity-email> or <random-id>"// This should represent the subject for JWT token. This can be an email or phone number, in case of known user, and in case of anonymous user, this can be a randomly generated unique id.
        
        public static var isAnonymous = true // This should be either true (in case of known-user) or false (in-case of anonymous user).

        public static var isWebhookEnabled = false // This should be either true (in case of Webhook connection) or false (in-case of Socket connection).
        
        public static var enableAckDelivery = false // Set true to send acknowledgment to server on receiving response from bot
        
        public static var customData : [String: Any] = [:]
        
        public static var queryParameters : [[String: Any]] = []
        
        public static var customJWToken : String = "" //This should represent the subject for send own JWToken.
        
        public static var isShowChatHistory = true // Set true to Show chat history or false hide chat history.
        
        public static var history_batch_size = 20 // history limit.
        
        public static var isShowSpeachToTextIcon : Bool = true
        
        public static var isShowAttachmentIcon : Bool = true
        
        public static var deviceToken:Data? =  nil

        public static var preferredLanguage = "en"

        static func normalizeLanguage(_ language: String?) -> String {
            guard let value = language?.trimmingCharacters(in: .whitespacesAndNewlines), !value.isEmpty else {
                return "en"
            }
            return value.replacingOccurrences(of: "_", with: "-")
        }

        static func resolveLanguage(_ responseLanguage: String?) -> String {
            guard let value = responseLanguage?.trimmingCharacters(in: .whitespacesAndNewlines), !value.isEmpty else {
                return preferredLanguage
            }
            return normalizeLanguage(value)
        }

        static func isRTL(_ language: String? = nil) -> Bool {
            let resolved = resolveLanguage(language)
            let languageCode = Locale(identifier: resolved).languageCode ?? resolved
            return Locale.characterDirection(forLanguage: languageCode) == .rightToLeft
        }

        static func responseLanguage(from components: NSArray?) -> String? {
            guard let components = components else { return nil }
            for value in components {
                let payload: String?
                if let component = value as? KREComponent {
                    payload = component.componentDesc
                } else if let component = value as? Component {
                    payload = component.payload
                } else {
                    payload = nil
                }
                if let language = responseLanguage(fromJSONString: payload) { return language }
            }
            return nil
        }

        static func responseLanguage(fromJSONString jsonString: String?) -> String? {
            guard let jsonString = jsonString,
                  let data = jsonString.data(using: .utf8),
                  let object = try? JSONSerialization.jsonObject(with: data) else { return nil }
            return findLanguage(in: object)
        }

        private static func findLanguage(in value: Any) -> String? {
            if let dictionary = value as? [String: Any] {
                if let language = dictionary["lang"] as? String, !language.isEmpty { return language }
                for nestedValue in dictionary.values {
                    if let language = findLanguage(in: nestedValue) { return language }
                }
            } else if let array = value as? [Any] {
                for nestedValue in array {
                    if let language = findLanguage(in: nestedValue) { return language }
                }
            }
            return nil
        }
    }
    
    struct serverConfig {
        public static var JWT_SERVER = String(format: "http://<jwt-server-host>/") // Replace it with the actual JWT server URL, if required. Refer to developer documentation for instructions on hosting JWT Server.
        
        static func koreJwtUrl() -> String {
            return JWT_SERVER
        }
        
        public static var BOT_SERVER = String(format: "https://bots.kore.ai")
        public static var Branding_SERVER = String(format: "https://bots.kore.ai")
        public static var WIDGET_SERVER = String(format: "https://bots.kore.ai")
    }
   
    struct widgetConfig {
        static let clientId = "<client-id>" // Copy this value from Bot Builder SDK Settings ex. cs-5250bdc9-6bfe-5ece-92c9-ab54aa2d4285
        
        static let clientSecret = "<client-secret>" // Copy this value from Bot Builder SDK Settings ex. Wibn3ULagYyq0J10LCndswYycHGLuIWbwHvTRSfLwhs=
        
        static let botId =  "<bot-id>" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. st-acecd91f-b009-5f3f-9c15-7249186d827d

        static let chatBotName = "bot-name" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. "Demo Bot"
        
        static let identity = "<identity-email> or <random-id>"// This should represent the subject for JWT token. This can be an email or phone number, in case of known user, and in case of anonymous user, this can be a randomly generated unique id.
        
        static let isAnonymous = true // This should be either true (in case of known-user) or false (in-case of anonymous user).
        
        static let isPanelView = false // This should be either true (in case of Show Panel) or false (in-case of Hide Panel).
    }
    
    // googleapi speech API_KEY
    struct speechConfig {
        static let API_KEY = "<speech_api_key>"
    }
}
