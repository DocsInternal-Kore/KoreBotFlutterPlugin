//
//  QuickReplyTextBubbleView.swift
//  react-native-kore-bot-sdk
//
//  Created by Kartheek Pagidimarri on 06/12/22.
//

import UIKit

class QuickReplyTextBubbleView: BubbleView {
    
    var tileBgv: UIView!
    var titleLbl: KREAttributedTextView!
    var cardView: UIView!
    let kMaxTextWidth: CGFloat = BubbleViewMaxWidth - 20.0
    let kMinTextWidth: CGFloat = 00.0
    
    var titleStr: String?
    
    
    override func applyBubbleMask() {
        //nothing to put here
        if(self.maskLayer == nil){
            self.maskLayer = CAShapeLayer()
        }
    }
    
    override var tailPosition: BubbleMaskTailPosition! {
        didSet {
            self.backgroundColor = .clear
        }
    }
    
    override func initialize() {
        super.initialize()
        
        intializeCardLayout()
        
        self.tileBgv = UIView(frame:.zero)
        self.tileBgv.translatesAutoresizingMaskIntoConstraints = false
        self.tileBgv.layer.rasterizationScale =  UIScreen.main.scale
        self.tileBgv.layer.shouldRasterize = true
        self.tileBgv.layer.cornerRadius = 10.0
        self.tileBgv.layer.borderColor = UIColor.lightGray.cgColor
        self.tileBgv.clipsToBounds = true
        self.tileBgv.layer.borderWidth = 0.0
        self.cardView.addSubview(self.tileBgv)
        self.tileBgv.backgroundColor = BubbleViewLeftTint
        
        let views: [String: UIView] = ["tileBgv": tileBgv]
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[tileBgv]-0-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[tileBgv]", options: [], metrics: nil, views: views))
        
        self.titleLbl = KREAttributedTextView(frame: CGRect.zero)
        self.titleLbl.textColor = Common.UIColorRGB(0x484848)
        self.titleLbl.mentionTextColor = .white
        self.titleLbl.hashtagTextColor = .white
        self.titleLbl.linkTextColor = .white
        self.titleLbl.font = UIFont(name: regularCustomFont, size: 14.0)
        self.titleLbl.backgroundColor = .clear
        self.titleLbl.isEditable = false
        self.titleLbl.isScrollEnabled = false
        self.titleLbl.textContainer.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.titleLbl.isUserInteractionEnabled = true
        self.titleLbl.contentMode = UIView.ContentMode.topLeft
        self.titleLbl.translatesAutoresizingMaskIntoConstraints = false
        self.titleLbl.linkTextColor = BubbleViewBotChatTextColor
        self.titleLbl.tintColor = BubbleViewBotChatTextColor
        self.tileBgv.addSubview(self.titleLbl)
        
        let subView: [String: UIView] = ["titleLbl": titleLbl]
        let metrics: [String: NSNumber] = ["textLabelMaxWidth": NSNumber(value: Float(kMaxTextWidth)), "textLabelMinWidth": NSNumber(value: Float(kMinTextWidth))]
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-16-[titleLbl]-16-|", options: [], metrics: metrics, views: subView))
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[titleLbl(>=textLabelMinWidth,<=textLabelMaxWidth)]-16-|", options: [], metrics: metrics, views: subView))
        
        
    }
    
    
    func intializeCardLayout(){
        self.cardView = UIView(frame:.zero)
        self.cardView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.cardView)
        cardView.backgroundColor =  UIColor.clear
        let cardViews: [String: UIView] = ["cardView": cardView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[cardView]-0-|", options: [], metrics: nil, views: cardViews))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[cardView]-0-|", options: [], metrics: nil, views: cardViews))
    }
    
    override func populateComponents() {
        if (components.count > 0) {
            let component: KREComponent = components[0] as! KREComponent
            
            if (!component.isKind(of: KREComponent.self)) {
                return;
            }

            if (component.componentDesc != nil) {
                let jsonString = component.componentDesc
                let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: jsonString!) as! NSDictionary

                if let string: String = jsonObject["text"] as? String {
                    let htmlStrippedString = KREUtilities.getHTMLStrippedString(from: string)
                    let parsedString:String = KREUtilities.formatHTMLEscapedString(htmlStrippedString);
                    self.titleLbl.setHTMLString(parsedString, withWidth: kMaxTextWidth)
                }else{
                    self.titleLbl.text = ""
                }
            }
        }
    }
    
    //MARK: View height calculation
    override var intrinsicContentSize : CGSize {
        self.titleLbl.textColor = BubbleViewBotChatTextColor
        self.titleLbl.mentionTextColor = BubbleViewBotChatTextColor
        self.titleLbl.hashtagTextColor = BubbleViewBotChatTextColor
        self.titleLbl.linkTextColor = BubbleViewBotChatTextColor
        self.titleLbl.tintColor = BubbleViewBotChatTextColor

        let limitingSize: CGSize  = CGSize(width: kMaxTextWidth, height: CGFloat.greatestFiniteMagnitude)
        var textSize: CGSize = self.titleLbl.sizeThatFits(limitingSize)
        if textSize.height < self.titleLbl.font?.pointSize ?? 0.0 {
            textSize.height = self.titleLbl.font?.pointSize ?? 0.0
        }
        return CGSize(width: textSize.width + 32, height: textSize.height + 32)
    }
}
