//
//  KABotClient.swift
//  KoraApp
//
//  Created by Srinivas Vasadi on 29/01/18.
//  Copyright © 2018 Srinivas Vasadi. All rights reserved.
//

import UIKit
import korebotplugin
import CoreData
import ObjectMapper
import Alamofire

public protocol KABotClientDelegate: NSObjectProtocol {
    func botConnection(with connectionState: BotClientConnectionState)
    func showTypingStatusForBot()
}

open class KABotClient: NSObject {
    // MARK:- shared instance
    fileprivate var isConnected: Bool = false {
        didSet {
            if isConnected {
                //whenever is connected is true it fetches the history if any
                
                fetchMessages()
            }
        }
    }
    fileprivate var isConnecting: Bool = false
    private static var client: KABotClient!
    fileprivate var retryCount = 0
    fileprivate(set) var maxRetryAttempts = 5
    fileprivate var botClientQueue = DispatchQueue(label: "com.kora.botclient")
    public var canSpeakUtterance: Bool = false
    open var onCarouselMsgReceived: (( _ knowledgeArr : Array<Any>) -> Void)!
    var messagesRequestInProgress: Bool = false
    var historyRequestInProgress: Bool = false
    private static var instance: KABotClient!
    static let shared: KABotClient = {
        if (instance == nil) {
            instance = KABotClient()
        }
        return instance
    }()
    
    var thread: KREThread?
    let defaultTimeDifference = 15
    
    // properties
    public static var suggestions: NSMutableOrderedSet = NSMutableOrderedSet()
    private var botClient: BotClient = BotClient()
    
    public var identity: String!
    public var userId: String!
    public var streamId: String = ""
    let sessionManager: Session = {
        let configuration = URLSessionConfiguration.af.default
        configuration.timeoutIntervalForRequest = 30
        return Session(configuration: configuration)
    }()
    
    public var connectionState: BotClientConnectionState! {
        get {
            return botClient.connectionState
        }
    }
    open weak var delegate: KABotClientDelegate?
    
    // MARK: - init
    public override init() {
        super.init()
        configureBotClient()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - fetch messages
    func fetchMessages(completion block: ((Bool) -> Void)? = nil) {
        guard isCallingHistoryApi else {
            isCallingHistoryApi = false
            self.reconnectStatus(completion: block)
            return
        }
        
        var limit = 0
        if showWelcomeMsg == true{
            historyLimit = 0
            limit = 1
        }else{
            limit = historyLimit
            if limit == 0{
                limit = 1
            }
            if historyLimit >= 20{
                limit = 20
            }
        }
        
        self.getMessages(offset: 0, limit: limit, completion:{ (success) in
            if success {
                isCallingHistoryApi = false
                self.reconnectStatus(completion: block)
            } else {
                block?(false)
            }
        })
        
    }
    
    func reconnectStatus(completion block: ((Bool) -> Void)?) {
        let dataStoreManager = DataStoreManager.sharedManager
        dataStoreManager.getLastMessage(completion: { [weak self] (message) in
            var status = false
            guard let weakSelf = self else {
                block?(status)
                return
            }
            
            status = weakSelf.canReconnect(using: message)
            block?(status)
        })
    }
    
    func canReconnect(using message: KREMessage?) -> Bool {
        var status = false
        guard let sentOn = message?.sentOn as Date? else {
            return status
        }
        
        let date = Date()
        let distanceBetweenDates = date.timeIntervalSince(sentOn)
        let secondsInMinute: Double = 60
        let minutesBetweenDates = Int((distanceBetweenDates / secondsInMinute))
        
        if minutesBetweenDates < defaultTimeDifference {
            status = true
        }
        
        return status
    }
    
    // MARK: - connect/reconnect - tries to reconnect the bot when isConnected is false
    @objc func tryConnect() {
        let delayInMilliSeconds = 250
        botClientQueue.asyncAfter(deadline: .now() + .milliseconds(delayInMilliSeconds)) { [weak self] in
            if self?.isConnected == true {
                self?.retryCount = 0
            } else if let weakSelf = self {
                if weakSelf.isConnecting == false  {
                    weakSelf.isConnecting = true
                    weakSelf.isConnected = false
                    
                    if weakSelf.retryCount + 1 > weakSelf.maxRetryAttempts {
                        weakSelf.retryCount = 0
                    }
                    
                    weakSelf.retryCount += 1
                    weakSelf.connect(block: {(client, thread) in
                    }, failure:{(error) in
                        self?.isConnecting = false
                        self?.isConnected = false
                        
                        self?.tryConnect()
                    })
                }
            }
        }
    }
    
    
    // MARK: -
    public func sendMessage(_ message: String, options: [String: Any]?) {
        botClient.sendMessage(message, options: options)
    }
    
    // methods
    func configureBotClient() {
        // events
        botClient.connectionWillOpen =  { [weak self] () in
            if let weakSelf = self {
                DispatchQueue.main.async {
                    weakSelf.delegate?.botConnection(with: weakSelf.connectionState)
                }
            }
        }
        
        botClient.connectionDidOpen = { [weak self] () in
            rowIndex = 0
            self?.isConnected = true
            self?.isConnecting = false
            
        }
        
        botClient.connectionReady = {
            
        }
        
        botClient.connectionDidClose = { [weak self] (code, reason) in
            self?.isConnected = false
            self?.isConnecting = false
            
            if let weakSelf = self {
                DispatchQueue.main.async {
                    weakSelf.delegate?.botConnection(with: weakSelf.connectionState)
                }
            }
            self?.tryConnect()
            NotificationCenter.default.post(name: Notification.Name("StopTyping"), object: nil)
        }
        
        botClient.connectionDidFailWithError = { [weak self] (error) in
            self?.isConnected = false
            self?.isConnecting = false
            
            if let weakSelf = self {
                DispatchQueue.main.async {
                    weakSelf.delegate?.botConnection(with: weakSelf.connectionState)
                }
            }
            self?.tryConnect()
            NotificationCenter.default.post(name: Notification.Name("StopTyping"), object: nil)
        }
        
        botClient.onMessage = { [weak self] (object) in
            history = false
            let message = self?.onReceiveMessage(object: object)
            if !isOTPValidationTemplate{
                self?.addMessages(message?.0, message?.1)
            }
            
            if reloadTabV == true {
                reloadTabV = false
                Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (_) in
                    NotificationCenter.default.post(name: Notification.Name(reloadTableNotification), object: nil)
                }
            }
        }
        
        botClient.onMessageAck = { (ack) in
            
        }
        
        botClient.onUserMessageReceived = {  (object) in
            if let message = object["message"] as? [String:Any]{
                if let agentTyping = message["type"] as? String{
                    if agentTyping == "typing"{
                        NotificationCenter.default.post(name: Notification.Name("StartTyping"), object: nil)
                    }else{
                        NotificationCenter.default.post(name: Notification.Name("StopTyping"), object: nil)
                    }
                }
            }
        }
    }
    func addMessages(_ message: Message?, _ ttsBody: String?) {
        if let m = message, m.components.count > 0 {
            let delayInMilliSeconds = 500
            DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(delayInMilliSeconds)) {
                let dataStoreManager = DataStoreManager.sharedManager
                dataStoreManager.createNewMessageIn(thread: self.thread, message: m, completion: { (success) in
                    
                })
                
                if let tts = ttsBody {
                    NotificationCenter.default.post(name: Notification.Name(startSpeakingNotification), object: tts)
                }
            }
        }
    }
    
    func deConfigureBotClient() {
        // events
        botClient.disconnect()
        botClient.connectionWillOpen = nil
        botClient.connectionDidOpen = nil
        botClient.connectionReady = nil
        botClient.connectionDidClose = nil
        botClient.connectionDidFailWithError = nil
        botClient.onMessage = nil
        botClient.onMessageAck = nil
    }
    
    // MARK: -
    func getTemplateType(_ templateType: String) -> ComponentType {
        switch templateType {
        case "quick_replies":
            return .quickReply
        case "button":
            return .options
        case "list":
            return .list
        case "carousel", "kora_welcome_carousel":
            return .carousel
        case "piechart", "linechart", "barchart":
            return .chart
        case "table":
            return .table
        default:
            return .text
        }
    }
    
    func getComponentType(_ templateType: String,_ tabledesign:String) -> ComponentType {
        if (templateType == "quick_replies") {
            return .quickReply
        } else if (templateType == "buttonn") {
            return .options
        }else if (templateType == "list") {
            return .list
        }else if (templateType == "carousel") {
            return .carousel
        }else if (templateType == "piechart" || templateType == "linechart" || templateType == "barchart") {
            return .chart
        }else if (templateType == "table"  && tabledesign == "regular") {
            return .table
        }
        else if (templateType == "table"  && tabledesign == "responsive") {
            return .responsiveTable
        }
        else if (templateType == "mini_table") {
            return .minitable
        }
        else if (templateType == "menu") {
            return .menu
        }
        else if (templateType == "listView") {
            return .newList
        }
        else if (templateType == "tableList") {
            return .tableList
        }
        else if (templateType == "daterange" || templateType == "dateTemplate") {
            return .calendarView
        }
        else if (templateType == "quick_replies_welcome" || templateType == "button" || templateType == "quick_repliess"){
            return .quick_replies_welcome
        }
        else if (templateType == "Notification") {
            return .notification
        }
        else if (templateType == "multi_select") {
            return .multiSelect
        }
        else if (templateType == "List_widget" || templateType == "listWidget") {
            return .list_widget
        }
        else if (templateType == "feedbackTemplate") {
            return .feedbackTemplate
        }
        else if (templateType == "form_template") {
            return .inlineForm
        }
        else if (templateType == "dropdown_template") {
            return .dropdown_template
        }
        else if (templateType == "transactionSuccessTemplate"){
            return .transactionSuccessTemplate
        }
        else if (templateType == "contactCardTemplate"){
            return .contactCardTemplate
        }
        else if (templateType == "radioListTemplate"){
            isExpandRadioTableBubbleView = false
            radioTableSelectedIndex = 1000
            return .radioListTemplate
        }
        else if (templateType == "pdfdownload"){
            return .pdfdownload
        }else if (templateType == "updatedIdfcCarousel"){
            return .updatedIdfcCarousel
        }else if (templateType == "buttonLinkTemplate"){
            showMaskVInBtnLink = true
            return .buttonLinkTemplate
        }else if (templateType == "idfcFeedbackTemplate"){
            return .idfcFeedbackTemplate
        }else if (templateType == "statusTemplate"){
            return .statusTemplate
        }else if (templateType == "serviceListTemplate"){
            return .serviceListTemplate
        }else if (templateType == "idfcAgentTemplate"){
            return .idfcAgentTemplate
        }else if (templateType == "idfcCarouselType2"){
            return .idfcCarouselType2
        }else if (templateType == "cardSelection"){
            return .cardSelection
        }else if (templateType == "beneficiaryTemplate"){
            return .beneficiaryTemplate
        }else if (templateType == "advanced_multi_select"){
            return .advanced_multi_select
        }else if (templateType == "salaampointsTemplate" || templateType == "listView_custom1"){
            return .salaampointsTemplate
        }else if (templateType == "welcome_template"){
            return .welcome_template
        }else if (templateType == "boldtextTemplate"){
            return .boldtextTemplate
        }else if (templateType == "emptyBubble"){
            return .emptyBubbleTemplate
        }else if (templateType == "custom_dropdown_template"){
            return .custom_dropdown_template
        }else if (templateType == "details_list"){
            return .details_list_template
        }else if (templateType == "search"){
            return .search_template
        }else if (templateType == "bankingFeedbackTemplate"){
            return .bankingFeedbackTemplate
        }
        return .text
    }
    
    func onReceiveMessage(object: BotMessageModel?) -> (Message?, String?) {
        isOTPValidationTemplate = false
        isMasking = false
        timerCounter = maxiumTimeCount
        NotificationCenter.default.post(name: Notification.Name("StopTyping"), object: nil)
        var ttsBody: String?
        var textMessage: Message! = nil
        let message: Message = Message()
        message.messageType = .reply
        if let type = object?.type, type == "incoming" {
            message.messageType = .default
        }
        lastMsgreceivedTime = object?.createdOn
        //message.sentDate = object?.createdOn
        if object?.createdOn != nil{
            message.sentDate = object?.createdOn
        }else{
            let timestamp = NSDate().timeIntervalSince1970
            let myTimeInterval = TimeInterval(timestamp)
            let time = NSDate(timeIntervalSince1970: TimeInterval(myTimeInterval))
            message.sentDate = time as Date
            lastMsgreceivedTime = time as Date
        }
        message.messageId = object?.messageId
        if history{
            messageIdIndexForHistory = messageIdIndexForHistory - 1
            message.messageIdIndex = NSNumber(value: messageIdIndexForHistory)
            
            lastMsgreceivedTime = Date() // this is remove when the history limit(20) removed
        }else{
            messageIdIndex = messageIdIndex + 1
            message.messageIdIndex = NSNumber(value: messageIdIndex)
            historyLimit += 1
            if showWelcomeMsg == true{
                showWelcomeMsg = false
            }
        }
        
        if let iconUrl = object?.iconUrl {
            message.iconUrl = iconUrl
            botHistoryIcon = iconUrl
        }else{
            message.iconUrl = botHistoryIcon
        }
        
        if let fromAgent = object?.fromAgent, fromAgent == true{
            isAgentConnect = true
        }else{
            isAgentConnect = false
        }
        
        guard let messages = object?.messages, messages.count > 0 else {
            return (nil, ttsBody)
        }
        
        let messageObject = messages.first
        if (messageObject?.component == nil) {
            
        } else if let componentModel = messageObject?.component, let componentType = componentModel.type {
            switch componentType {
            case "text":
                if let payload = componentModel.payload as? [String: Any],
                   let text = payload["text"] as? String {
                    let textComponent = Component()
                    textComponent.payload = text
                    ttsBody = text
                    
                    if text.contains("use a web form")  {
                        
                    }
                    if text == "You are now conversing with the bot in the English language" || text == "Language switched to English" || text == "You are now conversing with the bot in the  language" || text == "I have now switched the language to English" || text == "I have switched the language to English."{
                        if !history{
                            preferredLanguage = "EN"
                            default_language = "EN"
                            NotificationCenter.default.post(name: Notification.Name(langaugeChangeNotification), object: nil)
                        }
                    }
                    
                    if text.contains("أنت الآن تتحدث مع الروبوت في لغة العربية    ") || text == "Language switched to Arabic" || text == "أنت الآن تكلم الروبوت بـالعربية" || text == "لقد قمت بتحويل اللغة إلى العربية."{
                        if !history{
                            preferredLanguage = "AR"
                            default_language = "AR"
                            NotificationCenter.default.post(name: Notification.Name(langaugeChangeNotification), object: nil)
                        }
                    }
                    
                    
                    let string = text
                    let character: Character = "*"
                    if string.contains(character) ||  string.contains("http"){
                        print("\(string) contains \(character)")
                        if message.messageType == .default{
                            message.addComponent(textComponent)
                        }else{
                            let textComponent: Component = Component(.boldtextTemplate)
                            textComponent.payload = text
                            message.addComponent(textComponent)
                        }
                    } else {
                        print("\(string) doesn't contain \(character)")
                        message.addComponent(textComponent)
                    }
                    
                    return (message, ttsBody)
                }
            case "image":
                if let payload = componentModel.payload as? [String: Any] {
                    if let dictionary = payload["payload"] as? [String: Any] {
                        let optionsComponent: Component = Component(.image)
                        optionsComponent.payload = Utilities.stringFromJSONObject(object: dictionary)
                        message.sentDate = object?.createdOn
                        message.addComponent(optionsComponent)
                        return (message, ttsBody)
                    }
                }
            case "template":
                if let payload = componentModel.payload as? [String: Any] {
                    let type = payload["type"] as? String ?? ""
                    let text = payload["text"] as? String
                    ttsBody = payload["speech_hint"] as? String
                    
                    if let  maskingtext = payload["masking"] as? Bool, maskingtext == true{
                        isMasking = true
                    }else{
                        isMasking = false
                    }
                    
                    if let url =  payload["url"] as? String{
                        NotificationCenter.default.post(name: Notification.Name(autoDirectingWebVNotification), object: url)
                    }
                    
                    switch type {
                    case "template":
                        
                        if let endOfDialog = payload["endOfDialog"] as? Bool{
                            if endOfDialog{
                                Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { (_) in
                                    self.sendMessage("demoFeedback", options: nil)
                                }
                            }
                        }
                        
                        if let dictionary = payload["payload"] as? [String: Any] {
                            var templateType = dictionary["template_type"] as? String ?? ""
                            var tabledesign = "responsive"
                            if let value = dictionary["table_design"] as? String {
                                tabledesign = value
                            }
                            
                            if templateType == "quick_replies_welcome"{
                                var quickReplies: Array<Dictionary<String, AnyObject>>
                                quickReplies = dictionary["quick_replies"] as? Array<Dictionary<String, AnyObject>> ?? []
                                if quickReplies.count == 0{
                                    templateType = "quick_replies_welcome"
                                }
                            }
                            
                            var componentType:ComponentType!
                            if let displayButtonTemplate = dictionary["url_present"] as? Bool, displayButtonTemplate == true {
                                componentType = getComponentType("buttonn", tabledesign)
                            }else{
                                componentType = getComponentType(templateType, tabledesign)
                            }
                            
                            if componentType != .quickReply {
                                
                            }
                            
                            if componentType == .quickReply {
                                let quickReplyTitle = dictionary["text"] as? String
                                if quickReplyTitle == nil{
                                    componentType = getComponentType("emptyBubble", tabledesign)
                                }
                            }
                            
                            if templateType == "otpValidationTemplate"{
                                isOTPValidationTemplate = true
                                if !history{
                                    let otpStr = Utilities.stringFromJSONObject(object: dictionary)
                                    let otptemplateType = dictionary["type"] as? String ?? ""
                                    if otptemplateType == "resetPin"{
                                        NotificationCenter.default.post(name: Notification.Name(resetpinTemplateNotification), object: otpStr)
                                    }else if otptemplateType == "passwordReset" {
                                        NotificationCenter.default.post(name: Notification.Name(resetPasswordTemplateNotification), object: otpStr)
                                    }else{
                                        NotificationCenter.default.post(name: Notification.Name(otpValidationTemplateNotification), object: otpStr)
                                    }
                                }else{
                                    OTPValidationRemoveCount += 1
                                }
                            }else if templateType == "salikpinTemplate"{
                                isOTPValidationTemplate = true
                                let salikDic = Utilities.stringFromJSONObject(object: dictionary)
                                if !history{
                                    NotificationCenter.default.post(name: Notification.Name(salikTemplateNotification), object: salikDic)
                                    
                                }
                            }else if templateType == "date_with_time_selector"{
                                isOTPValidationTemplate = true
                                let dateWithTimeDic = Utilities.stringFromJSONObject(object: dictionary)
                                if !history{
                                    NotificationCenter.default.post(name: Notification.Name(timeSlotTemplateNotification), object: dateWithTimeDic)
                                    
                                }
                            }else if templateType == "transition_template"{
                                isOTPValidationTemplate = true
                                //let transitionDic = Utilities.stringFromJSONObject(object: dictionary)
                                if !history{
                                    if let utterence = dictionary["utterance_text"] as? String{
                                        self.sendMessage(utterence, options: [:])
                                    }
                                    
                                }
                            }else if templateType == "custom_form_template"{
                                isOTPValidationTemplate = true
                                let formTemplateDic = Utilities.stringFromJSONObject(object: dictionary)
                                if !history{
                                    NotificationCenter.default.post(name: Notification.Name(customFormTemplateNotification), object: formTemplateDic)
                                    
                                }
                            }else if templateType == "user_validation_template"{
                                isOTPValidationTemplate = true
                                let formTemplateDic = Utilities.stringFromJSONObject(object: dictionary)
                                if !history{
                                    NotificationCenter.default.post(name: Notification.Name(UserValidationTemplateNotification), object: formTemplateDic)
                                    
                                }
                            }
                            
                            if templateType == "form_template"{
                                if !history{
                                    isLogin = false
                                }
                            }
                            customDropDownShowText = false
                            if templateType == "custom_dropdown_template" || templateType == "dropdown_template"{
                                
                                if !history{
                                    customDropDownText = ""
                                    customDropDownShowText = true
                                }
                            }
                            
                            var isTextTemplate = false
                        
                            if templateType == "sessionExpiry"{
                                let text = dictionary["text"] as? String
                                if let text = text, text.count > 0 {
                                    isTextTemplate = true
                                    let textComponent: Component = Component()
                                    textComponent.payload = text
                                    message.addComponent(textComponent)
                                }
                                let timeToClose = dictionary["timeToClose"] as? String
                                if let  timerCount = timeToClose, timerCount.count > 0{
                                    if !history{
                                        Timer.scheduledTimer(withTimeInterval: Double(timerCount)!, repeats: false) { (_) in
                                            isSessionExpire = true
                                            NotificationCenter.default.post(name: Notification.Name(sessionExpiryNotification), object: nil)
                                        }
                                    }
                                }
                                
                            }
                            
                            
                            
                            ttsBody = dictionary["speech_hint"] != nil ? dictionary["speech_hint"] as? String : nil
                            if let tText = dictionary["text"] as? String, tText.count > 0 && (componentType == .carousel || componentType == .chart || componentType == .table || componentType == .minitable || componentType == .responsiveTable) {
                                textMessage = Message()
                                textMessage?.messageType = .reply
                                textMessage?.sentDate = message.sentDate
                                textMessage?.messageId = message.messageId
                                textMessage?.messageIdIndex = message.messageIdIndex
                                if let iconUrl = object?.iconUrl {
                                    textMessage?.iconUrl = iconUrl
                                }
                                let textComponent: Component = Component()
                                textComponent.payload = tText
                                textMessage?.addComponent(textComponent)
                            }
                            if !isTextTemplate{
                                let optionsComponent: Component = Component(componentType)
                                optionsComponent.payload = Utilities.stringFromJSONObject(object: dictionary)
                                //message.sentDate = object?.createdOn
                                
                                
                                if appEnterBackground{
                                    appEnterBackground = false
                                    if (templateType == "quick_replies_welcome"){
                                        
                                    }else{
                                        if templateType == "SYSTEM" || templateType == "live_agent" || templateType == "liveagent"{
                                            let textComponent = Component(.text)
                                            let text = "\(dictionary["text"] as? String ?? "")"
                                            textComponent.payload = text
                                            ttsBody = text
                                            message.addComponent(textComponent)
                                        }else{
                                            message.addComponent(optionsComponent)
                                        }
                                    }
                                }else{
                                    if templateType == "SYSTEM" || templateType == "live_agent" || templateType == "liveagent"{
                                        let textComponent = Component(.text)
                                        let text = "\(dictionary["text"] as? String ?? "")"
                                        textComponent.payload = text
                                        ttsBody = text
                                        message.addComponent(textComponent)
                                    }else{
                                        message.addComponent(optionsComponent)
                                    }
                                }
                            }
                            
                        }
                    case "image":
                        if let dictionary = payload["payload"] as? [String: Any] {
                            let optionsComponent: Component = Component(.image)
                            optionsComponent.payload = Utilities.stringFromJSONObject(object: dictionary)
                            message.sentDate = object?.createdOn
                            message.addComponent(optionsComponent)
                        }
                    case "message":
                        if let dictionary = payload["payload"] as? [String: Any] {
                            let  componentType = dictionary["audioUrl"] != nil ? Component(.audio) : Component(.video)
                            let optionsComponent: Component = componentType
                            if let speechText = dictionary["text"] as? String{
                                ttsBody = speechText
                            }
                            optionsComponent.payload = Utilities.stringFromJSONObject(object: dictionary)
                            message.sentDate = object?.createdOn
                            message.addComponent(optionsComponent)
                        }
                    case "video":
                        if let _ = payload["payload"] as? [String: Any] {
                            let  componentType = Component(.video)
                            let optionsComponent: Component = componentType
                            optionsComponent.payload = Utilities.stringFromJSONObject(object: payload)
                            message.sentDate = object?.createdOn
                            message.addComponent(optionsComponent)
                        }
                    case "audio":
                        if let dictionary = payload["payload"] as? [String: Any] {
                            let  componentType = Component(.audio)
                            let optionsComponent: Component = componentType
                            optionsComponent.payload = Utilities.stringFromJSONObject(object: dictionary)
                            message.sentDate = object?.createdOn
                            message.addComponent(optionsComponent)
                        }
                    case "error":
                        if let dictionary = payload["payload"] as? [String: Any] {
                            let errorComponent: Component = Component(.error)
                            errorComponent.payload = Utilities.stringFromJSONObject(object: dictionary)
                            message.addComponent(errorComponent)
                        }
                    default:
                        if let text = text, text.count > 0 {
                            let character: Character = "*"
                            let htmlcharacter = "</b>"
                            if text.contains(character) || text.contains(htmlcharacter) {
                                let textComponent: Component = Component(.boldtextTemplate)
                                textComponent.payload = text
                                message.addComponent(textComponent)
                            }else{
                                let textComponent =  Component()
                                textComponent.payload = text
                                message.addComponent(textComponent)
                            }
                            
                        }
                    }
                }else{ //kk
                    if let payload = componentModel.payload as? String{
                        print(payload as Any)
                        if message.messageType == .default{
                            let textComponent = Component()
                            textComponent.payload = payload
                            ttsBody = payload
                            message.addComponent(textComponent)
                        }else{
                            let string = payload
                            let character: Character = "*"
                            let htmlcharacter = "</b>"
                            if string.contains(character) || string.contains(htmlcharacter) {
                                let textComponent = Component(.boldtextTemplate)
                                textComponent.payload = payload
                                ttsBody = payload
                                message.addComponent(textComponent)
                            }else{
                                let textComponent = Component()
                                textComponent.payload = payload
                                ttsBody = payload
                                message.addComponent(textComponent)
                            }
                        }
                        
                    }
                }
                return (message, ttsBody)
            default:
                return (nil, ttsBody)
            }
        }
        return (nil, ttsBody)
    }
    
    // MARK: -
    func connect(block:((BotClient?, KREThread?) -> ())?, failure:((_ error: Error) -> Void)?){
        let clientId: String = SDKConfiguration.botConfig.clientId
        let clientSecret: String = SDKConfiguration.botConfig.clientSecret
        let isAnonymous: Bool = SDKConfiguration.botConfig.isAnonymous
        let chatBotName: String = SDKConfiguration.botConfig.chatBotName
        let botId: String = SDKConfiguration.botConfig.botId
        
        var identity: String! = nil
        if (isAnonymous) {
            identity = self.getUUID()
        } else {
            identity =  SDKConfiguration.botConfig.identity
        }
        
        let botInfo: [String: Any] = ["chatBot": chatBotName, "taskBotId": botId]
        self.getJwTokenWithClientId(clientId, clientSecret: clientSecret, identity: identity, isAnonymous: isAnonymous, success: { [weak self] (jwToken) in
            
            
            let dataStoreManager: DataStoreManager = DataStoreManager.sharedManager
            let context = dataStoreManager.coreDataManager.workerContext
            context.perform {
                let resources: Dictionary<String, AnyObject> = ["threadId": botId as AnyObject, "subject": chatBotName as AnyObject, "messages":[] as AnyObject]
                
                dataStoreManager.insertOrUpdateThread(dictionary: resources, with: {( thread1) in
                    self?.thread = thread1
                    try? context.save()
                    dataStoreManager.coreDataManager.saveChanges()
                    self?.botClient.initialize(botInfoParameters: botInfo, customData: [:])
                    if (SDKConfiguration.serverConfig.BOT_SERVER.count > 0) {
                        self?.botClient.setKoreBotServerUrl(url: SDKConfiguration.serverConfig.BOT_SERVER)
                    }
                    isErrorType = "Grant Call"
                    self?.botClient.connectWithJwToken(jwToken, intermediary: { [weak self] (client) in
                        self?.fetchMessages(completion: { (reconnects) in
                            if showWelcomeMsg == true{
                                self?.botClient.connect(isReconnect: reconnects)
                            }else{
                                self?.botClient.connect(isReconnect: true)
                            }
                        })
                    }, success: { (client) in
                        self?.botClient = client!
                        userInfoUserId = client?.userInfoModel?.userId
                        authInfoAccessToken = client?.authInfoModel?.accessToken
                        block?(self?.botClient, self?.thread)
                    }, failure: { (error) in
                        failure?(error!)
                    })
                })
            }
        }, failure: { (error) in
            print(error)
            failure?(error)
        })
        
    }
    
    func getUUID() -> String {
        var id: String?
        let userDefaults = UserDefaults.standard
        if let UUID = userDefaults.string(forKey: "UUID") {
            id = UUID
        } else {
            let date: Date = Date()
            id = String(format: "email%ld%@", date.timeIntervalSince1970, "@domain.com")
            userDefaults.set(id, forKey: "UUID")
        }
        return id!
    }
    
    // MARK: get JWT token request
    func getJwTokenWithClientId(_ clientId: String!, clientSecret: String!, identity: String!, isAnonymous: Bool!, success:((_ jwToken: String?) -> Void)?, failure:((_ error: Error) -> Void)?) {
        
        isErrorType = "STS"
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
                return
            }
            
            if let dictionary = response.value as? [String: Any],
               let jwToken = dictionary["jwt"] as? String {
                if appEnterBackground{
                    success?(previousJWTToken)
                }else{
                    previousJWTToken = jwToken
                    success?(jwToken)
                }
                
            } else {
                let error: NSError = NSError(domain: "bot", code: 100, userInfo: [:])
                failure?(error)
            }
            
        }
        
    }
    
    func request(with url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        
        guard let cookies = HTTPCookieStorage.shared.cookies(for: url) else {
            return request
        }
        
        request.allHTTPHeaderFields = HTTPCookie.requestHeaderFields(with: cookies)
        return request
    }
    
    
    // MARK: get Branding Values request
    func brandingApiRequest(_ accessToken: String!, success:((_ brandingDic: [String: Any]) -> Void)?, failure:((_ error: Error) -> Void)?) {
        //https://bots.kore.ai/api/websdkthemes/st-183e9c7d-fc8a-56d8-ba47-2733f8767d6b/activetheme
        let urlString: String =  "\(SDKConfiguration.serverConfig.BOT_SERVER)/api/websdkthemes/\(SDKConfiguration.botConfig.botId)/activetheme"
        let authorizationStr = "bearer \(accessToken!)"
        let headers : HTTPHeaders = [
            "Keep-Alive": "Connection",
            "Content-Type": "application/json",
            "Authorization": authorizationStr
        ]
        
        let dataRequest = sessionManager.request(urlString, method: .get, parameters: [:], headers: headers)
        dataRequest.validate().responseJSON { (response) in
            if let _ = response.error {
                let error: NSError = NSError(domain: "", code: 0, userInfo: [:])
                failure?(error)
                return
            }
            
            if let responseObject = response.value as? [String: Any] {
                success?(responseObject)
            } else {
                failure?(NSError(domain: "", code: 0, userInfo: [:]))
            }
        }
        
    }
    
    
    // MARK: -
    open func showTypingStatusForBot() {
        delegate?.showTypingStatusForBot()
    }
    
    
    // MARK: -
    open func datastorePath() -> URL {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let url = urls[urls.count-1] as NSURL
        return url.appendingPathComponent(".Bots.sqlite")!
    }
    
    // MARK: - set hash tags
    open func setHashTags(with array: [String]?) {
        if let values = array {
            KABotClient.suggestions.addObjects(from: values)
        }
    }
    
    // MARK: - get history
    public func getMessages(offset: Int, limit: Int, completion block:((Bool) -> Void)?) {
        guard historyRequestInProgress == false else {
            return
        }
        //getHistory - fetch all the history that the bot has previously
        botClient.getHistory(offset: offset, limit: limit, success: { [weak self] (responseObj) in
            if let responseObject = responseObj as? [String: Any], let messages = responseObject["messages"] as? Array<[String: Any]> {
                botHistoryIcon = responseObject["icon"] as? String
                print("History messges \(messages.count) \(messages)")
                let reverse: Array<[String: Any]> = messages.reversed()
                if showWelcomeMsg != true{
                    self?.insertOrUpdateHistoryMessages(reverse)
                }
            }
            self?.historyRequestInProgress = false
            block?(true)
        }, failure: { [weak self] (error) in
            self?.historyRequestInProgress = false
            print("Unable to fetch messges \(error?.localizedDescription ?? "")")
            block?(false)
        })
    }
    
    //MARK: getRecentHistory - fetch all the history that the bot has previously based on last messageId
    public func getRecentHistory() {
        guard messagesRequestInProgress == false else {
            return
        }
        
        let dataStoreManager = DataStoreManager.sharedManager
        let context = dataStoreManager.coreDataManager.workerContext
        messagesRequestInProgress = true
        let request: NSFetchRequest<KREMessage> = KREMessage.fetchRequest()
        let isSenderPredicate = NSPredicate(format: "isSender == \(false)")
        request.predicate = isSenderPredicate
        //let sortDates = NSSortDescriptor(key: "sentOn", ascending: false)
        let sortDates = NSSortDescriptor(key: "messageIdIndex", ascending: false)
        request.sortDescriptors = [sortDates]
        request.fetchLimit = 1
        
        context.perform { [weak self] in
            guard let array = try? context.fetch(request), array.count > 0, let messageId = array.first?.messageId else {
                self?.messagesRequestInProgress = false
                return
            }
            
            self?.botClient.getMessages(after: messageId, direction: 1, success: { (responseObj) in
                if let responseObject = responseObj as? [String: Any]{
                    if let messages = responseObject["messages"] as? Array<[String: Any]> {
                        self?.insertOrUpdateHistoryMessages(messages)
                    }
                }
                self?.messagesRequestInProgress = false
            }, failure: { (error) in
                self?.messagesRequestInProgress = false
                print("Unable to fetch history \(error?.localizedDescription ?? "")")
            })
        }
    }
    
    // MARK: - insert or update messages
    func insertOrUpdateHistoryMessages(_ messages: Array<[String: Any]>) {
        history = true
        let botMessages = Mapper<BotMessages>().mapArray(JSONArray: messages)
        guard botMessages.count > 0 else {
            return
        }
        
        var removeRemoveQuickReplies = false
        var found = 0
        welcomeMsgRemoveCount = 0
        OTPValidationRemoveCount = 0
        var allMessagesnew: [Message] = [Message]()
        
        var allMessages: [Message] = [Message]()
        for message in botMessages {
            removeRemoveQuickReplies = false
            if message.type == "outgoing" || message.type == "incoming" {
                guard let components = message.components, let data = components.first?.data else {
                    continue
                }
                
                guard let jsonString = data["text"] as? String else {
                    continue
                }
                
                let botMessage: BotMessageModel = BotMessageModel()
                botMessage.createdOn = message.createdOn
                botMessage.messageId = message.messageId
                botMessage.type = message.type
                
                let messageModel: MessageModel = MessageModel()
                let componentModel: ComponentModel = ComponentModel()
                if jsonString.contains("payload"), let jsonObject: [String: Any] = Utilities.jsonObjectFromString(jsonString: jsonString) as? [String : Any] {
                    componentModel.type = jsonObject["type"] as? String
                    
                    var payloadObj: [String: Any] = [String: Any]()
                    payloadObj["payload"] = jsonObject["payload"] as? [String : Any] ?? [:]
                    payloadObj["type"] = jsonObject["type"]
                    componentModel.payload = payloadObj
                    
                    let payloadDic = jsonObject["payload"] as? [String : Any] ?? [:]
                    //print((payloadDic["template_type"] as Any) as? String)
                    if (payloadDic["template_type"] as Any) as? String == "quick_replies_welcome" && found == 0{
                        removeRemoveQuickReplies = false//true
                        //welcomeMsgRemoveCount += 1
                    }else{
                        removeRemoveQuickReplies = false
                        found = 1
                    }
                } else {
                    removeRemoveQuickReplies = false
                    found = 1
                    
                    var payloadObj: [String: Any] = [String: Any]()
                    payloadObj["text"] = jsonString
                    payloadObj["type"] = "text"
                    componentModel.type = "text"
                    componentModel.payload = payloadObj
                    if jsonString == "User provided login inputs"{
                        removeRemoveQuickReplies = true
                        welcomeMsgRemoveCount += 1
                    }else if jsonString.contains("§§"){
                        removeRemoveQuickReplies = true
                        welcomeMsgRemoveCount += 1
                    }else if Utilities.isValidJson(check: jsonString) == true{
                        removeRemoveQuickReplies = true
                        welcomeMsgRemoveCount += 1
                    }
                }
                
                messageModel.type = "text"
                messageModel.component = componentModel
                botMessage.messages = [messageModel]
                let messageTuple = onReceiveMessage(object: botMessage)
                if let object = messageTuple.0 {
                    if !removeRemoveQuickReplies{
                        if !isOTPValidationTemplate{
                            allMessagesnew.append(object)
                        }
                    }
                }
            }
        }
        allMessages = allMessagesnew
        // insert all messages
        if allMessages.count > 0 {
            let dataStoreManager = DataStoreManager.sharedManager
            dataStoreManager.insertMessages(allMessages, in:  thread, completion: nil)
            
        }
    }
    
    // MARK: -
    public func setReachabilityStatusChange(_ status: NetworkReachabilityManager.NetworkReachabilityStatus) {
        botClient.setReachabilityStatusChange(status)
    }
}

// MARK: - UserDefaults Sign-In status
extension UserDefaults {
    func setKoraStartEventStatus(_ status: Bool, for identity: String) {
        set(status, forKey: identity)
        synchronize()
    }
    
    func koraStartEventStatus(for identity: String) -> Bool {
        return bool(forKey: identity)
    }
}
