//
//  ContactCardBubbleView.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek.Pagidimarri on 08/11/21.
//  Copyright © 2021 Kore. All rights reserved.
//

import UIKit

class ContactCardBubbleView: BubbleView {
    
    var cardView: UIView!
    var headingLabel: UILabel!
    var descLabel: UILabel!
    var listBgView: UIView!
    var tableView: UITableView!
    let cellIdentifier = "ContactCardCell"
    var cardsArray = [ContactCard]()
    let kMaxTextWidth: CGFloat = BubbleViewMaxWidth - 50.0
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
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[cardView]-0-|", options: [], metrics: nil, views: cardViews))
    }
    
    override func initialize() {
        super.initialize()
        intializeCardLayout()
        
        self.headingLabel = UILabel(frame: CGRect.zero)
        self.headingLabel.textColor = BubbleViewBotChatTextColor
        self.headingLabel.backgroundColor = UIColor.clear
        self.headingLabel.font = UIFont(name: regularCustomFont, size: 14.0)
        self.headingLabel.numberOfLines = 0
        self.headingLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.headingLabel.isUserInteractionEnabled = true
        self.headingLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.headingLabel)
        
        
        self.tableView = UITableView(frame: CGRect.zero,style:.plain)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.backgroundColor = .clear
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.showsVerticalScrollIndicator = true
        self.tableView.bounces = false
        self.tableView.separatorStyle = .none
        self.addSubview(self.tableView)
        self.tableView.isScrollEnabled = false
        let bundle = KREResourceLoader.shared.resourceBundle()
        self.tableView.register(UINib(nibName: cellIdentifier, bundle: bundle), forCellReuseIdentifier: cellIdentifier)
         
      
        let views: [String: UIView] = ["headingLabel": headingLabel, "tableView": tableView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-16-[headingLabel(>=15)]-12-[tableView]-12-|", options: [], metrics: nil, views: views))
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[headingLabel]-16-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[tableView]-16-|", options: [], metrics: nil, views: views))
      
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
                self.headingLabel.text = "\(allItems.title ?? "")"
                cardsArray = allItems.contactCard ?? []
                tableView.reloadData()
            }
        }
    }
    
    override var intrinsicContentSize : CGSize {
        let limitingSize: CGSize  = CGSize(width: kMaxTextWidth, height: CGFloat.greatestFiniteMagnitude)
        let headingLabelSize: CGSize = self.headingLabel.sizeThatFits(limitingSize)
        var tableViewHeight = 0.0
        for _ in 0..<cardsArray.count{
            tableViewHeight += 84.0
        }
        let templateHeight = headingLabelSize.height + CGFloat(tableViewHeight) + 42
        return CGSize(width: headingLabelSize.width + 32, height:  templateHeight)
    }
    
}

extension ContactCardBubbleView: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cardsArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : ContactCardCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! ContactCardCell
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        let cards = cardsArray[indexPath.row]
        cell.nameLbl.text = cards.userName
        cell.phonenoLbl.text = cards.userContactNumber
        cell.emailLbl.text = cards.userEmailId
        cell.nameLbl.textColor = .black
        cell.phonenoLbl.textColor = .black
        cell.phonenoLbl.tintColor = .black
        cell.phonenoLbl.isUserInteractionEnabled = false
        cell.emailLbl.textColor = .black
        cell.nameLbl.font =  UIFont(name: semiBoldCustomFont, size: 14.0)
        cell.phonenoLbl.font =  UIFont(name: regularCustomFont, size: 12.0)
        cell.emailLbl.font =  UIFont(name: regularCustomFont, size: 12.0)
        if cards.userIcon == nil || cards.userIcon == ""{
            cell.profilePic.image = UIImage(named: "faceIcon")
        }else{
            let url = URL(string: cards.userIcon!)
            cell.profilePic.af_setImage(withURL: url!, placeholderImage: UIImage(named: "faceIcon"))
        }
        cell.titleLblTopConstraint.constant = 7
        cell.phoneLblHeightConstraint.constant = 20
        if cards.userContactNumber == nil || cards.userContactNumber == ""{
            cell.phoneLblHeightConstraint.constant = 0
            cell.titleLblTopConstraint.constant = 15
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
}
