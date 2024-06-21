//
//  ServiceListBubbleView.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek.Pagidimarri on 07/12/21.
//  Copyright © 2021 Kore. All rights reserved.
//

import UIKit

class ServiceListBubbleView: BubbleView {
    
    var rowsDataLimit = 4
    var cardView: UIView!
    var tableView: UITableView!
    let kMaxTextWidth: CGFloat = BubbleViewMaxWidth - 80.0
    let cellIdentifier = "ServiceListCell"
    var showMoreTitle:String?
    public var linkAction: ((_ text: String?) -> Void)!
    var elementsArray = [ComponentElements]()
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
        cardView.layer.cornerRadius = 10.0
        cardView.backgroundColor =  BubbleViewLeftTint
        let cardViews: [String: UIView] = ["cardView": cardView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[cardView]-0-|", options: [], metrics: nil, views: cardViews))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[cardView]-16-|", options: [], metrics: nil, views: cardViews))
    }
    override func initialize() {
        super.initialize()
        intializeCardLayout()
        
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
        self.cardView.addSubview(self.tableView)
        self.tableView.isScrollEnabled = false
        let bundle = KREResourceLoader.shared.resourceBundle()
        self.tableView.register(UINib(nibName: cellIdentifier, bundle: bundle), forCellReuseIdentifier: cellIdentifier)
        
        let listViews: [String: UIView] = ["tableView": tableView]
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-12-[tableView]-12-|", options: [], metrics: nil, views: listViews))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-12-[tableView]-12-|", options: [], metrics: nil, views: listViews))
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
                elementsArray = allItems.elements ?? []
                rowsDataLimit = (allItems.displayLimit != nil ? allItems.displayLimit ?? elementsArray.count : elementsArray.count)
                showMoreTitle = allItems.seeMoreTitle ?? "View more"
                tableView.reloadData()
            }
        }
    }
    
    override var intrinsicContentSize : CGSize {
        var tableViewHeight = 0.0
        let numOfElements = rowsDataLimit > elementsArray.count ? elementsArray.count : rowsDataLimit
        for _ in 0..<numOfElements{
            tableViewHeight += 75.0
        }
        
        let footerViewHeight = rowsDataLimit > elementsArray.count ? 00.0 : 40.0
        return CGSize(width: kMaxTextWidth, height:  CGFloat(tableViewHeight) + 24 + CGFloat(footerViewHeight))
    }
    
    @objc fileprivate func showMoreButtonAction(_ sender: AnyObject!) {
            let component: KREComponent = components.firstObject as! KREComponent
            if (component.componentDesc != nil) {
                let jsonString = component.componentDesc
                NotificationCenter.default.post(name: Notification.Name(showListViewTemplateNotification), object: jsonString)
            }
    }
}
extension ServiceListBubbleView: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowsDataLimit > elementsArray.count ?  elementsArray.count : rowsDataLimit
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : ServiceListCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! ServiceListCell
        cell.backgroundColor = UIColor.white
        cell.selectionStyle = .none
        cell.titeLabel.font =  UIFont(name: semiBoldCustomFont, size: 14.0)
        cell.valueLabel.font =  UIFont(name: semiBoldCustomFont, size: 14.0)
        cell.tagLabel.font =  UIFont(name: boldCustomFont, size: 10.0)
        let elements = elementsArray[indexPath.row]
        cell.titeLabel.text = elements.title
        cell.titeLabel.textColor = BubbleViewUserChatTextColor
        cell.valueLabel.text = elements.value
        cell.valueLabel.textColor = BubbleViewUserChatTextColor
        
        cell.tagLabel.layer.cornerRadius = 4.0
        cell.tagLabel.clipsToBounds = true
        let tag = elements.elementTag
        cell.tagLabel.text = tag?.title
        cell.tagLabel.textColor =  UIColor.init(hexString: tag?.tagStyles?.color ?? "#ffffff")
        cell.tagLabel.backgroundColor =  UIColor.init(hexString: tag?.tagStyles?.background ?? "#3afe00")
        
        cell.tagLabel.textAlignment = .center
        cell.tagLblWidthConstraint.constant = 10
        let size = cell.tagLabel.text?.size(withAttributes:[.font: UIFont(name: boldCustomFont, size: 10.0) ?? UIFont.systemFont(ofSize: 10.0)])
        if cell.tagLabel.text != nil {
            cell.tagLblWidthConstraint.constant = (size?.width)! + 10.0
        }
        cell.dateLabel.text = elements.elementDescription
        if #available(iOS 11.0, *) {
            cell.roundCorners([.layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 0, borderColor: UIColor.clear, borderWidth: 1.5)
        }
        if indexPath.row == 0{
            if #available(iOS 11.0, *) {
                cell.roundCorners([.layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 10, borderColor: UIColor.clear, borderWidth: 1.5)
            }
        }
        
        let totalRows = tableView.numberOfRows(inSection: indexPath.section)
        if indexPath.row == totalRows - 1 {
            cell.underlineLbl.isHidden = true
            if #available(iOS 11.0, *) {
                cell.roundCorners([.layerMinXMaxYCorner, .layerMaxXMaxYCorner], radius: 10, borderColor: UIColor.clear, borderWidth: 1.5)
            }
        }else{
            cell.underlineLbl.isHidden = false
        }
        return cell
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
            let showMoreButton = UIButton(frame: CGRect.zero)
            showMoreButton.backgroundColor = .clear
            showMoreButton.translatesAutoresizingMaskIntoConstraints = false
            showMoreButton.clipsToBounds = true
            showMoreButton.layer.cornerRadius = 5
            showMoreButton.setTitleColor(.white, for: .normal)
            showMoreButton.setTitleColor(Common.UIColorRGB(0x999999), for: .disabled)
            showMoreButton.titleLabel?.font = UIFont(name: semiBoldCustomFont, size: 14.0)
            showMoreButton.addRightIcon(image: UIImage.init(named: "icons24ArrowCta") ?? UIImage())
            view.addSubview(showMoreButton)
            showMoreButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
            showMoreButton.addTarget(self, action: #selector(self.showMoreButtonAction(_:)), for: .touchUpInside)
            showMoreButton.setTitle(showMoreTitle, for: .normal)
            let views: [String: UIView] = ["showMoreButton": showMoreButton]
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[showMoreButton(30)]", options:[], metrics:nil, views:views))
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[showMoreButton(130)]-10-|", options:[], metrics:nil, views:views))
        return view
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return rowsDataLimit > elementsArray.count ? 0 : 40
    }
    
}

