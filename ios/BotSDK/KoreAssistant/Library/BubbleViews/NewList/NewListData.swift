//
//  NewListData.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek Pagidimarri on 12/05/20.
//  Copyright © 2020 Kore. All rights reserved.
//

import UIKit

public class Componentss: NSObject, Decodable {
    public var template_type: String?
    public var text: String?
    public var elements: [ComponentElements]?
    public var cardDetails: [ComponentElements]?
    public var buttons: [ComponentItemAction]?
    public var moreData: ComponentMoreData?
    public var heading: String?
    public var submitTitle: String?
    public var format: String?
    public var startDate: String?
    public var endDate: String?
    public var text_message: String?
    public var title: String?
    public var quickReplies: [QuickRepliesWelcomeData]?
    public var moreCount: Int?
    public var seeMore: Bool?
    public var lang: String?
    public var image_url: String?
    public var subtitle: String?
    public var smileyArrays: [SmileyArraysAction]?
    public var messageTodisplay: String?
    public var starArrays: [SmileyArraysAction]?
    public var feedbackView: String?
    public var boxShadow: Bool?
    public var isClassClick: String?
    public var headerActions: HeaderActionsData?
    public var background: String?
    
    public var transActionDesc: String?
    public var transactionHeader: String?
    public var transactionIDHeader: String?
    public var transactions: [Transactions]?
    public var contactCard: [ContactCard]?
    public var displayCount: Int?
    public var seeMoreTitle: String?
    public var items: [FeedBackItems]?
    public var tag: Tags?
    
    public var displayLimit: Int?
    public var quick_reply_title: String?
    
    public var form_fields: [FormFields]?
    public var dropdown: DropDowns?
    
    public var graph_answer: SearchGraphAnswers?
    public var results: SearchResults?
    
    public var feedbackListHeading: String?
    public var experienceContent: [ExperienceContent]?
    public var feedbackList: [FeedbackList]?
    
    public var url: String?
    public var videoUrl: String?
    public var audioUrl: String?
    
    enum ColorCodeKeys: String, CodingKey {
        case template_type = "template_type"
        case text = "text"
        case elements = "elements"
        case cardDetails = "cardDetails"
        case buttons = "buttons"
        case moreData = "moreData"
        case heading = "heading"
        case submitTitle = "submitTitle"
        case format = "format"
        case startDate = "startDate"
        case endDate = "endDate"
        case text_message = "text_message"
        case title = "title"
        case quickReplies = "quick_replies"
        case moreCount = "moreCount"
        case seeMore = "seeMore"
        case image_url = "image_url"
        case subtitle = "subtitle"
        case smileyArrays = "smileyArrays"
        case messageTodisplay = "messageTodisplay"
        case starArrays = "starArrays"
        case feedbackView = "view"
        case boxShadow = "boxShadow"
        case isClassClick = "class"
        case headerActions = "headerActions"
        case background = "background"
        
        case transActionDesc = "description"
        case transactionHeader = "transactionHeader"
        case transactionIDHeader = "transactionIDHeader"
        case transactions = "transactions"
        case contactCard = "cards"
        case displayCount = "displayCount"
        case seeMoreTitle = "seeMoreTitle"
        case items = "items"
        case tag = "tag"
        
        case displayLimit = "displayLimit"
        case lang = "lang"
        case quick_reply_title = "quick_reply_title"
        
        case form_fields = "form_fields"
        case dropdown = "dropdown"
        
        case graph_answer = "graph_answer"
        case results = "results"
        
        case url = "url"
        case videoUrl = "videoUrl"
        case audioUrl = "audioUrl"
        
        case feedbackListHeading = "feedbackListHeading"
        case experienceContent = "experienceContent"
        case feedbackList = "feedbackList"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        template_type = try? container.decode(String.self, forKey: .template_type)
        text = try? container.decode(String.self, forKey: .text)
        elements = try? container.decode([ComponentElements].self, forKey: .elements)
        cardDetails = try? container.decode([ComponentElements].self, forKey: .cardDetails)
        buttons = try? container.decode([ComponentItemAction].self, forKey: .buttons)
        moreData = try? container.decode(ComponentMoreData.self, forKey: .moreData)
        heading = try? container.decode(String.self, forKey: .heading)
        submitTitle = try? container.decode(String.self, forKey: .submitTitle)
        format = try? container.decode(String.self, forKey: .format)
        startDate = try? container.decode(String.self, forKey: .startDate)
        endDate = try? container.decode(String.self, forKey: .endDate)
        text_message = try? container.decode(String.self, forKey: .text_message)
        title = try? container.decode(String.self, forKey: .title)
        quickReplies = try? container.decode([QuickRepliesWelcomeData].self, forKey: .quickReplies)
        moreCount = try? container.decode(Int.self, forKey: .moreCount)
        seeMore = try? container.decode(Bool.self, forKey: .seeMore)
        image_url = try? container.decode(String.self, forKey: .image_url)
        subtitle = try? container.decode(String.self, forKey: .subtitle)
        smileyArrays = try? container.decode([SmileyArraysAction].self, forKey: .smileyArrays)
        messageTodisplay = try? container.decode(String.self, forKey: .messageTodisplay)
        starArrays = try? container.decode([SmileyArraysAction].self, forKey: .starArrays)
        feedbackView = try? container.decode(String.self, forKey: .feedbackView)
        boxShadow = try? container.decode(Bool.self, forKey: .boxShadow)
        isClassClick = try? container.decode(String.self, forKey: .isClassClick)
        headerActions = try? container.decode(HeaderActionsData.self, forKey: .headerActions)
        background = try? container.decode(String.self, forKey: .background)
        
        transActionDesc = try? container.decode(String.self, forKey: .transActionDesc)
        transactionHeader = try? container.decode(String.self, forKey: .transactionHeader)
        transactionIDHeader = try? container.decode(String.self, forKey: .transactionIDHeader)
        transactions = try? container.decode([Transactions].self, forKey: .transactions)
        contactCard = try? container.decode([ContactCard].self, forKey: .contactCard)
        displayCount = try? container.decode(Int.self, forKey: .displayCount)
        seeMoreTitle = try? container.decode(String.self, forKey: .seeMoreTitle)
        items = try? container.decode([FeedBackItems].self, forKey: .items)
        tag = try? container.decode(Tags.self, forKey: .tag)
        
        displayLimit = try? container.decode(Int.self, forKey: .displayLimit)
        lang = try? container.decode(String.self, forKey: .lang)
        quick_reply_title = try? container.decode(String.self, forKey: .quick_reply_title)
        form_fields = try? container.decode([FormFields].self, forKey: .form_fields)
        dropdown = try? container.decode(DropDowns.self, forKey: .dropdown)
        
        graph_answer = try? container.decode(SearchGraphAnswers.self, forKey: .graph_answer)
        results = try? container.decode(SearchResults.self, forKey: .results)
        
        url = try? container.decode(String.self, forKey: .url)
        videoUrl = try? container.decode(String.self, forKey: .videoUrl)
        audioUrl = try? container.decode(String.self, forKey: .audioUrl)
        
        feedbackListHeading = try? container.decode(String.self, forKey: .feedbackListHeading)
        experienceContent = try? container.decode([ExperienceContent].self, forKey: .experienceContent)
        feedbackList = try? container.decode([FeedbackList].self, forKey: .feedbackList)
    }
}
// MARK: - Elements
public class ComponentElements: NSObject, Decodable {
    public var color: String?
    public var subtitle: String?
    public var transactionDate: String?
    public var title: String?
    public var value: String?
    public var imageURL: String?
    public var action: ComponentItemAction?
    public var tag: String?
    public var elementDescription: String?
    public var elementPayload: String?
    public var elementType: String?
    public var elementUrl: String?
    public var elementText: String?
    public var elementsbuttons: [ComponentItemAction]?
    public var elementTag: Tags?
    public var backgroundImageUrl: String?
    public var ElementTagInfo : TagInformation?
    public var isSamePageNavigation: Bool?
    
    public var disbursalAmtTitle:String?
    public var disbursalAmtValue:String?
    public var disbursalDateTitle:String?
    public var disbursalDateValue:String?
    
    public var subTitle: String?
    //public var desc: String?
    public var icon: String?
    public var img: String?
    public var flag: String?
    public var copyValue: String?
    
    public var country_name : String?
    public var country_code: String?
    
    public var visible_values: [VisibleValues]?
    public var hidden_values: [VisibleValues]?
    public var hide: Bool?
    public var cardType: String?
    
    enum ColorCodeKeys: String, CodingKey {
        case color = "color"
        case subtitle = "subtitle"
        case title = "title"
        case transactionDate = "transactionDate"
        case value = "value"
        case imageURL = "image_url"
        case action = "default_action"
        case tag = "tag"
        case elementDescription = "description"
        case elementPayload = "payload"
        case elementType = "type"
        case elementUrl = "url"
        case elementText = "text"
        case elementsbuttons = "buttons"
        case elementTag = "tag1"
        case backgroundImageUrl = "backgroundImageUrl"
        case ElementTagInfo = "tagInformation"
        
        case disbursalAmtTitle = "disbursalAmtTitle"
        case disbursalAmtValue = "disbursalAmtValue"
        case disbursalDateTitle = "disbursalDateTitle"
        case disbursalDateValue = "disbursalDateValue"
        case isSamePageNavigation = "isSamePageNavigation"
        
        case subTitle = "subTitle"
        //case desc = "description"
        case icon = "icon"
        case img = "img"
        case flag = "flag"
        case copyValue = "copy"
        case country_name = "country_name"
        case country_code = "code"
        
        case visible_values = "visible_values"
        case hidden_values = "hidden_values"
        case hide = "hide"
        case cardType = "cardType"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        color = try? container.decode(String.self, forKey: .color)
        subtitle = try? container.decode(String.self, forKey: .subtitle)
        //title = try? container.decode(String.self, forKey: .title)
        if let titleInteger = try? container.decodeIfPresent(Int.self, forKey: .title) {
            title = String(titleInteger ?? -00)
            if title == "-00"{
                title = ""
            }
        } else if let titleString = try? container.decodeIfPresent(String.self, forKey: .title) {
            title = titleString
        }
        transactionDate = try? container.decode(String.self, forKey: .transactionDate)
        
        //value = try? container.decode(String.self, forKey: .value)
        
        if let valueInteger = try? container.decodeIfPresent(Int.self, forKey: .value) {
            value = String(valueInteger ?? -00)
            if value == "-00"{
                value = ""
            }
        } else if let valueString = try? container.decodeIfPresent(String.self, forKey: .value) {
            value = valueString
        }
        imageURL = try? container.decode(String.self, forKey: .imageURL)
        action = try? container.decode(ComponentItemAction.self, forKey: .action)
        tag = try? container.decode(String.self, forKey: .tag)
        elementDescription = try? container.decode(String.self, forKey: .elementDescription)
        elementType = try? container.decode(String.self, forKey: .elementType)
        elementUrl = try? container.decode(String.self, forKey: .elementUrl)
        elementText = try? container.decode(String.self, forKey: .elementText)
        elementsbuttons = try? container.decode([ComponentItemAction].self, forKey: .elementsbuttons)
        elementTag = try? container.decode(Tags.self, forKey: .elementTag )
        
        if let payloadInt = try? container.decodeIfPresent(Int.self, forKey: .elementPayload) {
            elementPayload = String(payloadInt ?? -00)
            if elementPayload == "-00"{
                elementPayload = ""
            }
        } else if let payloadStr = try? container.decodeIfPresent(String.self, forKey: .elementPayload) {
            elementPayload = payloadStr
        }
        
        backgroundImageUrl = try? container.decode(String.self, forKey: .backgroundImageUrl)
        ElementTagInfo = try? container.decode(TagInformation.self, forKey: .ElementTagInfo)
        
        disbursalAmtTitle = try? container.decode(String.self, forKey: .disbursalAmtTitle)
        disbursalAmtValue = try? container.decode(String.self, forKey: .disbursalAmtValue)
        disbursalDateTitle = try? container.decode(String.self, forKey: .disbursalDateTitle)
        disbursalDateValue = try? container.decode(String.self, forKey: .disbursalDateValue)
        isSamePageNavigation = try? container.decode(Bool.self, forKey: .isSamePageNavigation)
        
        subTitle = try? container.decode(String.self, forKey: .subTitle)
        //desc = try? container.decode(String.self, forKey: .desc)
        icon = try? container.decode(String.self, forKey: .icon)
        img = try? container.decode(String.self, forKey: .img)
        flag = try? container.decode(String.self, forKey: .flag)
        copyValue = try? container.decode(String.self, forKey: .copyValue)
        country_name = try? container.decode(String.self, forKey: .country_name)
        country_code = try? container.decode(String.self, forKey: .country_code)
        
        visible_values = try? container.decode([VisibleValues].self, forKey: .visible_values)
        hidden_values = try? container.decode([VisibleValues].self, forKey: .hidden_values)
        hide = try? container.decode(Bool.self, forKey: .hide)
        cardType = try? container.decode(String.self, forKey: .cardType)
    }
}


// MARK: - ItemAction
public class ComponentItemAction: NSObject, Decodable {
    // MARK: - properties
    public var payload: String?
    public var title: String?
    public var type: String?
    public var fallback_url: String?
    public var url: String?
    public var name: String?
    public var postback: PostbackAction?
    public var showMoreMessages : String?
    public var icon : String?
    
    enum ActionKeys: String, CodingKey {
        case payload = "payload"
        case title = "title"
        case type = "type"
        case fallback_url = "fallback_url"
        case url = "url"
        case name = "name"
        case postback = "postback"
        case showMoreMessages = "showMoreMessages"
        case icon = "icon"
        
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ActionKeys.self)
        //payload = try? container.decode(String.self, forKey: .payload)
        if let payloadInteger = try? container.decodeIfPresent(Int.self, forKey: .payload) {
            payload = String(payloadInteger ?? -00)
            if payload == "-00"{
                payload = ""
            }
        } else if let payloadString = try? container.decodeIfPresent(String.self, forKey: .payload) {
            payload = payloadString
        }
        title = try? container.decode(String.self, forKey: .title)
        type = try? container.decode(String.self, forKey: .type)
        fallback_url = try? container.decode(String.self, forKey: .fallback_url)
        url = try? container.decode(String.self, forKey: .url)
        name = try? container.decode(String.self, forKey: .name)
        postback  = try? container.decode(PostbackAction.self, forKey: .postback)
        showMoreMessages = try? container.decode(String.self, forKey: .showMoreMessages)
        icon = try? container.decode(String.self, forKey: .icon)
    }
}
// MARK: - MoreData
public class ComponentMoreData: NSObject, Decodable {
    // MARK: - properties
    public var tab1: [Tabs]?
    public var tab2: [Tabs]?
    
    enum ColorCodeKeys: String, CodingKey {
        case tab1 = "Tab1"
        case tab2 = "Tab2"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        tab1 = try? container.decode([Tabs].self, forKey: .tab1)
        tab2 = try? container.decode([Tabs].self, forKey: .tab2)
    }
}
// MARK: - Tabs
public class Tabs: NSObject, Decodable {
    public var title: String?
    public var subtitle: String?
    public var image_url: String?
    public var value: String?
    public var imageURL: String?
    public var action: ComponentItemAction?
    
    enum ColorCodeKeys: String, CodingKey {
        case title = "title"
        case subtitle = "subtitle"
        case image_url = "image_url"
        case value = "value"
        case action = "default_action"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        title = try? container.decode(String.self, forKey: .title)
        subtitle = try? container.decode(String.self, forKey: .subtitle)
        image_url = try? container.decode(String.self, forKey: .image_url)
        value = try? container.decode(String.self, forKey: .value)
        action = try? container.decode(ComponentItemAction.self, forKey: .action)
    }
}


// MARK: - Postback
public class PostbackAction: NSObject, Decodable {
    public var value: String?
    
    enum ColorCodeKeys: String, CodingKey {
        case value = "value"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        value = try? container.decode(String.self, forKey: .value)
        
    }
}

// MARK: - Smileys Array
public class SmileyArraysAction: NSObject, Decodable {
    public var value: Int?
    public var smileyId: Int?
    public var starId: Int?
    
    enum ColorCodeKeys: String, CodingKey {
        case value = "value"
        case smileyId = "smileyId"
        case starId = "starId"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        value = try? container.decode(Int.self, forKey: .value)
        smileyId = try? container.decode(Int.self, forKey: .smileyId)
        starId = try? container.decode(Int.self, forKey: .starId)
    }
}

// MARK: - headerActions
public class HeaderActionsData: NSObject, Decodable {
    public var copyBtn: HeaderActionsDetails?
    public var shareBtn: HeaderActionsDetails?
    
    enum ColorCodeKeys: String, CodingKey {
        case copyBtn = "copy"
        case shareBtn = "share"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        copyBtn = try? container.decode(HeaderActionsDetails.self, forKey: .copyBtn)
        shareBtn = try? container.decode(HeaderActionsDetails.self, forKey: .shareBtn)
    }
}

public class HeaderActionsDetails: NSObject, Decodable {
    public var enable: Bool?
    public var title: String?
    
    enum ColorCodeKeys: String, CodingKey {
        case enable = "enable"
        case title = "title"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        enable = try? container.decode(Bool.self, forKey: .enable)
        title = try? container.decode(String.self, forKey: .title)
    }
}


// MARK: - TransActions
public class Transactions: NSObject, Decodable {
    public var id: String?
    public var mode: String?
    
    enum ColorCodeKeys: String, CodingKey {
        case id = "id"
        case mode = "mode"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        //id = try? container.decode(Int.self, forKey: .id)
        if let valueInteger = try? container.decodeIfPresent(Int.self, forKey: .id) {
            id = String(valueInteger ?? -00)
            if id == "-00"{
                id = ""
            }
        } else if let valueString = try? container.decodeIfPresent(String.self, forKey: .id) {
            id = valueString
        }
        mode = try? container.decode(String.self, forKey: .mode)
    }
}

public class ContactCard: NSObject, Decodable {
    public var type: String?
    public var userContactNumber: String?
    public var userIcon: String?
    public var userName: String?
    public var userEmailId: String?
    
    enum ColorCodeKeys: String, CodingKey {
        case type = "type"
        case userContactNumber = "userContactNumber"
        case userIcon = "userIcon"
        case userName = "userName"
        case userEmailId = "userEmailId"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        
        type = try? container.decode(String.self, forKey: .type)
        userContactNumber = try? container.decode(String.self, forKey: .userContactNumber)
        userIcon = try? container.decode(String.self, forKey: .userIcon)
        userName = try? container.decode(String.self, forKey: .userName)
        userEmailId = try? container.decode(String.self, forKey: .userEmailId)
    }
}


public class FeedBackItems: NSObject, Decodable {
    public var value: String?
    public var type: String?
    public var emoji: String?
    public var feedBackDesc: String?
    public var id: Int?
    public var suggestionContent: SuggestionContent?
    
    enum ColorCodeKeys: String, CodingKey {
        case value = "value"
        case type = "type"
        case emoji = "emoji"
        case feedBackDesc = "description"
        case id = "id"
        case suggestionContent = "suggestionContent"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        
        value = try? container.decode(String.self, forKey: .value)
        type = try? container.decode(String.self, forKey: .type)
        emoji = try? container.decode(String.self, forKey: .emoji)
        feedBackDesc = try? container.decode(String.self, forKey: .feedBackDesc)
        id = try? container.decode(Int.self, forKey: .id)
        suggestionContent = try? container.decode(SuggestionContent.self, forKey: .suggestionContent)
    }
}

public class SuggestionContent: NSObject, Decodable {
    
    public var sendTitle: String?
    public var placeholder: String?
    public var heading: String?
    public var feedBackButtons: [FeedbackButtons]?
    enum ColorCodeKeys: String, CodingKey {
        
        case sendTitle = "sendTitle"
        case placeholder = "placeholder"
        case heading = "heading"
        case feedBackButtons = "buttons"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        
        sendTitle = try? container.decode(String.self, forKey: .sendTitle)
        placeholder = try? container.decode(String.self, forKey: .placeholder)
        heading = try? container.decode(String.self, forKey: .heading)
        feedBackButtons = try? container.decode([FeedbackButtons].self, forKey: .feedBackButtons)
    }
}

public class FeedbackButtons: NSObject, Decodable {
    public var type: String?
    public var title: String?
    public var payload: String?
    public var buttonStyles: FeedbackButtonStyles?
    
    
    enum ColorCodeKeys: String, CodingKey {
        case type = "type"
        case title = "title"
        case payload = "payload"
        case buttonStyles = "buttonStyles"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        
        type = try? container.decode(String.self, forKey: .type)
        title = try? container.decode(String.self, forKey: .title)
        payload = try? container.decode(String.self, forKey: .payload)
        buttonStyles = try? container.decode(FeedbackButtonStyles.self, forKey: .buttonStyles)
    }
}

public class FeedbackButtonStyles: NSObject, Decodable {
    public var background: String?
    public var border: String?
    public var color: String?
    
    enum ColorCodeKeys: String, CodingKey {
        case background = "background"
        case border = "border"
        case color = "color"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        
        background = try? container.decode(String.self, forKey: .background)
        border = try? container.decode(String.self, forKey: .border)
        color = try? container.decode(String.self, forKey: .color)
    }
}

public class Tags: NSObject, Decodable {
    public var title: String?
    public var tagStyles: TagStyles?
    
    
    enum ColorCodeKeys: String, CodingKey {
        case title = "title"
        case tagStyles = "tagStyles"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        
        title = try? container.decode(String.self, forKey: .title)
        tagStyles = try? container.decode(TagStyles.self, forKey: .tagStyles)
    }
}

public class TagStyles: NSObject, Decodable {
    public var background: String?
    public var color: String?
    
    
    enum ColorCodeKeys: String, CodingKey {
        case background = "background"
        case color = "color"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        
        background = try? container.decode(String.self, forKey: .background)
        color = try? container.decode(String.self, forKey: .color)
    }
}

public class TagInformation: NSObject, Decodable {
    public var title: String?
    public var styles: TagInfoStyles?
    
    
    enum ColorCodeKeys: String, CodingKey {
        case title = "title"
        case styles = "styles"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        
        title = try? container.decode(String.self, forKey: .title)
        styles = try? container.decode(TagInfoStyles.self, forKey: .styles)
    }
}

public class TagInfoStyles: NSObject, Decodable {
    public var background: String?
    public var color: String?
    
    enum ColorCodeKeys: String, CodingKey {
        case background = "background"
        case color = "color"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        
        background = try? container.decode(String.self, forKey: .background)
        color = try? container.decode(String.self, forKey: .color)
    }
}


public class FormFields: NSObject, Decodable {
    public var type: String?
    public var requireds: Bool?
    public var placeholder: String?
    public var label: String?
    public var text: String?
    public var errorMessage: String?
    
    enum ColorCodeKeys: String, CodingKey {
        case type = "type"
        case requireds = "required"
        case placeholder = "placeholder"
        case label = "label"
        case text = "text"
        case errorMessage = "errorMessage"
        
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        type = try? container.decode(String.self, forKey: .type)
        requireds = try? container.decode(Bool.self, forKey: .requireds)
        placeholder = try? container.decode(String.self, forKey: .placeholder)
        label = try? container.decode(String.self, forKey: .label)
        text = try? container.decode(String.self, forKey: .text)
        errorMessage = try? container.decode(String.self, forKey: .errorMessage)
    }
}

public class DropDowns: NSObject, Decodable {
    public var heading: String?
    public var elements: [ComponentElements]?
    public var dropDowntext: String?
    public var countrycode: String?
    
    
    enum ColorCodeKeys: String, CodingKey {
        case heading = "heading"
        case elements = "elements"
        case dropDowntext = "text"
        case countrycode = "countrycode"
        
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        heading = try? container.decode(String.self, forKey: .heading)
        elements = try? container.decode([ComponentElements].self, forKey: .elements)
        dropDowntext = try? container.decode(String.self, forKey: .dropDowntext)
        countrycode = try? container.decode(String.self, forKey: .countrycode)
    }
}

public class VisibleValues: NSObject, Decodable {
    public var subTitle: String?
    public var title: String?
    
    
    enum ColorCodeKeys: String, CodingKey {
        case subTitle = "subTitle"
        case title = "title"
        
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        title = try? container.decode(String.self, forKey: .title)
        subTitle = try? container.decode(String.self, forKey: .subTitle)
    }
}

public class SearchGraphAnswers: NSObject, Decodable {
    public var payload: GraphAnswersPayload?
    enum ColorCodeKeys: String, CodingKey {
        case payload = "payload"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        payload = try? container.decode(GraphAnswersPayload.self, forKey: .payload)
    }
}

public class GraphAnswersPayload: NSObject, Decodable {
    public var center_panel: PayloadCentralPanel?
    enum ColorCodeKeys: String, CodingKey {
        case center_panel = "center_panel"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        center_panel = try? container.decode(PayloadCentralPanel.self, forKey: .center_panel)
    }
}

public class PayloadCentralPanel: NSObject, Decodable {
    public var data: [CentralPanelData]?
    enum ColorCodeKeys: String, CodingKey {
        case data = "data"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        data = try? container.decode([CentralPanelData].self, forKey: .data)
    }
}

public class CentralPanelData: NSObject, Decodable {
    public var snippet_title: String?
    public var snippet_content: String?
    public var source: String?
    public var url: String?
    enum ColorCodeKeys: String, CodingKey {
        case snippet_title = "snippet_title"
        case snippet_content = "snippet_content"
        case source = "source"
        case url = "url"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        snippet_title = try? container.decode(String.self, forKey: .snippet_title)
        snippet_content = try? container.decode(String.self, forKey: .snippet_content)
        source = try? container.decode(String.self, forKey: .source)
        url = try? container.decode(String.self, forKey: .url)
    }
}




public class SearchResults: NSObject, Decodable {
    public var web: ResultsWeb?
    enum ColorCodeKeys: String, CodingKey {
        case web = "web"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        web = try? container.decode(ResultsWeb.self, forKey: .web)
    }
}

public class ResultsWeb: NSObject, Decodable {
    public var data: [WebData]?
    enum ColorCodeKeys: String, CodingKey {
        case data = "data"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        data = try? container.decode([WebData].self, forKey: .data)
    }
}
public class WebData: NSObject, Decodable {
    public var page_image_url: String?
    public var page_preview: String?
    public var page_title: String?
    public var page_url: String?
    
    enum ColorCodeKeys: String, CodingKey {
        case page_image_url = "page_image_url"
        case page_preview = "page_preview"
        case page_title = "page_title"
        case page_url = "page_url"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        page_image_url = try? container.decode(String.self, forKey: .page_image_url)
        page_preview = try? container.decode(String.self, forKey: .page_preview)
        page_title = try? container.decode(String.self, forKey: .page_title)
        page_url = try? container.decode(String.self, forKey: .page_url)
    }
}

public class ExperienceContent: NSObject, Decodable {
    public var id: String?
    public var value: String?
    
    
    enum ColorCodeKeys: String, CodingKey {
        case id = "id"
        case value = "value"
       
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        id = try? container.decode(String.self, forKey: .id)
        value = try? container.decode(String.self, forKey: .value)
    }
}

public class FeedbackList: NSObject, Decodable {
    public var id: String?
    public var value: String?
    
    
    enum ColorCodeKeys: String, CodingKey {
        case id = "id"
        case value = "value"
       
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        id = try? container.decode(String.self, forKey: .id)
        value = try? container.decode(String.self, forKey: .value)
    }
}

