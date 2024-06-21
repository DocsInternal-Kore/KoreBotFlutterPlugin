//
//  CardSelectionBubbleView.swift
//  KoreBotSDKFrameWork
//
//  Created by Kartheek.Pagidimarri on 27/05/22.
//  Copyright © 2022 Kartheek.Pagidimarri. All rights reserved.
//

import UIKit
import korebotplugin
class CardSelectionBubbleView: BubbleView {
    let bundle = KREResourceLoader.shared.resourceBundle()
    var tileBgv: UIView!
    public var maskview: UIView!
    var titleLbl: UILabel!
    var tableView: UITableView!
    var cardView: UIView!
    let kMaxTextWidth: CGFloat = BubbleViewMaxWidth - 32.0
    let kMinTextWidth: CGFloat = 20.0
    fileprivate let listCellIdentifier = "CardSelectionCellTableViewCell"
    var arrayOfComponents = [ComponentElements]()
    var submitBtnTitle = "Submit"
    var cancenBtnTitle = "Cancel"
    //    var checkArray = [String]()
    //    var selectedValues = [String]()
    public var optionsAction: ((_ text: String?, _ payload: String?) -> Void)!
    
    var checkboxIndexPath = [IndexPath]()
    var arrayOfSeletedValues = [String]()
    var arrayOfSeletedTitles = [String]()
    var templateLanguage:String?
    
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
        
        self.tableView.layer.cornerRadius = 2.0
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
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[tileBgv]-0-[tableView]-0-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[maskview]|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[tileBgv]-0-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[tableView]-0-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[maskview]-0-|", options: [], metrics: nil, views: views))
        
        self.titleLbl = UILabel(frame: CGRect.zero)
        self.titleLbl.textColor = BubbleViewBotChatTextColor
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
                let jsonDecoder = JSONDecoder()
                guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject as Any , options: .prettyPrinted),
                      let allItems = try? jsonDecoder.decode(Componentss.self, from: jsonData) else {
                    return
                }
                arrayOfComponents = allItems.elements ?? []
                self.titleLbl.text = allItems.heading ?? ""
                templateLanguage = allItems.lang ?? default_language
                if (templateLanguage?.caseInsensitiveCompare(preferred_language_Type) == .orderedSame){
                    self.titleLbl.textAlignment = .right
                }else{
                    self.titleLbl.textAlignment = .left
                }
                submitBtnTitle = allItems.submitTitle ?? "Submit"
                //                checkArray = []
                //                for _ in 0 ..< arrayOfComponents.count{
                //                    checkArray.append("No")
                //                }
                self.tableView.reloadData()
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
        var moreButtonHeight : CGFloat = 30.0
        let rows = arrayOfComponents.count
        var finalHeight: CGFloat = 72.0
        
        let verticalSpace = 40
        for i in 0..<rows {
            let elements = arrayOfComponents[i]
            cellHeight = 72
            if elements.subtitle == nil{
                
            }
            finalHeight += cellHeight
        }
        
        moreButtonHeight =  50.0
        return CGSize(width: 0.0, height: textSize.height+CGFloat(verticalSpace)+finalHeight+moreButtonHeight)
    }
    
    @objc fileprivate func submitButtonAction(_ sender: AnyObject!) {
        //        if selectedValues.count > 0{
        //            let titles = selectedValues.joined(separator: ", ")
        //            print(titles)
        //            maskview.isHidden = false
        //            //You have selected follwing cards for your travel :
        //            self.optionsAction("You have selected follwing cards for your travel : \(titles)","You have selected follwing cards for your travel : \(titles)")
        //        }
        if arrayOfSeletedTitles.count > 0{
            let titles = arrayOfSeletedTitles.joined(separator: ", ")
            print(titles)
            
            var enter = 0
            if arrayOfSeletedValues.count > 0{
                let payload = arrayOfSeletedValues.joined(separator: ", ")
                print(payload)
                enter = 1
                self.optionsAction("\(titles)","\(payload)")
                self.maskview.isHidden = false
            }
            if enter == 0{
                self.optionsAction("\(titles)","\(titles)")
                self.maskview.isHidden = false
            }
        }
    }
    @objc fileprivate func cancelButtonAction(_ sender: AnyObject!) {
        self.optionsAction("Cancel","discard")
        self.maskview.isHidden = false
    }
}

extension CardSelectionBubbleView: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrayOfComponents.count + 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : CardSelectionCellTableViewCell = tableView.dequeueReusableCell(withIdentifier: listCellIdentifier) as! CardSelectionCellTableViewCell
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        cell.tiltlLblHorizontalConstraint.constant = 58.0
        //cell.imageV.image = UIImage(named: "placeholder_image")
        if indexPath.row == 0{
            cell.titleLbl.text = "Select All"
            cell.cardnoLbl.text = ""
            cell.cardTypeLbl.text = ""
            cell.imageV.image = UIImage(named: "")
            cell.tiltlLblHorizontalConstraint.constant = 10.0
            cell.cardLblWidthConstraint.constant = 10.0
            cell.cardTypeLblWidthConstraint.constant = 10.0
            cell.checkBtn.addTarget(self, action: #selector(self.checkButtonAction(_:)), for: .touchUpInside)
            cell.checkBtn.tag = 100
            cell.titleLblHeightConstarint.constant = 21.0
            cell.titleLbl.numberOfLines = 1
        }else{
            cell.titleLblHeightConstarint.constant = 60.0
            cell.titleLbl.numberOfLines = 2
            cell.tiltlLblHorizontalConstraint.constant = 58.0
            let elements = arrayOfComponents[indexPath.row - 1]
            cell.titleLbl.text = elements.title
            cell.cardTypeLbl.text = elements.cardType
            cell.cardnoLbl.text = ""
            if let cardNo = elements.subTitle{
                if cardNo.contains("*"){
                    cell.cardnoLbl.setHTMLString(cardNo, withWidth: kMaxTextWidth)
                }else{
                    cell.cardnoLbl.text = cardNo
                }
            }
            
            cell.cardLblWidthConstraint.constant = 10
            let size = cell.cardnoLbl.text?.size(withAttributes:[.font: UIFont(name: boldCustomFont, size: 12.0) ?? UIFont.boldSystemFont(ofSize: 12.0)])
            if cell.cardnoLbl.text != nil {
                cell.cardLblWidthConstraint.constant = (size?.width)! + 10.0 + 10.0
            }
            
            cell.cardTypeLblWidthConstraint.constant = 10.0
            let sizee = cell.cardTypeLbl.text?.size(withAttributes:[.font: UIFont(name: boldCustomFont, size: 12.0) ?? UIFont.boldSystemFont(ofSize: 12.0)])
            if cell.cardTypeLbl.text != nil {
                cell.cardTypeLblWidthConstraint.constant = (sizee?.width)! + 10.0 + 10.0
            }
            
            if let imageStr = elements.imageURL{
                if let url = URL(string: imageStr){
                    cell.imageV.af_setImage(withURL: url, placeholderImage: UIImage(named: "placeholder_image"))
                }
            }
            
            cell.checkBtn.addTarget(self, action: #selector(self.checkButtonAction(_:)), for: .touchUpInside)
            cell.checkBtn.tag = indexPath.row
        }
        
        
        if checkboxIndexPath.contains(indexPath) {
            cell.checkBtn.setImage (UIImage(named: "check", in: bundle, compatibleWith: nil), for: .normal)
        }else{
            cell.checkBtn.setImage(UIImage(named: "uncheck", in: bundle, compatibleWith: nil), for: .normal)
        }
        
        if (templateLanguage?.caseInsensitiveCompare(preferred_language_Type) == .orderedSame){
            cell.bgV.semanticContentAttribute = .forceRightToLeft
            cell.titleLbl.textAlignment = .right
            cell.cardnoLbl.textAlignment = .left
        }else{
            cell.bgV.semanticContentAttribute = .forceLeftToRight
            cell.titleLbl.textAlignment = .left
            cell.cardnoLbl.textAlignment = .right
        }
        
        return cell
    }
    @objc fileprivate func checkButtonAction(_ sender: AnyObject!) {
        
        //        if checkArray[sender.tag] == "No"{
        //            checkArray[sender.tag] = "Yes"
        //            selectedValues.append(elements.value ?? "")
        //        }else{
        //            checkArray[sender.tag] = "No"
        //            var index = 1000
        //            for i in 0..<selectedValues.count{
        //                if elements.value == selectedValues[i]{
        //                    index = i
        //                }
        //            }
        //            if index != 1000{
        //                selectedValues.remove(at: index)
        //            }
        //        }
        //        tableView.reloadData()
        if sender.tag == 100{
            let indexPath = IndexPath(row: 0 , section: 0)
            if checkboxIndexPath.contains(indexPath) {
                checkboxIndexPath = []
                arrayOfSeletedTitles = []
                arrayOfSeletedValues = []
            }else{
                checkboxIndexPath = []
                arrayOfSeletedTitles = []
                arrayOfSeletedValues = []
                for i in 0..<arrayOfComponents.count + 1 {
                    let allIndexPath = IndexPath(row: i , section: 0)
                    checkboxIndexPath.append(allIndexPath)
                }
                
                for i in 0..<arrayOfComponents.count  {
                    let elements = arrayOfComponents[i]
                    let title = "\(elements.title!)"
                    arrayOfSeletedTitles.append(title)
                    
                    if elements.elementPayload != nil{
                        let valaue = "\(elements.elementPayload!)"
                        arrayOfSeletedValues.append(valaue)
                    }
                }
                
            }
            tableView.reloadData()
        }else{
            let elements = arrayOfComponents[sender.tag - 1]
            let indexPath = IndexPath(row: sender.tag , section: 0)
            if checkboxIndexPath.contains(indexPath) {
                removeSelectedTitles(title: elements.title!, index: sender.tag - 1)
                if elements.elementPayload != nil{
                    removeSelectedValues(value: elements.elementPayload!, index: sender.tag - 1)
                }
                checkboxIndexPath.remove(at: checkboxIndexPath.firstIndex(of: indexPath)!)
            }else{
                checkboxIndexPath.append(indexPath)
                let title = "\(elements.title!)"
                arrayOfSeletedTitles.append(title)
                
                if elements.elementPayload != nil{
                    let valaue = "\(elements.elementPayload!)"
                    arrayOfSeletedValues.append(valaue)
                }
                
            }
            
            
            if arrayOfSeletedTitles.count == arrayOfComponents.count{
                let indexPath = IndexPath(row: 0 , section: 0)
                checkboxIndexPath.append(indexPath)
            }else if arrayOfSeletedTitles.count == 0{
                checkboxIndexPath = []
            }else if checkboxIndexPath.count == 0{
                arrayOfSeletedValues = []
                arrayOfSeletedTitles = []
            } else{
                let indexPath = IndexPath(row: 0 , section: 0)
                if checkboxIndexPath.contains(indexPath) {
                    checkboxIndexPath.remove(at: checkboxIndexPath.firstIndex(of: indexPath)!)
                }
            }
            print("checkboxIndexPath\(checkboxIndexPath)")
            print("FinalValues \(arrayOfSeletedValues)")
            print("FinalTitles \(arrayOfSeletedTitles)")
            tableView.reloadData()
            //tableView.reloadRows(at: [indexPath], with: .none)
        }
        
    }
    func removeSelectedValues(value:String, index: Int){
        //print(arrayOfSeletedValues)
        //arrayOfSeletedValues = arrayOfSeletedValues.filter(){$0 != value}
        //print(arrayOfSeletedValues)
        var removeIndex = 100
        for i in 0..<arrayOfSeletedValues.count{
            if i == index{
                removeIndex = i
            }
        }
        
        if removeIndex != 100{
            arrayOfSeletedValues.remove(at: removeIndex)
        }
        //print(arrayOfSeletedValues)
    }
    func removeSelectedTitles(title:String, index: Int){
        //print(arrayOfSeletedTitles)
        //arrayOfSeletedTitles = arrayOfSeletedTitles.filter(){$0 != title}
        //print(arrayOfSeletedTitles)
        
        var removeIndex = 100
        for i in 0..<arrayOfSeletedTitles.count{
            if i == index{
                removeIndex = i
            }
        }
        
        if removeIndex != 100{
            arrayOfSeletedTitles.remove(at: removeIndex)
        }
        //print(arrayOfSeletedTitles)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let elements = arrayOfComponents[indexPath.row]
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        let showMoreButton = UIButton(frame: CGRect.zero)
        showMoreButton.backgroundColor = themeColor
        showMoreButton.translatesAutoresizingMaskIntoConstraints = false
        showMoreButton.clipsToBounds = true
        showMoreButton.layer.cornerRadius = 5
        showMoreButton.setTitleColor(.white, for: .normal)
        showMoreButton.setTitleColor(Common.UIColorRGB(0x999999), for: .disabled)
        showMoreButton.titleLabel?.font = UIFont(name: mediumCustomFont, size: 12.0)
        view.addSubview(showMoreButton)
        showMoreButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
        showMoreButton.addTarget(self, action: #selector(self.submitButtonAction(_:)), for: .touchUpInside)
        showMoreButton.setTitle(submitBtnTitle, for: .normal)
        showMoreButton.layer.borderWidth = 1
        showMoreButton.layer.borderColor = themeColor.cgColor
        if arrayOfSeletedValues.count > 0{
            showMoreButton.alpha = 1.0
        }else{
            showMoreButton.alpha = 0.5
        }
        
        let cancelButton = UIButton(frame: CGRect.zero)
        cancelButton.backgroundColor = .clear
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.clipsToBounds = true
        cancelButton.layer.cornerRadius = 5
        cancelButton.setTitleColor(themeColor, for: .normal)
        cancelButton.setTitleColor(themeColor, for: .disabled)
        cancelButton.titleLabel?.font = UIFont(name: mediumCustomFont, size: 12.0)
        view.addSubview(cancelButton)
        cancelButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
        cancelButton.addTarget(self, action: #selector(self.cancelButtonAction(_:)), for: .touchUpInside)
        cancelButton.setTitle(cancenBtnTitle, for: .normal)
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = themeColor.cgColor
        
        
        let views: [String: UIView] = ["showMoreButton": showMoreButton, "cancelButton": cancelButton]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[showMoreButton(35)]", options:[], metrics:nil, views:views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[showMoreButton(90)]-0-|", options:[], metrics:nil, views:views))
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[cancelButton(35)]", options:[], metrics:nil, views:views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[cancelButton(90)]", options:[], metrics:nil, views:views))
        
        if (templateLanguage?.caseInsensitiveCompare(preferred_language_Type) == .orderedSame){
            view.semanticContentAttribute = .forceRightToLeft
        }else{
            view.semanticContentAttribute = .forceLeftToRight
        }
        return view
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 50
    }
    
}
