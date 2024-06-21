//
//  InLineFormBubbleView.swift
//  KoreBotSDKDemo
//
//  Created by developer@kore.com on 05/05/20.
//  Copyright © 2020 Kore. All rights reserved.
//

import UIKit
import korebotplugin

class InLineFormBubbleView: BubbleView {
    static let buttonsLimit: Int = 3
    static let headerTextLimit: Int = 640
    public var maskview: UIView!
    var cardView: UIView!
    var tableView: UITableView!
    fileprivate let cellIdentifier = "InlineFormTableViewCell"
    var footerButtonTitle:NSString?
    
    var headingLabel: KREAttributedLabel!
    var textfeilds: Array<Dictionary<String, Any>> = []
    //var titleLbl: UILabel!
    var textFBgV: UIView!
    var inlineTextField: UITextField!
    var inlineButton: UIButton!
    public var optionsAction: ((_ text: String?, _ payload: String?) -> Void)!
    
    let yourAttributes : [NSAttributedString.Key: Any] = [
    NSAttributedString.Key.font : UIFont(name: mediumCustomFont, size: 14.0) as Any,
    NSAttributedString.Key.foregroundColor : bubbleViewBotChatButtonTextColor]
    var arrayOfTextFieldsText = NSMutableArray()
    let activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView(style: .gray)
    let sendButton = UIButton(frame: CGRect.zero)
    
    override func prepareForReuse() {
        arrayOfTextFieldsText = []
    }
    
    override func initialize() {
        super.initialize()
        
        self.cardView = UIView(frame:.zero)
        self.cardView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.cardView)
        cardView.backgroundColor =  BubbleViewLeftTint
        cardView.clipsToBounds = true
        if #available(iOS 11.0, *) {
            self.cardView.roundCorners([ .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner], radius: 15.0, borderColor: UIColor.clear, borderWidth: 1.5)
        }
        
        let cardViews: [String: UIView] = ["cardView": cardView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[cardView]-0-|", options: [], metrics: nil, views: cardViews))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[cardView]-0-|", options: [], metrics: nil, views: cardViews))
        
        self.headingLabel = KREAttributedLabel(frame: CGRect.zero)
        self.headingLabel.textColor = BubbleViewBotChatTextColor
        self.headingLabel.backgroundColor = UIColor.clear
        self.headingLabel.mentionTextColor = Common.UIColorRGB(0x8ac85a)
        self.headingLabel.hashtagTextColor = Common.UIColorRGB(0x8ac85a)
        self.headingLabel.linkTextColor = Common.UIColorRGB(0x0076FF)
        self.headingLabel.font = UIFont(name: mediumCustomFont, size: 14.0)
        self.headingLabel.numberOfLines = 0
        self.headingLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.headingLabel.isUserInteractionEnabled = true
        self.headingLabel.contentMode = UIView.ContentMode.topLeft
        self.headingLabel.textAlignment = .center
        self.headingLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.headingLabel)
        
        
        self.tableView = UITableView(frame: CGRect.zero,style:.plain)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.backgroundColor = .clear
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.bounces = false
        self.tableView.separatorStyle = .none
        self.addSubview(self.tableView)
        self.tableView.isScrollEnabled = false
        let bundle = KREResourceLoader.shared.resourceBundle()
        self.tableView.register(UINib(nibName: cellIdentifier, bundle: bundle), forCellReuseIdentifier: cellIdentifier)
        
        self.maskview = UIView(frame:.zero)
        self.maskview.translatesAutoresizingMaskIntoConstraints = false
        self.cardView.addSubview(self.maskview)
        self.maskview.isHidden = true
        maskview.backgroundColor = .clear
        
        let views: [String: UIView] = ["headingLabel": headingLabel, "tableView": tableView, "maskview": maskview]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-16-[headingLabel]-00-[tableView]-10-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[headingLabel]-16-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[tableView]-10-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[maskview]-0-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[maskview]", options: [], metrics: nil, views: views))
        
//        let views: [String: UIView] = ["headingLabel": headingLabel]
//        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[headingLabel(>=15)]-5-|", options: [], metrics: nil, views: views))
//        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[headingLabel]-10-|", options: [], metrics: nil, views: views))
               
        
        
        
    }
    
    // MARK: populate components
    override func populateComponents() {
        if (components.count > 0) {
            let component: KREComponent = components.firstObject as! KREComponent
            if (component.componentDesc != nil) {
                let jsonString = component.componentDesc
                let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: jsonString!) as! NSDictionary
                textfeilds = jsonObject["formFields"] != nil ? jsonObject["formFields"] as! Array<Dictionary<String, Any>> : []
                arrayOfTextFieldsText = []
                for _ in 0..<textfeilds.count{
                    arrayOfTextFieldsText.add("")
                }
                var headerText: String = jsonObject["heading"] != nil ? jsonObject["heading"] as! String : ""
                headerText = KREUtilities.formatHTMLEscapedString(headerText);

                if(headerText.count > InLineFormBubbleView.headerTextLimit){
                    headerText = String(headerText[..<headerText.index(headerText.startIndex, offsetBy: InLineFormBubbleView.headerTextLimit)]) + "..."
                }
                self.headingLabel.setHTMLString(headerText, withWidth: BubbleViewMaxWidth - 20)
                if jsonObject["fieldButton"] != nil {
                    let btnTitle = (jsonObject["fieldButton"] as AnyObject).object(forKey: "title") != nil ? ((jsonObject["fieldButton"] as AnyObject).object(forKey: "title") as! String) : ""
                    footerButtonTitle = btnTitle as NSString
                }
                tableView.reloadData()
                
                //self.headingLabel.text = "Your session has expired. Please re-login."
            }
        }
    }
    
    override var intrinsicContentSize : CGSize {
        self.headingLabel.font = UIFont(name: mediumCustomFont, size: 14.0)
        let limitingSize: CGSize  = CGSize(width: BubbleViewMaxWidth - 20, height: CGFloat.greatestFiniteMagnitude)
        let headingLabelSize: CGSize = self.headingLabel.sizeThatFits(limitingSize)
        sendButton.isHidden = false
        if isLogin {
            sendButton.isHidden = true
            return CGSize(width: BubbleViewMaxWidth-60, height: headingLabelSize.height + 32)
        }
        var tableviewHeight: CGFloat = 0.0
        for _ in 0..<textfeilds.count{
            tableviewHeight += 70.0
        }
        return CGSize(width: BubbleViewMaxWidth-60, height: headingLabelSize.height + tableviewHeight + 50)
    }
    
    
    
    @objc func tapsOnInlineFormBtn(_ sender:UIButton) {
        var isempty = false
        var isSecure = false
        var finalString = ""
        var secureString = ""
        
        var userNameTxt = ""
        var passwordTxt = ""
        for i in 0..<arrayOfTextFieldsText.count{
            if arrayOfTextFieldsText[i] as! String == "" {
                isempty = true
            }else{
                let dictionary = textfeilds[i]
                let formFeildType: String = dictionary["type"] != nil ? dictionary["type"] as! String : ""
                let textStr = arrayOfTextFieldsText[i] as? String
                if formFeildType == "password"{
                    passwordTxt = textStr ?? ""
                    let secureTxt = textStr?.regEx()
                    finalString.append("\(formFeildType): \(textStr!) ")
                    secureString.append("\(formFeildType): \(secureTxt!) ")
                    isSecure = true
                }else{
                    userNameTxt = textStr ?? ""
                    finalString.append("\(formFeildType): \(textStr!) ")
                    secureString.append("\(formFeildType): \(textStr!) ")
                }
            }
        }
        
        if !isempty{
//            for i in 0..<arrayOfTextFieldsText.count{
//                let indexPath = IndexPath(row: i, section: sender.tag)
//                let cell = tableView.cellForRow(at: indexPath) as! InlineFormTableViewCell
//                cell.textFeildName.resignFirstResponder()
//                arrayOfTextFieldsText.replaceObject(at: i, with: "")
//            }
//            tableView.reloadData()
//            self.maskview.isHidden = false
//            if isSecure {
//                self.optionsAction(secureString, finalString)
//            }else{
//                self.optionsAction(finalString, finalString)
//            }
            
            
            activityIndicatorView.isHidden = false
            activityIndicatorView.startAnimating()
            let udid = UIDevice.current.identifierForVendor?.uuidString
            print(udid ?? "12345")
            let body:[String: Any] = ["username": userNameTxt, "password": passwordTxt, "deviceId": udid ?? "12345", "deviceType": "iOS"]
            CallingMashreqLoginApi(url: "\(SDKConfiguration.serverConfig.Login_Url)", body: body) //api/prelogin/molpreauth
        }
           
    }
    
    func CallingMashreqLoginApi(url: String , body: [String: Any]) {
       
        let urlString = url
        //Create URL to the source file you want to download
        let fileURL = URL(string: urlString)
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        var request = URLRequest(url:fileURL!)
       
        request.httpMethod = "POST"
        let jsonDic = body
        
        var theJSONData = NSData()
        do {
            theJSONData = try JSONSerialization.data(withJSONObject: jsonDic, options: JSONSerialization.WritingOptions()) as NSData
        } catch {
            // completion(String())
            print("JSOn DIC Error")
        }
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("MOBILE", forHTTPHeaderField: "X-MOB-CHANNEL-NAME")
        
        request.httpBody = theJSONData as Data
          session.dataTask(with: request) { (data, response, error) in
              if let response = response {
                  print(response)
              }
              if let data = data {
                  do {
                      let jsonDic = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
//                   if let statusCode = (response as? HTTPURLResponse)?.statusCode {
//                       if statusCode != 200 {
//                        DispatchQueue.main.async {
//
//                        }
//
//                       }
 //                  }
                   if let responseDic = jsonDic,
                       let status = responseDic["status"] as? String, status == "success" {
                    DispatchQueue.main.async {
                        // Update UI
                        print(responseDic)
                        for i in 0..<self.arrayOfTextFieldsText.count{
                            let indexPath = IndexPath(row: i, section: 0)
                            let cell = self.tableView.cellForRow(at: indexPath) as! InlineFormTableViewCell
                            cell.textFeildName.resignFirstResponder()
                        }
                        self.activityIndicatorView.isHidden = true
                        self.activityIndicatorView.stopAnimating()
                        isLogin = true
                        //self.tableView.reloadData()
                        NotificationCenter.default.post(name: Notification.Name(reloadTableNotification), object: nil)
                        if let data = responseDic["data"] as? [String: Any]{
                            loginXauthToken = data["xAuthToken"] as? String
                            loginAccessToken = data["accessToken"] as? String
                            loginUserId = data["userId"] as? String
                            loginUserType = data["userType"] as? String
                            loginCustomerCif = data["customerCif"] as? String
                            loginCustomerName = data["customerName"] as? String
                            loginID = data["loginID"] as? String
                            loginUserSegments = data["userSegments"] as? String
                            loginEmailId = data["customerEmailId"] as? String
                            loginMobileNo = data["mobileNumber"] as? String
                            NotificationCenter.default.post(name: Notification.Name(loginNotification), object: nil)
                        }
                      }
                   }else{
                    if let responseDic = jsonDic,
                        let status = responseDic["message"] as? String, status == "Authentication Error" {
                        DispatchQueue.main.async {
                            self.activityIndicatorView.isHidden = true
                            self.activityIndicatorView.stopAnimating()
                            NotificationCenter.default.post(name: Notification.Name(loginNotification), object: status)
                        }
                    }else{
                        DispatchQueue.main.async {
                            self.activityIndicatorView.isHidden = true
                            self.activityIndicatorView.stopAnimating()
                            NotificationCenter.default.post(name: Notification.Name(loginNotification), object: "Login failed")
                        }
                    }
                   }
                  } catch {
                    DispatchQueue.main.async {
                        self.activityIndicatorView.isHidden = true
                        self.activityIndicatorView.stopAnimating()
                        NotificationCenter.default.post(name: Notification.Name(loginNotification), object: "Please try again")
                    }
                    print(error)
                  }
              }
          }.resume()
}
    
}
extension InLineFormBubbleView: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == " " {
            return false
        }
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string) as NSString
        return newString.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines).location != 0
    }
}

extension InLineFormBubbleView: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return textfeilds.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : InlineFormTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! InlineFormTableViewCell
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        let dictionary = textfeilds[indexPath.row]
        let placeHolder: String = dictionary["placeholder"] != nil ? dictionary["placeholder"] as! String : ""
        let title: String = dictionary["label"] != nil ? dictionary["label"] as! String : placeHolder
        let formFeildType: String = dictionary["type"] != nil ? dictionary["type"] as! String : ""
        //let titlStr = title == "" ? placeHolder : title
        if title == ""{
            cell.titileLblHeightConstraint.constant = 10.0
            cell.tiltLbl.text = ""
        }else{
            cell.titileLblHeightConstraint.constant = 21.0
            cell.tiltLbl.text = "\(title) :"
        }
        
       
        let attributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font: UIFont(name: mediumCustomFont, size: 14.0) ?? UIFont.systemFont(ofSize: 14.0), NSAttributedString.Key.foregroundColor: UIColor.darkGray]

        cell.textFeildName.attributedPlaceholder = NSAttributedString(string: placeHolder, attributes: attributes)

        
        cell.tiltLbl .textColor = BubbleViewBotChatTextColor
        cell.textFeildName.borderStyle = .bezel
        if formFeildType == "password"{
            cell.textFeildName.isSecureTextEntry = true
        }else{
            cell.textFeildName.isSecureTextEntry = false
        }
        cell.textFeildName.backgroundColor = .white
        cell.textFeildName.delegate = self
        cell.textFeildName.text = arrayOfTextFieldsText[indexPath.row] as? String
        cell.textFeildName.addTarget(self, action: #selector(valueChanged), for: .editingChanged)
        cell.textFeildName.tag = indexPath.row
        cell.textFeildName.translatesAutoresizingMaskIntoConstraints = false
       
        return cell
        
    }
     @objc func valueChanged(_ textField: UITextField){
        arrayOfTextFieldsText.replaceObject(at: textField.tag, with: textField.text ?? "")
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        
        sendButton.backgroundColor = bubbleViewBotChatButtonBgColor
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.clipsToBounds = true
        sendButton.layer.cornerRadius = 5
        sendButton.setTitleColor(bubbleViewBotChatButtonTextColor, for: .normal)
        sendButton.titleLabel?.font = UIFont(name: mediumCustomFont, size: 12.0)
        view.addSubview(sendButton)
        sendButton.addTarget(self, action: #selector(self.tapsOnInlineFormBtn(_:)), for: .touchUpInside)
        sendButton.tag = section
        let attributeString = NSMutableAttributedString(string: (footerButtonTitle ?? "Send") as String,
                                                                   attributes: yourAttributes)
                   sendButton.setAttributedTitle(attributeString, for: .normal)
        
        activityIndicatorView.center = sendButton.center
        activityIndicatorView.color = bubbleViewBotChatButtonTextColor
        //activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.isHidden = true
        view.addSubview(activityIndicatorView)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
    
        let views: [String: UIView] = ["sendButton": sendButton, "activityIndicatorView": activityIndicatorView]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[sendButton(30)]-0-|", options:[], metrics:nil, views:views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[sendButton]-10-|", options:[], metrics:nil, views:views))
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[activityIndicatorView(30)]-0-|", options:[], metrics:nil, views:views))
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-100-[activityIndicatorView(30)]", options:[], metrics:nil, views:views))
        
        return view
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return  40
    }
}
