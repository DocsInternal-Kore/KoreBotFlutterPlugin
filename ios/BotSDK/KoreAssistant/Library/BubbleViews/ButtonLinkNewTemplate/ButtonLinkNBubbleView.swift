//
//  ButtonLinkNBubbleView.swift
//  KoreBotSDKFrameWork
//
//  Created by Kartheek.Pagidimarri on 16/08/22.
//  Copyright © 2022 Kartheek.Pagidimarri. All rights reserved.
//

import UIKit
import korebotplugin
class ButtonLinkNBubbleView: BubbleView {
    var tileBgv: UIView!
    public var maskview: UIView!
    var titleLbl: KREAttributedTextView!
    var tableView: UITableView!
    var cardView: UIView!
    let kMaxTextWidth: CGFloat = BubbleViewMaxWidth - 32.0
    let kMinTextWidth: CGFloat = 20.0
    fileprivate let listCellIdentifier = "ButtonLinkNCell"
    var arrayOfElements = [ComponentElements]()
    
    var textLabelBottomConstraint: NSLayoutConstraint!
    var textLabelTopConstraint: NSLayoutConstraint!
    var textLabelHeightConstraint: NSLayoutConstraint!
    var templateLanguage:String?
    

    public var optionsAction: ((_ text: String?, _ payload: String?) -> Void)!
    public var linkAction: ((_ text: String?) -> Void)!
    
    var checkboxIndexPath = [IndexPath]()
    var arrayOfSeletedValues = [String]()
    var arrayOfSeletedTitles = [String]()
    
    override func prepareForReuse() {
        checkboxIndexPath = [IndexPath]()
         arrayOfSeletedValues = [String]()
        arrayOfSeletedTitles = [String]()
    }
    
    override func applyBubbleMask() {
        //nothing to put here
        if(self.maskLayer == nil){
            self.maskLayer = CAShapeLayer()
        }
        self.maskLayer.path = self.createBezierPath().cgPath
        self.maskLayer.position = CGPoint(x:0, y:0)
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
        self.tileBgv.layer.borderWidth = 1.0
        self.cardView.addSubview(self.tileBgv)
        self.tileBgv.backgroundColor = BubbleViewLeftTint
        if #available(iOS 11.0, *) {
            self.tileBgv.roundCorners([ .layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner], radius: 10.0, borderColor: UIColor.lightGray, borderWidth: 1.5)
        } else {
            // Fallback on earlier versions
        }
        
        self.tableView = UITableView(frame: CGRect.zero,style:.plain)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.backgroundColor = .clear
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.bounces = false
        self.tableView.separatorStyle = .none
        self.cardView.addSubview(self.tableView)
        self.tableView.isScrollEnabled = false
        let bundle = KREResourceLoader.shared.resourceBundle()
        self.tableView.register(UINib(nibName: listCellIdentifier, bundle: bundle), forCellReuseIdentifier: listCellIdentifier)
        
        self.maskview = UIView(frame:.zero)
        self.maskview.translatesAutoresizingMaskIntoConstraints = false
        self.cardView.addSubview(self.maskview)
        self.maskview.isHidden = true
        maskview.backgroundColor = .clear //UIColor(white: 1, alpha: 0.5)
        

        let views: [String: UIView] = ["tileBgv": tileBgv, "tableView": tableView, "maskview": maskview]
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[tileBgv]-(-5)-[tableView]-0-|", options: [], metrics: nil, views: views))
         self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[maskview]|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[tileBgv]-0-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[tableView]-0-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[maskview]-0-|", options: [], metrics: nil, views: views))


        
        self.titleLbl = KREAttributedTextView(frame: CGRect.zero)
        self.titleLbl.textColor = Common.UIColorRGB(0x484848)
        self.titleLbl.mentionTextColor = .white
        self.titleLbl.hashtagTextColor = .white
        self.titleLbl.linkTextColor = .white
        self.titleLbl.font = UIFont(name: mediumCustomFont, size: 14.0)
        self.titleLbl.backgroundColor = .clear
        self.titleLbl.isEditable = false
        self.titleLbl.isScrollEnabled = false
        self.titleLbl.textContainer.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.titleLbl.isUserInteractionEnabled = true
        self.titleLbl.contentMode = UIView.ContentMode.topLeft
        self.titleLbl.translatesAutoresizingMaskIntoConstraints = false
        self.titleLbl.linkTextColor = BubbleViewBotChatTextColor
        self.titleLbl.tintColor = BubbleViewBotChatTextColor
        self.titleLbl.textContainerInset = UIEdgeInsets.zero
        self.titleLbl.textContainer.lineFragmentPadding = 0
        self.tileBgv.addSubview(self.titleLbl)
        
        let subView: [String: UIView] = ["titleLbl": titleLbl]
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-16-[titleLbl]-16-|", options: [], metrics: nil, views: subView))
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[titleLbl]-16-|", options: [], metrics: nil, views: subView))
        
        self.textLabelBottomConstraint = NSLayoutConstraint.init(item: self.tileBgv as Any, attribute: .bottom, relatedBy: .equal, toItem: self.titleLbl, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        self.tileBgv.addConstraint(self.textLabelBottomConstraint)
        
        self.textLabelTopConstraint = NSLayoutConstraint.init(item: self.tileBgv as Any, attribute: .top, relatedBy: .equal, toItem: self.titleLbl, attribute: .top, multiplier: 1.0, constant: 0.0)
        self.tileBgv.addConstraint(self.textLabelTopConstraint)
        
        self.textLabelHeightConstraint = NSLayoutConstraint.init(item: self.tileBgv as Any, attribute: .height, relatedBy: .equal, toItem: self.titleLbl, attribute: .height, multiplier: 1.0, constant: 0.0)
        self.tileBgv.addConstraint(self.textLabelHeightConstraint)
        self.textLabelHeightConstraint.isActive = false
        
        //self.tileBgv.bringSubviewToFront(self.tableView)
         self.cardView.bringSubviewToFront(tileBgv)
         self.tileBgv.sendSubviewToBack(tableView)

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
    
    // MARK: populate components
    override func populateComponents() {
        
        if selectedTheme == "Theme 1"{
            self.tileBgv.layer.borderWidth = 0.0
        }else{
            self.tileBgv.layer.borderWidth = 0.0
        }
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
                arrayOfElements = allItems.elements ?? []
                
                self.titleLbl.setHTMLString(allItems.text ?? "", withWidth: kMaxTextWidth)
                templateLanguage = allItems.lang ?? default_language
                if (templateLanguage?.caseInsensitiveCompare(preferred_language_Type) == .orderedSame){
                    self.titleLbl.textAlignment = .right
//                    if #available(iOS 11.0, *) {
//                        self.tileBgv.roundCorners([ .layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner], radius: 10.0, borderColor: UIColor.clear, borderWidth: 1.5)
//                    }
                }else{
                    self.titleLbl.textAlignment = .left
//                    if #available(iOS 11.0, *) {
//                        self.tileBgv.roundCorners([ .layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner], radius: 10.0, borderColor: UIColor.clear, borderWidth: 1.5)
//                    }
                }
                tableView.reloadData()
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
        
        var cellHeight : CGFloat = 0.0
        
        let rows = arrayOfElements.count
        var finalHeight: CGFloat = 0.0
        var verticalSpace = 32
        var textHeight = textSize.height
        
        self.textLabelTopConstraint.constant = 16
        self.textLabelBottomConstraint.constant = 16
        
        
        self.textLabelHeightConstraint.isActive = false
        if textSize.width == 0.0{
             verticalSpace = 0
            self.textLabelTopConstraint.constant = 0
            self.textLabelBottomConstraint.constant = 0
            self.textLabelHeightConstraint.constant = 0
            textHeight = 0
            self.textLabelHeightConstraint.isActive = true
        }
        
        for _ in 0..<rows {
            cellHeight = 52
            finalHeight += cellHeight
        }
        return CGSize(width: 0.0, height: textHeight + CGFloat(verticalSpace) + finalHeight)
    }
}


extension ButtonLinkNBubbleView: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 52
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 52
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return arrayOfElements.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : ButtonLinkNCell = tableView.dequeueReusableCell(withIdentifier: listCellIdentifier) as! ButtonLinkNCell
        cell.selectionStyle = .none
        let elements = arrayOfElements[indexPath.row]
        cell.titleBtn.setTitle(elements.title, for: .normal)
        cell.titleBtn.isUserInteractionEnabled = false
        if (templateLanguage?.caseInsensitiveCompare(preferred_language_Type) == .orderedSame){
            cell.titleBtn.semanticContentAttribute = .forceRightToLeft
            cell.titleBtn.titleEdgeInsets = UIEdgeInsets(top: 2, left: 0, bottom: 0, right: 15)
            if let samePageNavigation = elements.isSamePageNavigation, samePageNavigation{
              cell.titleBtn.setImage(UIImage.init(named: "deeplink"), for: .normal)
            }else{
              cell.titleBtn.setImage(UIImage.init(named: "external_link"), for: .normal)
            }
        }else{
            cell.titleBtn.semanticContentAttribute = .forceLeftToRight
            cell.titleBtn.titleEdgeInsets = UIEdgeInsets(top: 2, left: 15, bottom: 0, right: 0)
            if let samePageNavigation = elements.isSamePageNavigation, samePageNavigation{
              cell.titleBtn.setImage(UIImage.init(named: "deeplinkE"), for: .normal)
            }else{
              cell.titleBtn.setImage(UIImage.init(named: "external_linkE"), for: .normal)
             }
        }
      return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let elements = arrayOfElements[indexPath.row]
        if let isSamePageNavigation = elements.isSamePageNavigation, isSamePageNavigation == true{
            //self.maskview.isHidden = false
            showMaskVInBtnLink = false
            let dic = ["event_code": "DEEPLINK_ROUTER", "event_message": "Deeplink navigation", "path": "\(elements.elementUrl ?? "")"]
            let jsonString = Utilities.stringFromJSONObject(object: dic)
            NotificationCenter.default.post(name: Notification.Name(CallbacksNotification), object: jsonString)
            NotificationCenter.default.post(name: Notification.Name(botClosedNotification), object: nil)
        }else{
            //self.maskview.isHidden = false
            if let url = elements.elementUrl{
                showMaskVInBtnLink = false
                self.linkAction(url)
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
}
