//
//  RadioListBubbleView.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek.Pagidimarri on 10/11/21.
//  Copyright © 2021 Kore. All rights reserved.
//

import UIKit

class RadioListBubbleView: BubbleView {

    var cardView: UIView!
    var headingLabel: UILabel!
    var descLabel: UILabel!
    var listBgView: UIView!
    var tableView: UITableView!
    let cellIdentifier = "RadioListCell"
    public var maskview: UIView!
    var listArray = [ComponentElements]()
    var buttonsArray = [ComponentItemAction]()
    let kMaxTextWidth: CGFloat = BubbleViewMaxWidth - 20.0
    var isSeeMore = false
    var seeMoreTitle = ""
    var rowsDataLimit = 4
    var isExpandTableview = false
    var selectedIndex = 1000
    public var optionsAction: ((_ text: String?, _ payload: String?) -> Void)!
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
        isExpandTableview = false
        selectedIndex = 1000
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
        self.cardView.addSubview(self.headingLabel)
        
        
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
         
        self.maskview = UIView(frame:.zero)
        self.maskview.translatesAutoresizingMaskIntoConstraints = false
        self.cardView.addSubview(self.maskview)
        self.maskview.isHidden = true
        maskview.backgroundColor = .clear
        
        
        let views: [String: UIView] = ["headingLabel": headingLabel, "tableView": tableView, "maskview":maskview]
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-16-[headingLabel(>=15)]-12-[tableView]-12-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[maskview]|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[headingLabel]-16-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[tableView]-16-|", options: [], metrics: nil, views: views))
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
        if !isExpandRadioTableBubbleView{
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
                    self.headingLabel.text = "\(allItems.heading ?? "")"
                    listArray = allItems.elements ?? []
                    rowsDataLimit = allItems.displayCount ?? listArray.count
                    isSeeMore = allItems.seeMore ?? false
                    seeMoreTitle = allItems.seeMoreTitle ?? "Show more"
                    buttonsArray = allItems.buttons ?? []
                    if buttonsArray.count > 0{
                        //isShowCantFindTransAction = true
                    }else{
                        //isShowCantFindTransAction = false
                    }
                    tableView.reloadData()
                }
            }
        }
    }
    
    override var intrinsicContentSize : CGSize {
        let limitingSize: CGSize  = CGSize(width: kMaxTextWidth, height: CGFloat.greatestFiniteMagnitude)
        let headingLabelSize: CGSize = self.headingLabel.sizeThatFits(limitingSize)
        var tableViewHeight = 0.0
        for _ in 0..<rowsDataLimit{
            tableViewHeight += 61.0
        }
        
        
        var tableFooterHeight = 0.0
        if isSeeMore{
            tableFooterHeight = 40.0
        }else{
            if buttonsArray.count > 0{
                tableFooterHeight = 40.0
            }
        }
        
        let templateHeight = headingLabelSize.height + CGFloat(tableViewHeight) + 42 + CGFloat(tableFooterHeight)
        return CGSize(width: headingLabelSize.width + 32, height:  templateHeight)
    }

    @objc fileprivate func showMoreButtonAction(_ sender: AnyObject!) {
          if (isSeeMore) {
            isExpandTableview = true
            isExpandRadioTableBubbleView = true
            rowsDataLimit =  listArray.count
            isSeeMore =  false
            tableView.reloadData()
            NotificationCenter.default.post(name: Notification.Name(reloadTableNotification), object: nil)
          }
    }
    
    @objc fileprivate func cantFindTransactionButtonAction(_ sender: AnyObject!){
        
        if buttonsArray.count > 0 {
            let radios = buttonsArray[0]
            if radios.payload != nil{
                maskview.isHidden = false
                self.optionsAction(radios.title, radios.payload)
            }
        }
        
    }
    
    @objc fileprivate func checkButtonAction(_ sender: UIButton!) {
        let radios = listArray[sender.tag]
        //if radios.elementType == "postback"{
            if radios.elementPayload != nil{
                maskview.isHidden = false
                self.optionsAction(radios.title, radios.elementPayload)
                selectedIndex = sender.tag
                radioTableSelectedIndex =  sender.tag
                tableView.reloadData()
            }
        //}
    }
}
extension RadioListBubbleView: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 61
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 61
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowsDataLimit
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : RadioListCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! RadioListCell
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        let radios = listArray[indexPath.row]
        cell.titleLbl.text = radios.title
        cell.descLbl.text = radios.elementDescription
        cell.priceLbl.text = radios.value
        if radios.value == "0"{
            cell.priceLbl.text = ""
        }
        
        cell.titleLbl.textColor = .black
        cell.descLbl.textColor = .black
        cell.priceLbl.textColor = .black
        
        cell.titleLbl.font =  UIFont(name: semiBoldCustomFont, size: 14.0)
        cell.descLbl.font =  UIFont(name: regularCustomFont, size: 12.0)
        cell.priceLbl.font =  UIFont(name: semiBoldCustomFont, size: 14.0)
        
        cell.priceLblWidthConstraint.constant = 10
        let size = cell.priceLbl.text?.size(withAttributes:[.font: UIFont(name: semiBoldCustomFont, size: 14.0) as Any])
        if cell.priceLbl.text != nil {
            cell.priceLblWidthConstraint.constant = (size?.width)! + 10.0
        }
        
        cell.titleLblTopConstarint.constant = 10
        if radios.elementDescription == nil{
            cell.titleLblTopConstarint.constant = 20
        }
        
        cell.clipsToBounds = false
        let totalRows = tableView.numberOfRows(inSection: indexPath.section)
        if indexPath.row == totalRows - 1 {
            if #available(iOS 11.0, *) {
                cell.clipsToBounds = true
                cell.roundCorners([.layerMinXMaxYCorner, .layerMaxXMaxYCorner], radius: 10, borderColor: UIColor.clear, borderWidth: 1.5)
            }
        }
        if radioTableSelectedIndex == indexPath.row{ //checkBtn
            cell.checkBtn.setImage(UIImage.init(named: "radio_check"), for: .normal)
        }else{
            cell.checkBtn.setImage(UIImage.init(named: "radio_uncheck"), for: .normal)
        }
        cell.checkBtn.tag = indexPath.row
        cell.checkBtn.addTarget(self, action: #selector(self.checkButtonAction(_:)), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("dsfsdf")
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        let showMoreButton = UIButton(frame: CGRect.zero)
        showMoreButton.backgroundColor = .clear
        showMoreButton.translatesAutoresizingMaskIntoConstraints = false
        showMoreButton.clipsToBounds = true
        showMoreButton.layer.cornerRadius = 5
        showMoreButton.setTitleColor(.white, for: .normal)
        showMoreButton.titleLabel?.font = UIFont(name: semiBoldCustomFont, size: 14.0)
        view.addSubview(showMoreButton)
        showMoreButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
        showMoreButton.addTarget(self, action: #selector(self.showMoreButtonAction(_:)), for: .touchUpInside)
        showMoreButton.addRightIcon(image: UIImage.init(named: "icons24ArrowCta")!)
        showMoreButton.setTitle(seeMoreTitle, for: .normal)
        
        if isSeeMore{
            showMoreButton.isHidden = false
        }else{
            showMoreButton.isHidden = true
        }
        
        let cantFindButton = UIButton(frame: CGRect.zero)
        cantFindButton.backgroundColor = .clear
        cantFindButton.translatesAutoresizingMaskIntoConstraints = false
        cantFindButton.clipsToBounds = true
        cantFindButton.layer.cornerRadius = 5
        cantFindButton.setTitleColor(.white, for: .normal)
        cantFindButton.titleLabel?.font = UIFont(name: semiBoldCustomFont, size: 14.0)
        view.addSubview(cantFindButton)
        cantFindButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
        cantFindButton.addTarget(self, action: #selector(self.cantFindTransactionButtonAction(_:)), for: .touchUpInside)
        //cantFindButton.addRightIcon(image: UIImage.init(named: "icons24ArrowCta")!)
        cantFindButton.setTitle("Can't Find transaction", for: .normal)
        cantFindButton.contentHorizontalAlignment = .left;
        cantFindButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0);
        if buttonsArray.count > 0 {
            cantFindButton.isHidden = false
        }else{
            cantFindButton.isHidden = true
        }
        
        let views: [String: UIView] = ["showMoreButton": showMoreButton, "cantFindButton": cantFindButton]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[showMoreButton(35)]", options:[], metrics:nil, views:views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[cantFindButton(35)]", options:[], metrics:nil, views:views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[cantFindButton]-0-[showMoreButton(120)]-0-|", options:[], metrics:nil, views:views))
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        var height = 0.0
        if isSeeMore{
            height = 40.0
        }else{
            if buttonsArray.count > 0{
                height = 40.0
            }
        }
        return CGFloat(height)
    }
}

extension UIButton {
    func addRightIcon(image: UIImage) {
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(imageView)

        let length = CGFloat(30)
        titleEdgeInsets.right += length

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: self.titleLabel!.trailingAnchor, constant: 10),
            imageView.centerYAnchor.constraint(equalTo: self.titleLabel!.centerYAnchor, constant: 0),
            imageView.widthAnchor.constraint(equalToConstant: length),
            imageView.heightAnchor.constraint(equalToConstant: length)
        ])
    }
}

