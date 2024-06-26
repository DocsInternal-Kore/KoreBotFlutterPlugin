//
//  LeftMenuView.swift
//  KoreBotSDKFrameWork
//
//  Created by Kartheek.Pagidimarri on 03/10/22.
//  Copyright © 2022 Kartheek.Pagidimarri. All rights reserved.
//

import UIKit
protocol LeftMenuViewDelegate {
    func leftMenuSelectedText(text:String, payload:String)
    func popUpChangeLanguageVC()
}
class LeftMenuView: UIView {
    let bundle = KREResourceLoader.shared.resourceBundle()
    var viewDelegate: LeftMenuViewDelegate?
    var tableView: UITableView!
    
    var headersArray = [String]()
    var recentSearchs = [String]()
    var moreOptions = [String]()
    
    var arrayOftasks = [Task]()
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupViews()
    }
    
    fileprivate func setupViews() { 
        //self.backgroundColor = UIColor.init(hexString: "#f8f9fc")
        self.tableView = UITableView(frame: CGRect.zero,style:.plain)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.backgroundColor = .clear
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.layer.cornerRadius = 10.0
        self.tableView.layer.masksToBounds = true
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.bounces = false
        self.tableView.separatorStyle = .none
        self.addSubview(self.tableView)
        self.tableView.tableFooterView = UIView()
        
        self.tableView.register(UINib(nibName: "LeftMenuCell", bundle: bundle), forCellReuseIdentifier: "LeftMenuCell")
        
        let views: [String: UIView] = ["tableView": tableView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[tableView]-5-|", options: [], metrics: nil, views: views))
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[tableView]-0-|", options: [], metrics: nil, views: views))
        
        getData()
    }
    
    func getData(){
        let jsonDic = brandingShared.hamburgerOptions
        if let jsonResult = jsonDic as Dictionary<String, AnyObject>? {
            let jsonData = try? DictionaryDecoder().decode(TaskMenu.self, from: jsonResult as [String : Any])
            self.arrayOftasks = jsonData!.tasks
            leftMenuTableviewReload()
        }
    }
    func leftMenuTableviewReload(){
        headersArray = []
        recentSearchs = []
        moreOptions = []
        recentSearchs = NSOrderedSet(array: recentSearchArray).map({ $0 as! String })
        //moreOptions.append("Change Language")
        if recentSearchs.count > 0{
            headersArray.append("Recent Search")
        }
        headersArray.append("Quick Links")
        //headersArray.append("More Options")
        self.tableView.reloadData()
    }
}

extension LeftMenuView: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return headersArray.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if headersArray[section] == "Recent Search"{
            return recentSearchs.count
        }else if headersArray[section] == "Quick Links"{
            return  self.arrayOftasks.count
        }else{
            return moreOptions.count
        }
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : LeftMenuCell = self.tableView.dequeueReusableCell(withIdentifier: "LeftMenuCell") as! LeftMenuCell
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        let imgV = UIImage.init(named: "otpVBg", in: bundle, compatibleWith: nil)
        cell.imgView.image = imgV?.withRenderingMode(.alwaysTemplate)
        cell.imgView.tintColor = BubbleViewLeftTint
        
        cell.iconImageV.contentMode = .scaleAspectFit
        cell.iconImageV.tintColor = themeColor
        if headersArray[indexPath.section] == "Recent Search"{
            cell.titleLabel.text = recentSearchs[indexPath.row]
            let img = UIImage.init(named: "recentSearch", in: bundle, compatibleWith: nil)
            cell.iconImageV.image = img?.withRenderingMode(.alwaysTemplate)
            
        }else if headersArray[indexPath.section] == "Quick Links"{
            let tasks =  self.arrayOftasks[indexPath.row]
            cell.titleLabel.text = tasks.title
            let image = Utilities.base64ToImage(base64String: tasks.icon)
            cell.iconImageV.image = image.withRenderingMode(.alwaysTemplate)
        }else{
            cell.titleLabel.text = moreOptions[indexPath.row]
            let img = UIImage.init(named: "moreOption", in: bundle, compatibleWith: nil)
            cell.iconImageV.image =  img?.withRenderingMode(.alwaysTemplate)
        }
        
        cell.bgView.backgroundColor = UIColor.init(hexString: "#FFFFFF")
        cell.titleLabel.textColor = UIColor.init(hexString: (brandingShared.widgetTextColor) ?? "#26344A")
        if preferred_language_Type == preferredLanguage{
            cell.bgView.semanticContentAttribute = .forceRightToLeft
            cell.titleLabel.textAlignment = .right
        }else{
            cell.bgView.semanticContentAttribute = .forceLeftToRight
            cell.titleLabel.textAlignment = .left
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if headersArray[indexPath.section] == "Recent Search"{
            let elements = recentSearchs[indexPath.row]
            self.viewDelegate?.leftMenuSelectedText(text: elements, payload: elements)
        }else if headersArray[indexPath.section] == "Quick Links"{
            let elements = arrayOftasks[indexPath.row]
            self.viewDelegate?.leftMenuSelectedText(text: (elements.postback.title), payload: (elements.postback.value))
            
        }else{
            self.viewDelegate?.popUpChangeLanguageVC()
        }
        
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        
        let subView = UIView()
        subView.backgroundColor = .white
        subView.translatesAutoresizingMaskIntoConstraints = false
        subView.layer.cornerRadius = 5.0
        subView.clipsToBounds = true
        view.addSubview(subView)
        
        let headerLabel = UILabel(frame: .zero)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.textAlignment = .left
        headerLabel.font = UIFont(name: semiBoldCustomFont, size: 16.0)
        headerLabel.font = headerLabel.font.withSize(15.0)
        
        headerLabel.textColor = .black
        headerLabel.text = headersArray[section]
        subView.addSubview(headerLabel)
        
        if preferred_language_Type == preferredLanguage{
            headerLabel.textAlignment = .right
        }else{
            headerLabel.textAlignment = .left
        }
        
        let views: [String: UIView] = ["headerLabel": headerLabel]
        subView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[headerLabel]-16-|", options:[], metrics:nil, views:views))
        subView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[headerLabel]-0-|", options:[], metrics:nil, views:views))
        
        
        let subViews: [String: UIView] = ["subView": subView]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[subView]-0-|", options:[], metrics:nil, views:subViews))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[subView]-0-|", options:[], metrics:nil, views:subViews))
        
        return view
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
}

extension CATransition {
    
    //New viewController will appear from bottom of screen.
    func segueFromBottom() -> CATransition {
        self.duration = 0.375 //set the duration to whatever you'd like.
        self.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        self.type = CATransitionType.moveIn
        self.subtype = CATransitionSubtype.fromTop
        return self
    }
    //New viewController will appear from top of screen.
    func segueFromTop() -> CATransition {
        self.duration = 0.375 //set the duration to whatever you'd like.
        self.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        self.type = CATransitionType.moveIn
        self.subtype = CATransitionSubtype.fromBottom
        return self
    }
    //New viewController will appear from left side of screen.
    func segueFromLeft() -> CATransition {
        self.duration = 0.9 //set the duration to whatever you'd like.
        self.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        self.type = CATransitionType.moveIn
        self.subtype = CATransitionSubtype.fromLeft
        return self
    }
    func segueFromLeftOut() -> CATransition {
        self.duration = 0.9 //set the duration to whatever you'd like.
        self.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        self.type = CATransitionType.moveIn
        self.subtype = CATransitionSubtype.fromLeft
        return self
    }
    //New viewController will appear from left side of screen.
    func segueFromRight() -> CATransition {
        self.duration = 0.9 //set the duration to whatever you'd like.
        self.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        self.type = CATransitionType.moveIn
        self.subtype = CATransitionSubtype.fromRight
        return self
    }
    //New viewController will pop from right side of screen.
    func popFromRight() -> CATransition {
        self.duration = 0.9 //set the duration to whatever you'd like.
        self.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        self.type = CATransitionType.reveal
        self.subtype = CATransitionSubtype.fromRight
        return self
    }
    //New viewController will appear from left side of screen.
    func popFromLeft() -> CATransition {
        self.duration = 0.9 //set the duration to whatever you'd like.
        self.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        self.type = CATransitionType.reveal
        self.subtype = CATransitionSubtype.fromLeft
        return self
    }
}
