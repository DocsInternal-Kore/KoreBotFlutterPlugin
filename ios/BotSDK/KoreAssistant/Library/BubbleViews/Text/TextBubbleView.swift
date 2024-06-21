//
//  TextBubbleView.swift
//  KoreBotSDKDemo
//
//  Created by developer@kore.com on 09/05/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit

class TextBubbleView : BubbleView {
    var onChange: ((_ reload: Bool) -> ())!
    func kTextColor() -> UIColor {
        //return (self.tailPosition == BubbleMaskTailPosition.left ? Common.UIColorRGB(0x484848) : Common.UIColorRGB(0xFFFFFF))
        return (self.tailPosition == BubbleMaskTailPosition.left ? BubbleViewBotChatTextColor : BubbleViewUserChatTextColor)
    }
    let kMaxTextWidth: CGFloat = BubbleViewMaxWidth - 20.0
    let kMinTextWidth: CGFloat = 20.0
    var textLabel: KREAttributedLabel!
    
    override func initialize() {
        super.initialize()
        
        self.textLabel = KREAttributedLabel(frame: CGRect.zero)
        self.textLabel.textColor = Common.UIColorRGB(0x484848)
        self.textLabel.mentionTextColor = BubbleViewBotChatTextColor
        self.textLabel.hashtagTextColor = BubbleViewBotChatTextColor
        self.textLabel.linkTextColor = BubbleViewBotChatTextColor
        self.textLabel.tintColor = BubbleViewBotChatTextColor
        
        self.textLabel.font = UIFont(name: mediumCustomFont, size: 14.0)
        self.textLabel.numberOfLines = 0
        self.textLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.textLabel.isUserInteractionEnabled = true
        self.textLabel.contentMode = UIView.ContentMode.topLeft
        self.textLabel.translatesAutoresizingMaskIntoConstraints = false
        self.textLabel.imageDetectionBlock = {[weak self] (reload) in
            self?.onChange(reload)
        }

        self.addSubview(self.textLabel)
        
        let views: [String: UIView] = ["textLabel": textLabel]
        let metrics: [String: NSNumber] = ["textLabelMaxWidth": NSNumber(value: Float(kMaxTextWidth)), "textLabelMinWidth": NSNumber(value: Float(kMinTextWidth))]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-16-[textLabel]-14-|", options: [], metrics: metrics, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[textLabel(>=textLabelMinWidth,<=textLabelMaxWidth)]-16-|", options: [], metrics: metrics, views: views))
        if preferred_language_Type == preferredLanguage{
            textLabel.semanticContentAttribute = .forceRightToLeft
        }else{
            textLabel.semanticContentAttribute = .forceLeftToRight
        }
    }
    
    func setTextColor() {
        if self.tailPosition == BubbleMaskTailPosition.left {
            self.textLabel.textColor = BubbleViewBotChatTextColor
            self.textLabel.linkTextColor = BubbleViewBotChatTextColor//Common.UIColorRGB(0x3EA3AD)
            self.textLabel.mentionTextColor = BubbleViewBotChatTextColor
            self.textLabel.hashtagTextColor = BubbleViewBotChatTextColor
            self.textLabel.tintColor = BubbleViewBotChatTextColor
        }else{
            self.textLabel.textColor = BubbleViewUserChatTextColor
            self.textLabel.linkTextColor = BubbleViewUserChatTextColor
            self.textLabel.mentionTextColor = BubbleViewUserChatTextColor
            self.textLabel.hashtagTextColor = BubbleViewUserChatTextColor
            self.textLabel.tintColor = BubbleViewUserChatTextColor
            textLabel.semanticContentAttribute = .forceLeftToRight
        }
    }
    
    // MARK: populate components
    override func populateComponents() {
        if (components.count > 0) {
            let component: KREComponent = components[0] as! KREComponent
            
            if (!component.isKind(of: KREComponent.self)) {
                return;
            }
            
            setTextColor()
            if ((component.componentDesc) != nil) {
                let string: String = component.componentDesc! as String
                var htmlStr = false
                let character: Character = "_"
                if string.contains(character) {
                    htmlStr = true
                }
                if isHtmlString(for: string) || htmlStr == true{
                    self.textLabel.setHTMLString(string, withWidth: kMaxTextWidth)
                }else{
                    var replaceStr = string
                    replaceStr = replaceStr.replacingOccurrences(of: "&quot;", with: "\"")
                    self.textLabel.setString(replaceStr, withWidth: kMaxTextWidth)
                }
            }
        }
    }
    func isHtmlString(for text: String) -> Bool {
        let regex = try! NSRegularExpression(pattern: #"\[[^\[]*?\]\([^\)]*\)"#, options: [.caseInsensitive])
        let range = NSRange(location: 0, length: text.count)
        let matches = regex.matches(in: text, options: [], range: range)
        return matches.first != nil
    }
    override var intrinsicContentSize : CGSize {
        let limitingSize: CGSize  = CGSize(width: kMaxTextWidth, height: CGFloat.greatestFiniteMagnitude)
        var textSize: CGSize = self.textLabel.sizeThatFits(limitingSize)
        if textSize.height < self.textLabel.font.pointSize {
            textSize.height = self.textLabel.font.pointSize
        }
        return CGSize(width: textSize.width + 32, height: textSize.height + 30)
    }
}

class QuickReplyBubbleView : TextBubbleView {
    
    override func populateComponents() {
        if (components.count > 0) {
            let component: KREComponent = components[0] as! KREComponent
            
            if (!component.isKind(of: KREComponent.self)) {
                return;
            }
            
            self.textLabel.textColor = self.kTextColor()
            if (component.componentDesc != nil) {
                let jsonString = component.componentDesc
                let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: jsonString!) as! NSDictionary

                if let string: String = jsonObject["text"] as? String {
                    let htmlStrippedString = KREUtilities.getHTMLStrippedString(from: string)
                    let parsedString:String = KREUtilities.formatHTMLEscapedString(htmlStrippedString);
                    self.textLabel.setHTMLString(parsedString, withWidth: kMaxTextWidth)
                    
                    self.textLabel.textColor = BubbleViewBotChatTextColor
                    self.textLabel.mentionTextColor = BubbleViewBotChatTextColor
                    self.textLabel.hashtagTextColor = BubbleViewBotChatTextColor
                    self.textLabel.linkTextColor = UIColor.red
                    self.textLabel.tintColor = BubbleViewBotChatTextColor
                }else{
                    self.textLabel.text = ""
                }
            }
        }
    }
}

class ErrorBubbleView : TextBubbleView {
    
    override func populateComponents() {
        if (components.count > 0) {
            let component: KREComponent = components[0] as! KREComponent
            
            if (!component.isKind(of: KREComponent.self)) {
                return;
            }
            
            if (component.componentDesc != nil) {
                let jsonString = component.componentDesc
                let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: jsonString!) as! NSDictionary
                
                if let string: String = jsonObject["text"] as? String{
                    let htmlStrippedString = KREUtilities.getHTMLStrippedString(from: string)
                    let parsedString:String = KREUtilities.formatHTMLEscapedString(htmlStrippedString);
                    self.textLabel.setHTMLString(parsedString, withWidth: kMaxTextWidth)
                }else{
                    self.textLabel.setHTMLString("", withWidth: kMaxTextWidth)
                }
            
                if var colorString: String = jsonObject["color"] as? String {
                    if(colorString.hasPrefix("#")){
                        colorString = String(colorString.dropFirst())
                    }
                    self.textLabel.textColor = Common.UIColorRGB(Int(colorString, radix: 16)!)
                }
            }
        }
    }
}

extension String {
    func condenseWhitespace() -> String {
        let components = self.components(separatedBy: .whitespacesAndNewlines)
        return components.filter { !$0.isEmpty }.joined(separator: " ")
    }
}

