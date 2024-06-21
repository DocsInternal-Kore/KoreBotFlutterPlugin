//
//  WelcomeTemplateBubbleView.swift
//  KoreBotSDKFrameWork
//
//  Created by Kartheek.Pagidimarri on 10/10/22.
//  Copyright © 2022 Kartheek.Pagidimarri. All rights reserved.
//

import UIKit

class WelcomeTemplateBubbleView: BubbleView {
    var tileBgv: UIView!
    var tileBgSubv: UIView!
    var titleLbl: UILabel!
    var polyImgV: UIImageView!
    var welcomeImgV: UIImageView!
    var headingLbl: UILabel!
    var descLbl: UILabel!
    var cardView: UIView!
    let kMaxTextWidth: CGFloat = BubbleViewMaxWidth - 20.0
    let kMinTextWidth: CGFloat = 20.0
    var polyImgVLeadingConstarint: NSLayoutConstraint!
    var polyImgVWidthConstarint: NSLayoutConstraint!
    
    public var maskview: UIView!
    var suggestionLbl: UILabel!
    var collectionView: UICollectionView!
    let customCellIdentifier = "ButtonLinkCell"
    var arrayOfElements = [QuickRepliesWelcomeData]()
    var isReloadBtnLink = true
    var templateLanguage:String?
    public var optionsAction: ((_ text: String?, _ payload: String?) -> Void)!
    public var linkAction: ((_ text: String?) -> Void)!
   
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
       // UserDefaults.standard.set(false, forKey: "SliderKey")
        intializeCardLayout()
        
        self.polyImgV = UIImageView(frame: CGRect.zero)
        self.polyImgV.contentMode = .scaleAspectFit
        self.polyImgV.translatesAutoresizingMaskIntoConstraints = false
        let bundle = KREResourceLoader.shared.resourceBundle()
        self.polyImgV.image = UIImage.init(named: "Polygon", in: bundle, compatibleWith: nil)
        self.cardView.addSubview(self.polyImgV)
        self.polyImgV.contentMode = .scaleAspectFit
        //self.polyImgV.backgroundColor = UIColor.init(hexString: "#313131")
        
        self.tileBgv = UIView(frame:.zero)
        self.tileBgv.translatesAutoresizingMaskIntoConstraints = false
        self.tileBgv.layer.rasterizationScale =  UIScreen.main.scale
        self.tileBgv.layer.shouldRasterize = true
        self.tileBgv.layer.cornerRadius = 17.0
        self.tileBgv.clipsToBounds = true
        self.cardView.addSubview(self.tileBgv)
        self.tileBgv.backgroundColor = .clear
        
        self.welcomeImgV = UIImageView(frame: CGRect.zero)
        self.welcomeImgV.contentMode = .scaleAspectFit
        self.welcomeImgV.translatesAutoresizingMaskIntoConstraints = false
        self.welcomeImgV.image = UIImage.init(named: "welcome", in: bundle, compatibleWith: nil)
        self.cardView.addSubview(self.welcomeImgV)
        
        self.headingLbl = UILabel(frame: CGRect.zero)
        self.headingLbl.textColor = BubbleViewBotChatTextColor
        self.headingLbl.font = UIFont(name: regularCustomFont, size: 18.0)
        self.headingLbl.numberOfLines = 0
        self.headingLbl.textAlignment = .center
        self.headingLbl.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.headingLbl.isUserInteractionEnabled = true
        self.headingLbl.contentMode = UIView.ContentMode.topLeft
        self.headingLbl.translatesAutoresizingMaskIntoConstraints = false
        self.cardView.addSubview(self.headingLbl)
        self.headingLbl.adjustsFontSizeToFitWidth = true
        self.headingLbl.backgroundColor = .clear
        self.headingLbl.layer.cornerRadius = 6.0
        self.headingLbl.clipsToBounds = true
        self.headingLbl.sizeToFit()
        
        self.descLbl = UILabel(frame: CGRect.zero)
        self.descLbl.textColor = themeColor
        self.descLbl.font = UIFont(name: boldCustomFont, size: 20.0)
        self.descLbl.numberOfLines = 0
        self.descLbl.textAlignment = .center
        self.descLbl.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.descLbl.isUserInteractionEnabled = true
        self.descLbl.contentMode = UIView.ContentMode.topLeft
        self.descLbl.translatesAutoresizingMaskIntoConstraints = false
        self.cardView.addSubview(self.descLbl)
        self.descLbl.adjustsFontSizeToFitWidth = true
        self.descLbl.backgroundColor = .clear
        self.descLbl.layer.cornerRadius = 6.0
        self.descLbl.clipsToBounds = true
        self.descLbl.sizeToFit()
        
        self.suggestionLbl = UILabel(frame: CGRect.zero)
        self.suggestionLbl.textColor = BubbleViewBotChatTextColor
        self.suggestionLbl.font = UIFont(name: regularCustomFont, size: 10.0)
        self.suggestionLbl.numberOfLines = 0
        self.suggestionLbl.textAlignment = .left
        self.suggestionLbl.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.suggestionLbl.isUserInteractionEnabled = true
        self.suggestionLbl.contentMode = UIView.ContentMode.topLeft
        self.suggestionLbl.translatesAutoresizingMaskIntoConstraints = false
        self.cardView.addSubview(self.suggestionLbl)
        self.suggestionLbl.adjustsFontSizeToFitWidth = true
        self.suggestionLbl.backgroundColor = .clear
        self.suggestionLbl.layer.cornerRadius = 6.0
        self.suggestionLbl.clipsToBounds = true
        self.suggestionLbl.sizeToFit()
        
        let layout = TagFlowLayout()
        layout.scrollDirection = .vertical
        self.collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.backgroundColor = .clear
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.bounces = false
        self.collectionView.isScrollEnabled = true
        self.cardView.addSubview(self.collectionView)
        
        
        self.collectionView.register(UINib(nibName: "ButtonLinkCell", bundle: bundle),
                                     forCellWithReuseIdentifier: customCellIdentifier)
        
        self.maskview = UIView(frame:.zero)
        self.maskview.translatesAutoresizingMaskIntoConstraints = false
        self.cardView.addSubview(self.maskview)
        self.maskview.isHidden = true
        self.maskview.backgroundColor =  .clear //UIColor(white: 1, alpha: 0.5)
        
        
        let views: [String: UIView] = ["tileBgv": tileBgv,"polyImgV":polyImgV, "welcomeImgV": welcomeImgV, "headingLbl": headingLbl,"descLbl": descLbl, "suggestionLbl": suggestionLbl, "collectionView": collectionView,  "maskview": maskview]
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[tileBgv]-(-16)-[polyImgV(25)]-10-[welcomeImgV(0)]-32-[headingLbl(>=21)]-4-[descLbl(>=21)]-26-[suggestionLbl(16)]-15-[collectionView]-5-|", options: [], metrics: nil, views: views)) //152
        //self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[tileBgv]", options: [], metrics: nil, views: views))
        tileBgv.centerXAnchor.constraint(equalTo: cardView.centerXAnchor).isActive = true
        //self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-135.5-[polyImgV(25)]", options: [], metrics: nil, views: views))
        
        self.polyImgVLeadingConstarint = NSLayoutConstraint.init(item: self.polyImgV as Any, attribute: .leading, relatedBy: .equal, toItem: self.tileBgv, attribute: .leading, multiplier: 1.0, constant: 0.0)
        self.cardView.addConstraint(self.polyImgVLeadingConstarint)
        
        self.polyImgVWidthConstarint = NSLayoutConstraint.init(item: self.polyImgV as Any, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 25.0)
        self.cardView.addConstraint(self.polyImgVWidthConstarint)
        
        
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[welcomeImgV]-16-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[headingLbl]-16-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[descLbl]-16-|", options: [], metrics: nil, views: views))
        
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[suggestionLbl]-5-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[collectionView]-0-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[maskview]|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[maskview]-0-|", options: [], metrics: nil, views: views))
        
        self.tileBgSubv = UIView(frame:.zero)
        self.tileBgSubv.translatesAutoresizingMaskIntoConstraints = false
        self.tileBgSubv.layer.rasterizationScale =  UIScreen.main.scale
        self.tileBgSubv.layer.shouldRasterize = true
        self.tileBgSubv.layer.cornerRadius = 18.0
        self.tileBgSubv.clipsToBounds = true
        self.tileBgv.addSubview(self.tileBgSubv)
        self.tileBgv.backgroundColor =   UIColor.init(hexString: "#313131")
        
        self.titleLbl = UILabel(frame: CGRect.zero)
        self.titleLbl.textColor = BubbleViewUserChatTextColor
        self.titleLbl.font = UIFont(name: semiBoldCustomFont, size: 16.0)
        self.titleLbl.numberOfLines = 0
        self.titleLbl.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.titleLbl.isUserInteractionEnabled = true
        self.titleLbl.contentMode = UIView.ContentMode.topLeft
        self.titleLbl.translatesAutoresizingMaskIntoConstraints = false
        self.tileBgv.addSubview(self.titleLbl)
        self.titleLbl.adjustsFontSizeToFitWidth = true
        self.titleLbl.backgroundColor = .clear
        self.titleLbl.layer.cornerRadius = 6.0
        self.titleLbl.clipsToBounds = true
        self.titleLbl.sizeToFit()
        
        let subView: [String: UIView] = ["tileBgSubv": tileBgSubv,"titleLbl": titleLbl]
        let metrics: [String: NSNumber] = ["textLabelMaxWidth": NSNumber(value: Float(kMaxTextWidth)), "textLabelMinWidth": NSNumber(value: Float(kMinTextWidth))]
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[titleLbl]-10-|", options: [], metrics: metrics, views: subView))
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[titleLbl(>=textLabelMinWidth,<=textLabelMaxWidth)]-16-|", options: [], metrics: metrics, views: subView))
        
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[tileBgSubv]-0-|", options: [], metrics: metrics, views: subView))
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[tileBgSubv]-0-|", options: [], metrics: metrics, views: subView))
        
        if isReloadBtnLink {
            print("yeReload")
            isReloadBtnLink = false
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (_) in
              NotificationCenter.default.post(name: Notification.Name(reloadTableNotification), object: nil)
            }
        }
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
                self.titleLbl.text = allItems.title ?? ""
                self.headingLbl.text = allItems.heading ?? ""
                self.descLbl.text = allItems.transActionDesc ?? ""
                self.suggestionLbl.text = allItems.quick_reply_title ?? ""
                templateLanguage = allItems.lang ?? default_language
                arrayOfElements = allItems.quickReplies ?? []
                if (templateLanguage?.caseInsensitiveCompare(preferred_language_Type) == .orderedSame){
                    suggestionLbl.textAlignment = .right
                    collectionView.transform = CGAffineTransform(scaleX: -1, y: 1)
                }else{
                    suggestionLbl.textAlignment = .left
                    collectionView.transform = .identity
                }
                self.collectionView.collectionViewLayout.invalidateLayout()
                self.collectionView.reloadData()
            }
        }
    }
    
    //MARK: View height calculation
    override var intrinsicContentSize : CGSize {
        
        let limitingSize: CGSize  = CGSize(width: kMaxTextWidth, height: CGFloat.greatestFiniteMagnitude)
        var textSize: CGSize = self.titleLbl.sizeThatFits(limitingSize)
        if textSize.height < self.titleLbl.font.pointSize {
            textSize.height = self.titleLbl.font.pointSize
        }
        let verticalSpaceing = 72.0 + 47.0
        let welcomeImagVHeight = 0.0//152.0
        let collectionviewHeight  = Double(self.collectionView.collectionViewLayout.collectionViewContentSize.height)
        return CGSize(width: 0.0, height: 50 + verticalSpaceing + welcomeImagVHeight + CGFloat(collectionviewHeight) + 54)
    }
}
extension WelcomeTemplateBubbleView : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    //MARK: collection view delegate methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return arrayOfElements.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // swiftlint:disable force_cast
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: customCellIdentifier, for: indexPath) as! ButtonLinkCell
        cell.backgroundColor = .clear
        
        let elements = arrayOfElements[indexPath.row]
        cell.textlabel.text = elements.title
       
        cell.bgV.backgroundColor = .clear
        
        cell.textlabel.font = UIFont(name: semiBoldCustomFont, size: 12.0)
        cell.textlabel.textAlignment = .center
        let textColor =  UserDefaults.standard.value(forKey: "ButtonBgColor") as? String
        cell.textlabel.textColor = UIColor.init(hexString: textColor ?? "ff5e00")
        cell.textlabel.numberOfLines = 2
        cell.imagvWidthConstraint.constant = 0.0
        
        let borderColor =  UserDefaults.standard.value(forKey: "ButtonBgColor") as? String
        cell.layer.borderColor = UIColor.init(hexString: borderColor ?? "ff5e00").cgColor
        cell.layer.borderWidth = 1.5
        cell.layer.cornerRadius = 8
        let bgColor =  UserDefaults.standard.value(forKey: "ButtonTextColor") as? String
        cell.backgroundColor = UIColor.init(hexString: bgColor ?? "ffffff")
        
        if (templateLanguage?.caseInsensitiveCompare(preferred_language_Type) == .orderedSame){
            cell.transform = CGAffineTransform(scaleX: -1, y: 1)
        }else{
            cell.transform = .identity
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ButtonLinkCell
        
        let textColor =  UserDefaults.standard.value(forKey: "ButtonBgColor") as? String
        let bgColor =  UserDefaults.standard.value(forKey: "ButtonTextColor") as? String
        cell.textlabel.textColor = UIColor.init(hexString: bgColor ?? "ff5e00")
        cell.backgroundColor = UIColor.init(hexString: textColor ?? "ffffff")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let cell = collectionView.cellForItem(at: indexPath) as! ButtonLinkCell
        
            let textColor =  UserDefaults.standard.value(forKey: "ButtonBgColor") as? String
            cell.textlabel.textColor = UIColor.init(hexString: textColor ?? "ff5e00")
        
            let bgColor =  UserDefaults.standard.value(forKey: "ButtonTextColor") as? String
            cell.backgroundColor = UIColor.init(hexString: bgColor ?? "ffffff")
        }
        
        let elements = arrayOfElements[indexPath.row]
            if elements.type == "web_url"{
                    self.linkAction?(elements.url)
            }else{
                self.optionsAction?(elements.title, elements.payload)
            }
        self.maskview.isHidden = false
    }
//    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath){
//        let cell = collectionView.cellForItem(at: indexPath) as! ButtonLinkCell
//
//        let textColor =  UserDefaults.standard.value(forKey: "ButtonBgColor") as? String
//        let bgColor =  UserDefaults.standard.value(forKey: "ButtonTextColor") as? String
//        cell.textlabel.textColor = UIColor.init(hexString: bgColor ?? "ff5e00")
//        cell.contentView.backgroundColor = UIColor.init(hexString: textColor ?? "ffffff")
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath){
//        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { (_) in
//
//            let cell = collectionView.cellForItem(at: indexPath) as! ButtonLinkCell
//
//            let textColor =  UserDefaults.standard.value(forKey: "ButtonBgColor") as? String
//            cell.textlabel.textColor = UIColor.init(hexString: textColor ?? "ff5e00")
//
//            let bgColor =  UserDefaults.standard.value(forKey: "ButtonTextColor") as? String
//            cell.contentView.backgroundColor = UIColor.init(hexString: bgColor ?? "ffffff")
//        }
//
//    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var text:String?
        let elements = arrayOfElements[indexPath.row]
        text = elements.title
        
        var textWidth = 10
        let size = text?.size(withAttributes:[.font: UIFont(name: semiBoldCustomFont, size: 12.0) as Any])
        if text != nil {
            textWidth = Int(size!.width)
        }
        return CGSize(width: min(Int(maxContentWidth()) - 10 , textWidth + 32) , height: 40)
    }
    
    func maxContentWidth() -> CGFloat {
        if let collectionViewLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let sectionInset: UIEdgeInsets = collectionViewLayout.sectionInset
            return max(frame.size.width - sectionInset.left - sectionInset.right, 1.0)
        }
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
}
