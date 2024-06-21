//
//  SalaamPointsDetailsViewController.swift
//  KoreBotSDKFrameWork
//
//  Created by Kartheek Pagidimarri on 09/12/22.
//  Copyright © 2022 Kartheek.Pagidimarri. All rights reserved.
//

import UIKit
import SafariServices
class SalaamPointsDetailsViewController: UIViewController {
    let bundle = KREResourceLoader.shared.resourceBundle()
    var templateLanguage:String?
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var tableview: UITableView!
    fileprivate let listCellIdentifier = "SalaamElemetsCell"
    fileprivate let listCellICarddentifier = "SalaamPointsCardCell"
    var arrayOfElements = [ComponentElements]()
    var arrayOfCardDetails = [ComponentElements]()
    var dataString: String!
    var jsonData : Componentss?
    let kMaxTextWidth: CGFloat = BubbleViewMaxWidth - 32.0
    
    // MARK: init
    init(dataString: String) {
        super.init(nibName: "SalaamPointsDetailsViewController", bundle: bundle)
        self.dataString = dataString
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        headerView.backgroundColor = BubbleViewLeftTint
        if #available(iOS 11.0, *) {
            headerView.roundCorners([ .layerMinXMaxYCorner, .layerMaxXMaxYCorner], radius: 10.0, borderColor: UIColor.clear, borderWidth: 1.5)
        }
        
        headingLabel.font = UIFont(name: boldCustomFont, size: 16.0)
        if #available(iOS 11.0, *) {
            self.subView.roundCorners([ .layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 10.0, borderColor: UIColor.clear, borderWidth: 1.5)
        }
        self.tableview.layer.cornerRadius = 2.0
        self.tableview.register(UINib(nibName: listCellIdentifier, bundle: bundle), forCellReuseIdentifier: listCellIdentifier)
        self.tableview.register(UINib(nibName: listCellICarddentifier, bundle: bundle), forCellReuseIdentifier: listCellICarddentifier)
        
        subView.backgroundColor = UIColor.init(hexString: (brandingShared.widgetBodyColor) ?? "#FFFFFF")
        headingLabel.textColor = UIColor.init(hexString: (brandingShared.widgetTextColor) ?? "#000000")
        getData()
    }
    func getData(){
        let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: dataString!) as! NSDictionary
        let jsonDecoder = JSONDecoder()
        guard let jsonData1 = try? JSONSerialization.data(withJSONObject: jsonObject as Any , options: .prettyPrinted),
              let allItems = try? jsonDecoder.decode(Componentss.self, from: jsonData1) else {
            return
        }
        jsonData = allItems
        arrayOfElements = jsonData?.elements ?? []
        headingLabel.text = jsonData?.text ?? ""
        
        arrayOfElements = allItems.elements ?? []
        arrayOfCardDetails = allItems.cardDetails ?? []
        self.headingLabel.text = allItems.title ?? ""
        templateLanguage = allItems.lang ?? default_language
        if (templateLanguage?.caseInsensitiveCompare(preferred_language_Type) == .orderedSame){
            self.headingLabel.textAlignment = .right
        }else{
            self.headingLabel.textAlignment = .left
        }
        self.tableview.reloadData()
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
    
    @objc fileprivate func copyBtnAction(_ sender: UIButton!) {
        let cardsDetails = arrayOfCardDetails[sender.tag]
        let value = cardsDetails.value
        UIPasteboard.general.string = value
        // read from clipboard
        //NotificationCenter.default.post(name: Notification.Name(activityViewControllerNotification), object: "Copy")
        toastMessage("Copied")
    }
    
      func toastMessage(_ message: String){
        guard let window = UIApplication.shared.keyWindow else {return}
        let messageLbl = UILabel()
        messageLbl.text = message
        messageLbl.textAlignment = .center
        messageLbl.font = UIFont.systemFont(ofSize: 12)
        messageLbl.textColor = .white
        messageLbl.backgroundColor = UIColor(white: 0, alpha: 0.5)
    
        let textSize:CGSize = messageLbl.intrinsicContentSize
        let labelWidth = min(textSize.width, window.frame.width - 40)
    
        messageLbl.frame = CGRect(x: 20, y: window.frame.height - 90, width: labelWidth + 30, height: textSize.height + 20)
        messageLbl.center.x = window.center.x
        messageLbl.layer.cornerRadius = messageLbl.frame.height/2
        messageLbl.layer.masksToBounds = true
        window.addSubview(messageLbl)
    
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
    
        UIView.animate(withDuration: 1, animations: {
            messageLbl.alpha = 0
        }) { (_) in
            messageLbl.removeFromSuperview()
        }
        }
    }
    
}
extension SalaamPointsDetailsViewController: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return arrayOfElements.count
        }
        return arrayOfCardDetails.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell : SalaamElemetsCell = tableView.dequeueReusableCell(withIdentifier: listCellIdentifier) as! SalaamElemetsCell
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
            let elements = arrayOfElements[indexPath.row]
            cell.titleLbl.text = elements.title
            cell.valueLbl.text = elements.value
            if (templateLanguage?.caseInsensitiveCompare(preferred_language_Type) == .orderedSame){
                cell.bgView.semanticContentAttribute = .forceRightToLeft
                cell.titleLbl.textAlignment = .right
                cell.valueLbl.textAlignment = .left
            }else{
                cell.bgView.semanticContentAttribute = .forceLeftToRight
                cell.titleLbl.textAlignment = .left
                cell.valueLbl.textAlignment = .right
            }
            return cell
        }else{
            let cell : SalaamPointsCardCell = tableView.dequeueReusableCell(withIdentifier: listCellICarddentifier) as! SalaamPointsCardCell
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
            let cardsDetails = arrayOfCardDetails[indexPath.row]
            cell.offersLbl.text = cardsDetails.title
            //cell.cardLbl.text = cardsDetails.value
            if let cardValue = cardsDetails.value{
                cell.cardLbl.setHTMLString(cardValue, withWidth: kMaxTextWidth)
//                if cardValue.contains("**"){
//                    cell.cardTxtV.text = cardValue
//                }else{
                    cell.cardTxtV.setHTMLString(cardValue, withWidth: kMaxTextWidth)
                //}
                self.textLinkDetection(textLabel: cell.cardLbl)
                self.textViewLinkDetection(textLabel: cell.cardTxtV)
            }
            if (templateLanguage?.caseInsensitiveCompare(preferred_language_Type) == .orderedSame){
                cell.bgView.semanticContentAttribute = .forceRightToLeft
                cell.offersLbl.textAlignment = .right
                cell.cardLbl.textAlignment = .right
                cell.cardTxtV.textAlignment = .right
            }else{
                cell.bgView.semanticContentAttribute = .forceLeftToRight
                cell.offersLbl.textAlignment = .left
                cell.cardLbl.textAlignment = .left
                cell.cardTxtV.textAlignment = .left
            }
            if let color = cardsDetails.color{
                cell.cardTxtV.textColor = UIColor.init(hexString: (color))
            }
            
            cell.copyBtn.addTarget(self, action: #selector(copyBtnAction(_:)), for: .touchUpInside)
            cell.copyBtn.tag = indexPath.row
            cell.copyBtnWidthConstraint.constant = 0
            if let copy = cardsDetails.copyValue{
                let size = copy.size(withAttributes:[.font: UIFont(name: mediumCustomFont, size: 12.0) ?? UIFont.systemFont(ofSize: 12.0)])
                cell.copyBtnWidthConstraint.constant = size.width + 10
                cell.copyBtn.setTitle(copy, for: .normal)
            }
            
            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let elements = arrayOfComponents[indexPath.row]
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return  0
    }
    
    func textLinkDetection(textLabel:KREAttributedLabel) {
        textLabel.detectionBlock = {(hotword, string) in
            switch hotword {
            case KREAttributedHotWordLink:
                self.movetoWebViewController(urlString: string!)
                print(string!)
                break
            default:
                break
            }
        }
    }
    
    func textViewLinkDetection(textLabel:KREAttributedTextView) {
        textLabel.detectionBlock = {(hotword, string) in
            switch hotword {
            case KREAttributedHotWordLink:
                self.movetoWebViewController(urlString: string)
                break
            default:
                break
            }
        }
    }
    
    func movetoWebViewController(urlString:String){
        if (urlString.count > 0) {
            let url: URL = URL(string: urlString)!
            let webViewController = SFSafariViewController(url: url)
            present(webViewController, animated: true, completion:nil)
        }
    }
    
}

