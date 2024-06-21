//
//  BrandingSingleton.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek.Pagidimarri on 12/11/20.
//  Copyright © 2020 Kore. All rights reserved.
//

import UIKit

class BrandingSingleton: NSObject {
    
    // MARK: Shared Instance
    static let shared = BrandingSingleton()
    
    // MARK: Local Variable
    var widgetBorderColor: String?
    var widgetTextColor: String?
    var buttonInactiveBgColor: String?
    var buttonInactiveTextColor: String?
    var widgetBgColor: String?
    var botchatTextColor: String?
    var buttonActiveBgColor: String?
    var buttonActiveTextColor: String?
    var userchatBgColor: String?
    var theme: String?
    var botName: String?
    var botchatBgColor: String?
    var userchatTextColor: String?
    var widgetDividerColor: String?
    
    var bankLogo: String?
    var widgetBgImage: String?
    var widgetBodyColor: String?
    var widgetFooterColor: String?
    var widgetFooterTextColor: String?
    var widgetFooterPlaceholderColor: String?
    var widgetHeaderColor: String?
    
    var hamburgerOptions: Dictionary<String, Any>?
    var brandingInfoModel: BrandingModel?
    
    let brandingjsonStr = "{\"_id\":\"wsth-7560022f-5e9f-5cf7-a2d3-2c506b1ca8cb\",\"streamId\":\"st-b9889c46-218c-58f7-838f-73ae9203488c\",\"__v\":0,\"activeTheme\":true,\"botMessage\":{\"bubbleColor\":\"#dfb462\",\"fontColor\":\"#ffffff\",\"borderColor\":\"#F3F5F8\"},\"buttons\":{\"defaultButtonColor\":\"#21b2ed\",\"defaultFontColor\":\"#e91e1e\",\"onHoverButtonColor\":\"#9dc3fa\",\"onHoverFontColor\":\"#ff0000\",\"borderColor\":\"#0D6EFD\"},\"createdBy\":\"u-f37609a4-6430-5f4c-8724-abfc08e174ae\",\"createdOn\":\"2024-06-06T11:19:14.177Z\",\"defaultTheme\":false,\"digitalViews\":{\"panelTheme\":\"theme_one\"},\"generalAttributes\":{\"fontStyle\":\"arial\",\"bubbleShape\":\"square\",\"borderColor\":\"#F3F5F8\"},\"lastModifiedBy\":\"u-f37609a4-6430-5f4c-8724-abfc08e174ae\",\"lastModifiedOn\":\"2024-06-10T12:03:53.253Z\",\"refId\":\"6681d92f-03da-57c2-ac99-f5307f357efa\",\"state\":\"published\",\"themeName\":\"newtheme\",\"userMessage\":{\"bubbleColor\":\"#f515e3\",\"fontColor\":\"#060505\",\"borderColor\":\"#0D6EFD\"},\"widgetBody\":{\"backgroundImage\":\"\",\"backgroundColor\":\"#ffffff\",\"useBackgroundImage\":false},\"widgetFooter\":{\"backgroundColor\":\"#dff9fd\",\"fontColor\":\"#0007ff\",\"borderColor\":\"#ffffff\",\"placeHolder\":\"#000000\"},\"widgetHeader\":{\"backgroundColor\":\"#0048ff\",\"fontColor\":\"#ffffff\",\"borderColor\":\"#e5e8ec\"}}"
}
