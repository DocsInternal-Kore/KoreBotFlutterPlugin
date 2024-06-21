//
//  UpdatedCarouselBubbleView.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek.Pagidimarri on 17/11/21.
//  Copyright © 2021 Kore. All rights reserved.
//

import UIKit

class UpdatedCarouselBubbleView: BubbleView {
    var cardView: UIView!
    var maskview: UIView!
    var collectionView: UICollectionView!
    let customCellIdentifier = "UpdatedCarouselCell"
    let kMaxTextWidth: CGFloat = BubbleViewMaxWidth
    let kMinTextWidth: CGFloat = 20.0
    var arrayOfCarousels = [ComponentElements]()
    
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
         self.collectionView.register(UINib(nibName: "UpdatedCarouselCell", bundle: bundle),
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
                self.collectionView.reloadData()
            }
        }
    }
    
    //MARK: View height calculation
       override var intrinsicContentSize : CGSize {
           return CGSize(width: 0.0, height: 170) //150
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
            }
        }
    }

}
extension UpdatedCarouselBubbleView : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    //MARK: collection view delegate methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayOfCarousels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // swiftlint:disable force_cast
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: customCellIdentifier, for: indexPath) as! UpdatedCarouselCell
        let elements = arrayOfCarousels[indexPath.row]
        cell.bgView.backgroundColor = BubbleViewLeftTint
        cell.titleLbl.text = elements.elementText
        cell.titleLbl.font = UIFont(name: semiBoldCustomFont, size: 14.0)
        cell.titleLbl.textColor = BubbleViewBotChatTextColor
        cell.carouselBtn.setTitleColor(BubbleViewBotChatTextColor, for: .normal)
        cell.layer.borderColor = UIColor.clear.cgColor
        cell.layer.cornerRadius = 10.0
        cell.clipsToBounds = true
        cell.backgroundColor = bubbleViewBotChatButtonBgColor
        
        let cellWidth = 150
        let limitingSize: CGSize  = CGSize(width: cellWidth - 24, height: 21)
        let headingLabelSize: CGSize = cell.titleLbl.sizeThatFits(limitingSize)
        cell.titlelblHeightConstraint.constant = headingLabelSize.height
        
        let elementsBtn = elements.elementsbuttons
        if elementsBtn?.count ?? 0  > 0{
            let btnsDetails = elementsBtn?[0]
            cell.carouselBtn.setTitle(btnsDetails?.title, for: .normal)
        }
        cell.carouselBtn.tag = indexPath.row
        cell.carouselBtn.addTarget(self, action: #selector(self.carouselButtonAction(_:)), for: .touchUpInside)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let elements = arrayOfCarousels[indexPath.row]
        let text = elements.elementText
         let indexPath = IndexPath(row: indexPath.item, section: indexPath.section)
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: customCellIdentifier, for: indexPath) as! UpdatedCarouselCell
        cell.titleLbl.text = text
        cell.titleLbl.font = UIFont(name: semiBoldCustomFont, size: 14.0)

        let cellWidth = 150
        let cellBtnHeight = 30
        let limitingSize: CGSize  = CGSize(width: cellWidth - 24, height: 21)
        let headingLabelSize: CGSize = cell.titleLbl.sizeThatFits(limitingSize)
        cell.titlelblHeightConstraint.constant = headingLabelSize.height
        return CGSize(width: cellWidth, height: 150) //Int(headingLabelSize.height) + 36 + cellBtnHeight
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
