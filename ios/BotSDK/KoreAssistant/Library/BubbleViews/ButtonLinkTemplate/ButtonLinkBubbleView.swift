//
//  ButtonLinkBubbleView.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek.Pagidimarri on 06/12/21.
//  Copyright © 2021 Kore. All rights reserved.
//

import UIKit


class ButtonLinkBubbleView: BubbleView  {
    static let elementsLimit: Int = 4
    
    var tileBgv: UIView!
    var maskview: UIView!
    var titleLbl: UILabel!
    var tableView: UITableView!
    var cardView: UIView!
    let kMaxTextWidth: CGFloat = BubbleViewMaxWidth - 20.0
    let kMinTextWidth: CGFloat = 20.0
    var collectionView: UICollectionView!
    let customCellIdentifier = "ButtonLinkCell"
    
    var arrayOfElements = [ComponentElements]()
    var showMore = false
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
    
    var isReloadBtnLink = true
    
    override var tailPosition: BubbleMaskTailPosition! {
        didSet {
            self.backgroundColor = .clear
        }
    }
    
    override func initialize() {
        super.initialize()
        // UserDefaults.standard.set(false, forKey: "SliderKey")
        intializeCardLayout()
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
        self.collectionView.isScrollEnabled = false
        self.cardView.addSubview(self.collectionView)
        let bundle = KREResourceLoader.shared.resourceBundle()
        self.collectionView.register(UINib(nibName: "ButtonLinkCell", bundle: bundle),
                                     forCellWithReuseIdentifier: customCellIdentifier)
        
        self.maskview = UIView(frame:.zero)
        self.maskview.translatesAutoresizingMaskIntoConstraints = false
        self.cardView.addSubview(self.maskview)
        self.maskview.isHidden = true
        self.maskview.backgroundColor = .clear
        
        let views: [String: UIView] = ["collectionView": collectionView, "maskview": maskview]
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[collectionView]-0-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[maskview]|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[collectionView]-16-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[maskview]-0-|", options: [], metrics: nil, views: views))
        
        if isReloadBtnLink {
            isReloadBtnLink = false
            NotificationCenter.default.post(name: Notification.Name(reloadTableNotification), object: nil)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(showMaskView), name: NSNotification.Name(rawValue: btnlinkTempMaskViewNotification), object: nil)
    }
    @objc func showMaskView(notification:Notification) {
        //self.maskview.isHidden = false
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
                arrayOfElements = allItems.elements ?? []
            }
            
            self.collectionView.collectionViewLayout.invalidateLayout()
            //self.collectionView.layoutIfNeeded()
            self.collectionView.reloadData()
        }
    }
    
    //MARK: View height calculation
    override var intrinsicContentSize : CGSize {
        let collectionviewHeight  = Double(self.collectionView.collectionViewLayout.collectionViewContentSize.height)
        return CGSize(width: 0.0, height: collectionviewHeight)
    }
    
}
extension ButtonLinkBubbleView : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
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
        cell.textlabel.font = UIFont(name: semiBoldCustomFont, size: 14.0)
        cell.textlabel.textAlignment = .center
        cell.textlabel.textColor = bubbleViewBotChatButtonTextColor
        cell.bgV.backgroundColor = bubbleViewBotChatButtonBgColor
        cell.layer.borderWidth = 1.0
        cell.layer.borderColor = bubbleViewBotChatButtonBgColor.cgColor
        cell.layer.cornerRadius = 8.0
        cell.clipsToBounds = true
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
            showMaskVInBtnLink = false
            self.linkAction(elements.elementUrl)
        }
    }
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath){
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath){
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let elements = arrayOfElements[indexPath.row]
        let text = elements.title
//        let indexPath = IndexPath(row: indexPath.item, section: indexPath.section)
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: customCellIdentifier, for: indexPath) as! ButtonLinkCell
//        cell.textlabel.text = text
//        cell.layer.cornerRadius = 20.0
        var textWidth = 10
        let size = text?.size(withAttributes:[.font: UIFont(name: semiBoldCustomFont, size: 14.0) as Any])
        if text != nil {
            textWidth = Int(size!.width)
        }
        return CGSize(width:textWidth + 32 + 20, height: 40)
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
