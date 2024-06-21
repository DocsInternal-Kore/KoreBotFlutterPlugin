//
//  AdvancedListData.swift
//  KoreBotSDKFrameWork
//
//  Created by Kartheek.Pagidimarri on 04/08/22.
//  Copyright © 2022 Kartheek.Pagidimarri. All rights reserved.
//

import UIKit

public class AdvancedListData: NSObject, Decodable {
      public var template_type: String?
      public var text: String?
      public var elements: [AdvancedElements]?
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
      public var image_url: String?
      public var subtitle: String?
      public var smileyArrays: [SmileyArraysAction]?
      public var messageTodisplay: String?
      public var starArrays: [SmileyArraysAction]?
      public var feedbackView: String?
      public var boxShadow: Bool?
       public var lang: String?
    public var selectAllCheckbox: Bool?
    
    enum ColorCodeKeys: String, CodingKey {
            case template_type = "template_type"
            case text = "text"
            case elements = "elements"
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
        case lang = "lang"
        case selectAllCheckbox = "selectAllCheckbox"
        
       }
       
       // MARK: - init
       public override init() {
           super.init()
       }
       
       required public init(from decoder: Decoder) throws {
           let container = try decoder.container(keyedBy: ColorCodeKeys.self)
           template_type = try? container.decode(String.self, forKey: .template_type)
           text = try? container.decode(String.self, forKey: .text)
           elements = try? container.decode([AdvancedElements].self, forKey: .elements)
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
           lang = try? container.decode(String.self, forKey: .lang)
           selectAllCheckbox = try? container.decode(Bool.self, forKey: .selectAllCheckbox)
       }
}



public class AdvancedElements: NSObject, Decodable {
      
    public var collection: [ComponentElements]?
        enum ColorCodeKeys: String, CodingKey {
            case collection = "collection"
       }
       
       // MARK: - init
       public override init() {
           super.init()
       }
       
       required public init(from decoder: Decoder) throws {
           let container = try decoder.container(keyedBy: ColorCodeKeys.self)
           collection = try? container.decode([ComponentElements].self, forKey: .collection)
       }
}
