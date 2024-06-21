//
//  ServerConfigs.swift
//  KoreBotSDKDemo
//
//  Created by developer@kore.com on 10/25/14.
//  Copyright (c) 2014 Kore Inc. All rights reserved.
//

import UIKit
import Foundation
import korebotplugin

var startSpeakingNotification = "StartSpeakingNowNotificationName"
var stopSpeakingNotification = "StopSpeakingNowNotificationName"
var showTableTemplateNotification = "ShowTableTemplateNotificationName"
var reloadTableNotification = "reloadTableNotification"
var updateUserImageNotification = "updateUserImageNotification"
var showListViewTemplateNotification = "ListViewTemplateNotificationName"
var showListWidgetViewTemplateNotification = "ListWidgetViewTemplateNotificationName"
var dropDownTemplateNotification = "DropDownTemplateNotificationName"
var activityViewControllerNotification = "ActivityViewControllerNotificationName"
var autoDirectingWebVNotification = "MovetoWebView"
var btnlinkTempMaskViewNotification = "buttonlinkTempLateMaskViewNotification"
var newListTempMaskViewNotification = "newListTempLateMaskViewNotification"
var carouselTempMaskViewNotification = "carouselTempMaskViewNotification"
var botClosedNotification = "botClosedNotification"
var sessionExpiryNotification = "sessionExpiryNotification"
var pdfcTemplateViewNotification = "pdfShowViewNotification"
var pdfcTemplateViewErrorNotification = "pdfShowErrorNotification"
var tokenExipryNotification = "TokenExpiryNotification"
var otpValidationTemplateNotification = "OTPvalidationTemplateNotificationName"
var resetpinTemplateNotification = "ResetPinTemplateNotificationName"
var loginNotification = "loginNotificationName"
var langaugeChangeNotification = "langaugeChangeNotification"
var salaamPointsDetailsNotification = "SalaamPointsDetailsNotification"
var salikTemplateNotification = "salikTemplateNotification"
var timeSlotTemplateNotification = "timeSlotTemplateNotification"

var customDropDownTemplateNotification = "customDropDownTemplateNotification"
var customDropDownTextAppendNotification = "customDropDownTextAppendNotification"
var customDDTextAppendInTemplateNotification = "customDDTextAppendInTemplateNotification"
var resetPasswordTemplateNotification = "ResetPasswordTemplateNotificationName"

var customFormTemplateNotification = "customFormTemplateNotification"
var UserValidationTemplateNotification = "UserValidationTemplateNotification"
var CallbacksNotification = "CallbacksNotification"

var customDropDownSeletct = ""

var isSpeakingEnabled = false
var selectedTheme = "Theme 1"


let userColor: UIColor = UIColor(red: 38 / 255.0, green: 52 / 255.0, blue: 74 / 255.0, alpha: 1)
let botColor: UIColor = UIColor(red: 237 / 255.0, green: 238 / 255.0, blue: 241 / 255.0, alpha: 1)

let defaultLoaderColorStr = "#26344A"
var themeColor: UIColor = UIColor.init(hexString: defaultLoaderColorStr)
var textlinkColor: UIColor = UIColor.init(hexString: "#591efd")
var botHistoryIcon:String?

var regularCustomFont = "HelveticaNeue"
var mediumCustomFont = "HelveticaNeue-Medium"
var boldCustomFont = "HelveticaNeue-Bold"
var semiBoldCustomFont = "HelveticaNeue-Semibold"
var italicCustomFont =  "HelveticaNeue-Italic"
var isCallChatHistory = false

var uniqueUserId: String?
var userInfoUserId: String?
var authInfoAccessToken: String?
var rowIndex = 1000

var calenderCloseTag = true

var messageIdIndex = 5000
var messageIdIndexForHistory = 5000

var history = true
var lastMsgreceivedTime: Date?
var welcomeMsgRemoveCount = 0
var shareAndCopyStr: String?
public var showWelcomeMsg = true
var historyLimit = 0

public var authorizationToken: String?
public var xAuthToken: String?
public var xcorelationID: String?
public var mashreqLoginID: String?
public var mashreqLoginUserType: String?
public var mashreqLoginUserSegments: String?

public var isSessionExpire: Bool?
public var previousSessionxAuth = ""
var isErrorType: String?

var alertName = "Kore"

var isAgentConnect = false
var reloadTabV = true
var previousJWTToken: String?
var appEnterBackground = false
var showMaskVInBtnLink = false
var showMaskVInNewlist = false
var showMaskVInCarousel = false

var isLogin = false
var loginParameters: [String: Any]? = [:]
var loginXauthToken: String?
var loginAccessToken: String?
var loginUserId: String?
var loginUserType: String?
var loginCustomerCif: String?
var loginCustomerName: String?
var loginID: String?
var loginUserSegments: String?
var loginEmailId: String?
var loginMobileNo: String?

var preferred_language_Type = "AR"
var preferredLanguage: String?
var default_language = "EN"
var isCallingHistoryApi = true
let date: Date = Date()
var recentSearchArray = [String]()

var customDropDownShowText = false
var frameworkBundle:Bundle? {
    let bundleId = "com.kore.rtc"
    return Bundle(identifier: bundleId)
}

var isAlreadyConnectedBot = false
var isExpandTableBubbleView = false
var isExpandRadioTableBubbleView = false
var radioTableSelectedIndex = 1000
var isMasking = false
var isNewListViewClick = false

var softExpiryTime = 25
var softExpiryWarningTime = 20
var maxiumTimeCount = softExpiryWarningTime
var timerCounter = maxiumTimeCount
var softExpiryWarningMsg =  "Session is about to expire. Please click to continue."
var ReactNativeEventMsg = ["event_code": "USER_CANCELLED", "event_message": "User Cancelled Event Occurred"]

var hardExpiryTime =  60
var hardExpiryWarningTime =  50
var maximumHardTimeCount = hardExpiryWarningTime
var hardTimerCounter = maximumHardTimeCount
var hardExpiryWarningMsg = "Session is about to expire in 3 minute. Please click to continue."
var currentSessionStartTime = 10
var currentIDFCLoginSessionTime:NSString?


var sessionExpiryGraceTime = 0
var  sessionTimeOutAlert = UIAlertController()
var  sessionHardTimeOutAlert = UIAlertController()
var sessionHardExpiryGraceTime = 0

var isOTPValidationTemplate = false
var OTPValidationRemoveCount = 0
var customDropDownText = ""



open class Common : NSObject {
    public static func UIColorRGB(_ rgb: Int) -> UIColor {
        let blue = CGFloat(rgb & 0xFF)
        let green = CGFloat((rgb >> 8) & 0xFF)
        let red = CGFloat((rgb >> 16) & 0xFF)
        return UIColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: 1)
    }
    
    public static func UIColorRGBA(_ rgb: Int, a: CGFloat) -> UIColor {
        let blue = CGFloat(rgb & 0xFF)
        let green = CGFloat((rgb >> 8) & 0xFF)
        let red = CGFloat((rgb >> 16) & 0xFF)
        return UIColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: a)
    }
}

open class Utilities: NSObject {
    // MARK:-
    public static func stringFromJSONObject(object: Any) -> String? {
        var jsonString: String? = nil
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: object, options: .prettyPrinted)
            jsonString = String(data: jsonData, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        } catch {
            print(error.localizedDescription)
        }
        return jsonString
    }
    
    public static func jsonObjectFromString(jsonString: String) -> Any? {
        var jsonObject: Any?
        do {
            let data: Data = jsonString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))! as Data
            jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            return jsonObject!
        } catch {
            print(error.localizedDescription)
        }
        return jsonObject
    }
    
    public static func getKREActionFromDictionary(dictionary: Dictionary<String, Any>) -> KREAction? {
        let actionInfo:Dictionary<String,Any> = dictionary
        let actionType: String = actionInfo["type"] != nil ? actionInfo["type"] as! String : ""
        //let title: String = actionInfo["title"] != nil ? actionInfo["title"] as! String : ""
        let title: String = (actionInfo["title"] != nil ? actionInfo["title"] as? String : "") ?? String(actionInfo["title"] as! Int)
        switch (actionType.lowercased()) {
        case "web_url", "iframe_web_url", "url":
            var url: String = actionInfo["url"] != nil ? actionInfo["url"] as! String : ""
            if url == "" {
                url = actionInfo["payload"] != nil ? actionInfo["payload"] as! String : ""
            }
            return KREAction(actionType: .webURL, title: title, payload: url)
        case "postback":
            let payload: String = (actionInfo["payload"] != nil ? actionInfo["payload"] as? String : "") ?? String(actionInfo["payload"] as! Int) //kk
            return KREAction(actionType: .postback, title: title, payload: payload)
        case "postback_disp_payload":
            let payload: String = actionInfo["payload"] != nil ? actionInfo["payload"] as! String : ""
            return KREAction(actionType: .postback_disp_payload, title: payload, payload: payload)
        default:
            break
        }
        return nil
    }
    
    public static func base64ToImage(base64String: String?) -> UIImage{
           if (base64String?.isEmpty)! {
               return #imageLiteral(resourceName: "no_image_found")
           }else {
               // Separation part is optional, depends on your Base64String !
               let tempImage = base64String?.components(separatedBy: ",")
               let dataDecoded : Data = Data(base64Encoded: tempImage![1], options: .ignoreUnknownCharacters)!
               let decodedimage = UIImage(data: dataDecoded)
               return decodedimage!
           }
       }
    
    public static func isValidJson(check jsonString:String) -> Bool{
        if let jsonDataToVerify = jsonString.data(using: .utf8)
        {
            do {
                _ = try JSONSerialization.jsonObject(with: jsonDataToVerify)
                print("JSON is valid.")
                return true
            } catch {
                print("Error deserializing JSON: \(error.localizedDescription)")
                return false
            }
        }
        return false
    }
}

