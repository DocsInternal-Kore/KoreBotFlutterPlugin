//
//  StatusTemplateBubbleView.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek.Pagidimarri on 06/12/21.
//  Copyright © 2021 Kore. All rights reserved.
//

import UIKit

class StatusTemplateBubbleView: BubbleView {
    
    var cardView: UIView!
    var headingLabel: KREAttributedLabel!
    var tagLabel: KREAttributedLabel!
    let kMaxTextWidth: CGFloat = BubbleViewMaxWidth - 40.0
    var tagLabelWidthConstraint: NSLayoutConstraint!
    
    public var optionsAction: ((_ text: String?, _ payload: String?) -> Void)!
    override func applyBubbleMask() {
        //nothing to put here
    }
    
    override var tailPosition: BubbleMaskTailPosition! {
        didSet {
            self.backgroundColor = .clear
        }
    }
    func intializeCardLayout(){
        self.cardView = UIView(frame:.zero)
        self.cardView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.cardView)
        cardView.layer.rasterizationScale =  UIScreen.main.scale
        cardView.layer.shadowColor = UIColor.clear.cgColor
        cardView.layer.shadowOpacity = 1
        cardView.layer.shadowOffset =  CGSize(width: 0.0, height: -3.0)
        cardView.layer.shadowRadius = 6.0
        cardView.layer.shouldRasterize = true
        cardView.layer.cornerRadius = 10.0
        cardView.backgroundColor =  BubbleViewLeftTint
        let cardViews: [String: UIView] = ["cardView": cardView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[cardView]-0-|", options: [], metrics: nil, views: cardViews))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[cardView]-0-|", options: [], metrics: nil, views: cardViews))
    }
    
    override func initialize() {
        super.initialize()
        intializeCardLayout()
        
        self.tagLabel = KREAttributedLabel(frame: CGRect.zero)
        self.tagLabel.textColor = BubbleViewBotChatTextColor
        self.tagLabel.backgroundColor = UIColor.clear
        self.tagLabel.font = UIFont(name: boldCustomFont, size: 10.0)
        self.tagLabel.numberOfLines = 0
        self.tagLabel.textAlignment = .center
        self.tagLabel.layer.cornerRadius = 5.0
        self.tagLabel.clipsToBounds = true
        self.tagLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.tagLabel.isUserInteractionEnabled = true
        self.tagLabel.translatesAutoresizingMaskIntoConstraints = false
        self.cardView.addSubview(self.tagLabel)
        
        self.headingLabel = KREAttributedLabel(frame: CGRect.zero)
        self.headingLabel.textColor = BubbleViewBotChatTextColor
        self.headingLabel.backgroundColor = UIColor.clear
        self.headingLabel.font = UIFont(name: regularCustomFont, size: 14.0)
        self.headingLabel.numberOfLines = 0
        self.headingLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.headingLabel.isUserInteractionEnabled = true
        self.headingLabel.translatesAutoresizingMaskIntoConstraints = false
        self.cardView.addSubview(self.headingLabel)
    
        
        let views: [String: UIView] = ["headingLabel": headingLabel, "tagLabel": tagLabel]
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[tagLabel(24)]-16-[headingLabel(>=15)]-16-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[headingLabel]-16-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[tagLabel]-16-|", options: [], metrics: nil, views: views))
        
        tagLabelWidthConstraint = NSLayoutConstraint.init(item: tagLabel as Any, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0)
        self.cardView.addConstraint(tagLabelWidthConstraint)
    }
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
    // MARK: populate components
    override func populateComponents() {
        
        if (components.count > 0) {
            let component: KREComponent = components.firstObject as! KREComponent
            if (component.componentDesc != nil) {
                let jsonString = component.componentDesc
                let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: jsonString!) as! NSDictionary
                
                let jsonDecoder = JSONDecoder()
                guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject as Any , options: .prettyPrinted),
                      let allItems = try? jsonDecoder.decode(Componentss.self, from: jsonData) else {
                    return
                }
                self.headingLabel.setHTMLString(allItems.text ?? "", withWidth: kMaxTextWidth)
                self.tagLabel.setHTMLString(allItems.tag?.title ?? "", withWidth: kMaxTextWidth)
                self.tagLabel.textColor =  UIColor.init(hexString: allItems.tag?.tagStyles?.color ?? "#ffffff")
                self.tagLabel.backgroundColor =  UIColor.init(hexString: allItems.tag?.tagStyles?.background ?? "#3afe00")
            }
        }
    }
    
    
    override var intrinsicContentSize : CGSize {
        let limitingSize: CGSize  = CGSize(width: kMaxTextWidth, height: CGFloat.greatestFiniteMagnitude)
        let headingLabelSize: CGSize = self.headingLabel.sizeThatFits(limitingSize)
        
        self.tagLabel.font = UIFont(name: boldCustomFont, size: 10.0)
        let tagLabelSize: CGSize = self.tagLabel.sizeThatFits(limitingSize)
        
        tagLabelWidthConstraint.constant = tagLabelSize.width + 10
        return CGSize(width: headingLabelSize.width + 32, height:  headingLabelSize.height + 42)
    }
}
