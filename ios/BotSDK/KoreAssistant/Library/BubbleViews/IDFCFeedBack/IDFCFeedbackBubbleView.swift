//
//  IDFCFeedbackBubbleView.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek.Pagidimarri on 06/12/21.
//  Copyright © 2021 Kore. All rights reserved.
//

import UIKit

class IDFCFeedbackBubbleView: BubbleView {
    let bundle = KREResourceLoader.shared.resourceBundle()
    static let elementsLimit: Int = 4
    
    var tileBgv: UIView!
    var titleLbl: UILabel!
    var descBGV: UIView!
    var feedBackTxtV: UITextView!
    var underlineLabel: UILabel!
    var placeHolderLabel: UILabel!
    var suggestionTitleLbl: UILabel!
    var tableView: UITableView!
    var cardView: UIView!
    var suggestionView: UIView!
    let kMaxTextWidth: CGFloat = BubbleViewMaxWidth - 20.0
    let kMinTextWidth: CGFloat = 20.0
    var collectionView: UICollectionView!
    let customCellIdentifier = "IDFCFeedbackCell"
    var suggestionVHeightConstraint: NSLayoutConstraint!
    var sendBtn: UIButton!
    
    public var maskview: UIView!
    
    var arrayOfElements = [FeedBackItems]()
    var arrayOfButtons = [FeedbackButtons]()
    var showMore = false
    
    var  selectedIndex = 100
    var selectedRows = NSMutableArray()
    var selectedRowsValue = NSMutableArray()
    var selectElements = [FeedBackItems]()
    var selectButtons = [FeedbackButtons]()
    
    public var optionsAction: ((_ text: String?, _ payload: String?) -> Void)!
    public var linkAction: ((_ text: String?) -> Void)!

    override func applyBubbleMask() {
        //nothing to put here
        if(self.maskLayer == nil){
            self.maskLayer = CAShapeLayer()
            // self.tileBgv.layer.mask = self.maskLayer
        }
        self.maskLayer.path = self.createBezierPath().cgPath
        self.maskLayer.position = CGPoint(x:0, y:0)
    }
    
    override var tailPosition: BubbleMaskTailPosition! {
        didSet {
            self.backgroundColor = .clear
        }
    }
    
    override func prepareForReuse() {
    }
    
    override func initialize() {
        super.initialize()
        // UserDefaults.standard.set(false, forKey: "SliderKey")
        intializeCardLayout()
        let layout = UICollectionViewFlowLayout()
         layout.scrollDirection = .horizontal
         self.collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
         self.collectionView.translatesAutoresizingMaskIntoConstraints = false
         self.collectionView.dataSource = self
         self.collectionView.delegate = self
         self.collectionView.backgroundColor = .clear
         self.collectionView.showsHorizontalScrollIndicator = false
         self.collectionView.showsVerticalScrollIndicator = false
         self.collectionView.bounces = false
         self.collectionView.isScrollEnabled = false
         self.cardView.addSubview(self.collectionView)
        
        self.collectionView.register(UINib(nibName: "IDFCFeedbackCell", bundle: bundle),
                                     forCellWithReuseIdentifier: customCellIdentifier)
        
        self.suggestionView = UIView(frame:.zero)
        self.suggestionView.translatesAutoresizingMaskIntoConstraints = false
        self.cardView.addSubview(self.suggestionView)
        suggestionView.layer.rasterizationScale =  UIScreen.main.scale
        suggestionView.layer.shadowColor = UIColor.clear.cgColor
        suggestionView.layer.shadowOpacity = 1
        suggestionView.layer.shadowOffset =  CGSize(width: 0.0, height: -3.0)
        suggestionView.layer.shadowRadius = 6.0
        suggestionView.layer.shouldRasterize = true
        suggestionView.layer.cornerRadius = 10.0
        suggestionView.backgroundColor =  UIColor.init(hexString: "#712126")
       
        self.maskview = UIView(frame:.zero)
        self.maskview.translatesAutoresizingMaskIntoConstraints = false
        self.cardView.addSubview(self.maskview)
        self.maskview.isHidden = true
        maskview.backgroundColor = .clear
        
        
        let views: [String: UIView] = ["collectionView": collectionView, "maskview": maskview, "suggestionView":suggestionView]
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[collectionView(110)]-5-[suggestionView]-10-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[collectionView]-16-|", options: [], metrics: nil, views: views))
        
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[suggestionView]-10-|", options: [], metrics: nil, views: views))
        
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[maskview]|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[maskview]-0-|", options: [], metrics: nil, views: views))
        
        suggestionVHeightConstraint = NSLayoutConstraint.init(item: suggestionView as Any, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0)
        self.cardView.addConstraint(suggestionVHeightConstraint)
        
        intializeSuggestionsLayout()
        
//        selectedIndex = 100
//         selectedRows = []
//         selectedRowsValue = []
//         selectElements = []
//         selectButtons = []
//        feedBackTxtV.text = ""
//        collectionView.reloadData()
//        tableView.reloadData()
    }
    func intializeSuggestionsLayout(){
        self.titleLbl = UILabel(frame: CGRect.zero)
        self.titleLbl.textColor = BubbleViewBotChatTextColor
        self.titleLbl.backgroundColor = UIColor.clear
        self.titleLbl.font = UIFont(name: regularCustomFont, size: 14.0)
        self.titleLbl.numberOfLines = 0
        self.titleLbl.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.titleLbl.isUserInteractionEnabled = true
        self.titleLbl.translatesAutoresizingMaskIntoConstraints = false
        self.suggestionView.addSubview(self.titleLbl)
        
        self.tableView = UITableView(frame: CGRect.zero,style:.plain)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.backgroundColor = .clear
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.showsVerticalScrollIndicator = true
        self.tableView.bounces = false
        self.tableView.layer.cornerRadius = 10
        self.tableView.clipsToBounds = true
        self.tableView.separatorStyle = .none
        self.suggestionView.addSubview(self.tableView)
        self.tableView.isScrollEnabled = false
        
        self.tableView.register(UINib(nibName: "IDFCFeedbackSugggestionCell", bundle: bundle), forCellReuseIdentifier: "IDFCFeedbackSugggestionCell")
        
        self.descBGV = UIView(frame:.zero)
        self.descBGV.translatesAutoresizingMaskIntoConstraints = false
        self.descBGV.layer.rasterizationScale =  UIScreen.main.scale
        self.descBGV.layer.shouldRasterize = true
        self.descBGV.layer.cornerRadius = 20.0
        self.descBGV.layer.borderColor = UIColor.lightGray.cgColor
        self.descBGV.clipsToBounds = true
        self.descBGV.layer.borderWidth = 0.0
        self.suggestionView.addSubview(self.descBGV)
        self.descBGV.backgroundColor = .clear
        
        sendBtn = UIButton(frame: CGRect.zero)
        sendBtn.backgroundColor = .clear
        sendBtn.translatesAutoresizingMaskIntoConstraints = false
        sendBtn.clipsToBounds = true
        sendBtn.layer.cornerRadius = 5
        sendBtn.setTitleColor(.white, for: .normal)
        sendBtn.titleLabel?.font = UIFont(name: semiBoldCustomFont, size: 12.0)
        suggestionView.addSubview(sendBtn)
        sendBtn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
        sendBtn.addTarget(self, action: #selector(self.sendButtonAction(_:)), for: .touchUpInside)
        sendBtn.addRightIcon(image: UIImage.init(named: "icons24ArrowCta")!)
        sendBtn.setTitle("Send FEEDBACK", for: .normal)
        
       
        
        let views: [String: UIView] = ["titleLbl":titleLbl, "tableView": tableView, "descBGV": descBGV, "sendBtn": sendBtn]
        self.suggestionView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-16-[titleLbl]-16-[tableView]-5-[descBGV(35)]-16-[sendBtn(35)]-16-|", options: [], metrics: nil, views: views))
        self.suggestionView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[titleLbl]-16-|", options: [], metrics: nil, views: views))
        self.suggestionView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[descBGV]-16-|", options: [], metrics: nil, views: views))
        self.suggestionView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[tableView]-10-|", options: [], metrics: nil, views: views))
        suggestionView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[sendBtn(150)]-0-|", options:[], metrics:nil, views:views))
        
        
        self.placeHolderLabel = UILabel(frame: CGRect.zero)
        self.placeHolderLabel.textColor = UIColor.init(hexString: "#a27174")
        placeHolderLabel.text = ""
        self.placeHolderLabel.backgroundColor =  .clear//UIColor.init(hexString: "#712126")
        self.placeHolderLabel.font = UIFont(name: regularCustomFont, size: 14.0)
        self.placeHolderLabel.numberOfLines = 0
        self.placeHolderLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.placeHolderLabel.isUserInteractionEnabled = true
        self.placeHolderLabel.translatesAutoresizingMaskIntoConstraints = false
        self.descBGV.addSubview(self.placeHolderLabel)
        
        self.feedBackTxtV = UITextView(frame: CGRect.zero)
        feedBackTxtV.delegate = self
        self.feedBackTxtV.textColor = BubbleViewBotChatTextColor
        self.feedBackTxtV.backgroundColor = UIColor.clear
        self.feedBackTxtV.text = ""
        self.feedBackTxtV.font = UIFont(name: semiBoldCustomFont, size: 12.0)
        self.feedBackTxtV.isUserInteractionEnabled = true
        self.feedBackTxtV.translatesAutoresizingMaskIntoConstraints = false
        self.descBGV.addSubview(self.feedBackTxtV)
        
        self.underlineLabel = UILabel(frame: CGRect.zero)
        self.underlineLabel.textColor = BubbleViewBotChatTextColor
        self.underlineLabel.backgroundColor =  UIColor.init(hexString: "#a27174")
        self.underlineLabel.font = UIFont(name: regularCustomFont, size: 14.0)
        self.underlineLabel.numberOfLines = 0
        self.underlineLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.underlineLabel.isUserInteractionEnabled = true
        self.underlineLabel.translatesAutoresizingMaskIntoConstraints = false
        self.descBGV.addSubview(self.underlineLabel)
        
        
        let subViews: [String: UIView] = ["feedBackTxtV": feedBackTxtV, "placeHolderLabel": placeHolderLabel ,"underlineLabel": underlineLabel]
        self.descBGV.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[feedBackTxtV(32)]-1-[underlineLabel(1)]-1-|", options: [], metrics: nil, views: subViews))
        self.descBGV.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-2-[placeHolderLabel(21)]", options: [], metrics: nil, views: subViews))
        self.descBGV.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[feedBackTxtV]-5-|", options: [], metrics: nil, views: subViews))
        self.descBGV.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[placeHolderLabel]-5-|", options: [], metrics: nil, views: subViews))
        self.descBGV.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[underlineLabel]-0-|", options: [], metrics: nil, views: subViews))
        
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
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[cardView]-16-|", options: [], metrics: nil, views: cardViews))
    }
    
    @objc fileprivate func sendButtonAction(_ sender: AnyObject!) {
        
        let selectedFeedbackArray = NSMutableArray()
        for i in 0..<selectButtons.count{
            let selectButton = selectButtons[i]
            let btnStyls : [String: Any] = ["color" : selectButton.buttonStyles?.color ?? "", "background":selectButton.buttonStyles?.background ?? "", "border": selectButton.buttonStyles?.border ?? ""]
            let selectedFeedbackDic : [String: Any] = ["title" : selectButton.title ?? "", "type":selectButton.type ?? "", "payload": selectButton.payload ?? "", "buttonStyles": btnStyls]
            selectedFeedbackArray.add(selectedFeedbackDic)
        }
        var selectedExperienceDic : [String: Any]?
        var displayTxt = ""
        for i in 0..<selectElements.count{
            let selectElement = selectElements[i]
            displayTxt = selectElement.feedBackDesc ?? ""
            selectedExperienceDic = ["emoji" : selectElement.emoji ?? "", "description":selectElement.feedBackDesc ?? "", "value": selectElement.value ?? "", "type": selectElement.type ?? "", "id": selectElement.id ?? 00]
        }
        var feedBackDic: NSDictionary?
        feedBackDic = ["selectedFeedback": selectedFeedbackArray,
                      "selectedExperience": selectedExperienceDic ?? [:],
                      "userSuggestion": feedBackTxtV.text ?? ""]
        
        if let theJSONData = try? JSONSerialization.data(withJSONObject: feedBackDic ?? [],options: []) {
            let theJSONText = String(data: theJSONData,encoding: .ascii)
            print("JSON string = \(theJSONText!)")
            self.optionsAction("feedback Sent", theJSONText!)
            self.maskview.isHidden = false
            selectedIndex = 100
        }
    }
    
    // MARK: populate components
    override func populateComponents() {
        if selectedIndex == 100{
        if (components.count > 0) {
            let component: KREComponent = components.firstObject as! KREComponent
            if (component.componentDesc != nil) {
                let jsonString = component.componentDesc
                let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: jsonString!) as! NSDictionary
                //let jsonObject1: NSString = Utilities.stringFromJSONObject(object: jsonObject) as! NSString
                let jsonDecoder = JSONDecoder()
                guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject as Any , options: .prettyPrinted),
                      let allItems = try? jsonDecoder.decode(Componentss.self, from: jsonData) else {
                    return
                }
                arrayOfElements = allItems.items ?? []
                selectedRows = []
                selectedRowsValue = []
                
                if arrayOfElements.count > 0{
                    self.titleLbl.text = arrayOfElements[0].suggestionContent?.heading
                    let feedBackBtns  = arrayOfElements[0].suggestionContent?.feedBackButtons ?? []
                    self.arrayOfButtons = feedBackBtns
                    if arrayOfButtons.count > 0 {
                        descBGV.isHidden  = false
                        sendBtn.isHidden = false
                        sendBtn.setTitle(arrayOfElements[0].suggestionContent?.sendTitle, for: .normal)
                        placeHolderLabel.text = arrayOfElements[0].suggestionContent?.placeholder ?? ""
                        for _ in 0..<arrayOfButtons.count{
                            selectedRows.add("false")
                            selectedRowsValue.add("")
                        }
                    }else{
                        descBGV.isHidden  = true
                        sendBtn.isHidden = true
                    }
                    self.tableView.reloadData()
                }
            }
            self.collectionView.reloadData()
        }
    }
    }
    
    //MARK: View height calculation
    override var intrinsicContentSize : CGSize {
        
        let limitingSize: CGSize  = CGSize(width: kMaxTextWidth, height: CGFloat.greatestFiniteMagnitude)
        let headingLabelSize: CGSize = self.titleLbl.sizeThatFits(limitingSize)
        var tableViewHeight = 0.0
        var spaces = 25.0 - 48.0 - 26.0 - 16.0 - 35.0
        for _ in 0..<arrayOfButtons.count{
            tableViewHeight += 50.0
            spaces = 25.0 + 48.0 + 26.0 + 16.0 + 35.0
        }
        let templateHeight = headingLabelSize.height + CGFloat(tableViewHeight) + CGFloat(spaces)
        suggestionVHeightConstraint.constant = templateHeight
        let collectionviewHeight = self.collectionView.contentSize.height == 0.0 ? 110 : self.collectionView.contentSize.height
        return CGSize(width: 0.0, height: collectionviewHeight + templateHeight )
    }
    
}
extension IDFCFeedbackBubbleView : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    //MARK: collection view delegate methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayOfElements.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // swiftlint:disable force_cast
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: customCellIdentifier, for: indexPath) as! IDFCFeedbackCell
        cell.backgroundColor = .clear
        let elements = arrayOfElements[indexPath.item]
        let image = Utilities.base64ToImage(base64String: elements.emoji)
        cell.imagV.image = image
        cell.textLabel.text = elements.feedBackDesc
        cell.textLabel.font = UIFont(name: regularCustomFont, size: 14.0)
        cell.textLabel.textAlignment = .center
        cell.textLabel.textColor = BubbleViewBotChatTextColor
        if selectedIndex == indexPath.item{
            cell.bgView.backgroundColor = UIColor.init(hexString: "#440408")
        }else{
            cell.bgView.backgroundColor = .clear
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        feedBackTxtV.resignFirstResponder()
        feedBackTxtV.text = ""
        let elements = arrayOfElements[indexPath.row]
        selectElements = []
        selectButtons = []
        
        selectElements.append(elements)
        maskview.isHidden = false
        selectedIndex = indexPath.item
        collectionView.reloadData()

        if elements.suggestionContent == nil{
            if elements.value != nil{
                self.optionsAction("feedback Sent", elements.value) //elements.feedBackDesc
                Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (_) in
                    self.selectedIndex = 100
                }
            }
        }else{
            self.titleLbl.text = elements.suggestionContent?.heading
            let feedBackBtns  = elements.suggestionContent?.feedBackButtons ?? []
            self.arrayOfButtons = feedBackBtns
            selectedRows = []
            selectedRowsValue = []
            if arrayOfButtons.count > 0 {
                descBGV.isHidden  = false
                sendBtn.isHidden = false
                sendBtn.setTitle(elements.suggestionContent?.sendTitle, for: .normal)
                placeHolderLabel.text = elements.suggestionContent?.placeholder ?? ""
                for _ in 0..<arrayOfButtons.count{
                    selectedRows.add("false")
                    selectedRowsValue.add("")
                }
            }else{
                descBGV.isHidden  = true
                sendBtn.isHidden = true
            }
            self.tableView.reloadData()
            NotificationCenter.default.post(name: Notification.Name(reloadTableNotification), object: nil)
        }
        
      
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let bubbleWidth = UIScreen.main.bounds.size.width - 64
        let cellWidth = (Int(bubbleWidth)/arrayOfElements.count) - 5
        print("cellWidth..\(cellWidth)")
        
        return CGSize(width: cellWidth, height: 110) //75
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
}

extension IDFCFeedbackBubbleView :UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayOfButtons.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : IDFCFeedbackSugggestionCell = tableView.dequeueReusableCell(withIdentifier: "IDFCFeedbackSugggestionCell") as! IDFCFeedbackSugggestionCell
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        let btns = arrayOfButtons[indexPath.row]
        cell.textlabel.text = btns.title
        cell.textlabel.textAlignment = .center
        cell.textlabel.font =  UIFont(name: semiBoldCustomFont, size: 12.0)
        cell.textlabel.textColor = .white
        
        cell.textlabel.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        if selectedRows[indexPath.row] as! String == "true"{
            cell.textlabel.backgroundColor = UIColor.init(hexString: btns.buttonStyles?.background ?? "#9B1E26")
            cell.textlabel.textColor = UIColor.init(hexString: btns.buttonStyles?.color ?? "#FFFFFF")
            
            cell.textlabel.layer.borderColor = UIColor.init(hexString: btns.buttonStyles?.background ?? "#9B1E26").cgColor
        }else{
            cell.textlabel.backgroundColor = .clear
            cell.textlabel.textColor = .white
            
            cell.textlabel.layer.borderColor = UIColor.white.cgColor
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let btns = arrayOfButtons[indexPath.row]
        if selectedRows[indexPath.row] as! String == "false"{
            selectedRows.replaceObject(at: indexPath.row, with: "true")
            selectButtons.append(btns)
        }else{
            selectedRows.replaceObject(at: indexPath.row, with: "false")
            selectButtons.remove(at: indexPath.row)
        }
        tableView.reloadData()
    }
   
}
extension IDFCFeedbackBubbleView : UITextViewDelegate{
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let text = textView.text,
           let _ = Range(range, in: text) {
                  //let updatedText = text.replacingCharacters(in: textRange, with: text)
                placeHolderLabel.isHidden = true
        }else{
            placeHolderLabel.isHidden = false
        }
        
        
        
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            placeHolderLabel.isHidden = false
        }
    }
}

class EdgeInsetLabel: UILabel {
    var textInsets = UIEdgeInsets.zero {
        didSet { invalidateIntrinsicContentSize() }
    }

    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let textRect = super.textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines)
        let invertedInsets = UIEdgeInsets(top: -textInsets.top,
                                          left: -textInsets.left,
                                          bottom: -textInsets.bottom,
                                          right: -textInsets.right)
        return textRect.inset(by: invertedInsets)
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }
}
