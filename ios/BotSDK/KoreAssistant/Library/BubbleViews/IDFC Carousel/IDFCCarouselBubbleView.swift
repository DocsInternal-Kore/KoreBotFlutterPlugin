//
//  IDFCCarouselBubbleView.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek.Pagidimarri on 17/12/21.
//  Copyright © 2021 Kore. All rights reserved.
//

import UIKit

class IDFCCarouselBubbleView: BubbleView {
    var cardView: UIView!
    var maskview: UIView!
    var collectionView: UICollectionView!
    let customCellIdentifier = "IDFCCarouselCell"
    let kMaxTextWidth: CGFloat = BubbleViewMaxWidth
    let kMinTextWidth: CGFloat = 20.0
    var arrayOfCarousels = [ComponentElements]()
    var maxCellHeight = 0.0
    
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
         self.collectionView.register(UINib(nibName: "IDFCCarouselCell", bundle: bundle),
                                     forCellWithReuseIdentifier: customCellIdentifier)
        
        self.maskview = UIView(frame:.zero)
        self.maskview.translatesAutoresizingMaskIntoConstraints = false
        self.cardView.addSubview(self.maskview)
        self.maskview.isHidden = true
        maskview.backgroundColor = .clear
        
        let views: [String: UIView] = ["collectionView": collectionView, "maskview": maskview]
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[collectionView]-5-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[maskview]|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[collectionView]-20-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[maskview]-0-|", options: [], metrics: nil, views: views))
       
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
                self.collectionView.layoutIfNeeded()
                
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
        let cellWidth = 209.0
        var cellBtnHeight = 30
        var imageVHeight = 120
        var maxiCellHeight = 10
        
        for i in 0..<arrayOfCarousels.count{
            let elements = arrayOfCarousels[i]
            var textHeight = 10
            let padding = 30.0
            let attrString: NSMutableAttributedString = getAttributedString(text: elements.title ?? "")
            let limitingSize: CGSize = CGSize(width: CGFloat(cellWidth - padding), height: CGFloat.greatestFiniteMagnitude)
            let rect: CGRect = (attrString.boundingRect(with: limitingSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil))
            textHeight = Int(rect.size.height)
            
            if elements.imageURL == nil{
                imageVHeight = 0
            }else{
                imageVHeight = 120
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
            return CGSize(width: 0.0, height: maxCellHeight + 30)
       }
    
    @objc fileprivate func carouselButtonAction(_ sender: AnyObject!) {
        let elements = arrayOfCarousels[sender.tag]
        let elementsBtn = elements.elementsbuttons
        if elementsBtn?.count ?? 0  > 0{
            let btnsDetails = elementsBtn?[0]
            if btnsDetails?.type == "postback"{
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

}
extension IDFCCarouselBubbleView : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    //MARK: collection view delegate methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayOfCarousels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // swiftlint:disable force_cast
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: customCellIdentifier, for: indexPath) as! IDFCCarouselCell
        let cellWidth = 209
        let elements = arrayOfCarousels[indexPath.row]
        
        if elements.imageURL == nil{
            cell.imagVHeightConstraint.constant = 0.0
        }else{
            cell.imagVHeightConstraint.constant = 120.0
            let url = URL(string: elements.imageURL!)
            cell.imagView.af_setImage(withURL: url!, placeholderImage: UIImage(named: "placeholder_image"))
        }
        
        cell.titleLbl.setHTMLString(elements.title, withWidth: CGFloat(cellWidth))
        
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
        let attrString: NSMutableAttributedString = getAttributedString(text: elements.title ?? "")
        let limitingSize: CGSize = CGSize(width: CGFloat(cellWidth - padding), height: CGFloat.greatestFiniteMagnitude)
        let rect: CGRect = (attrString.boundingRect(with: limitingSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil))
        textHeight = Int(rect.size.height)
        
        cell.titlelblHeightConstraint.constant = CGFloat(textHeight)
        
        let elementsBtn = elements.elementsbuttons
        if elementsBtn?.count ?? 0  > 0{
            let btnsDetails = elementsBtn?[0]
            cell.carouselBtn.setTitle("\(btnsDetails?.title ?? "") -->", for: .normal)
        }
        cell.carouselBtn.tag = indexPath.row
        cell.carouselBtn.addTarget(self, action: #selector(self.carouselButtonAction(_:)), for: .touchUpInside)
        cell.carouselBtn.setTitleColor(UIColor.init(hexString: "#9B1E26"), for: .normal)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = 209
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
