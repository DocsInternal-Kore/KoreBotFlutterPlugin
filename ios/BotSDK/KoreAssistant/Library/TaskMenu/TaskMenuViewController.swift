//
//  TaskMenuViewController.swift
//  KoreBotSDKDemo
//
//  Created by MatrixStream_01 on 29/05/20.
//  Copyright © 2020 Kore. All rights reserved.
//

import UIKit
protocol TaskMenuNewDelegate {
    func optionsButtonTapNewAction(text:String, payload:String)
    func languageChange(text:String)
    func popUpChangeLanguageVC()
}
class TaskMenuViewController: UIViewController {
    let bundle = KREResourceLoader.shared.resourceBundle()
    var brandingHeading = ""
    @IBOutlet weak var subView: UIView!
    @IBOutlet var backBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableview: UITableView!
    var arrayOftasks = [Task]()
    fileprivate let taskMenuCellIdentifier = "TaskMenuTablViewCell"
    fileprivate let leftMenuCellIdentifier = "LeftMenuCell"
    var viewDelegate: TaskMenuNewDelegate?
    
    @IBOutlet weak var bgViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var bgViewTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet var engBtn: UIButton!
    @IBOutlet var arabicBtn: UIButton!
    
    var headersArray = [String]()
    var recentSearchs = [String]()
    var moreOptions = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        getData()
        recentSearchs = NSOrderedSet(array: recentSearchArray).map({ $0 as! String })
        moreOptions.append("Change Language")
        if recentSearchs.count > 0{
            headersArray.append("Recent Search")
        }
        if brandingHeading != ""{
            headersArray.append(brandingHeading)
        }
        
        headersArray.append("More Options")
        
        subView.backgroundColor = UIColor.init(hexString: (brandingShared.widgetBodyColor) ?? "#FFFFFF")
        titleLabel.textColor = UIColor.init(hexString: (brandingShared.widgetTextColor) ?? "#26344A")
        subView.layer.masksToBounds = false
        subView?.layer.shadowColor = UIColor.lightGray.cgColor
        subView?.layer.shadowOffset =  CGSize.zero
        
        self.tableview.register(UINib(nibName: taskMenuCellIdentifier, bundle: bundle), forCellReuseIdentifier: taskMenuCellIdentifier)
        self.tableview.register(UINib(nibName: leftMenuCellIdentifier, bundle: bundle), forCellReuseIdentifier: leftMenuCellIdentifier)
        
        self.engBtn.titleLabel?.font = UIFont(name: regularCustomFont, size: 14.0)
        self.arabicBtn.titleLabel?.font = UIFont(name: regularCustomFont, size: 14.0)
        
        engBtn.layer.cornerRadius = 4.0
        engBtn.layer.borderWidth = 1.0
        engBtn.layer.borderColor = themeColor.cgColor
        engBtn.clipsToBounds = true
        engBtn.backgroundColor = themeColor
        engBtn.setTitle("Continue in English", for: .normal)
        
        arabicBtn.layer.cornerRadius = 4.0
        arabicBtn.layer.borderWidth = 1.0
        arabicBtn.layer.borderColor = themeColor.cgColor
        arabicBtn.clipsToBounds = true
        arabicBtn.backgroundColor = themeColor
        arabicBtn.setTitle("تغيير اللغة إلى العربية", for: .normal)
        
        if preferredLanguage == preferred_language_Type{
            //engBtn.setImage(UIImage.init(named: "uncheckM"), for: .normal)
            //arabicBtn.setImage(UIImage.init(named: "checkM"), for: .normal)
            
            arabicBtn.layer.borderWidth = 0.0
            arabicBtn.backgroundColor = themeColor
            arabicBtn.setTitleColor(.white, for: .normal)
            engBtn.layer.borderWidth = 1.0
            engBtn.backgroundColor = .clear
            engBtn.setTitleColor(themeColor, for: .normal)
            
            bgViewTrailingConstraint.constant = 0.0
            bgViewLeadingConstraint.constant = 75.0
            
            subView.semanticContentAttribute = .forceRightToLeft
            titleLabel.textAlignment = .center
            titleLabel.text = "قائمة الطعام"
            backBtn.setBackgroundImage(UIImage.init(named: "keyboard-arrow-right"), for: .normal)
            
        }else{
            //engBtn.setImage(UIImage.init(named: "checkM"), for: .normal)
            //arabicBtn.setImage(UIImage.init(named: "uncheckM"), for: .normal)
            engBtn.layer.borderWidth = 0.0
            engBtn.backgroundColor = themeColor
            engBtn.setTitleColor(.white, for: .normal)
            
            arabicBtn.layer.borderWidth = 1.0
            arabicBtn.backgroundColor = .clear
            arabicBtn.setTitleColor(themeColor, for: .normal)
            
            bgViewTrailingConstraint.constant = -75.0
            bgViewLeadingConstraint.constant = 0.0
            
            subView.semanticContentAttribute = .forceLeftToRight
            titleLabel.textAlignment = .center
            titleLabel.text = "Menu"
            backBtn.setBackgroundImage(UIImage.init(named: "keyboard-arrow-left"), for: .normal)
            
        }
    }
    
    func getData(){
        
        let jsonDic = brandingShared.hamburgerOptions
        if let jsonResult = jsonDic as Dictionary<String, AnyObject>? {
            // do stuff
            let jsonData = try? DictionaryDecoder().decode(TaskMenu.self, from: jsonResult as [String : Any])
            self.arrayOftasks = jsonData?.tasks ?? []
            //titleLabel.text = jsonData!.heading
            brandingHeading = jsonData?.heading ?? ""
            self.tableview.reloadData()
        }
        
    }
    @IBAction func tapsOnCloseBtnAct(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    public init() {
        super.init(nibName: "TaskMenuViewController", bundle: Bundle(for: TaskMenuViewController.self))
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func tapsOnEngLishBtn(_ sender: Any) {
        //        engBtn.setImage(UIImage.init(named: "checkM"), for: .normal)
        //        arabicBtn.setImage(UIImage.init(named: "uncheckM"), for: .normal)
        self.viewDelegate?.languageChange(text: "cheat lang en")
        preferredLanguage = "EN"
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func tapsOnArabicBtn(_ sender: Any) {
        //        engBtn.setImage(UIImage.init(named: "uncheckM"), for: .normal)
        //        arabicBtn.setImage(UIImage.init(named: "checkM"), for: .normal)
        self.viewDelegate?.languageChange(text: "cheat lang ar")
        preferredLanguage = "AR"
        self.dismiss(animated: true, completion: nil)
    }
    
}
extension TaskMenuViewController: UITableViewDelegate,UITableViewDataSource{
    
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
        }else if headersArray[section] == brandingHeading{
            return  self.arrayOftasks.count
        }else{
            return moreOptions.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : LeftMenuCell = self.tableview.dequeueReusableCell(withIdentifier: leftMenuCellIdentifier) as! LeftMenuCell
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        if headersArray[indexPath.section] == "Recent Search"{
            cell.titleLabel.text = recentSearchs[indexPath.row]
            cell.imgView.image = UIImage.init(named: "recentSearch", in: bundle, compatibleWith: nil)
        }else if headersArray[indexPath.section] == brandingHeading{
            let tasks =  self.arrayOftasks[indexPath.row]
            cell.titleLabel.text = tasks.title
            //let image = Utilities.base64ToImage(base64String: tasks.icon)
            //cell.imgView.image = image
            cell.imgView.image = UIImage.init(named: "quicklinks", in: bundle, compatibleWith: nil)
        }else{
            cell.titleLabel.text = moreOptions[indexPath.row]
            cell.imgView.image = UIImage.init(named: "moreOption", in: bundle, compatibleWith: nil)
        }
        cell.bgView.backgroundColor = UIColor.init(hexString: (brandingShared.widgetBodyColor) ?? "#FFFFFF")
        cell.titleLabel.textColor = UIColor.init(hexString: (brandingShared.widgetTextColor) ?? "#26344A")
        if preferredLanguage == preferred_language_Type{
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
            self.viewDelegate?.optionsButtonTapNewAction(text: elements, payload: elements)
            self.dismiss(animated: true, completion: nil)
        }else if headersArray[indexPath.section] == brandingHeading{
            let elements = arrayOftasks[indexPath.row]
            self.viewDelegate?.optionsButtonTapNewAction(text: (elements.postback.title), payload: (elements.postback.value))
            self.dismiss(animated: true, completion: nil)
        }else{
            self.dismiss(animated: false, completion: nil)
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
