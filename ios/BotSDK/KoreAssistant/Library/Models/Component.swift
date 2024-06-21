//
//  Component.swift
//  KoreBotSDKDemo
//
//  Created by developer@kore.com on 09/05/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import Foundation
import UIKit

enum ComponentType : Int {
    case text = 1, image = 2, options = 3, quickReply = 4, list = 5, carousel = 6, error = 7, chart = 8, table = 9, minitable = 10, responsiveTable = 11, menu = 12, newList = 13, tableList = 14, calendarView = 15, quick_replies_welcome = 16, notification = 17, multiSelect = 18, list_widget = 19, feedbackTemplate = 20, inlineForm = 21, dropdown_template = 22, transactionSuccessTemplate = 23, contactCardTemplate = 24, radioListTemplate = 25, pdfdownload = 26, updatedIdfcCarousel = 27, buttonLinkTemplate = 28, idfcFeedbackTemplate = 29, statusTemplate = 30, serviceListTemplate = 31, idfcAgentTemplate = 32, idfcCarouselType2 = 33 , cardSelection = 34, beneficiaryTemplate = 35, advanced_multi_select = 36, salaampointsTemplate = 37, welcome_template = 38, boldtextTemplate = 39, emptyBubbleTemplate = 40, custom_dropdown_template = 41, details_list_template = 42, search_template = 43, video = 44, bankingFeedbackTemplate = 45, audio = 46
}

class Component : NSObject {
    var componentType: ComponentType = .text
    var message: Message?
    var payload: String?
    var text: String?

    override init() {
        super.init()
    }
    
    convenience init(_ type: ComponentType) {
        self.init()
        componentType = type
    }
}
