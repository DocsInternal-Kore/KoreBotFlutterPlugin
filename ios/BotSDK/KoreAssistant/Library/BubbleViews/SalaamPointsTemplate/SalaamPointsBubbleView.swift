//
//  SalaamPointsBubbleView.swift
//  KoreBotSDKFrameWork
//
//  Created by Kartheek.Pagidimarri on 09/08/22.
//  Copyright © 2022 Kartheek.Pagidimarri. All rights reserved.
//

import UIKit
import korebotplugin
class SalaamPointsBubbleView: BubbleView {
    let bundle = KREResourceLoader.shared.resourceBundle()
    var tileBgv: UIView!
    public var maskview: UIView!
    var titleLbl: KREAttributedLabel!
    var tableView: UITableView!
    var cardView: UIView!
    let kMaxTextWidth: CGFloat = BubbleViewMaxWidth - 32.0
    let kMinTextWidth: CGFloat = 20.0
    fileprivate let listCellIdentifier = "SalaamElemetsCell"
    fileprivate let listCellICarddentifier = "SalaamPointsCardCell"
    var arrayOfElements = [ComponentElements]()
    var arrayOfCardDetails = [ComponentElements]()
    var submitBtnTitle = "Submit"
    public var optionsAction: ((_ text: String?, _ payload: String?) -> Void)!
    public var linkAction: ((_ text: String?) -> Void)!
    var templateLanguage:String?
    
    var isCopyBtnEnabled =  false
    var isShareBtnEnabled = false
    var isShowFooterView = false
    
    var checkboxIndexPath = [IndexPath]()
    var arrayOfSeletedValues = [String]()
    var arrayOfSeletedTitles = [String]()
    
    var copyTitle = ""
    var shareTitle = ""
    
    let lbl = UILabel()
    var dynamicCellHeight = [Int]()
    
    var isShowMore = false
    
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
            self.tileBgv.roundCorners([ .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner], radius: 10.0, borderColor: UIColor.lightGray, borderWidth: 1.5)
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
        self.tableView.register(UINib(nibName: listCellIdentifier, bundle: bundle), forCellReuseIdentifier: listCellIdentifier)
        self.tableView.register(UINib(nibName: listCellICarddentifier, bundle: bundle), forCellReuseIdentifier: listCellICarddentifier)
        
        
//        self.tableView.layer.cornerRadius = 2.0
//        self.tableView.clipsToBounds = true
//        self.tableView.layer.masksToBounds = false
//        self.tableView.layer.shadowColor = UIColor.lightGray.cgColor
//        self.tableView.layer.shadowOffset =  CGSize.zero
//        self.tableView.layer.shadowOpacity = 0.3
//        self.tableView.layer.shadowRadius = 4
//        self.tableView.layer.shadowOffset = CGSize(width: 0 , height:2)
        
        self.maskview = UIView(frame:.zero)
        self.maskview.translatesAutoresizingMaskIntoConstraints = false
        self.cardView.addSubview(self.maskview)
        self.maskview.isHidden = true
        maskview.backgroundColor = .clear //UIColor(white: 1, alpha: 0.5)
        

        let views: [String: UIView] = ["tileBgv": tileBgv, "tableView": tableView, "maskview": maskview]
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[tileBgv]-16-[tableView]-0-|", options: [], metrics: nil, views: views))
         self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[maskview]|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[tileBgv]-0-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[tableView]-0-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[maskview]-0-|", options: [], metrics: nil, views: views))

        self.titleLbl = KREAttributedLabel(frame: CGRect.zero)
        self.titleLbl.textColor = BubbleViewBotChatTextColor
        self.titleLbl.linkTextColor = BubbleViewBotChatTextColor
        self.titleLbl.mentionTextColor = BubbleViewBotChatTextColor
        self.titleLbl.hashtagTextColor = BubbleViewBotChatTextColor
        self.titleLbl.font = UIFont(name: mediumCustomFont, size: 14.0)
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
        
        let subView: [String: UIView] = ["titleLbl": titleLbl]
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-16-[titleLbl(>=21)]-16-|", options: [], metrics: nil, views: subView))
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[titleLbl]-16-|", options: [], metrics: nil, views: subView))

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
                //print(jsonObject)
                let jsonDecoder = JSONDecoder()
                guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject as Any , options: .prettyPrinted),
                    let allItems = try? jsonDecoder.decode(Componentss.self, from: jsonData) else {
                                                return
                                        }
                arrayOfElements = allItems.elements ?? []
                arrayOfCardDetails = allItems.cardDetails ?? []
                
                var FinalcardDetails = [ComponentElements]()
                FinalcardDetails = allItems.cardDetails ?? []
                var cardDetails = [ComponentElements]()
                for i in 0..<FinalcardDetails.count{
                    let cards = FinalcardDetails[i]
                    if let isHide = cards.hide,  isHide == true{
                        //arrayOfCardDetails.remove(at: i)
                    }else{
                        cardDetails.append(FinalcardDetails[i])
                    }
                }
                arrayOfCardDetails = cardDetails
                
                dynamicCellHeight = []
                for i in 0..<arrayOfCardDetails.count {
                    let details = arrayOfCardDetails[i]
                    let values = details.value
                    lbl.numberOfLines = 0
                    lbl.font = UIFont(name: regularCustomFont, size: 14.0)
                    lbl.text = values
                    let width = UIScreen.main.bounds.size.width - 50 
                    let height = lbl.systemLayoutSizeFitting(CGSize(width: width, height: UIView.layoutFittingCompressedSize.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel).height
                    print("height...\(height)")
                    if height > 26{
                        let hhh = height/2 + 8 //- 55
                        dynamicCellHeight.append(Int(hhh))
                        
                    }else{
                        dynamicCellHeight.append(0)
                    }
                }
                
                //self.titleLbl.text = allItems.title ?? ""
                if let string: String = allItems.title {
                    let htmlStrippedString = KREUtilities.getHTMLStrippedString(from: string)
                    let parsedString:String = KREUtilities.formatHTMLEscapedString(htmlStrippedString);
                    self.titleLbl.setHTMLString(parsedString, withWidth: kMaxTextWidth)
                }else{
                    self.titleLbl.text = ""
                }
                templateLanguage = allItems.lang ?? default_language
                if (templateLanguage?.caseInsensitiveCompare(preferred_language_Type) == .orderedSame){
                    self.titleLbl.textAlignment = .right
                }else{
                    self.titleLbl.textAlignment = .left
                }
                isShowMore = (allItems.seeMore != nil ? allItems.seeMore : false)!
                if isShowMore{
                    isShowFooterView = true
                }
                
                copyTitle = ""
                shareTitle = ""
                if let headerActions = allItems.headerActions{
//                     isCopyBtnEnabled = headerActions.copy != nil ? headerActions.copy ?? false : false
//                     isShareBtnEnabled = headerActions.share != nil ? headerActions.share ?? false : false
                    isCopyBtnEnabled = headerActions.copyBtn?.enable != nil ? headerActions.copyBtn?.enable ?? false : false
                    isShareBtnEnabled = headerActions.shareBtn?.enable != nil ? headerActions.shareBtn?.enable ?? false : false
                    copyTitle = headerActions.copyBtn?.title ?? ""
                    shareTitle = headerActions.shareBtn?.title ?? ""
                    if isCopyBtnEnabled || isShareBtnEnabled{
                        isShowFooterView = true
                    }
                }
                tableView.reloadData()
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
        
        var cellHeight : CGFloat = 0.0
        
        let rows = arrayOfElements.count
        var finalHeight: CGFloat = 0.0
        let verticalSpace = 32 + 20
        for _ in 0..<rows {
            cellHeight = 62
            finalHeight += cellHeight
        }
        
        //dynamicCellHeight = []
        for i in 0..<arrayOfCardDetails.count {
//            cellHeight = 74
//            finalHeight += cellHeight
            let details = arrayOfCardDetails[i]
            let values = details.value
            lbl.numberOfLines = 0
            lbl.font = UIFont(name: regularCustomFont, size: 14.0)
            lbl.text = values
            let width = UIScreen.main.bounds.size.width - 50 // the width of the view you are constraint to, keep in mind any applied margins here
            let height = lbl.systemLayoutSizeFitting(CGSize(width: width, height: UIView.layoutFittingCompressedSize.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel).height
            print("height...\(height)")
            if height > 26{
               // let hhh = height/2 + 8 //- 55
                //dynamicCellHeight.append(Int(hhh))
                let ddHeight = dynamicCellHeight[i]
                cellHeight = CGFloat(64 + Int(ddHeight))//hhh
            }else{
               // dynamicCellHeight.append(0)
                cellHeight = 74
            }
            
            finalHeight += cellHeight
        }
        
        var footerViewHeight = 0.0
        if isShowFooterView{
            footerViewHeight = 50.0
        }
        
        return CGSize(width: 0.0, height: textSize.height+CGFloat(verticalSpace) + finalHeight + CGFloat(footerViewHeight))
    }
}
extension SalaamPointsBubbleView: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            return 62
        }else{
            if dynamicCellHeight.count>0{
                let heighttt = dynamicCellHeight[indexPath.row]
                    if heighttt != 0{
                        let txtHeight = heighttt
                        return CGFloat(64 + txtHeight)
                    }else{
                        return 74
                    }
            }
            return 74
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            return 62
        }else{
            if dynamicCellHeight.count>0{
                let heighttt = dynamicCellHeight[indexPath.row]
                    if heighttt != 0{
                        let txtHeight = heighttt
                        return CGFloat(64 + txtHeight)
                    }else{
                        return 74
                    }
            }
            return 74
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return arrayOfElements.count
        }
        return arrayOfCardDetails.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell : SalaamElemetsCell = tableView.dequeueReusableCell(withIdentifier: listCellIdentifier) as! SalaamElemetsCell
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
            let elements = arrayOfElements[indexPath.row]
            cell.titleLbl.text = elements.title
            cell.valueLbl.text = elements.value
            if (templateLanguage?.caseInsensitiveCompare(preferred_language_Type) == .orderedSame){
                cell.bgView.semanticContentAttribute = .forceRightToLeft
                cell.titleLbl.textAlignment = .right
                cell.valueLbl.textAlignment = .left
            }else{
                cell.bgView.semanticContentAttribute = .forceLeftToRight
                cell.titleLbl.textAlignment = .left
                cell.valueLbl.textAlignment = .right
            }
            return cell
        }else{
            let cell : SalaamPointsCardCell = tableView.dequeueReusableCell(withIdentifier: listCellICarddentifier) as! SalaamPointsCardCell
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
            let cardsDetails = arrayOfCardDetails[indexPath.row]
            cell.offersLbl.text = cardsDetails.title
            //cell.cardLbl.text = cardsDetails.value
            if let cardValue = cardsDetails.value{
                cell.cardLbl.setHTMLString(cardValue, withWidth: kMaxTextWidth)
//                if cardValue.contains("**"){
//                    cell.cardTxtV.text = cardValue
//                }else{
                    cell.cardTxtV.setHTMLString(cardValue, withWidth: kMaxTextWidth)
                //}
                self.textLinkDetection(textLabel: cell.cardLbl)
                self.textViewLinkDetection(textLabel: cell.cardTxtV)
            }
            if (templateLanguage?.caseInsensitiveCompare(preferred_language_Type) == .orderedSame){
                cell.bgView.semanticContentAttribute = .forceRightToLeft
                cell.offersLbl.textAlignment = .right
                cell.cardLbl.textAlignment = .right
                cell.cardTxtV.textAlignment = .right
            }else{
                cell.bgView.semanticContentAttribute = .forceLeftToRight
                cell.offersLbl.textAlignment = .left
                cell.cardLbl.textAlignment = .left
                cell.cardTxtV.textAlignment = .left
            }
            if let color = cardsDetails.color{
                cell.cardTxtV.textColor = UIColor.init(hexString: (color))
            }
            
            cell.copyBtn.addTarget(self, action: #selector(copyBtnAction(_:)), for: .touchUpInside)
            cell.copyBtn.tag = indexPath.row
            cell.copyBtnWidthConstraint.constant = 0
            if let copy = cardsDetails.copyValue{
                let size = copy.size(withAttributes:[.font: UIFont(name: mediumCustomFont, size: 12.0)!])
                cell.copyBtnWidthConstraint.constant = size.width + 10
                cell.copyBtn.setTitle(copy, for: .normal)
            }
            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let elements = arrayOfComponents[indexPath.row]
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        
            let copyBtn = UIButton(frame: CGRect.zero)
        copyBtn.backgroundColor = .clear
        copyBtn.translatesAutoresizingMaskIntoConstraints = false
        copyBtn.clipsToBounds = true
        copyBtn.layer.cornerRadius = 5
        copyBtn.setTitleColor(themeColor, for: .normal)
        copyBtn.setTitleColor(Common.UIColorRGB(0x999999), for: .disabled)
        copyBtn.titleLabel?.font = UIFont(name: mediumCustomFont, size: 12.0)
            view.addSubview(copyBtn)
        copyBtn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
        copyBtn.addTarget(self, action: #selector(self.copyButtonAction(_:)), for: .touchUpInside)
        copyBtn.setTitle(copyTitle, for: .normal)
        copyBtn.layer.borderWidth = 1
        copyBtn.layer.borderColor = themeColor.cgColor
        
        let shareBtn = UIButton(frame: CGRect.zero)
        shareBtn.backgroundColor = .clear
        shareBtn.translatesAutoresizingMaskIntoConstraints = false
        shareBtn.clipsToBounds = true
        shareBtn.layer.cornerRadius = 5
        shareBtn.setTitleColor(themeColor, for: .normal)
        shareBtn.setTitleColor(Common.UIColorRGB(0x999999), for: .disabled)
        shareBtn.titleLabel?.font = UIFont(name: mediumCustomFont, size: 12.0)
        view.addSubview(shareBtn)
        shareBtn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
        shareBtn.addTarget(self, action: #selector(self.shareButtonAction(_:)), for: .touchUpInside)
        shareBtn.setTitle(shareTitle, for: .normal)
        shareBtn.layer.borderWidth = 1
        shareBtn.layer.borderColor = themeColor.cgColor
            
            
        let showMoreBtn = UIButton(frame: CGRect.zero)
        showMoreBtn.backgroundColor = .clear
        showMoreBtn.translatesAutoresizingMaskIntoConstraints = false
        showMoreBtn.clipsToBounds = true
        showMoreBtn.layer.cornerRadius = 5
        showMoreBtn.setTitleColor(themeColor, for: .normal)
        showMoreBtn.setTitleColor(Common.UIColorRGB(0x999999), for: .disabled)
        showMoreBtn.titleLabel?.font = UIFont(name: mediumCustomFont, size: 12.0)
        view.addSubview(showMoreBtn)
        showMoreBtn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
        showMoreBtn.addTarget(self, action: #selector(self.showMoreButtonAction(_:)), for: .touchUpInside)
        showMoreBtn.setTitle("Show more", for: .normal)
        showMoreBtn.layer.borderWidth = 1
        showMoreBtn.layer.borderColor = themeColor.cgColor
        
        var copyBtnHeight = 35
        var shareBtnHeight = 35
        var copyBtnWidth = 130
        var shareBtnWidth = 90
        var shareBtnLeadingConstarint = 15
        var copyBtnLeadingConstarint = 15
        var showMoreBtnLeadingConstarint = 15
        if copyTitle == ""{
            copyBtnHeight = 0
            copyBtnWidth = 0
            copyBtnLeadingConstarint = 0
            showMoreBtnLeadingConstarint = 0
        }
        if shareTitle == ""{
            shareBtnHeight = 0
            shareBtnWidth = 0
            shareBtnLeadingConstarint = 0
            showMoreBtnLeadingConstarint = 0
        }
        var showMoreBtnHeight = 0
        var showMoreBtnWidth = 0
        if isShowMore{
            showMoreBtnHeight = 35
            showMoreBtnWidth = 90
        }
            
        let views: [String: UIView] = ["copyBtn": copyBtn, "shareBtn": shareBtn, "showMoreBtn": showMoreBtn]
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[copyBtn(\(copyBtnHeight))]", options:[], metrics:nil, views:views))
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[shareBtn(\(shareBtnHeight))]", options:[], metrics:nil, views:views))
           view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[showMoreBtn(\(showMoreBtnHeight))]", options:[], metrics:nil, views:views))
            
            if (templateLanguage?.caseInsensitiveCompare(preferred_language_Type) == .orderedSame){
                view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[showMoreBtn(\(showMoreBtnWidth))]-\(shareBtnLeadingConstarint)-[shareBtn(\(shareBtnWidth))]-\(showMoreBtnLeadingConstarint)-[copyBtn(\(copyBtnWidth))]-0-|", options:[], metrics:nil, views:views))
                //view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[showMoreBtn(90)]", options:[], metrics:nil, views:views))
            }else{
                view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[copyBtn(\(copyBtnWidth))]-\(shareBtnLeadingConstarint)-[shareBtn(\(shareBtnWidth))]-\(showMoreBtnLeadingConstarint)-[showMoreBtn(\(showMoreBtnWidth))]", options:[], metrics:nil, views:views))
                //view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[showMoreBtn(90)]-0-|", options:[], metrics:nil, views:views))
            }
        return view
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0{
            return 0
        }
        return self.isShowFooterView ? 50 : 0
    }
    
    @objc fileprivate func copyBtnAction(_ sender: UIButton!) {
        let cardsDetails = arrayOfCardDetails[sender.tag]
        let value = cardsDetails.value
        UIPasteboard.general.string = value
        // read from clipboard
        NotificationCenter.default.post(name: Notification.Name(activityViewControllerNotification), object: "Copy")
    }
    
    @objc fileprivate func copyButtonAction(_ sender: AnyObject!) {
        UIPasteboard.general.string = copiedAndShareString()
        // read from clipboard
        NotificationCenter.default.post(name: Notification.Name(activityViewControllerNotification), object: "Copy")
    }
    
    @objc fileprivate func showMoreButtonAction(_ sender: AnyObject!) {
        if (isShowMore) {
            let component: KREComponent = components.firstObject as! KREComponent
            if (component.componentDesc != nil) {
                let jsonString = component.componentDesc
                NotificationCenter.default.post(name: Notification.Name(salaamPointsDetailsNotification), object: jsonString)
            }
        }
    }
    
    func copiedAndShareString() -> String {
        var finalCopiedString = ""
        for i in 0..<arrayOfElements.count {
            let elements = arrayOfElements[i]
            let str = "\(elements.title ?? "")     \(elements.value ?? "")\n"
            finalCopiedString += str
        }
        
        for i in 0..<arrayOfCardDetails.count {
            let elements = arrayOfCardDetails[i]
            let str = "\(elements.title ?? "")     \(elements.value ?? "")\n"
            finalCopiedString += str
        }
        return finalCopiedString
    }
    
    @objc fileprivate func shareButtonAction(_ sender: AnyObject!) {
        shareAndCopyStr = copiedAndShareString()
        NotificationCenter.default.post(name: Notification.Name(activityViewControllerNotification), object: "Share")
    }
    
    func textLinkDetection(textLabel:KREAttributedLabel) {
        textLabel.detectionBlock = {(hotword, string) in
            switch hotword {
            case KREAttributedHotWordLink:
                self.linkAction(string!)
                print(string!)
                break
            default:
                break
            }
        }
    }
    
    func textViewLinkDetection(textLabel:KREAttributedTextView) {
        textLabel.detectionBlock = {(hotword, string) in
            switch hotword {
            case KREAttributedHotWordLink:
                self.linkAction(string)
                break
            default:
                break
            }
        }
    }
    
}
