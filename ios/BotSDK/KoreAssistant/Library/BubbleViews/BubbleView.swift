//
//  BubbleView.swift
//  KoreBotSDKDemo
//
//  Created by developer@kore.com on 26/05/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit

enum BubbleMaskTailPosition : Int {
    case none = 1, left = 2, right = 3
}

let brandingShared = BrandingSingleton.shared

var BubbleViewRightTint: UIColor = UIColor.init(hexString: (brandingShared.userchatBgColor) ?? "#37474f")
var BubbleViewLeftTint: UIColor = UIColor.init(hexString: (brandingShared.botchatBgColor) ?? "#fce9e6")
var BubbleViewUserChatTextColor: UIColor = UIColor.init(hexString: (brandingShared.userchatTextColor) ?? "#000000")
var BubbleViewBotChatTextColor: UIColor = UIColor.init(hexString: (brandingShared.botchatTextColor) ?? "#313131")
var bubbleViewBotChatButtonTextColor: UIColor = UIColor.init(hexString: (brandingShared.buttonActiveTextColor) ?? "#ffffff")
var bubbleViewBotChatButtonBgColor: UIColor = UIColor.init(hexString: (brandingShared.buttonActiveBgColor) ?? "#ff5e00")
var bubbleViewBotChatButtonInactiveTextColor: UIColor = UIColor.init(hexString: (brandingShared.buttonInactiveTextColor) ?? "#ff5e00")

var BubbleViewRightContrastTint: UIColor = Common.UIColorRGB(0xFFFFFF)
let BubbleViewLeftContrastTint: UIColor = Common.UIColorRGB(0xBCBCBC)
let BubbleViewCurveRadius: CGFloat = 20.0
let BubbleViewMaxWidth: CGFloat = (UIScreen.main.bounds.size.width - 50.0)  //90.0

class BubbleView: UIView {
    var tailPosition: BubbleMaskTailPosition! {
        didSet {
            self.backgroundColor = self.borderColor()
        }
    }
    var bubbleType: ComponentType!
    var didSelectComponentAtIndex:((Int) -> Void)!
    var maskLayer: CAShapeLayer!
    var borderLayer: CAShapeLayer!
    
    var components:NSArray! {
        didSet(c) {
            self.populateComponents()
        }
    }
    
    var drawBorder: Bool = false
    
    // MARK: init
    init() {
        super.init(frame: CGRect.zero)
        self.initialize()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    // MARK: bubbleWithType
    static func bubbleWithType(_ bubbleType: ComponentType) -> BubbleView{
        var bubbleView: BubbleView!
        
        switch (bubbleType) {
        case .text:
            bubbleView = TextBubbleView()
            break
        case .image, .video:
            let bundle = KREResourceLoader.shared.resourceBundle()
            bubbleView = bundle.loadNibNamed("MultiImageBubbleView", owner: self, options: nil)![0] as? BubbleView
            break
        case .audio:
            let bundle = KREResourceLoader.shared.resourceBundle()
            bubbleView =  bundle.loadNibNamed("AudioBubbleView", owner: self, options: nil)![0] as? BubbleView
            break
        case .options:
            bubbleView = OptionsBubbleView()
            break
        case .quickReply:
            bubbleView =  QuickReplyTextBubbleView()//QuickReplyBubbleView()
            break
        case .list:
            bubbleView = ListBubbleView()
            break
        case .carousel:
            bubbleView = CarouselBubbleView()
            break
        case .error:
            bubbleView = ErrorBubbleView()
            break
        case .chart:
            //bubbleView = ChartBubbleView()
            bubbleView = ErrorBubbleView()
            break
        case .table:
            bubbleView = TableBubbleView()
            break
        case .minitable:
            bubbleView = MiniTableBubbleView()
            break
        case .responsiveTable:
            bubbleView = ResponsiveTableBubbleView()
            break
        case .menu:
            bubbleView = MenuBubbleView()
            break
        case .newList:
            bubbleView = NewListBubbleView()
            break
        case .tableList:
            bubbleView = TableListBubbleView()
            break
        case .calendarView:
            bubbleView = CalenderBubbleView()
            break
        case .quick_replies_welcome:
            bubbleView = QuickReplyWelcomeBubbleView()
            break
        case .notification:
            bubbleView = NotificationBubbleView()
            break
        case .multiSelect:
            bubbleView = MultiSelectNewBubbleView()
            break
        case .list_widget:
            bubbleView = ListWidgetBubbleView()
            break
        case .feedbackTemplate:
            bubbleView = FeedbackBubbleView()
            break
        case .inlineForm:
            bubbleView = InLineFormBubbleView()
            break
        case .dropdown_template:
            bubbleView = DropDownBubbleView()
            break
        case .transactionSuccessTemplate:
            bubbleView = CongratulationsBubbleView()
            break
        case .contactCardTemplate:
            bubbleView = ContactCardBubbleView()
            break
        case .radioListTemplate:
             bubbleView = RadioListBubbleView()
             break
        case .pdfdownload:
             bubbleView = PDFBubbleView()
             break
        case .updatedIdfcCarousel:
             bubbleView = UpdatedCarouselBubbleView()
             break
        case .buttonLinkTemplate:
             bubbleView = ButtonLinkNBubbleView()
             break
        case .idfcFeedbackTemplate:
             bubbleView = IDFCFeedbackBubbleView()
             break
        case .statusTemplate:
             bubbleView = StatusTemplateBubbleView()
             break
        case .serviceListTemplate:
             bubbleView = ServiceListBubbleView()
             break
        case .idfcAgentTemplate:
            bubbleView = IDFCAgentBubbleView()
            break
        case .idfcCarouselType2:
            bubbleView = IDFCCarouselBubbleView()
            break
        case .cardSelection:
            bubbleView = CardSelectionBubbleView()
            break
        case .beneficiaryTemplate:
            bubbleView = BeneficiaryBubbleView()
            break
        case .advanced_multi_select:
            bubbleView = AdvancedMultiSelectBubbleView()
            break
        case .salaampointsTemplate:
            bubbleView = SalaamPointsBubbleView()
            break
        case .welcome_template:
             bubbleView = WelcomeTemplateBubbleView()
             break
        case .boldtextTemplate:
            bubbleView = BoldTextBubbleView()
            break
        case .emptyBubbleTemplate:
            bubbleView = EmptyBubbleView()
            break
        case .custom_dropdown_template:
            bubbleView = CustomDropDownTemplate()
            break
        case .details_list_template:
            bubbleView = DetailsListBubbleView()
            break
        case .search_template:
            bubbleView = SearchBubbleView()
            break
        case .bankingFeedbackTemplate:
            bubbleView = BankingFeedbackBubbleView()
            break
        }
        bubbleView.bubbleType = bubbleType
        
        return bubbleView
    }
    
    // MARK: 
    func initialize() {
        
    }
    
    // MARK: populate components
    func populateComponents() {
        
    }
    
    //MARK:- Method to be overridden
    func prepareForReuse() {
        
    }
    
    func transitionImage() -> UIImage {
        return UIImage()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.applyBubbleMask()
    }
    
    func contrastTintColor() -> UIColor {
        if (self.tailPosition == BubbleMaskTailPosition.left) {
            return BubbleViewLeftContrastTint
        }
        
        return BubbleViewRightContrastTint
    }
    
    func borderColor() -> UIColor {
        if (self.tailPosition == BubbleMaskTailPosition.left) {
            return BubbleViewLeftTint
        }
        
        return BubbleViewRightTint
    }
    
    func applyBubbleMask() {
        if(self.maskLayer == nil){
            self.maskLayer = CAShapeLayer()
            self.layer.mask = self.maskLayer
        }
        self.maskLayer.path = self.createBezierPath().cgPath
        self.maskLayer.position = CGPoint(x:0, y:0)
        
        if (self.drawBorder) {
            if(self.borderLayer == nil){
                self.borderLayer = CAShapeLayer()
                self.layer.addSublayer(self.borderLayer)
            }
            self.borderLayer.path = self.maskLayer.path // Reuse the Bezier path
            self.borderLayer.fillColor = UIColor.clear.cgColor
           // self.borderLayer.strokeColor = Common.UIColorRGB(0xebebeb).cgColor
            self.borderLayer.lineWidth = 0
            self.borderLayer.frame = self.bounds
            if selectedTheme == "Theme 1"{
               self.borderLayer.strokeColor = Common.UIColorRGB(0xebebeb).cgColor
            }else{
                self.borderLayer.strokeColor = UIColor.lightGray.cgColor
            }
        } else {
            if (self.borderLayer != nil) {
                self.borderLayer.removeFromSuperlayer()
                self.borderLayer = nil
            }
        }
    }
    
    func createBezierPath() -> UIBezierPath {
        // Drawing code
        let cornerRadius: CGFloat = BubbleViewCurveRadius
        var aPath = UIBezierPath()
        
        if(self.tailPosition == .left){
//            if preferred_language_Type == preferredLanguage{
//                aPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topLeft, .bottomLeft,.bottomRight],
//                cornerRadii: CGSize(width: 10.0, height: 0.0))
//            }else{
                aPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topRight, .bottomLeft,.bottomRight],
                cornerRadii: CGSize(width: 10.0, height: 0.0))
           // }
            
        }else{
//            if preferred_language_Type == preferredLanguage{
//                aPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topRight, .bottomLeft,.bottomRight],
//                cornerRadii: CGSize(width: 10.0, height: 0.0))
//            }else{
                aPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topLeft, .bottomLeft,.bottomRight],
                cornerRadii: CGSize(width: 10.0, height: 0.0))
            //}
        }
        aPath.close()
        return aPath
    }
}
