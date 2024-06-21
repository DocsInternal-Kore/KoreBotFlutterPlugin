//
//  DetailsListBubbleView.swift
//  KoreBotSDKFrameWork
//
//  Created by Kartheek Pagidimarri on 19/01/23.
//  Copyright © 2023 Kartheek.Pagidimarri. All rights reserved.
//

import UIKit
import korebotplugin

class DetailsListBubbleView: BubbleView {
    var templateLanguage:String?
    var tileBgv: UIView!
    public var maskview: UIView!
    var titleLbl: KREAttributedTextView!
    var tableView: UITableView!
    var cardView: UIView!
    let kMaxTextWidth: CGFloat = BubbleViewMaxWidth - 32.0
    let kMinTextWidth: CGFloat = 20.0
    fileprivate let listCellIdentifier = "DetailsListCell"
    var arrayOfElements = [ComponentElements]()
    var arrayOfVisibleValues = [VisibleValues]()
    var arrayOfHiddenValues = [VisibleValues]()
    var arrayOfAllTitles = NSMutableArray()
    var arrayOfAllSubTitles = NSMutableArray()
    
    let arrayOFSelectedSections = NSMutableArray()
    
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
        
        if #available(iOS 13.0, *) {
            self.tableView = UITableView(frame: CGRect.zero,style:.grouped) //insetGrouped
        } else {
            // Fallback on earlier versions
            self.tableView = UITableView(frame: CGRect.zero,style:.grouped)
        }
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
        
        
        self.tableView.contentInset = UIEdgeInsets(top: -36, left: 0, bottom: 0, right: 0) //removing tableview top spacing
        
        //self.tableView.layer.cornerRadius = 10.0
        self.tableView.clipsToBounds = true
        self.tableView.layer.masksToBounds = false
        self.tableView.layer.shadowColor = UIColor.lightGray.cgColor
        self.tableView.layer.shadowOffset =  CGSize.zero
        self.tableView.layer.shadowOpacity = 0.3
        self.tableView.layer.shadowRadius = 4
        self.tableView.layer.shadowOffset = CGSize(width: 0 , height:2)
        
        
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
//        let style = NSMutableParagraphStyle()
//        style.lineSpacing = 0
//        let attributes = [NSAttributedString.Key.paragraphStyle : style]
//        self.titleLbl.typingAttributes = attributes
        self.tileBgv.addSubview(self.titleLbl)
        
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
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
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
                print(jsonObject)
                let jsonDecoder = JSONDecoder()
                guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject as Any , options: .prettyPrinted),
                      let allItems = try? jsonDecoder.decode(Componentss.self, from: jsonData) else {
                    return
                }
                if arrayOFSelectedSections.count == 0{
                    templateLanguage = allItems.lang ?? default_language
                    templateLanguage = allItems.lang ?? default_language
                    if (templateLanguage?.caseInsensitiveCompare(preferred_language_Type) == .orderedSame){
                        self.titleLbl.textAlignment = .right
                    }else{
                        self.titleLbl.textAlignment = .left
                    }
                    arrayOfElements = allItems.elements ?? []
                    self.titleLbl.setHTMLString(allItems.heading ?? "", withWidth: kMaxTextWidth)
                    arrayOfAllTitles = []
                    arrayOfAllSubTitles = []
                    for i in 0..<arrayOfElements.count{
                        //arrayOFSelectedSections.add(100)
                        let element = arrayOfElements[i]
                        let visibleValues = element.visible_values
                        let hiddenValues = element.hidden_values
                        
                        let arrayTitle = NSMutableArray()
                        let arraySubTitle = NSMutableArray()
                        for i in 0..<(visibleValues?.count ?? 0){
                            let visible = visibleValues![i]
                            arrayTitle.add(visible.title ?? "")
                            arraySubTitle.add(visible.subTitle ?? "")
                        }
                        var noHiddenValues = false
                        for i in 0..<(hiddenValues?.count ?? 0){
                            noHiddenValues = true
                            let hidden = hiddenValues![i]
                            arrayTitle.add(hidden.title ?? "")
                            arraySubTitle.add(hidden.subTitle ?? "")
                        }
                        
                        if noHiddenValues{
                            arrayOFSelectedSections.add(100)
                        }else{
                            arrayOFSelectedSections.add(1000)
                        }
                        arrayOfAllTitles.add(arrayTitle )
                        arrayOfAllSubTitles.add(arraySubTitle )
                    }
                }
                
            }
        }
        print("arrayOfAllTitles\(arrayOfAllTitles.count)")
        print("arrayOfAllSubTitles\(arrayOfAllSubTitles.count)")
        tableView.reloadData()
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
        
        let cellHeight : CGFloat = 81.0
        let tableviewHeaderSpacing = 20.0
        var viewMoreBtns = 00.0
        
        
        //let sections = arrayOfElements.count
        var finalHeight: CGFloat = 0.0
        let extraHeight = 50
        let verticalSpace = 32 + 20 + extraHeight
        for i in 0..<arrayOfElements.count{
            let rows = arrayOfElements[i]
            let isSectionSelected = arrayOFSelectedSections[i]
            if isSectionSelected as! Int == 100{
                viewMoreBtns += 50.0
                for _ in 0..<(rows.visible_values?.count ?? 0) {
                    finalHeight += cellHeight
                }
            }else{
                //viewMoreBtns = 00.0
                let titles = arrayOfAllTitles[i]
                for _ in 0..<((titles as AnyObject).count ) {
                    finalHeight += cellHeight
                }
                
            }
            
        }
        
        return CGSize(width: 0.0, height: textSize.height+CGFloat(verticalSpace) + finalHeight + tableviewHeaderSpacing + viewMoreBtns)
    }
    
}
extension DetailsListBubbleView: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 81
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 81
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrayOfElements.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let isSectionSelected = arrayOFSelectedSections[section]
        if isSectionSelected as! Int == 100{
            let section = arrayOfElements[section]
            let visibleValues = section.visible_values
            return visibleValues?.count ?? 0
        }else{
            let allRows = arrayOfAllTitles[section]
            return (allRows as AnyObject).count
        }
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : DetailsListCell = tableView.dequeueReusableCell(withIdentifier: listCellIdentifier) as! DetailsListCell
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        let isSectionSelected = arrayOFSelectedSections[indexPath.section]
        if isSectionSelected as! Int == 100{
            let section = arrayOfElements[indexPath.section]
            let visibleValues = section.visible_values
            let vlues = visibleValues?[indexPath.row]
            cell.titleLbl.text = vlues?.title
            cell.detailsLbl.text = vlues?.subTitle
            cell.underLineLbl.isHidden = false
        }else{
            let titlesection = arrayOfAllTitles[indexPath.section] as? NSArray
            let titlerow = titlesection?[indexPath.row] as? String
            
            let subTitlesection = arrayOfAllSubTitles[indexPath.section] as? NSArray
            let subTitlerow = subTitlesection?[indexPath.row] as? String
            cell.titleLbl.text = titlerow
            cell.detailsLbl.text = subTitlerow
            
            cell.underLineLbl.isHidden = false
            let totalRows = tableView.numberOfRows(inSection: indexPath.section)
            if indexPath.row == totalRows - 1 {
                cell.underLineLbl.isHidden = true
            }
        }
        
        if #available(iOS 11.0, *) {
            cell.bgV.roundCorners([ .layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 0.0, borderColor: UIColor.lightGray, borderWidth: 0)
        }
        if indexPath.row == 0{
            if #available(iOS 11.0, *) {
                cell.bgV.roundCorners([ .layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 10.0, borderColor: UIColor.lightGray, borderWidth: 0)
            }
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let elements = arrayOfComponents[indexPath.row]
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .white
        view.clipsToBounds = true
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.lightGray.cgColor
        view.layer.shadowOffset =  CGSize.zero
        view.layer.shadowOpacity = 0.3
        view.layer.shadowRadius = 4
        view.layer.shadowOffset = CGSize(width: 0 , height:2)
        
        if #available(iOS 11.0, *) {
            view.roundCorners([ .layerMaxXMaxYCorner, .layerMinXMaxYCorner], radius: 10.0, borderColor: UIColor.lightGray, borderWidth: 0)
        }
        
        let viewMore = UIButton(frame: CGRect.zero)
        viewMore.backgroundColor = .clear
        viewMore.translatesAutoresizingMaskIntoConstraints = false
        viewMore.clipsToBounds = true
        viewMore.layer.cornerRadius = 5
        viewMore.setTitleColor(themeColor, for: .normal)
        viewMore.setTitleColor(Common.UIColorRGB(0x999999), for: .disabled)
        viewMore.titleLabel?.font = UIFont(name: mediumCustomFont, size: 12.0)!
        view.addSubview(viewMore)
        viewMore.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
        viewMore.addTarget(self, action: #selector(self.viewMoreButtonAction(_:)), for: .touchUpInside)
        viewMore.setTitle("View More", for: .normal)
        viewMore.layer.borderWidth = 0
        viewMore.layer.borderColor = themeColor.cgColor
        viewMore.tag = section
        
        let views: [String: UIView] = ["viewMore": viewMore]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[viewMore(\(35))]", options:[], metrics:nil, views:views))
        
        if (templateLanguage?.caseInsensitiveCompare(preferred_language_Type) == .orderedSame){
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[viewMore(\(100))]-0-|", options:[], metrics:nil, views:views))
        }else{
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[viewMore(\(100))]", options:[], metrics:nil, views:views))
        }
        return view
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let isSectionSelected = arrayOFSelectedSections[section]
        if isSectionSelected as! Int == 100{
            return 50
        }else{
            return 0
        }
        
    }
    
    @objc fileprivate func viewMoreButtonAction(_ sender: AnyObject!) {
        print("viewMore")
        arrayOFSelectedSections.replaceObject(at: sender.tag, with: 1000)
        NotificationCenter.default.post(name: Notification.Name(reloadTableNotification), object: nil)
    }
}
