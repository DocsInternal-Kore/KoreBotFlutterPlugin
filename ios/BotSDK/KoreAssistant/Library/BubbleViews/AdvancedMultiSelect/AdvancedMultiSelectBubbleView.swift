//
//  AdvancedMultiSelectBubbleView.swift
//  KoreBotSDKFrameWork
//
//  Created by Kartheek.Pagidimarri on 03/08/22.
//  Copyright © 2022 Kartheek.Pagidimarri. All rights reserved.
//
import UIKit
import korebotplugin
class AdvancedMultiSelectBubbleView: BubbleView {
    let bundle = KREResourceLoader.shared.resourceBundle()
    var tileBgv: UIView!
    public var maskview: UIView!
    var titleLbl: KREAttributedTextView!
    var tableView: UITableView!
    var cardView: UIView!
    let kMaxTextWidth: CGFloat = BubbleViewMaxWidth - 32.0
    let kMinTextWidth: CGFloat = 20.0
    fileprivate let listCellIdentifier = "AdvancedMultiCellTableViewCell"
    var arrayOfElements = [AdvancedElements]()
    var arrayOfComponents = [ComponentElements]()
    var submitBtnTitle = "Submit"
//    var checkArray = [String]()
//    var selectedValues = [String]()
    public var optionsAction: ((_ text: String?, _ payload: String?) -> Void)!
    var templateLanguage:String?
    
    var checkboxIndexPath = [IndexPath]()
    var arrayOfSeletedValues = [String]()
    var arrayOfSeletedTitles = [String]()
    var cancelBtn : UIButton!
    var showMoreButton :UIButton!
    
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
                print(jsonObject)
                let jsonDecoder = JSONDecoder()
                guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject as Any , options: .prettyPrinted),
                    let allItems = try? jsonDecoder.decode(AdvancedListData.self, from: jsonData) else {
                                                return
                                        }
                arrayOfElements = allItems.elements ?? []
                if arrayOfElements.count > 0{
                    let elements = arrayOfElements[0]
                    print(elements)
                    arrayOfComponents = elements.collection ?? []
                }
                //self.titleLbl.text = allItems.heading ?? ""
                self.titleLbl.setHTMLString(allItems.heading ?? "", withWidth: kMaxTextWidth)
                if let arrayOFBtns = allItems.buttons, arrayOFBtns.count > 0{
                    let btn = arrayOFBtns[0]
                    submitBtnTitle = btn.title ?? "Submit"
                }

                if let selectallBox = allItems.selectAllCheckbox, selectallBox == true{
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
                        
                        if elements.value != nil{
                            let valaue = "\(elements.value!)"
                            arrayOfSeletedValues.append(valaue)
                         }
                      }
                    }
                }
                
                
                templateLanguage = allItems.lang ?? default_language
                if (templateLanguage?.caseInsensitiveCompare(preferred_language_Type) == .orderedSame){
                    self.titleLbl.textAlignment = .right
                }else{
                    self.titleLbl.textAlignment = .left
                }
                self.tableView.reloadData()
            }
        }
    }
    
    //MARK: View height calculation
    override var intrinsicContentSize : CGSize {
        
        let limitingSize: CGSize  = CGSize(width: kMaxTextWidth, height: CGFloat.greatestFiniteMagnitude)
        var textSize: CGSize = self.titleLbl.sizeThatFits(limitingSize)
        if textSize.height < self.titleLbl.font?.pointSize ?? 0.0 {
            textSize.height = self.titleLbl.font?.pointSize ?? 0.0
        }
        
        var cellHeight : CGFloat = 0.0
        var moreButtonHeight : CGFloat = 30.0
        let rows = arrayOfComponents.count
        var finalHeight: CGFloat = 78.0
        
        let verticalSpace = 40
            for i in 0..<rows {
                let elements = arrayOfComponents[i]
                if i == 0 {
                    cellHeight = 55
                }else{
                    cellHeight = 78
                }
                
                if elements.subtitle == nil{

                }
                finalHeight += cellHeight
            }
        
        moreButtonHeight =  50.0
        return CGSize(width: 0.0, height: textSize.height+CGFloat(verticalSpace)+finalHeight+moreButtonHeight)
    }
    @objc fileprivate func cancelButtonAction(_ sender: AnyObject!) {
        cancelBtn.setTitleColor(.white, for: .normal)
        cancelBtn.backgroundColor = themeColor
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { (_) in
            self.cancelBtn.setTitleColor(themeColor, for: .normal)
            self.cancelBtn.backgroundColor = .white
        }
        self.maskview.isHidden = false
        self.optionsAction("cancel","cancel")
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
}

extension AdvancedMultiSelectBubbleView: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 78
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 55
        }
        return 78
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfComponents.count + 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : AdvancedMultiCellTableViewCell = tableView.dequeueReusableCell(withIdentifier: listCellIdentifier) as! AdvancedMultiCellTableViewCell
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        cell.titleLbl.font =  UIFont(name: regularCustomFont, size: 14.0)
        if indexPath.row == 0{
            cell.titleLbl.text = "Select All"
            cell.cardnoLbl.text = ""
            cell.checkBtn.addTarget(self, action: #selector(self.checkButtonAction(_:)), for: .touchUpInside)
            cell.checkBtn.tag = 100
            cell.titleLblTopConstarint.constant = 12
        }else{
            let elements = arrayOfComponents[indexPath.row - 1]
            cell.titleLbl.text = elements.title
            cell.cardnoLbl.text = elements.elementDescription
            cell.checkBtn.addTarget(self, action: #selector(self.checkButtonAction(_:)), for: .touchUpInside)
            cell.checkBtn.tag = indexPath.row
            cell.titleLblTopConstarint.constant = 12
            if elements.elementDescription == nil{
                cell.titleLblTopConstarint.constant = 25
            }
        }
       
//        if checkArray[indexPath.row] == "Yes"{
//            cell.checkBtn.setImage (UIImage(named: "check", in: bundle, compatibleWith: nil), for: .normal)
//        }else{
//            cell.checkBtn.setImage(UIImage(named: "uncheck", in: bundle, compatibleWith: nil), for: .normal)
//        }
        if checkboxIndexPath.contains(indexPath) {
            //cell.checkBtn.setImage (UIImage(named: "checkM", in: bundle, compatibleWith: nil), for: .normal)
            cell.checkImage.image = UIImage.init(named: "checkM", in: bundle, compatibleWith: nil)
        }else{
            //cell.checkBtn.setImage(UIImage(named: "uncheckM", in: bundle, compatibleWith: nil), for: .normal)
            cell.checkImage.image = UIImage.init(named: "uncheckM", in: bundle, compatibleWith: nil)
        }
        
        if (templateLanguage?.caseInsensitiveCompare(preferred_language_Type) == .orderedSame){
            cell.bgV.semanticContentAttribute = .forceRightToLeft
            cell.titleLbl.textAlignment = .right
            cell.cardnoLbl.textAlignment = .right
        }else{
            cell.bgV.semanticContentAttribute = .forceLeftToRight
            cell.titleLbl.textAlignment = .left
            cell.cardnoLbl.textAlignment = .left
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
                
                if elements.value != nil{
                    let valaue = "\(elements.value!)"
                    arrayOfSeletedValues.append(valaue)
                 }
              }
                
            }
            tableView.reloadData()
        }else{
            let elements = arrayOfComponents[sender.tag - 1]
            let indexPath = IndexPath(row: sender.tag , section: 0)
            if checkboxIndexPath.contains(indexPath) {
                removeSelectedTitles(title: elements.title!)
                if elements.value != nil{
                    removeSelectedValues(value: elements.value!)
                }
                checkboxIndexPath.remove(at: checkboxIndexPath.firstIndex(of: indexPath)!)
            }else{
                checkboxIndexPath.append(indexPath)
                let title = "\(elements.title!)"
                arrayOfSeletedTitles.append(title)
                
                if elements.value != nil{
                    let valaue = "\(elements.value!)"
                    arrayOfSeletedValues.append(valaue)
                }
                
            }
            
            
            if arrayOfSeletedTitles.count == arrayOfComponents.count{
                let indexPath = IndexPath(row: 0 , section: 0)
                checkboxIndexPath.append(indexPath)
            }else if arrayOfSeletedTitles.count == 0{
                checkboxIndexPath = []
            }else{
                let indexPath = IndexPath(row: 0 , section: 0)
                if checkboxIndexPath.contains(indexPath) {
                    checkboxIndexPath.remove(at: checkboxIndexPath.firstIndex(of: indexPath)!)
                }
            }
            tableView.reloadData()
            //tableView.reloadRows(at: [indexPath], with: .none)
        }
        
    }
    func removeSelectedValues(value:String){
        arrayOfSeletedValues = arrayOfSeletedValues.filter(){$0 != value}
        print(arrayOfSeletedValues)
    }
    func removeSelectedTitles(title:String){
        arrayOfSeletedTitles = arrayOfSeletedTitles.filter(){$0 != title}
        print(arrayOfSeletedTitles)
    }
    
    func getAllIndexPathsInSection(section : Int) -> [IndexPath] {
        return tableView.visibleCells.map({tableView.indexPath(for: $0)}).filter({($0?.section)! == section}) as! [IndexPath]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let elements = arrayOfComponents[indexPath.row]
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
            showMoreButton = UIButton(frame: CGRect.zero)
            showMoreButton.backgroundColor = themeColor
            showMoreButton.translatesAutoresizingMaskIntoConstraints = false
            showMoreButton.clipsToBounds = true
            showMoreButton.layer.cornerRadius = 5
            showMoreButton.setTitleColor(BubbleViewUserChatTextColor, for: .normal)
            showMoreButton.setTitleColor(Common.UIColorRGB(0x999999), for: .disabled)
            showMoreButton.titleLabel?.font = UIFont(name: mediumCustomFont, size: 12.0)
            view.addSubview(showMoreButton)
            showMoreButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
            showMoreButton.addTarget(self, action: #selector(self.submitButtonAction(_:)), for: .touchUpInside)
            showMoreButton.setTitle(submitBtnTitle, for: .normal)
            showMoreButton.layer.borderWidth = 1
            showMoreButton.layer.borderColor = themeColor.cgColor
        if arrayOfSeletedTitles.count == 0 {
            //showMoreButton.isHidden = true
            showMoreButton.alpha = 0.5
        }else{
            //showMoreButton.isHidden = false
            showMoreButton.alpha = 1.0
        }
        
         cancelBtn = UIButton(frame: CGRect.zero)
        cancelBtn.backgroundColor = .white
        cancelBtn.translatesAutoresizingMaskIntoConstraints = false
        cancelBtn.clipsToBounds = true
        cancelBtn.layer.cornerRadius = 5
        cancelBtn.setTitleColor(themeColor, for: .normal)
        cancelBtn.setTitleColor(Common.UIColorRGB(0x999999), for: .disabled)
        cancelBtn.titleLabel?.font = UIFont(name: mediumCustomFont, size: 12.0)
        view.addSubview(cancelBtn)
        cancelBtn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
        cancelBtn.addTarget(self, action: #selector(self.cancelButtonAction(_:)), for: .touchUpInside)
        cancelBtn.setTitle("Cancel", for: .normal)
        cancelBtn.layer.borderWidth = 1
        cancelBtn.layer.borderColor = themeColor.cgColor
          
            
        let views: [String: UIView] = ["cancelBtn": cancelBtn,"showMoreButton": showMoreButton]
        if (templateLanguage?.caseInsensitiveCompare(preferred_language_Type) == .orderedSame){
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[showMoreButton(90)]", options:[], metrics:nil, views:views))
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[cancelBtn(90)]-0-|", options:[], metrics:nil, views:views))
        }else{
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[showMoreButton(90)]-0-|", options:[], metrics:nil, views:views))
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[cancelBtn(90)]", options:[], metrics:nil, views:views))
        }
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[showMoreButton(35)]", options:[], metrics:nil, views:views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[cancelBtn(35)]", options:[], metrics:nil, views:views))
            
        return view
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 50
    }
    
}
