//
//  CongratulationsBubbleView.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek.Pagidimarri on 08/11/21.
//  Copyright © 2021 Kore. All rights reserved.
//

import UIKit
import korebotplugin

class CongratulationsBubbleView: BubbleView {
    
    var cardView: UIView!
    var headingLabel: UILabel!
    var descLabel: UILabel!
    var listBgView: UIView!
    var gifImgV: UIImageView!
    var tableView: UITableView!
    let cellIdentifier = "CongratulationsCellTableViewCell"
    var transactionsArray = [Transactions]()
    var gifHeightConstraint: NSLayoutConstraint!
    var gifWidthConstraint: NSLayoutConstraint!
    var listVHeightConstraint: NSLayoutConstraint!
    let kMaxTextWidth: CGFloat = BubbleViewMaxWidth - 80.0
    var tableHeaderTitle = ""
    var tableHeaderValaue = ""
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
        cardView.backgroundColor =  UIColor.init(hexString: "#4EA081")
        
        
        self.gifImgV = UIImageView(frame:.zero)
        self.gifImgV.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.gifImgV)
        
        //Assest Image
        //let jeremyGif = UIImage.gif(asset: "Congratulationss")
        
        //Bundle Image
        //let jeremyGif = UIImage.gifImageWithName("Congratulationss")
        
        //Base64 Image
        let base64GifImage = ""
        let jeremyGif = UIImage()// UIImage.gifImageWithBase64(base64GifImage)
        
        gifImgV.image = jeremyGif
        gifImgV.contentMode = .scaleAspectFill
        
        let cardViews: [String: UIView] = ["cardView": cardView, "gifImgV": gifImgV]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[gifImgV(110)]", options: [], metrics: nil, views: cardViews))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[cardView]-0-|", options: [], metrics: nil, views: cardViews))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[cardView]-0-|", options: [], metrics: nil, views: cardViews))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[gifImgV]-0-|", options: [], metrics: nil, views: cardViews))
        
        gifWidthConstraint = NSLayoutConstraint.init(item: gifImgV as Any, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: kMaxTextWidth + 32)
       self.addConstraint(gifWidthConstraint)
    }
    
    override func initialize() {
        super.initialize()
        intializeCardLayout()
        
        self.headingLabel = UILabel(frame: CGRect.zero)
        self.headingLabel.textColor = BubbleViewBotChatTextColor
        self.headingLabel.backgroundColor = UIColor.clear
        self.headingLabel.font = UIFont(name: semiBoldCustomFont, size: 14.0)
        self.headingLabel.numberOfLines = 0
        self.headingLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.headingLabel.isUserInteractionEnabled = true
        self.headingLabel.translatesAutoresizingMaskIntoConstraints = false
        self.cardView.addSubview(self.headingLabel)
        
        
        self.listBgView = UIView(frame:.zero)
        self.listBgView.translatesAutoresizingMaskIntoConstraints = false
        self.cardView.addSubview(self.listBgView)
        listBgView.layer.rasterizationScale =  UIScreen.main.scale
        listBgView.layer.shadowColor = UIColor.clear.cgColor
        listBgView.layer.shadowOpacity = 1
        listBgView.layer.shadowOffset =  CGSize(width: 0.0, height: -3.0)
        listBgView.layer.shadowRadius = 6.0
        listBgView.layer.shouldRasterize = true
        listBgView.layer.cornerRadius = 5.0
        listBgView.backgroundColor =  UIColor.init(hexString: "#307B5E")
        
  
        let views: [String: UIView] = ["headingLabel": headingLabel, "listBgView": listBgView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-16-[headingLabel(>=15)]-10-[listBgView(0)]-16-|", options: [], metrics: nil, views: views))
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[headingLabel]-16-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[listBgView]-16-|", options: [], metrics: nil, views: views))
      
        
        listVHeightConstraint = NSLayoutConstraint.init(item: listBgView as Any, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0.0)
       self.addConstraint(listVHeightConstraint)
        
        self.tableView = UITableView(frame: CGRect.zero,style:.plain)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.backgroundColor = .clear
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.showsVerticalScrollIndicator = true
        self.tableView.bounces = false
        self.tableView.separatorStyle = .none
        self.listBgView.addSubview(self.tableView)
        self.tableView.isScrollEnabled = false
        let bundle = KREResourceLoader.shared.resourceBundle()
        self.tableView.register(UINib(nibName: cellIdentifier, bundle: bundle), forCellReuseIdentifier: cellIdentifier)
        
        let listViews: [String: UIView] = ["tableView": tableView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[tableView]-5-|", options: [], metrics: nil, views: listViews))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[tableView]-10-|", options: [], metrics: nil, views: listViews))
        
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
                //self.headingLabel.text = "\(allItems.heading ?? "") \n\(allItems.transActionDesc ?? "")" //\U20b9800
                //let str = "Happy to help you Happy to help you Smiley \u{1F603}"
                //self.headingLabel.text = str
                
                let attributedString = NSAttributedString(string:(allItems.heading ?? ""),
                                                   attributes:[NSAttributedString.Key.foregroundColor: UIColor.white,
                                                               NSAttributedString.Key.font: UIFont(name: semiBoldCustomFont, size: 14.0) as Any])
                
                let attributedString1 = NSAttributedString(string:("\n\(allItems.transActionDesc ?? "")"),
                                                   attributes:[NSAttributedString.Key.foregroundColor: UIColor.white,
                                                               NSAttributedString.Key.font: UIFont(name: regularCustomFont, size: 14.0) as Any])
                let combination = NSMutableAttributedString()
                    
                    combination.append(attributedString)
                    combination.append(attributedString1)
                self.headingLabel.attributedText = combination
                
                tableHeaderTitle = allItems.transactionHeader ?? ""
                tableHeaderValaue = allItems.transactionIDHeader ?? ""
                transactionsArray = allItems.transactions ?? []
                tableView.reloadData()
            }
        }
    }
    
    override var intrinsicContentSize : CGSize {
        let limitingSize: CGSize  = CGSize(width: kMaxTextWidth, height: CGFloat.greatestFiniteMagnitude)
        let headingLabelSize: CGSize = self.headingLabel.sizeThatFits(limitingSize)
        var tableViewHeight = 0.0
        var tableViewtopSpacing = 0.0
        if transactionsArray.count == 0{
            tableViewtopSpacing = 25.0
        }
        for _ in 0..<transactionsArray.count{
            tableViewHeight += 30.0
        }
        listVHeightConstraint.constant = CGFloat(tableViewHeight)
        let templateHeight = headingLabelSize.height + CGFloat(tableViewHeight) + 70 - CGFloat(tableViewtopSpacing)
        let gifImageHeight = 80
        return CGSize(width: headingLabelSize.width + 32, height:  templateHeight + CGFloat(gifImageHeight))
    }
    
}

extension CongratulationsBubbleView: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactionsArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : CongratulationsCellTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! CongratulationsCellTableViewCell
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        let transact = transactionsArray[indexPath.row]
        cell.titleLbl.text = transact.mode
        cell.valueLbl.text = transact.id
        cell.titleLbl.textColor = BubbleViewBotChatTextColor
        cell.titleLbl.textColor = BubbleViewBotChatTextColor
        cell.titleLbl.font =  UIFont(name: boldCustomFont, size: 12.0)
        cell.valueLbl.font =  UIFont(name: boldCustomFont, size: 12.0)
        return cell
    }
     func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 21
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        
        let subView = UIView()
        subView.backgroundColor = .clear
        subView.translatesAutoresizingMaskIntoConstraints = false
        subView.layer.cornerRadius = 5.0
        subView.clipsToBounds = true
        view.addSubview(subView)
        
        let headerLabel = UILabel(frame: .zero)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.textAlignment = .left
        headerLabel.font = UIFont(name: regularCustomFont, size: 10.0)
        headerLabel.textColor = BubbleViewBotChatTextColor
        headerLabel.text =   tableHeaderTitle
        subView.addSubview(headerLabel)
        
        let headerDescLabel = UILabel(frame: .zero)
        headerDescLabel.translatesAutoresizingMaskIntoConstraints = false
        headerDescLabel.textAlignment = .right
        headerDescLabel.font = UIFont(name: regularCustomFont, size: 10.0)
        headerDescLabel.textColor = BubbleViewBotChatTextColor
        headerDescLabel.text =  tableHeaderValaue
        subView.addSubview(headerDescLabel)
        
        let views: [String: UIView] = ["headerLabel": headerLabel, "headerDescLabel":headerDescLabel]
        subView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[headerLabel]-[headerDescLabel]-0-|", options:[], metrics:nil, views:views))
        subView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[headerLabel]-0-|", options:[], metrics:nil, views:views))
        subView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[headerDescLabel]-0-|", options:[], metrics:nil, views:views))
        
        let subViews: [String: UIView] = ["subView": subView]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[subView]-0-|", options:[], metrics:nil, views:subViews))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[subView]-0-|", options:[], metrics:nil, views:subViews))
    
        return view
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
}
