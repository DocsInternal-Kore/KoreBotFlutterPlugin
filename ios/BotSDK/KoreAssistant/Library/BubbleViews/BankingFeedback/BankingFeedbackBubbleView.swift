//
//  BankingFeedbackBubbleView.swift
//  KoreBotSDKFrameWork
//
//  Created by Kartheek Pagidimarri on 05/05/23.
//  Copyright © 2023 Kartheek.Pagidimarri. All rights reserved.
//

import UIKit

class BankingFeedbackBubbleView: BubbleView {
    
    static let elementsLimit: Int = 4
    let bundle = KREResourceLoader.shared.resourceBundle()
    public var maskview: UIView!
    var titleLbl: UILabel!
    var tableView: UITableView!
    var cardView: UIView!
    let kMaxTextWidth: CGFloat = BubbleViewMaxWidth - 32.0
    let kMinTextWidth: CGFloat = 20.0
    fileprivate let listCellIdentifier = "BankingFeedbackCell"
    fileprivate let listExpCellIdentifier = "BankingFeedbackExpCell"
    var placeHolderlbl: UILabel!
    var txtView:UITextView!
    var templateLanguage:String?
    
    var arrayOfExpirenceContetnt = [ExperienceContent]()
    var arrayOfFeedbackList = [FeedbackList]()
    var headersArray = NSMutableArray()
    
    var selectedExpContentIndex = 1000
    var selectedExpContentValue: String?
    var selectedExpContentId: String?
    
    var arrayOfSelectedFeedbackListIndex = NSMutableArray()
    var arrayOfSelectedFeedbackListId = NSMutableArray()
    var arrayOfSelectedFeedbackListValues = NSMutableArray()
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    public var optionsAction: ((_ text: String?, _ payload: String?) -> Void)!
    public var optionsSlientAction: ((_ payload: String?) -> Void)!
    public var linkAction: ((_ text: String?) -> Void)!
    override func applyBubbleMask() {
        //nothing to put here
        if(self.maskLayer == nil){
            self.maskLayer = CAShapeLayer()
            //self.tileBgv.layer.mask = self.maskLayer
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
        
        if #available(iOS 13.0, *) {
            self.tableView = UITableView(frame: CGRect.zero,style:.grouped) //insetGrouped
        } else {
            // Fallback on earlier versions
            self.tableView = UITableView(frame: CGRect.zero,style:.grouped)
        }
        
        //self.tableView = UITableView(frame: CGRect.zero,style:.plain)
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
        self.tableView.register(UINib(nibName: listExpCellIdentifier, bundle: bundle), forCellReuseIdentifier: listExpCellIdentifier)
        self.tableView.contentInset = UIEdgeInsets(top: -10, left: 0, bottom: 0, right: 0) //removing tableview top spacing
       
        self.maskview = UIView(frame:.zero)
        self.maskview.translatesAutoresizingMaskIntoConstraints = false
        self.cardView.addSubview(self.maskview)
        self.maskview.isHidden = true
        maskview.backgroundColor = .clear//UIColor(white: 1, alpha: 0.5)
        
        
        let views: [String: UIView] = ["tableView": tableView, "maskview": maskview]
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[tableView]-0-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[maskview]|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[tableView]-0-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[maskview]-0-|", options: [], metrics: nil, views: views))
        
    }
    
    func intializeCardLayout(){
        self.cardView = UIView(frame:.zero)
        self.cardView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.cardView)
        if #available(iOS 11.0, *) {
            self.cardView.roundCorners([ .layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner], radius: 10.0, borderColor: UIColor.clear, borderWidth: 1.5)
        }
        cardView.backgroundColor =  BubbleViewLeftTint
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
                templateLanguage = allItems.lang ?? default_language
                
                headersArray = []
                if let heading = allItems.heading{
                    headersArray.add(heading)
                }
                
                arrayOfExpirenceContetnt = allItems.experienceContent ?? []
                if selectedExpContentValue == nil{
                    selectedExpContentIndex = 1000
                }else{
                    if let feedbackHeading = allItems.feedbackListHeading{
                        headersArray.add(feedbackHeading)
                    }
                }
                
                arrayOfFeedbackList = allItems.feedbackList ?? []
                for _ in 0..<arrayOfFeedbackList.count{
                    arrayOfSelectedFeedbackListIndex.add("uncheck")
                    arrayOfSelectedFeedbackListValues.add("")
                    arrayOfSelectedFeedbackListId.add("")
                }
                self.tableView.reloadData()
            }
        }
    }
    
    override var intrinsicContentSize : CGSize {
        var headerViewHeight = 0.0
        headerViewHeight = Double(headersArray.count) * 60.0
        var footerviewHeight = 0.0
        var cellHeight = 0.0
        for _ in 0..<arrayOfExpirenceContetnt.count{
            cellHeight += 54.0
        }
        var extraspace = 10.0
//        if headersArray.count > 1{
//            for _ in 0..<arrayOfFeedbackList.count{
//                cellHeight +=  54.0
//            }
            footerviewHeight = 200.0
            extraspace = 0.0
       // }
        return CGSize(width: 0.0, height: cellHeight + headerViewHeight + footerviewHeight + extraspace)
    }
    

    @objc func radioButtonAction(_ sender: AnyObject!){
       
        selectedExpContentIndex = sender.tag
        let details = arrayOfExpirenceContetnt[sender.tag]
        selectedExpContentValue = details.value
        selectedExpContentId = details.id
        //self.tableView.reloadData()
        NotificationCenter.default.post(name: Notification.Name(reloadTableNotification), object: nil)
        
        //NotificationCenter.default.post(name: Notification.Name("StartTyping"), object: nil)
        //self.maskview.isHidden = false
        //self.optionsSlientAction(details.value ?? "")
    }
    
    @objc func checkButtonAction(_ sender: AnyObject!){
        let details = arrayOfFeedbackList[sender.tag]
        if arrayOfSelectedFeedbackListIndex[sender.tag] as! String == "uncheck"{
            arrayOfSelectedFeedbackListIndex.replaceObject(at: sender.tag, with: "check")
            arrayOfSelectedFeedbackListValues.replaceObject(at: sender.tag, with: details.value ?? "")
            arrayOfSelectedFeedbackListId.replaceObject(at: sender.tag, with: details.id ?? "")
        }else{
            arrayOfSelectedFeedbackListIndex.replaceObject(at: sender.tag, with: "uncheck")
            arrayOfSelectedFeedbackListValues.replaceObject(at: sender.tag, with: "")
            arrayOfSelectedFeedbackListId.replaceObject(at: sender.tag, with: "")
        }
        self.tableView.reloadData()
    }
    
    @objc func confirmButtonAction(_ sender: AnyObject!){
        self.maskview.isHidden = false
        let expDic = ["id": selectedExpContentId ?? "", "value": selectedExpContentValue ?? ""]
        let feedbackArray = NSMutableArray()
        
        for i in 0..<arrayOfSelectedFeedbackListValues.count{
            let feedBackDic = NSMutableDictionary()
           if arrayOfSelectedFeedbackListValues[i] as! String != ""{
               feedBackDic.setObject(arrayOfSelectedFeedbackListId[i], forKey: "id" as NSCopying)
               feedBackDic.setObject(arrayOfSelectedFeedbackListValues[i], forKey: "value" as NSCopying)
               feedbackArray.add(feedBackDic)
            }
        }
        let dic = NSMutableDictionary()
        dic.setObject(txtView.text ?? "", forKey: "userSuggestion" as NSCopying)
        dic.setObject(expDic, forKey: "selectedExperience" as NSCopying)
        dic.setObject(feedbackArray, forKey: "selectedFeedback" as NSCopying)
         print(dic)
        let jsonStr = jsonToString(json: dic)
        var removeStr = jsonStr.replacingOccurrences(of: "\\", with: "")
        removeStr = removeStr.replacingOccurrences(of: "\n", with: "")
        NotificationCenter.default.post(name: Notification.Name("StartTyping"), object: nil)
        self.optionsSlientAction(removeStr)
        txtView.resignFirstResponder()
    }
    
    
    @objc func cancelBtnButtonAction(_ sender: AnyObject!){
        self.maskview.isHidden = false
        self.optionsAction("Cancel", "Cancel")
    }
    
    func jsonToString(json: AnyObject) -> String{
        do {
            let data1 = try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted)
            let convertedString = String(data: data1, encoding: String.Encoding.utf8) as NSString? ?? ""
            //debugPrint(convertedString)
            return convertedString as String
        } catch _ {
            //debugPrint(myJSONError)
            return ""
        }
    }
    
}

extension BankingFeedbackBubbleView: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return headersArray.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return arrayOfExpirenceContetnt.count
        }else{
            return arrayOfFeedbackList.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell : BankingFeedbackExpCell = tableView.dequeueReusableCell(withIdentifier: listExpCellIdentifier) as! BankingFeedbackExpCell
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
            let details = arrayOfExpirenceContetnt[indexPath.row]
            cell.titleLbl.text = details.id
            
            //cell.checkBtn.setImage(UIImage(named: "radio_uncheck", in: bundle, compatibleWith: nil), for: .normal)
            if selectedExpContentIndex == indexPath.row{
                let radio_check = UIImage(named: "radio_check", in: bundle, compatibleWith: nil)
                let tintedradio_checkImage = radio_check?.withRenderingMode(.alwaysTemplate)
                cell.checkBtn.setImage(tintedradio_checkImage, for: .normal)
                cell.checkBtn.tintColor = themeColor
            }else{
                let radio_uncheck = UIImage(named: "radio_uncheck", in: bundle, compatibleWith: nil)
                let tintedradio_uncheckImage = radio_uncheck?.withRenderingMode(.alwaysTemplate)
                cell.checkBtn.setImage(tintedradio_uncheckImage, for: .normal)
                cell.checkBtn.tintColor = themeColor
            }
            cell.checkBtn.addTarget(self, action: #selector(self.radioButtonAction(_:)), for: .touchUpInside)
            cell.checkBtn.tag = indexPath.row
            if #available(iOS 11.0, *) {
                cell.bgV.roundCorners([ .layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner], radius: 0.0, borderColor: UIColor.clear, borderWidth: 1.5)
                if indexPath.row == 0{
                    cell.bgV.roundCorners([ .layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 10.0, borderColor: UIColor.clear, borderWidth: 1.5)
                }
                if arrayOfExpirenceContetnt.count - 1 == indexPath.row{
                    cell.bgV.roundCorners([ .layerMaxXMaxYCorner, .layerMinXMaxYCorner], radius: 10.0, borderColor: UIColor.clear, borderWidth: 0)
                }
            }
            return cell
        }else{
            let cell : BankingFeedbackCell = tableView.dequeueReusableCell(withIdentifier: listCellIdentifier) as! BankingFeedbackCell
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
            let details = arrayOfFeedbackList[indexPath.row]
            cell.titleLbl.text = details.id
            
            //cell.checkBtn.setImage(UIImage(named: "uncheck", in: bundle, compatibleWith: nil), for: .normal)
            if arrayOfSelectedFeedbackListIndex[indexPath.row] as! String == "uncheck"{
                let uncheck = UIImage(named: "uncheck", in: bundle, compatibleWith: nil)
                let tinteduncheckImage = uncheck?.withRenderingMode(.alwaysTemplate)
                cell.checkBtn.setImage(tinteduncheckImage, for: .normal)
            }else{
                let check = UIImage(named: "check", in: bundle, compatibleWith: nil)
                let tintedcheckImage = check?.withRenderingMode(.alwaysTemplate)
                cell.checkBtn.setImage(tintedcheckImage, for: .normal)
            }
            
            cell.checkBtn.tintColor = themeColor
            cell.checkBtn.addTarget(self, action: #selector(self.checkButtonAction(_:)), for: .touchUpInside)
            cell.checkBtn.tag = indexPath.row
            if #available(iOS 11.0, *) {
                cell.bgV.roundCorners([ .layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner], radius: 0.0, borderColor: UIColor.clear, borderWidth: 1.5)
                if indexPath.row == 0{
                    cell.bgV.roundCorners([ .layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 10.0, borderColor: UIColor.clear, borderWidth: 1.5)
                }
                if arrayOfExpirenceContetnt.count - 1 == indexPath.row{
                    cell.bgV.roundCorners([ .layerMaxXMaxYCorner, .layerMinXMaxYCorner], radius: 10.0, borderColor: UIColor.clear, borderWidth: 0)
                }
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 60))
        headerView.backgroundColor = .clear
        let label = UILabel()
        label.frame = CGRect.init(x: 10, y: 0, width: headerView.frame.width-20, height: headerView.frame.height)
        label.text = headersArray[section] as? String
        label.font = UIFont(name: mediumCustomFont, size: 14)
        label.numberOfLines = 2
        label.textColor = .black
        headerView.addSubview(label)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        if section == 0{
//            return 0
//        }
        return 200
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        view.clipsToBounds = true
        view.layer.masksToBounds = false
        
        if #available(iOS 11.0, *) {
            view.roundCorners([ .layerMaxXMaxYCorner, .layerMinXMaxYCorner], radius: 10.0, borderColor: UIColor.lightGray, borderWidth: 0)
        }
        
        txtView = UITextView(frame: CGRect.zero)
        txtView.backgroundColor = .white
        txtView.delegate = self
        txtView.translatesAutoresizingMaskIntoConstraints = false
        txtView.clipsToBounds = true
        txtView.layer.cornerRadius = 5
        txtView.layer.cornerRadius = 5.0
        txtView.layer.borderWidth = 1.0
        txtView.font = UIFont(name: regularCustomFont, size: 14)
        txtView.layer.borderColor = UIColor.gray.cgColor
        view.addSubview(txtView)
        
        placeHolderlbl = UILabel(frame: CGRect.zero)
        placeHolderlbl.backgroundColor = .clear
        placeHolderlbl.translatesAutoresizingMaskIntoConstraints = false
        placeHolderlbl.clipsToBounds = true
        placeHolderlbl.text = "Tell us more.."
        placeHolderlbl.font = UIFont(name: regularCustomFont, size: 14)
        placeHolderlbl.textColor = .darkGray
        view.addSubview(placeHolderlbl)
        
        
        let confirmBtn = UIButton(frame: CGRect.zero)
        confirmBtn.backgroundColor = themeColor
        confirmBtn.translatesAutoresizingMaskIntoConstraints = false
        confirmBtn.clipsToBounds = true
        confirmBtn.layer.cornerRadius = 5
        confirmBtn.setTitleColor(.white, for: .normal)
        confirmBtn.setTitleColor(Common.UIColorRGB(0x999999), for: .disabled)
        confirmBtn.titleLabel?.font = UIFont(name: mediumCustomFont, size: 12.0)
        view.addSubview(confirmBtn)
        confirmBtn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
        confirmBtn.addTarget(self, action: #selector(self.confirmButtonAction(_:)), for: .touchUpInside)
        confirmBtn.setTitle("Confirm", for: .normal)
        confirmBtn.layer.borderWidth = 1.0
        confirmBtn.layer.borderColor = themeColor.cgColor
        
        let cancelBtn = UIButton(frame: CGRect.zero)
        cancelBtn.backgroundColor = .clear
        cancelBtn.translatesAutoresizingMaskIntoConstraints = false
        cancelBtn.clipsToBounds = true
        cancelBtn.layer.cornerRadius = 5
        cancelBtn.setTitleColor(.black, for: .normal)
        cancelBtn.setTitleColor(Common.UIColorRGB(0x999999), for: .disabled)
        cancelBtn.titleLabel?.font = UIFont(name: mediumCustomFont, size: 12.0)
        view.addSubview(cancelBtn)
        cancelBtn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
        cancelBtn.addTarget(self, action: #selector(self.cancelBtnButtonAction(_:)), for: .touchUpInside)
        cancelBtn.setTitle("Cancel", for: .normal)
        cancelBtn.layer.borderWidth = 1.0
        cancelBtn.layer.borderColor = UIColor.darkGray.cgColor
        
        
        let views: [String: UIView] = ["txtView": txtView, "placeHolderlbl": placeHolderlbl, "confirmBtn": confirmBtn, "cancelBtn": cancelBtn]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[placeHolderlbl(\(30))]", options:[], metrics:nil, views:views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[txtView(\(135))]-10-[confirmBtn(30)]", options:[], metrics:nil, views:views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[txtView(\(135))]-10-[cancelBtn(30)]", options:[], metrics:nil, views:views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[txtView]-10-|", options:[], metrics:nil, views:views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[placeHolderlbl]-15-|", options:[], metrics:nil, views:views))
        
        if (templateLanguage?.caseInsensitiveCompare(preferred_language_Type) == .orderedSame){
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[cancelBtn(\(100))]-10-[confirmBtn(\(100))]-10-|", options:[], metrics:nil, views:views))
        }else{
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[confirmBtn(\(100))]-10-[cancelBtn(\(100))]", options:[], metrics:nil, views:views))
        }
        return view
    }
    
    
}
extension BankingFeedbackBubbleView: UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        placeHolderlbl.isHidden = !textView.text.isEmpty
    }
}
