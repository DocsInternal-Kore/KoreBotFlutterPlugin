//
//  SearchBubbleView.swift
//  KoreBotSDKFrameWork
//
//  Created by Kartheek Pagidimarri on 11/04/23.
//  Copyright © 2023 Kartheek.Pagidimarri. All rights reserved.
//

import UIKit

class SearchBubbleView: BubbleView {
    let bundle = KREResourceLoader.shared.resourceBundle()
    var tileBgv: UIView!
    public var maskview: UIView!
    var titleLbl: KREAttributedLabel!
    var descLbl: UILabel!
    var sourceLbl: UILabel!
    var arrowImgv: UIImageView!
    var urlLbl: KREAttributedTextView!
    var tableView: UITableView!
    var cardView: UIView!
    var showMoreBtn: UIButton!
    let kMaxTextWidth: CGFloat = BubbleViewMaxWidth - 32.0
    let kMinTextWidth: CGFloat = 20.0
    fileprivate let listCellIdentifier = "SearchListCell"
    public var optionsAction: ((_ text: String?, _ payload: String?) -> Void)!
    public var linkAction: ((_ text: String?) -> Void)!
    var isShowMore = false
    var showMoreBtnHeightConstraint: NSLayoutConstraint!
    var arrayOfWebData = [WebData]()
    var isReadMore = false
    var readMoreBtn: UIButton!
    
    override func applyBubbleMask() {
        //nothing to put here
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
        self.tableView.backgroundColor = BubbleViewLeftTint
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.bounces = false
        self.tableView.separatorStyle = .none
        self.cardView.addSubview(self.tableView)
        self.tableView.isScrollEnabled = false
        self.tableView.register(UINib(nibName: listCellIdentifier, bundle: bundle), forCellReuseIdentifier: listCellIdentifier)
        
        self.tableView.layer.cornerRadius = 5.0
        self.tableView.clipsToBounds = true
        self.tableView.layer.masksToBounds = false
        self.tableView.layer.shadowColor = UIColor.lightGray.cgColor
        self.tableView.layer.shadowOffset =  CGSize.zero
        self.tableView.layer.shadowOpacity = 0.3
        self.tableView.layer.shadowRadius = 4
        self.tableView.layer.shadowOffset = CGSize(width: 0 , height:2)
        if #available(iOS 15.0, *){
            self.tableView.sectionHeaderTopPadding = 0.0
        }
        
        self.maskview = UIView(frame:.zero)
        self.maskview.translatesAutoresizingMaskIntoConstraints = false
        self.cardView.addSubview(self.maskview)
        self.maskview.isHidden = true
        maskview.backgroundColor = .clear
        
        showMoreBtn = UIButton(frame: CGRect.zero)
        showMoreBtn.backgroundColor = BubbleViewLeftTint
        showMoreBtn.translatesAutoresizingMaskIntoConstraints = false
        showMoreBtn.clipsToBounds = true
        showMoreBtn.layer.cornerRadius = 10
        showMoreBtn.setTitleColor(BubbleViewBotChatTextColor, for: .normal)
        showMoreBtn.setTitleColor(Common.UIColorRGB(0x999999), for: .disabled)
        showMoreBtn.titleLabel?.font = UIFont(name: semiBoldCustomFont, size: 12.0)
        cardView.addSubview(showMoreBtn)
        showMoreBtn.setTitle("See more results", for: .normal)
        showMoreBtn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
        showMoreBtn.addTarget(self, action: #selector(self.showMoreButtonAction(_:)), for: .touchUpInside)
        
        

        let views: [String: UIView] = ["tileBgv": tileBgv, "tableView": tableView, "maskview": maskview, "showMoreBtn": showMoreBtn]
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[tileBgv]-5-[showMoreBtn(32)]-10-[tableView]-0-|", options: [], metrics: nil, views: views))
         self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[maskview]|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[tileBgv]-0-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[tableView]-0-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[maskview]-0-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[showMoreBtn(115)]-0-|", options: [], metrics: nil, views: views))

        self.showMoreBtnHeightConstraint = NSLayoutConstraint.init(item: self.showMoreBtn as Any, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 30.0)
        self.cardView.addConstraint(self.showMoreBtnHeightConstraint)
        

        self.titleLbl = KREAttributedLabel(frame: CGRect.zero)
        self.titleLbl.textColor = BubbleViewBotChatTextColor
        self.titleLbl.font = UIFont(name: boldCustomFont, size: 16.0)
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
        
        self.descLbl = UILabel(frame: CGRect.zero)
        self.descLbl.textColor = BubbleViewBotChatTextColor
        self.descLbl.font = UIFont(name: regularCustomFont, size: 14.0)
        self.descLbl.numberOfLines = 0
        self.descLbl.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.descLbl.isUserInteractionEnabled = true
        self.descLbl.contentMode = UIView.ContentMode.topLeft
        self.descLbl.translatesAutoresizingMaskIntoConstraints = false
        self.tileBgv.addSubview(self.descLbl)
        self.descLbl.adjustsFontSizeToFitWidth = true
        self.descLbl.backgroundColor = .clear
        self.descLbl.layer.cornerRadius = 6.0
        self.descLbl.clipsToBounds = true
        self.descLbl.sizeToFit()
        
        readMoreBtn = UIButton(frame: CGRect.zero)
        readMoreBtn.backgroundColor = .clear
        readMoreBtn.translatesAutoresizingMaskIntoConstraints = false
        readMoreBtn.clipsToBounds = true
        readMoreBtn.layer.cornerRadius = 10
        readMoreBtn.setTitleColor(.white, for: .normal)
        readMoreBtn.setTitleColor(Common.UIColorRGB(0x999999), for: .disabled)
        readMoreBtn.titleLabel?.font = UIFont(name: semiBoldCustomFont, size: 14.0)
        tileBgv.addSubview(readMoreBtn)
        readMoreBtn.setTitle("Read More", for: .normal)
        readMoreBtn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
        readMoreBtn.addTarget(self, action: #selector(self.readMoreButtonAction(_:)), for: .touchUpInside)
        let yourAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: semiBoldCustomFont, size: 14.0) as Any,
              .foregroundColor: textlinkColor,
              .underlineStyle: NSUnderlineStyle.single.rawValue
          ]
        let attributeString = NSMutableAttributedString(
                string: "Read More",
                attributes: yourAttributes
             )
        readMoreBtn.setAttributedTitle(attributeString, for: .normal)
        
        self.sourceLbl = UILabel(frame: CGRect.zero)
        self.sourceLbl.textColor = BubbleViewBotChatTextColor
        self.sourceLbl.font = UIFont(name: boldCustomFont, size: 14.0)
        self.sourceLbl.numberOfLines = 0
        self.sourceLbl.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.sourceLbl.isUserInteractionEnabled = true
        self.sourceLbl.contentMode = UIView.ContentMode.topLeft
        self.sourceLbl.translatesAutoresizingMaskIntoConstraints = false
        self.tileBgv.addSubview(self.sourceLbl)
        self.sourceLbl.adjustsFontSizeToFitWidth = true
        self.sourceLbl.backgroundColor = .clear
        self.sourceLbl.layer.cornerRadius = 6.0
        self.sourceLbl.clipsToBounds = true
        self.sourceLbl.sizeToFit()
        
        self.urlLbl = KREAttributedTextView(frame: CGRect.zero)
        self.urlLbl.textColor = BubbleViewBotChatTextColor
        self.urlLbl.font = UIFont(name: boldCustomFont, size: 14.0)

        self.urlLbl.textContainer.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.urlLbl.isUserInteractionEnabled = true
        self.urlLbl.contentMode = UIView.ContentMode.topLeft
        self.urlLbl.translatesAutoresizingMaskIntoConstraints = false
        self.tileBgv.addSubview(self.urlLbl)
        
        self.urlLbl.isEditable = false
        self.urlLbl.isScrollEnabled = false
        self.urlLbl.backgroundColor = .clear
        self.urlLbl.layer.cornerRadius = 6.0
        self.urlLbl.clipsToBounds = true
        self.urlLbl.sizeToFit()
        
        self.arrowImgv = UIImageView(frame:.zero)
        self.arrowImgv.translatesAutoresizingMaskIntoConstraints = false
        self.tileBgv.addSubview(self.arrowImgv)
        let jeremyGif = UIImage(named: "PageAction", in: bundle, compatibleWith: nil)
        arrowImgv.image = jeremyGif
        arrowImgv.contentMode = .scaleAspectFit
        arrowImgv.image = jeremyGif?.withRenderingMode(.alwaysTemplate)
        let brandingShared = BrandingSingleton.shared
        arrowImgv.tintColor = UIColor.init(hexString: (brandingShared.widgetHeaderColor) ?? "#ffffff")
        
        let subView: [String: UIView] = ["titleLbl": titleLbl, "descLbl": descLbl, "readMoreBtn": readMoreBtn, "sourceLbl": sourceLbl,"urlLbl": urlLbl, "arrowImgv": arrowImgv]
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-16-[titleLbl(>=21)]-5-[descLbl(>=21)]-0-[readMoreBtn(30)]-5-[sourceLbl(>=21)]-5-[urlLbl(>=21)]-10-|", options: [], metrics: nil, views: subView))
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-16-[titleLbl(>=21)]-5-[descLbl(>=21)]-0-[readMoreBtn(30)]-5-[sourceLbl(>=21)]-8-[arrowImgv(15)]", options: [], metrics: nil, views: subView))
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[titleLbl]-16-|", options: [], metrics: nil, views: subView))
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[descLbl]-16-|", options: [], metrics: nil, views: subView))
        let screenwidth = UIScreen.main.bounds.size.width - 50
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[sourceLbl(\(screenwidth))]", options: [], metrics: nil, views: subView))
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[urlLbl(\(screenwidth))]", options: [], metrics: nil, views: subView))
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[arrowImgv(15)]-10-|", options: [], metrics: nil, views: subView))
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[readMoreBtn(80)]", options: [], metrics: nil, views: subView))
        
        
//        self.showMoreBtnHeightConstraint = NSLayoutConstraint.init(item: self.showMoreBtn as Any, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 30.0)
//        self.tileBgv.addConstraint(self.showMoreBtnHeightConstraint)

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
    
    @objc fileprivate func showMoreButtonAction(_ sender: AnyObject!) {
        isShowMore = true
        NotificationCenter.default.post(name: Notification.Name(reloadTableNotification), object: nil)
    }
    
    @objc fileprivate func readMoreButtonAction(_ sender: AnyObject!) {
        if isReadMore{
            isReadMore = false
            let yourAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: semiBoldCustomFont, size: 14.0) as Any,
                  .foregroundColor: textlinkColor,
                  .underlineStyle: NSUnderlineStyle.single.rawValue
              ]
            let attributeString = NSMutableAttributedString(
                    string: "Read More",
                    attributes: yourAttributes
                 )
            readMoreBtn.setAttributedTitle(attributeString, for: .normal)
        }else{
            isReadMore = true
            let yourAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: semiBoldCustomFont, size: 14.0) as Any,
                  .foregroundColor: textlinkColor,
                  .underlineStyle: NSUnderlineStyle.single.rawValue
              ]
            let attributeString = NSMutableAttributedString(
                    string: "Show less",
                    attributes: yourAttributes
                 )
            readMoreBtn.setAttributedTitle(attributeString, for: .normal)
        }
        NotificationCenter.default.post(name: Notification.Name(reloadTableNotification), object: nil)
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
                //print(jsonObject)
                let jsonDecoder = JSONDecoder()
                    guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject as Any , options: .prettyPrinted),
                          let allItems = try? jsonDecoder.decode(Componentss.self, from: jsonData) else {
                        return
                    }
                
                let headingArray = allItems.graph_answer?.payload?.center_panel?.data ?? []
                if headingArray.count > 0 {
                    let heading = headingArray[0]
                    let tiltleTxt = heading.snippet_title
                    let descTxt = heading.snippet_content
                    let sourceTxt = heading.source
                    let urlTxt = heading.url ?? ""
                    
                    self.titleLbl.setHTMLString(tiltleTxt, withWidth: kMaxTextWidth)
                    self.descLbl.text = descTxt
                    self.sourceLbl.text = sourceTxt
                    self.urlLbl.setHTMLString(urlTxt, withWidth: kMaxTextWidth)
                }
                
                arrayOfWebData = allItems.results?.web?.data ?? []
                self.tableView.reloadData()
            }
        }
    }
    
    //MARK: View height calculation
    override var intrinsicContentSize : CGSize {
        
        self.urlLbl.textColor = BubbleViewUserChatTextColor
        self.urlLbl.mentionTextColor = BubbleViewUserChatTextColor
        self.urlLbl.hashtagTextColor = BubbleViewUserChatTextColor
        self.urlLbl.linkTextColor = BubbleViewUserChatTextColor
        self.urlLbl.tintColor = textlinkColor
        
        let limitingSize: CGSize  = CGSize(width: kMaxTextWidth, height: CGFloat.greatestFiniteMagnitude)
        var textSize: CGSize = self.titleLbl.sizeThatFits(limitingSize)
        if textSize.height < self.titleLbl.font.pointSize {
            textSize.height = self.titleLbl.font.pointSize
        }
        
        if isReadMore{
            self.descLbl.numberOfLines = 0
        }else{
            self.descLbl.numberOfLines = 5
        }
        
        var textSizeDesc: CGSize = self.descLbl.sizeThatFits(limitingSize)
        if textSizeDesc.height < self.descLbl.font.pointSize {
            textSizeDesc.height = self.descLbl.font.pointSize
        }
        
        var sourcetextSizeDesc: CGSize = self.sourceLbl.sizeThatFits(limitingSize)
        if sourcetextSizeDesc.height < self.sourceLbl.font.pointSize {
            sourcetextSizeDesc.height = self.sourceLbl.font.pointSize
        }
        
        var urltextSizeDesc: CGSize = self.urlLbl.sizeThatFits(limitingSize)
        if urltextSizeDesc.height < self.urlLbl.font?.pointSize ?? 0.0 {
            urltextSizeDesc.height = self.urlLbl.font?.pointSize ?? 0.0
        }
        
        var tabvHeaderHeight = 40.0
        var tableHeight = 200.0 + 34.0
        var showMoreBtnHeight = 00.0
        self.showMoreBtnHeightConstraint.constant = 00.0
        var readMoreBtnHeight = 40.0
        if isReadMore{
             readMoreBtnHeight = 30.0
        }
        if !isShowMore{
            tabvHeaderHeight = 0.0
            tableHeight = 0.0
            showMoreBtnHeight = 30.0
            self.showMoreBtnHeightConstraint.constant = 30.0
        }
        return CGSize(width: 0.0, height: textSize.height + textSizeDesc.height + tableHeight + tabvHeaderHeight + showMoreBtnHeight + sourcetextSizeDesc.height + 10.0 + urltextSizeDesc.height + readMoreBtnHeight)
       
    }

}
extension SearchBubbleView: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 103
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 103
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfWebData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : SearchListCell = tableView.dequeueReusableCell(withIdentifier: listCellIdentifier) as! SearchListCell
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        let webDetails = arrayOfWebData[indexPath.row]
        cell.titleLbl.text = webDetails.page_title
        cell.descLbl.text = webDetails.page_preview
        if let imgUrlStr = webDetails.page_image_url{
            if !imgUrlStr.contains(".svg"){
                let imgurl = URL(string: imgUrlStr)
                cell.imagV.af_setImage(withURL: imgurl!, placeholderImage: UIImage(named: "placeholder_image", in: bundle, compatibleWith: nil))
            }else{
                cell.imagV.image = UIImage.init(named: "placeholder_image", in: bundle, compatibleWith: nil)
            }
            
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let webDetails = arrayOfWebData[indexPath.row]
        if let pageUrl = webDetails.page_url{
            self.linkAction(pageUrl)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 35))
        headerView.backgroundColor = .clear
        let label = UILabel()
        label.frame = CGRect.init(x: 10, y: 5, width: headerView.frame.width-24, height: headerView.frame.height-5)
        label.text = "Web pages"
        label.font = UIFont(name: semiBoldCustomFont, size: 16)
        label.textColor = BubbleViewBotChatTextColor
        headerView.addSubview(label)
        
        return headerView
    }

    
}
