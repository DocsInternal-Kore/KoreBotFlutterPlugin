//
//  IDFCUpdatedCarouselBubbleView.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek.Pagidimarri on 04/01/22.
//  Copyright © 2022 Kore. All rights reserved.
//

import UIKit

class IDFCUpdatedCarouselBubbleView: BubbleView {
    var cardView: UIView!
    var maskview: UIView!
    var collectionView: UICollectionView!
    let customCellIdentifier = "IDFCUpdatedCaroselCell"
    let kMaxTextWidth: CGFloat = BubbleViewMaxWidth - 20.0
    let kMinTextWidth: CGFloat = 20.0
    var arrayOfCarousels = [ComponentElements]()
    var arrayOfElementsTitles = NSMutableArray()
    var maxCellHeight = 0.0
    let templateWidth = 300
    var tileBgv: UIView!
    var titleLbl: KREAttributedLabel!
    
    public var optionsAction: ((_ text: String?, _ payload: String?) -> Void)!
    public var linkAction: ((_ text: String?) -> Void)!
    
    override func applyBubbleMask() {
        //nothing to put here
    }
    
    override var tailPosition: BubbleMaskTailPosition! {
        didSet {
            self.backgroundColor = .clear
        }
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
        cardView.backgroundColor =  UIColor.clear
        let cardViews: [String: UIView] = ["cardView": cardView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[cardView]-0-|", options: [], metrics: nil, views: cardViews))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[cardView]-0-|", options: [], metrics: nil, views: cardViews))
    }
    
    override func initialize() {
        super.initialize()
        intializeCardLayout()
        createCollectionView()
    }

    func createCollectionView(){
        
        self.tileBgv = UIView(frame:.zero)
        self.tileBgv.translatesAutoresizingMaskIntoConstraints = false
        self.tileBgv.layer.rasterizationScale =  UIScreen.main.scale
        self.tileBgv.layer.shouldRasterize = true
        self.tileBgv.layer.cornerRadius = 10.0
        self.tileBgv.layer.borderColor = UIColor.lightGray.cgColor
        self.tileBgv.clipsToBounds = true
        self.tileBgv.layer.borderWidth = 0.0
        self.tileBgv.backgroundColor = .lightGray
        self.cardView.addSubview(self.tileBgv)
        self.tileBgv.backgroundColor = BubbleViewLeftTint
        
        
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
         self.cardView.addSubview(self.collectionView)
        let bundle = KREResourceLoader.shared.resourceBundle()
         self.collectionView.register(UINib(nibName: customCellIdentifier, bundle: bundle),
                                     forCellWithReuseIdentifier: customCellIdentifier)
        
        self.maskview = UIView(frame:.zero)
        self.maskview.translatesAutoresizingMaskIntoConstraints = false
        self.cardView.addSubview(self.maskview)
        self.maskview.isHidden = true
        maskview.backgroundColor = .clear
        
        let views: [String: UIView] = ["tileBgv": tileBgv, "collectionView": collectionView, "maskview": maskview]
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[tileBgv]-15-[collectionView]-5-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[maskview]|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[collectionView]-20-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[maskview]-0-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[tileBgv]", options: [], metrics: nil, views: views))
        
        self.titleLbl = KREAttributedLabel(frame: CGRect.zero)
        self.titleLbl.textColor = BubbleViewBotChatTextColor
        self.titleLbl.font = UIFont(name: regularCustomFont, size: 14.0)
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
        let metrics: [String: NSNumber] = ["textLabelMaxWidth": NSNumber(value: Float(kMaxTextWidth)), "textLabelMinWidth": NSNumber(value: Float(kMinTextWidth))]
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-16-[titleLbl]-16-|", options: [], metrics: metrics, views: subView))
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[titleLbl(>=textLabelMinWidth,<=textLabelMaxWidth)]-16-|", options: [], metrics: metrics, views: subView))
       
        NotificationCenter.default.addObserver(self, selector: #selector(showMaskView), name: NSNotification.Name(rawValue: carouselTempMaskViewNotification), object: nil)
    }
    @objc func showMaskView(notification:Notification) {
        self.maskview.isHidden = false
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
              
                self.arrayOfCarousels = allItems.elements ?? []
                self.collectionView.collectionViewLayout.invalidateLayout()
                //self.collectionView.layoutIfNeeded()
                self.titleLbl.setHTMLString(jsonObject["text"] as? String, withWidth: kMaxTextWidth)
                let elements: Array<Dictionary<String, Any>> = jsonObject["elements"] != nil ? jsonObject["elements"] as! Array<Dictionary<String, Any>> : []
                arrayOfElementsTitles = []
                for i in 0..<elements.count {
                    let dictionary = elements[i]
                    let elementsContent: Array = dictionary["content"] != nil ? dictionary["content"] as! Array : []
                    var titleStr = ""
                    var appendStr = ""
                    for j in 0..<elementsContent.count{
                        if j == 0{
                            appendStr = "\n•  \(elementsContent[j])\n"
                        }else{
                            appendStr = "•  \(elementsContent[j])\n"
                        }
                        titleStr += appendStr
                    }
                    print(titleStr)
                    let title: String = titleStr
                    arrayOfElementsTitles.add(title)
                }
                
                maxCellHeight = Double(getExpectedHeight())
                collectionView.reloadData()
            }
        }
    }
    
    func getAttributedString(text: String) -> NSMutableAttributedString {
        let title = text
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 0.25 * 16.0
        let myAttributes = [NSAttributedString.Key.foregroundColor:UIColor(hex: 0x353535),
                            NSAttributedString.Key.font: UIFont(name: semiBoldCustomFont, size: 14.0),
                            NSAttributedString.Key.paragraphStyle:paragraphStyle]
        let mutableAttrString = NSMutableAttributedString(string: title, attributes: myAttributes as [NSAttributedString.Key : Any])
        return mutableAttrString
    }
    
     func getExpectedHeight() -> CGFloat {
        let cellWidth = templateWidth
        var cellBtnHeight = 30
        var imageVHeight = 120
        var maxiCellHeight = 10
        
        for i in 0..<arrayOfCarousels.count{
            let elements = arrayOfCarousels[i]
            var textHeight = 10
            let padding = 30.0
            let attrString: NSMutableAttributedString = getAttributedString(text: arrayOfElementsTitles[i] as? String ?? "")
            let limitingSize: CGSize = CGSize(width: CGFloat(Double(cellWidth) - padding), height: CGFloat.greatestFiniteMagnitude)
            let rect: CGRect = (attrString.boundingRect(with: limitingSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil))
            textHeight = Int(rect.size.height)
            
            if elements.backgroundImageUrl == nil{
                imageVHeight = 0
            }else{
                imageVHeight = 200
            }
            
            let elementsBtn = elements.elementsbuttons
            if elementsBtn?.count ?? 0  > 0{
                cellBtnHeight = 30
            }else{
                cellBtnHeight = 0
            }

            let number = (Int(textHeight) + cellBtnHeight + imageVHeight)
            if (maxiCellHeight < number) {
                maxiCellHeight = number
            }
        }
        
        return CGFloat(maxiCellHeight)
    }
    
    
    //MARK: View height calculation
       override var intrinsicContentSize : CGSize {
        let limitingSize: CGSize  = CGSize(width: kMaxTextWidth, height: CGFloat.greatestFiniteMagnitude)
        var textSize: CGSize = self.titleLbl.sizeThatFits(limitingSize)
        if textSize.height < self.titleLbl.font.pointSize {
            textSize.height = self.titleLbl.font.pointSize
        }
        return CGSize(width: 0.0, height: Double(textSize.height) + 40 + maxCellHeight + 30)
       }
    
    @objc fileprivate func MailButtonAction(_ sender: AnyObject!) {
        let elements = arrayOfCarousels[sender.tag]
        let elementsBtn = elements.elementsbuttons
        if elementsBtn?.count ?? 0  > 0{
            let btnsDetails = elementsBtn?[sender.tag]
            if btnsDetails?.type == "postback"{
                showMaskVInCarousel = false
                maskview.isHidden = false
              let payload = btnsDetails?.payload == "" || btnsDetails?.payload == nil ? btnsDetails?.title : btnsDetails?.payload
                self.optionsAction(btnsDetails?.title, payload)
            }else if btnsDetails?.type == "web_url"{
                if btnsDetails?.payload != "" || btnsDetails?.payload != nil{
                    self.linkAction(btnsDetails?.payload)
                }
            }
        }
    }
    @objc fileprivate func DownloadButtonAction(_ sender: AnyObject!) {
        let elements = arrayOfCarousels[sender.tag]
        let elementsBtn = elements.elementsbuttons
        if elementsBtn?.count ?? 0  > 0{
            let btnsDetails = elementsBtn?[sender.tag]
            if btnsDetails?.type == "postback"{
                showMaskVInCarousel = false
                maskview.isHidden = false
              let payload = btnsDetails?.payload == "" || btnsDetails?.payload == nil ? btnsDetails?.title : btnsDetails?.payload
                self.optionsAction(btnsDetails?.title, payload)
            }else if btnsDetails?.type == "web_url"{
                if btnsDetails?.payload != "" || btnsDetails?.payload != nil{
                    self.linkAction(btnsDetails?.payload)
                }
            }
        }
    }
    
    @objc fileprivate func carouselButtonAction(_ sender: AnyObject!) {
        let elements = arrayOfCarousels[sender.tag]
        let elementsBtn = elements.elementsbuttons
        if elementsBtn?.count ?? 0  > 0{
            let btnsDetails = elementsBtn?[sender.tag]
            if btnsDetails?.type == "postback"{
                maskview.isHidden = false
                showMaskVInCarousel = false
              let payload = btnsDetails?.payload == "" || btnsDetails?.payload == nil ? btnsDetails?.title : btnsDetails?.payload
                self.optionsAction(btnsDetails?.title, payload)
            }else if btnsDetails?.type == "web_url"{
                if btnsDetails?.payload != "" || btnsDetails?.payload != nil{
                    self.linkAction(btnsDetails?.payload)
                }
            }
        }
    }

}
extension IDFCUpdatedCarouselBubbleView : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    //MARK: collection view delegate methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayOfCarousels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // swiftlint:disable force_cast
        //let cell = collectionView.dequeueReusableCell(withReuseIdentifier: customCellIdentifier, for: indexPath) as! IDFCUpdatedCaroselCell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: customCellIdentifier, for: indexPath) as! IDFCUpdatedCaroselCell
        let cellWidth = templateWidth
        let elements = arrayOfCarousels[indexPath.row]
        
        if let tagInfo =  elements.ElementTagInfo {
            cell.tagLbl.isHidden = false
            cell.tagLbl.text = tagInfo.title?.uppercased()
            cell.tagLbl.textColor = UIColor.init(hexString: tagInfo.styles?.color ?? "#26344A")
            cell.tagLbl.backgroundColor = UIColor.init(hexString: tagInfo.styles?.background ?? "#b5e90b")
            let size = cell.tagLbl.text?.size(withAttributes:[.font: UIFont(name: semiBoldCustomFont, size: 12.0) as Any])
            if cell.tagLbl.text != nil {
                cell.tagLblWidthConstraint.constant = (size?.width)! + 30.0
            }
        }else{
            cell.tagLbl.isHidden = true
        }
        
        
        if elements.backgroundImageUrl == nil{
            cell.imagVHeightConstraint.constant = 0.0
        }else{
            cell.imagVHeightConstraint.constant = 200.0
            let url = URL(string: elements.backgroundImageUrl!)
            cell.imagView.af_setImage(withURL: url!, placeholderImage: UIImage(named: "placeholder_image"))
        }
        
        cell.titleLbl.setHTMLString(arrayOfElementsTitles[indexPath.item] as? String ?? "", withWidth: CGFloat(cellWidth))
        cell.titleLbl.textColor = BubbleViewUserChatTextColor
        cell.carouselBtn.setTitleColor(BubbleViewBotChatTextColor, for: .normal)
        cell.layer.borderColor = UIColor.clear.cgColor
        cell.layer.cornerRadius = 10.0
        cell.clipsToBounds = true
        cell.bgView.layer.cornerRadius = 10.0
        cell.bgView.clipsToBounds = true
        cell.backgroundColor = bubbleViewBotChatButtonBgColor
        
        
        var textHeight = 10
        let padding = 30
        let attrString: NSMutableAttributedString = getAttributedString(text: arrayOfElementsTitles[indexPath.item] as? String ?? "")
        let limitingSize: CGSize = CGSize(width: CGFloat(cellWidth - padding), height: CGFloat.greatestFiniteMagnitude)
        let rect: CGRect = (attrString.boundingRect(with: limitingSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil))
        textHeight = Int(rect.size.height)
        
        cell.titlelblHeightConstraint.constant = CGFloat(textHeight)
        
        cell.idfcMailBtn.isHidden = true
        cell.IdfcDownloadBtn.isHidden = true
        cell.carouselBtn.isHidden = true
        let elementsBtn = elements.elementsbuttons
        if elementsBtn?.count ?? 0  > 0{
            for i in 0..<elementsBtn!.count{
                let btnsDetails = elementsBtn?[i]
                if i == 0{
                    cell.idfcMailBtn.isHidden = false
                    cell.idfcMailBtn.tag = i
                    cell.idfcMailBtn.addTarget(self, action: #selector(self.MailButtonAction(_:)), for: .touchUpInside)
                    cell.idfcMailBtn.setTitleColor(UIColor.init(hexString: "#9B1E26"), for: .normal)
                    //let btnsDetails = elementsBtn?[i]
                    cell.idfcMailBtn.setImage(Utilities.base64ToImage(base64String: btnsDetails?.icon), for: .normal)
                }else if i == 1{
                    cell.IdfcDownloadBtn.isHidden = false
                    cell.IdfcDownloadBtn.tag = i
                    cell.IdfcDownloadBtn.addTarget(self, action: #selector(self.DownloadButtonAction(_:)), for: .touchUpInside)
                    cell.IdfcDownloadBtn.setTitleColor(UIColor.init(hexString: "#9B1E26"), for: .normal)
                    cell.IdfcDownloadBtn.setImage(Utilities.base64ToImage(base64String: btnsDetails?.icon), for: .normal)
                }else{
                    cell.carouselBtn.isHidden = false
                   // let btnsDetails = elementsBtn?[i]
                    cell.carouselBtn.setTitle("\(btnsDetails?.title ?? "") -->", for: .normal)
                    cell.carouselBtn.tag = i
                    cell.carouselBtn.addTarget(self, action: #selector(self.carouselButtonAction(_:)), for: .touchUpInside)
                    cell.carouselBtn.setTitleColor(UIColor.init(hexString: "#9B1E26"), for: .normal)
                }
            }
            
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = templateWidth
        return CGSize(width: cellWidth, height: Int(maxCellHeight) + 15)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5.0, left: 0.0, bottom: 0.0, right: 5.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }

}
