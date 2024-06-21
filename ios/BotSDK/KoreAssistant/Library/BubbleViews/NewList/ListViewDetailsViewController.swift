//
//  ListViewDetailsViewController.swift
//  KoreBotSDKDemo
//
//  Created by MatrixStream_01 on 14/05/20.
//  Copyright © 2020 Kore. All rights reserved.
//

import UIKit
import SafariServices

protocol NewListViewDelegate {
    func optionsButtonTapNewAction(text:String, payload:String)
}

class ListViewDetailsViewController: UIViewController {
    
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var headingLabel: KREAttributedLabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var tableview: UITableView!
    fileprivate let listCellIdentifier = "NewListTableViewCell"
    fileprivate let listTransACellIdentifier = "NewListTrannsActionCell"
    fileprivate let listTransAMultiLineCellIdentifier = "NewListTransActionsMultilineCell"
    
    var dataString: String!
    var arrayOfElements = [ComponentElements]()
    var jsonData : Componentss?
    var viewDelegate: NewListViewDelegate?
    var dateCompareStr:String?
    var duplicateDates = [Bool]()
    var isBoxShadow = false
    let bundle = KREResourceLoader.shared.resourceBundle()
    var templateLanguage:String?
    let kMaxTextWidth: CGFloat = BubbleViewMaxWidth
    
    fileprivate let listAdvacedCellIdentifier = "AdvancedListViewCell"
    var templateType:String?
    @IBOutlet weak var headerView: UIView!
    
    // MARK: init
    init(dataString: String) {
        super.init(nibName: "ListViewDetailsViewController", bundle: bundle)
        self.dataString = dataString
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if #available(iOS 11.0, *) {
            self.subView.roundCorners([ .layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 10.0, borderColor: UIColor.clear, borderWidth: 1.5)
        }
        
        headerView.backgroundColor = BubbleViewLeftTint
        if #available(iOS 11.0, *) {
            headerView.roundCorners([ .layerMinXMaxYCorner, .layerMaxXMaxYCorner], radius: 10.0, borderColor: UIColor.clear, borderWidth: 1.5)
        }

        headingLabel.font = UIFont(name: semiBoldCustomFont, size: 16.0)
        self.tableview.tableFooterView = UIView(frame:.zero)
        self.tableview.register(UINib(nibName: listCellIdentifier, bundle: bundle), forCellReuseIdentifier: listCellIdentifier)
        self.tableview.register(UINib(nibName: listTransACellIdentifier, bundle: bundle), forCellReuseIdentifier: listTransACellIdentifier)
        self.tableview.register(UINib(nibName: listAdvacedCellIdentifier, bundle: bundle), forCellReuseIdentifier: listAdvacedCellIdentifier)
        self.tableview.register(UINib(nibName: listTransAMultiLineCellIdentifier, bundle: bundle), forCellReuseIdentifier: listTransAMultiLineCellIdentifier)
        
        
        subView.backgroundColor = UIColor.init(hexString: (brandingShared.widgetBodyColor) ?? "#FFFFFF")
        headingLabel.textColor = UIColor.init(hexString: (brandingShared.widgetTextColor)  ?? "#000000")
        getData()
    }
    func getData(){
        let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: dataString!) as! NSDictionary
        let jsonDecoder = JSONDecoder()
        guard let jsonData1 = try? JSONSerialization.data(withJSONObject: jsonObject as Any , options: .prettyPrinted),
            let allItems = try? jsonDecoder.decode(Componentss.self, from: jsonData1) else {
                return
        }
        jsonData = allItems
        arrayOfElements = jsonData?.elements ?? []
        if let heading = jsonData?.text{
            if heading.contains("*"){
                headingLabel.setHTMLString(heading, withWidth: kMaxTextWidth)
            }else{
                headingLabel.text = heading
            }
            
        }
        
        isBoxShadow = (allItems.boxShadow != nil ? allItems.boxShadow : false)!
        duplicateDates = []
        for i in 0..<arrayOfElements.count{
            let elements = arrayOfElements[i] as ComponentElements
            if elements.transactionDate != nil{
            }else{
                isBoxShadow = false
            }
            if i == 0 {
                dateCompareStr = elements.transactionDate
                duplicateDates.append(false)
            }else{
                //                if i == 1 || i == 2{
                //                    duplicateDates.append(true)
                //                }else{
                if dateCompareStr == elements.transactionDate{
                    duplicateDates.append(true)
                }else{
                    dateCompareStr = elements.transactionDate
                    duplicateDates.append(false)
                }
                // }
                
            }
        }
        templateLanguage = allItems.lang ?? default_language
        if (templateLanguage?.caseInsensitiveCompare(preferred_language_Type) == .orderedSame){
            self.headingLabel.textAlignment = .right
        }else{
            self.headingLabel.textAlignment = .left
        }
        tableview.reloadData()
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    @IBAction func tapsOnCloseBtnAct(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
extension ListViewDetailsViewController: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrayOfElements.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isBoxShadow{
            let elements = arrayOfElements[indexPath.row] as ComponentElements
            if elements.subtitle != nil{
                let cell : NewListTransActionsMultilineCell = tableView.dequeueReusableCell(withIdentifier: listTransAMultiLineCellIdentifier) as! NewListTransActionsMultilineCell
                cell.backgroundColor = UIColor.clear
                cell.selectionStyle = .none
                
                let elements = arrayOfElements[indexPath.row] as ComponentElements
                cell.titleLabl.text = elements.title
                cell.dateLbl.text = elements.transactionDate
                cell.subTitle.text = elements.subtitle
                let price = elements.value
                cell.priceLbl.text = price?.replacingOccurrences(of: "<br />", with: "\n")
                
                cell.priceLblWidthConstraint.constant = 10
                let size = cell.priceLbl.text?.size(withAttributes:[.font: UIFont(name: semiBoldCustomFont, size: 14.0) ?? UIFont.systemFont(ofSize: 14.0)])
                if cell.priceLbl.text != nil {
                    cell.priceLblWidthConstraint.constant = (size?.width)! + 10.0
                 }

                
                cell.dateHeightConstraint.constant = 17.0
                cell.dateTopConstaint.constant = 16.0
                //        if indexPath.row == 0 {
                //            dateCompareStr = elements.subtitle
                //        }else{
                //            if dateCompareStr == elements.subtitle{
                //                cell.dateHeightConstraint.constant = 0.0
                //                cell.dateTopConstaint.constant = 8.0
                //            }else{
                //                dateCompareStr = elements.subtitle
                //            }
                //        }
                
                if duplicateDates[indexPath.row] == true{
                    cell.dateHeightConstraint.constant = 0.0
                    cell.dateTopConstaint.constant = 4.0
                }
                
                let dateFormatterUK = DateFormatter()
                dateFormatterUK.dateFormat = "MM/dd/yy"
                let stringDate = elements.transactionDate ?? "date"
                if let date = dateFormatterUK.date(from: stringDate) {
                    if let sentOn = date as Date? {
                        //               if let sentOn = date as Date? {
                        //                    let dateFormatter = DateFormatter()
                        //                    dateFormatter.dateFormat = "d MMMM YYYY"
                        //                    cell.dateLbl.text = dateFormatter.string(from: sentOn)
                        //                }
                        
                        
                        // Use this to add st, nd, th, to the day
                        let numberFormatter = NumberFormatter()
                        numberFormatter.numberStyle = .ordinal
                        numberFormatter.locale = Locale.current
                        
                        //Set other sections as preferred
                        let monthFormatter = DateFormatter()
                        monthFormatter.dateFormat = "MMMM"
                        
                        // Works well for adding suffix
                        let dayFormatter = DateFormatter()
                        dayFormatter.dateFormat = "dd"
                        
                        // Works well for adding suffix
                        let yearFormatter = DateFormatter()
                        yearFormatter.dateFormat = "YYYY"
                        
                        let dayString = dayFormatter.string(from: date)
                        let monthString = monthFormatter.string(from: date)
                        let yearString = yearFormatter.string(from: date)
                        
                        // Add the suffix to the day
                        let dayNumber = NSNumber(value: Int(dayString)!)
                        let day = numberFormatter.string(from: dayNumber)!
                        
                        cell.dateLbl.text = "\(day) \(monthString) \(yearString)"
                        
                    }
                }
                if (templateLanguage?.caseInsensitiveCompare(preferred_language_Type) == .orderedSame){
                    cell.bgView.semanticContentAttribute = .forceRightToLeft
                    cell.dateLbl.textAlignment = .right
                    cell.titleLabl.textAlignment = .right
                    cell.subTitle.textAlignment = .right
                    cell.priceLbl.textAlignment = .left
                }
                return cell
            }else{
                let cell : NewListTrannsActionCell = tableView.dequeueReusableCell(withIdentifier: listTransACellIdentifier) as! NewListTrannsActionCell
                cell.backgroundColor = UIColor.clear
                cell.selectionStyle = .none
                
                let elements = arrayOfElements[indexPath.row] as ComponentElements
                cell.titleLabl.text = elements.title
                cell.dateLbl.text = elements.transactionDate
                //cell.priceLbl.text = elements.value
                
                cell.priceLbl.text = ""
               if let value = elements.value, value != "0"{
                   cell.priceLbl.text = value
               }
                
                cell.priceLblWidthConstraint.constant = 10
                let size = cell.priceLbl.text?.size(withAttributes:[.font: UIFont(name: semiBoldCustomFont, size: 14.0) ?? UIFont.systemFont(ofSize: 14.0)])
                if cell.priceLbl.text != nil {
                    cell.priceLblWidthConstraint.constant = (size?.width)! + 10.0
                }
                
                cell.dateHeightConstraint.constant = 17.0
                cell.dateTopConstaint.constant = 16.0
                //        if indexPath.row == 0 {
                //            dateCompareStr = elements.subtitle
                //        }else{
                //            if dateCompareStr == elements.subtitle{
                //                cell.dateHeightConstraint.constant = 0.0
                //                cell.dateTopConstaint.constant = 8.0
                //            }else{
                //                dateCompareStr = elements.subtitle
                //            }
                //        }
                
                if duplicateDates[indexPath.row] == true{
                    cell.dateHeightConstraint.constant = 0.0
                    cell.dateTopConstaint.constant = 4.0
                }
                
                let dateFormatterUK = DateFormatter()
                dateFormatterUK.dateFormat = "MM/dd/yy"
                let stringDate = elements.transactionDate ?? "date"
                if let date = dateFormatterUK.date(from: stringDate) {
                    if let sentOn = date as Date? {
                        //               if let sentOn = date as Date? {
                        //                    let dateFormatter = DateFormatter()
                        //                    dateFormatter.dateFormat = "d MMMM YYYY"
                        //                    cell.dateLbl.text = dateFormatter.string(from: sentOn)
                        //                }
                        
                        
                        // Use this to add st, nd, th, to the day
                        let numberFormatter = NumberFormatter()
                        numberFormatter.numberStyle = .ordinal
                        numberFormatter.locale = Locale.current
                        
                        //Set other sections as preferred
                        let monthFormatter = DateFormatter()
                        monthFormatter.dateFormat = "MMMM"
                        
                        // Works well for adding suffix
                        let dayFormatter = DateFormatter()
                        dayFormatter.dateFormat = "dd"
                        
                        // Works well for adding suffix
                        let yearFormatter = DateFormatter()
                        yearFormatter.dateFormat = "YYYY"
                        
                        let dayString = dayFormatter.string(from: date)
                        let monthString = monthFormatter.string(from: date)
                        let yearString = yearFormatter.string(from: date)
                        
                        // Add the suffix to the day
                        let dayNumber = NSNumber(value: Int(dayString)!)
                        let day = numberFormatter.string(from: dayNumber)!
                        
                        cell.dateLbl.text = "\(day) \(monthString) \(yearString)"
                        
                    }
                }
                if (templateLanguage?.caseInsensitiveCompare(preferred_language_Type) == .orderedSame){
                    cell.bgView.semanticContentAttribute = .forceRightToLeft
                    cell.dateLbl.textAlignment = .right
                    cell.titleLabl.textAlignment = .right
                    cell.priceLbl.textAlignment = .left
                }
                return cell
            }
        }else{
            let cell : NewListTableViewCell = tableView.dequeueReusableCell(withIdentifier: listCellIdentifier) as! NewListTableViewCell
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
            cell.bgView.backgroundColor =  UIColor.init(hexString: (brandingShared.widgetBodyColor) ?? "#FFFFFF")
            
            let elements = arrayOfElements[indexPath.row] as ComponentElements
            if elements.imageURL == nil{
                cell.imageViewWidthConstraint.constant = 0.0
                cell.imageVLeadingConstraint.constant = 5.0
            }else{
                cell.imageViewWidthConstraint.constant = 50.0
                cell.imageVLeadingConstraint.constant = 10.0
                cell.imgView.contentMode = .scaleAspectFit
                if  let url = URL(string: elements.imageURL ?? ""){
                    cell.imgView.af_setImage(withURL: url, placeholderImage: UIImage(named: "placeholder_image"))
                }
                
            }
            cell.titleLabel.text = elements.title
            cell.subTitleLabel.text = elements.subtitle
            cell.priceLbl.text = ""
           if let value = elements.value, value != "0"{
               if value.contains("*"){
                   cell.priceLbl.setHTMLString(value, withWidth: kMaxTextWidth)
               }else{
                   cell.priceLbl.text = elements.value
               }
           }
            if selectedTheme == "Theme 1"{
                cell.bgView.layer.borderWidth = 0.0
            }else{
                cell.bgView.layer.borderWidth = 1.5
            }
            //cell.valueLabelWidthConstraint.constant = 85
            cell.valueLabelWidthConstraint.constant = 10
            let size = cell.priceLbl.text?.size(withAttributes:[.font: UIFont(name: semiBoldCustomFont, size: 14.0) ?? UIFont.systemFont(ofSize: 14.0)])
            if cell.priceLbl.text != nil {
                cell.valueLabelWidthConstraint.constant = (size?.width)! + 10.0
             }
            cell.titlaLblTopConstriant.constant = 10.0
            cell.priceLblTopConstraint.constant = 22.0
            cell.subTitleHeightConstraint.constant = 16.0
            cell.subTitle2HeightConstraint.constant = 16.0
            if elements.subtitle == nil{
                cell.titlaLblTopConstriant.constant = 25.0
                cell.priceLblTopConstraint.constant = 37.0
                cell.subTitleHeightConstraint.constant = 0.0
                cell.subTitle2HeightConstraint.constant = 0.0
                cell.subTitleLabel2.text = ""
            }else{
                //cell.subTitleLabel2.text = elements.subtitle
                
                if let subTitle = elements.subtitle{
                    let strStr = subTitle
                    
                   // strStr = strStr.replacingOccurrences(of: "<b>", with: "*")
                    //strStr = strStr.replacingOccurrences(of: "</b>", with: "*")
                    if  strStr.contains("<b>") {
                        cell.subTitleLabel2.setHTMLString(strStr, withWidth: kMaxTextWidth)
                    }else if strStr.contains("**"){
                        cell.subTitleLabel2.text = subTitle
                    }else if strStr.contains("*"){
                        cell.subTitleLabel2.setHTMLString(strStr, withWidth: kMaxTextWidth)
                    }else{
                        cell.subTitleLabel2.text = subTitle
                    }
                    
                }
                
//                let str = elements.subtitle! //"XX"
//                //print("full str:  \(str)")
//                if str.count >= 3{
//                    cell.subTitleLabel.text = "\(str.prefix(3))"
//                    //print("firstCharacter str:  \(str.prefix(3))")
//
//                    let startIndex = str.index(str.startIndex, offsetBy: 3)
//                    //print("secondCharacter str:  \((str[startIndex...]))")
//                    cell.subTitleLabel2.text = (String(str[startIndex...]))
//                }else{
//                    cell.subTitleLabel.text = str
//                    cell.subTitleLabel2.text = ""
//                }
            }
            
            if elements.value == nil{
                cell.valueLabelWidthConstraint.constant = 0
            }
            
            cell.tagBtn.isHidden = true
            cell.tagBtnWidthConstraint.constant = 0.0
            if let tag = elements.tag {
                cell.titlaLblTopConstriant.constant = 10.0
                cell.priceLblTopConstraint.constant = 22.0
                cell.tagBtn.isHidden = false
                let tagBtnText = "   \(tag)   "
                cell.tagBtn.setTitle(tagBtnText, for: .normal)
                cell.tagBtn.backgroundColor = BubbleViewLeftTint
                cell.tagBtn.setTitleColor(themeColor, for: .normal)
                cell.tagBtn.layer.cornerRadius = 5.0
                
                let size = tagBtnText.size(withAttributes:[.font: UIFont(name: semiBoldCustomFont, size: 14.0) ?? UIFont.systemFont(ofSize: 9.0)])
                cell.tagBtnWidthConstraint.constant = (size.width) + 10.0
            }
            
            if (templateLanguage?.caseInsensitiveCompare(preferred_language_Type) == .orderedSame){
                cell.bgView.semanticContentAttribute = .forceRightToLeft
                cell.titleLabel.textAlignment = .right
                cell.subTitleLabel.textAlignment = .right
                cell.subTitleLabel2.textAlignment = .right
                cell.priceLbl.textAlignment = .left
            }
            cell.underlineLbl.isHidden = false
            //cell.bgView.backgroundColor = .yellow
            return cell
        }
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isNewListViewClick{
            let elements = arrayOfElements[indexPath.row]
            if elements.action?.type != nil {
                if elements.action?.type == "postback"{
                    self.dismiss(animated: true, completion: nil)
                    let title = (elements.action?.title) ?? ""
                    let payload = elements.action?.payload == "" || elements.action?.payload == nil || elements.action?.payload == "0" ? elements.action?.title : elements.action?.payload
                    self.viewDelegate?.optionsButtonTapNewAction(text: title, payload: payload ?? title)
                }else{
                    if elements.action?.fallback_url != nil {
                        self.movetoWebViewController(urlString: (elements.action?.fallback_url)!)
                    }
                }
            }
        }
        
    }
    func movetoWebViewController(urlString:String){
        if (urlString.count > 0) {
            let url: URL = URL(string: urlString)!
            let webViewController = SFSafariViewController(url: url)
            present(webViewController, animated: true, completion:nil)
        }
    }
}

