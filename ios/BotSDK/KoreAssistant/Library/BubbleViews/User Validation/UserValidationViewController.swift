//
//  UserValidationViewController.swift
//  KoreBotSDKFrameWork
//
//  Created by Kartheek Pagidimarri on 06/02/23.
//  Copyright © 2023 Kartheek.Pagidimarri. All rights reserved.
//

import UIKit
protocol userValidationDelegate {
    func optionsButtonTapNewAction(text:String, payload:String)
    func sendSlientMessageTobot(text:String)
}
class UserValidationViewController: UIViewController {
    let bundle = KREResourceLoader.shared.resourceBundle()
    var viewDelegate: userValidationDelegate?
    var dataString: String!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var bgV: UIView!
    @IBOutlet weak var errorLbl: UILabel!
    @IBOutlet weak var underToplineLbl: UILabel!
    @IBOutlet weak var tabV: UITableView!
    var submitBtn: UIButton!
    var submitBtnTitle = "Submit"
    var arrayOfFields = [FormFields]()
    var arrayOfTextFieldsText = NSMutableArray()
    var templateLanguage:String?
    var isWithOutCard = false
    var errorArray = NSMutableArray()
    
    @IBOutlet var scrollV: UIScrollView!
    @IBOutlet var bgVBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet var acoountNoV: UIView!
    @IBOutlet var accountnoLbl: UILabel!
    @IBOutlet var accountNoTF: UITextField!
    @IBOutlet var accountNoErrorLbl: UILabel!
    var accountNoErrorStr = ""
    
    @IBOutlet var cvvNoV: UIView!
    @IBOutlet var cvvnoLbl: UILabel!
    @IBOutlet var cvvNoTF: UITextField!
    @IBOutlet var cvvErrorLbl: UILabel!
    var cvvErrorStr = ""
    
    @IBOutlet var DOBV: UIView!
    @IBOutlet var DOBLbl: UILabel!
    @IBOutlet var DOBTF: UITextField!
    @IBOutlet var DOBErrorLbl: UILabel!
    var DOBErrorStr = ""
    
    @IBOutlet var userNameV: UIView!
    @IBOutlet var userNameLbl: UILabel!
    @IBOutlet var userNameTF: UITextField!
    @IBOutlet var UserNameErrorLbl: UILabel!
    var UserNameErrorStr = ""
    
    var isAccountText = false
    var isCVVText = false
    var isDOBText = false
    var isUserNameText = false
    @IBOutlet var cvvNoHeightConstarint: NSLayoutConstraint!
    @IBOutlet var cvvNoVtopConstarint: NSLayoutConstraint!
    
    @IBOutlet var cvvErrorLblHeightConstarint: NSLayoutConstraint!
    
    @IBOutlet var cvvErrorLblTopConstraint: NSLayoutConstraint!
    @IBOutlet var scrollViewContentHightConstraint: NSLayoutConstraint!
    @IBOutlet var submitbtn: UIButton!
    func scrollVSetUp(){
        acoountNoV.layer.borderWidth = 1.0
        acoountNoV.layer.cornerRadius = 4.0
        acoountNoV.layer.borderColor = UIColor.init(hexString: "#7C7C7C").cgColor
        acoountNoV.clipsToBounds = true
        accountnoLbl.font = UIFont(name: semiBoldCustomFont, size: 14.0)
        accountNoTF.textColor = .black
        accountNoTF.font = UIFont(name: regularCustomFont, size: 14.0)
        accountNoErrorLbl.font = UIFont(name: regularCustomFont, size: 12.0)
        accountNoErrorLbl.textColor = UIColor.init(hexString: "#B00020")
        accountNoErrorLbl.isHidden = true
        accountNoErrorLbl.text = ""
        
        cvvNoV.layer.borderWidth = 1.0
        cvvNoV.layer.cornerRadius = 4.0
        cvvNoV.layer.borderColor = UIColor.init(hexString: "#7C7C7C").cgColor
        cvvNoV.clipsToBounds = true
        cvvnoLbl.font = UIFont(name: semiBoldCustomFont, size: 14.0)
        cvvNoTF.textColor = .black
        cvvNoTF.font = UIFont(name: regularCustomFont, size: 14.0)
        cvvErrorLbl.font = UIFont(name: regularCustomFont, size: 12.0)
        cvvErrorLbl.textColor = UIColor.init(hexString: "#B00020")
        cvvErrorLbl.isHidden = true
        cvvErrorLbl.text = ""
        
        DOBV.layer.borderWidth = 1.0
        DOBV.layer.cornerRadius = 4.0
        DOBV.layer.borderColor = UIColor.init(hexString: "#7C7C7C").cgColor
        DOBV.clipsToBounds = true
        DOBLbl.font = UIFont(name: semiBoldCustomFont, size: 14.0)
        DOBTF.textColor = .black
        DOBTF.font = UIFont(name: regularCustomFont, size: 14.0)
        DOBErrorLbl.font = UIFont(name: regularCustomFont, size: 12.0)
        DOBErrorLbl.textColor = UIColor.init(hexString: "#B00020")
        DOBErrorLbl.isHidden = true
        DOBErrorLbl.text = ""
        
        userNameV.layer.borderWidth = 1.0
        userNameV.layer.cornerRadius = 4.0
        userNameV.layer.borderColor = UIColor.init(hexString: "#7C7C7C").cgColor
        userNameV.clipsToBounds = true
        userNameLbl.font = UIFont(name: semiBoldCustomFont, size: 14.0)
        userNameTF.textColor = .black
        userNameTF.font = UIFont(name: regularCustomFont, size: 14.0)
        UserNameErrorLbl.font = UIFont(name: regularCustomFont, size: 12.0)
        UserNameErrorLbl.textColor = UIColor.init(hexString: "#B00020")
        UserNameErrorLbl.isHidden = true
        UserNameErrorLbl.text = ""
        
        submitbtn.setTitle(submitBtnTitle, for: .normal)
        submitbtn.titleLabel?.font = UIFont(name: semiBoldCustomFont, size: 14.0)
        submitbtn.titleLabel?.textColor = UIColor.white
        submitbtn.backgroundColor = themeColor
        submitbtn.layer.cornerRadius = 4.0
        submitbtn.clipsToBounds = true
        submitbtn.alpha = 0.5
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        scrollVSetUp()
        
        underToplineLbl.layer.cornerRadius = 3.0
        underToplineLbl.clipsToBounds = true
        if #available(iOS 15.0, *) {
            tabV.sectionHeaderTopPadding = 0.0
        } else {
            // Fallback on earlier versions
        }
        let bundle = KREResourceLoader.shared.resourceBundle()
        tabV.register(UINib.init(nibName: "UserValidationCell", bundle: bundle), forCellReuseIdentifier: "UserValidationCell")
        titleLbl.font = UIFont(name: semiBoldCustomFont, size: 22.0)
        errorLbl.font = UIFont(name: regularCustomFont, size: 12.0)
        
        getData()
        if #available(iOS 11.0, *) {
            self.bgV.roundCorners([ .layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 15.0, borderColor: UIColor.lightGray, borderWidth: 0)
        } else {
            // Fallback on earlier versions
        }
        errorLbl.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
       
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: notification handlers
    @objc func keyboardWillShow(_ notification: Notification) {
        let keyboardUserInfo: NSDictionary = NSDictionary(dictionary: (notification as NSNotification).userInfo!)
        let keyboardFrameEnd: CGRect = ((keyboardUserInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue?)!.cgRectValue)
        let options = UIView.AnimationOptions(rawValue: UInt((keyboardUserInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16))
        let durationValue = keyboardUserInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber
        let duration = durationValue.doubleValue
        
        var keyboardHeight = keyboardFrameEnd.size.height;
        if #available(iOS 11.0, *) {
            keyboardHeight -= self.view.safeAreaInsets.bottom
        } else {
            // Fallback on earlier versions
        };
        if !isWithOutCard{
            self.scrollViewContentHightConstraint.constant = 150.0
        }else{
            self.scrollViewContentHightConstraint.constant = 50.0
        }
        
            self.bgVBottomConstraint.constant = 10 - keyboardHeight - 10
        //self.scrollV.contentSize = CGSize(width: self.view.frame.size.width - 48, height: 700)
       
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            self.view.layoutIfNeeded()
        }, completion: { (Bool) in
            
        })
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        let keyboardUserInfo: NSDictionary = NSDictionary(dictionary: (notification as NSNotification).userInfo!)
        let durationValue = keyboardUserInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber
        let duration = durationValue.doubleValue
        let options = UIView.AnimationOptions(rawValue: UInt((keyboardUserInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16))
       
            self.bgVBottomConstraint.constant = 0
        self.scrollViewContentHightConstraint.constant = 0.0
        //self.scrollV.contentSize = CGSize(width: self.view.frame.size.width - 48, height: 0)
        
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            self.view.layoutIfNeeded()
        }, completion: { (Bool) in
            
        })
    }
    
    func dateOfBirthValidation(dateString: String, withFormat format: String) -> String? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd/MM/yyyy"

        if let date = inputFormatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = format
            return outputFormatter.string(from: date)
        }
        return nil
    }
    
    // MARK: init
    init(dataString: String) {
        super.init(nibName: "UserValidationViewController", bundle: bundle)
        self.dataString = dataString
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func closeBtnAct(_ sender: Any) {
        self.view.endEditing(true)
        self.viewDelegate?.optionsButtonTapNewAction(text: "cancel", payload: "cancel")
        self.dismiss(animated: true, completion: nil)
    }
    
    func getData(){
        let jsonDic: NSDictionary = Utilities.jsonObjectFromString(jsonString: dataString!) as! NSDictionary
        print(jsonDic)
        let title = jsonDic["heading"] as? String
        submitBtnTitle = jsonDic["submit_button"] as? String ?? "Submit"
        let arrayOfElements = NSMutableArray()
        if let formDetailsDic = jsonDic["form_details"] as? [String:Any]{
            if let cardDetails = formDetailsDic["cardDetails"] as? [String: Any]{
                arrayOfElements.add(cardDetails)
            }
            isWithOutCard = false
            if let cvvDetails = formDetailsDic["cvvDetails"] as? [String: Any]{
                arrayOfElements.add(cvvDetails)
            }else{
                isWithOutCard = true
            }
            if let birthDate = formDetailsDic["birthDate"] as? [String: Any]{
                arrayOfElements.add(birthDate)
            }
            if let username = formDetailsDic["username"] as? [String: Any]{
                arrayOfElements.add(username)
            }
        }
        print(arrayOfElements)

        let form_fieldsDic = NSMutableDictionary()
        form_fieldsDic.setObject(arrayOfElements, forKey: "form_fields" as NSCopying)
        form_fieldsDic.setObject("user_validation_template", forKey: "template_type" as NSCopying)
        form_fieldsDic.setObject(title ?? "", forKey: "heading" as NSCopying)
        
        let jsonDecoder = JSONDecoder()
        guard let jsonData = try? JSONSerialization.data(withJSONObject: form_fieldsDic as Any , options: .prettyPrinted),
              let allItems = try? jsonDecoder.decode(Componentss.self, from: jsonData) else {
            return
        }
        print(allItems)
        templateLanguage = allItems.lang ?? default_language
        
        titleLbl.text = title
        
        arrayOfFields = allItems.form_fields ?? []
        arrayOfTextFieldsText = []
        for _ in 0..<arrayOfFields.count{
            arrayOfTextFieldsText.add("")
            errorArray.add(true)
        }
        
        
        for i in 0..<arrayOfElements.count {
            let fields = arrayOfFields[i]
            if !isWithOutCard{
                cvvNoHeightConstarint.constant = 74.0
                cvvNoV.isHidden = false
                if i == 0{
                    if let required = fields.requireds, required == true{
                        let str = "\(fields.label ?? "") *"
                        let range = (str as NSString).range(of: "*")
                        let attributedString = NSMutableAttributedString(string: str)
                        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: themeColor, range: range)
                        accountnoLbl.attributedText = attributedString
                    }else{
                        accountnoLbl.text = fields.label
                    }
                    
                    if let errorMsg = fields.errorMessage{
                        //accountNoErrorLbl.text = errorMsg
                        accountNoErrorStr = errorMsg
                    }
                    accountNoTF.placeholder = fields.placeholder
                    accountNoTF.tag = i
                    accountNoTF.keyboardType = .numberPad
                }else if i == 1{
                    if let required = fields.requireds, required == true{
                        let str = "\(fields.label ?? "") *"
                        let range = (str as NSString).range(of: "*")
                        let attributedString = NSMutableAttributedString(string: str)
                        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: themeColor, range: range)
                        cvvnoLbl.attributedText = attributedString
                    }else{
                        cvvnoLbl.text = fields.label
                    }
                    
                    if let errorMsg = fields.errorMessage{
                        //cvvErrorLbl.text = errorMsg
                        cvvErrorStr = errorMsg
                    }
                    cvvNoTF.placeholder = fields.placeholder
                    cvvNoTF.tag = i
                    cvvNoTF.keyboardType = .numberPad
                }else if i == 2{
                    if let required = fields.requireds, required == true{
                        let str = "\(fields.label ?? "") *"
                        let range = (str as NSString).range(of: "*")
                        let attributedString = NSMutableAttributedString(string: str)
                        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: themeColor, range: range)
                        DOBLbl.attributedText = attributedString
                    }else{
                        DOBLbl.text = fields.label
                    }
                    
                    if let errorMsg = fields.errorMessage{
                        //DOBErrorLbl.text = errorMsg
                        DOBErrorStr = errorMsg
                    }
                    DOBTF.placeholder = fields.placeholder
                    DOBTF.placeholder = "DD/MM/YYYY"
                    DOBTF.tag = i
                    DOBTF.keyboardType = .default
                }else if i == 3{
                    if let required = fields.requireds, required == true{
                        let str = "\(fields.label ?? "") *"
                        let range = (str as NSString).range(of: "*")
                        let attributedString = NSMutableAttributedString(string: str)
                        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: themeColor, range: range)
                        userNameLbl.attributedText = attributedString
                    }else{
                        userNameLbl.text = fields.label
                    }
                    
                    if let errorMsg = fields.errorMessage{
                       // UserNameErrorLbl.text = errorMsg
                        UserNameErrorStr = errorMsg
                    }
                    userNameTF.placeholder = fields.placeholder
                    userNameTF.tag = i
                    userNameTF.keyboardType = .default
                }
            }else{
                cvvNoV.isHidden = true
                cvvNoHeightConstarint.constant = 0.0
                cvvErrorLblHeightConstarint.constant = 0.0
                cvvNoVtopConstarint.constant = 0.0
                cvvErrorLblTopConstraint.constant = 0.0
                if i == 0{
                    if let required = fields.requireds, required == true{
                        let str = "\(fields.label ?? "") *"
                        let range = (str as NSString).range(of: "*")
                        let attributedString = NSMutableAttributedString(string: str)
                        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: themeColor, range: range)
                        accountnoLbl.attributedText = attributedString
                    }else{
                        accountnoLbl.text = fields.label
                    }
                    
                    if let errorMsg = fields.errorMessage{
                        //accountNoErrorLbl.text = errorMsg
                        accountNoErrorStr = errorMsg
                    }
                    accountNoTF.placeholder = fields.placeholder
                    accountNoTF.tag = i
                    accountNoTF.keyboardType = .numberPad
                }else if i == 10{
                    if let required = fields.requireds, required == true{
                        let str = "\(fields.label ?? "") *"
                        let range = (str as NSString).range(of: "*")
                        let attributedString = NSMutableAttributedString(string: str)
                        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: themeColor, range: range)
                        cvvnoLbl.attributedText = attributedString
                    }else{
                        cvvnoLbl.text = fields.label
                    }
                    
                    if let errorMsg = fields.errorMessage{
                        //cvvErrorLbl.text = errorMsg
                        cvvErrorStr = errorMsg
                    }
                    cvvNoTF.placeholder = fields.placeholder
                    cvvNoTF.tag = i
                    cvvNoTF.keyboardType = .numberPad
                }else if i == 1{
                    if let required = fields.requireds, required == true{
                        let str = "\(fields.label ?? "") *"
                        let range = (str as NSString).range(of: "*")
                        let attributedString = NSMutableAttributedString(string: str)
                        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: themeColor, range: range)
                        DOBLbl.attributedText = attributedString
                    }else{
                        DOBLbl.text = fields.label
                    }
                    
                    if let errorMsg = fields.errorMessage{
                        //DOBErrorLbl.text = errorMsg
                        DOBErrorStr = errorMsg
                    }
                    DOBTF.placeholder = fields.placeholder
                    DOBTF.placeholder = "DD/MM/YYYY"
                    DOBTF.tag = i
                    DOBTF.keyboardType = .default
                }else if i == 2{
                    if let required = fields.requireds, required == true{
                        let str = "\(fields.label ?? "") *"
                        let range = (str as NSString).range(of: "*")
                        let attributedString = NSMutableAttributedString(string: str)
                        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: themeColor, range: range)
                        userNameLbl.attributedText = attributedString
                    }else{
                        userNameLbl.text = fields.label
                    }
                    
                    if let errorMsg = fields.errorMessage{
                       // UserNameErrorLbl.text = errorMsg
                        UserNameErrorStr = errorMsg
                    }
                    userNameTF.placeholder = fields.placeholder
                    userNameTF.tag = i
                    userNameTF.keyboardType = .default
                }
            }
            
        }
        
        tabV.reloadData()
        
        
    }
    
    
    @IBAction func submitBtnAct(_ sender: Any) {
        
        let  payloadDic = NSMutableDictionary()
        if !isWithOutCard{
            payloadDic.setObject("\(accountNoTF.text ?? "")", forKey: "cardnumber" as NSCopying)
            payloadDic.setObject("\(cvvNoTF.text ?? "")", forKey: "cvv" as NSCopying)
            payloadDic.setObject("\(DOBTF.text ?? "")", forKey: "birthdate" as NSCopying)
            payloadDic.setObject("\(userNameTF.text ?? "")", forKey: "username" as NSCopying)
        }else{
            payloadDic.setObject("\(accountNoTF.text ?? "")", forKey: "cardnumber" as NSCopying)
            payloadDic.setObject("\(DOBTF.text ?? "")", forKey: "birthdate" as NSCopying)
            payloadDic.setObject("\(userNameTF.text ?? "")", forKey: "username" as NSCopying)
        }
        let jsonStr = jsonToString(json: payloadDic)
            self.view.endEditing(true)
            self.dismiss(animated: true, completion: nil)
            //self.viewDelegate?.optionsButtonTapNewAction(text: "Address updated successfully", payload: jsonStr)
            var removeStr = jsonStr.replacingOccurrences(of: "\\", with: "")
            removeStr = removeStr.replacingOccurrences(of: "\n", with: "")
            self.viewDelegate?.sendSlientMessageTobot(text: removeStr)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    @objc fileprivate func submitButtonAction(_ sender: AnyObject!) {
        //print("Submit \(arrayOfTextFieldsText)")
        var finalString = ""
        var isempty:Bool = false
        
        let  payloadDic = NSMutableDictionary()
        for i in 0..<arrayOfTextFieldsText.count{
            let textStr = arrayOfTextFieldsText[i] as? String
            let arrayOfFields = arrayOfFields[i]
            let requiredAddress =  arrayOfFields.requireds ?? false
            if let isSecure = arrayOfFields.requireds, isSecure{
                if arrayOfTextFieldsText[i] as! String == "" &&  requiredAddress == true{
                    isempty = true
                    showErrorLbl(message: arrayOfFields.errorMessage ?? "")
                    break
                }else{
                    
                    //finalString.append("\(textStr!) ")
                }
            }else{
                //finalString.append("\(textStr!) ")
            }
            
            if !isWithOutCard{
                if i == 0{
                    payloadDic.setObject("\(textStr!)", forKey: "cardnumber" as NSCopying)
                    if textStr?.count != 16{
                        isempty = true
                        showErrorLbl(message: arrayOfFields.errorMessage ?? "")
                        break
                    }
                }else if i == 1{
                    payloadDic.setObject("\(textStr!)", forKey: "cvv" as NSCopying)
                    if textStr?.count != 3{
                        isempty = true
                        showErrorLbl(message: arrayOfFields.errorMessage ?? "")
                        break
                    }
                }else if i == 2{
                    payloadDic.setObject("\(textStr!)", forKey: "birthdate" as NSCopying)
                    let DOBStr = dateOfBirthValidation(dateString: textStr!, withFormat: "dd/MM/yyyy")
                    if DOBStr == nil{
                        isempty = true
                        showErrorLbl(message: arrayOfFields.errorMessage ?? "")
                        break
                    }
                    
                }else if i == 3{
                    payloadDic.setObject("\(textStr!)", forKey: "username" as NSCopying)
                }
            }else{
                if i == 0{
                    payloadDic.setObject("\(textStr!)", forKey: "cardnumber" as NSCopying)
                    if textStr?.count == 12 || textStr?.count == 9{
                        
                    }else{
                        isempty = true
                        showErrorLbl(message: arrayOfFields.errorMessage ?? "")
                        break
                    }
                }else if i == 1{
                    payloadDic.setObject("\(textStr!)", forKey: "birthdate" as NSCopying)
                    let DOBStr = dateOfBirthValidation(dateString: textStr!, withFormat: "dd/MM/yyyy")
                    if DOBStr == nil{
                        isempty = true
                        showErrorLbl(message: arrayOfFields.errorMessage ?? "")
                        break
                    }
                    
                }else if i == 2{
                    payloadDic.setObject("\(textStr!)", forKey: "username" as NSCopying)
                }
            }
            
            
        }
        let jsonStr = jsonToString(json: payloadDic)
        if isempty == false{
            self.view.endEditing(true)
            self.dismiss(animated: true, completion: nil)
            //self.viewDelegate?.optionsButtonTapNewAction(text: "Address updated successfully", payload: jsonStr)
            var removeStr = jsonStr.replacingOccurrences(of: "\\", with: "")
            removeStr = removeStr.replacingOccurrences(of: "\n", with: "")
            self.viewDelegate?.sendSlientMessageTobot(text: removeStr)
        }else{
            //            showErrorLbl(message: "Please enter required feilds.")
        }
    }
    
    func jsonToString(json: AnyObject) -> String{
        do {
            let data1 = try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted)
            let convertedString = String(data: data1, encoding: String.Encoding.utf8) as NSString? ?? ""
            //debugPrint(convertedString)
            return convertedString as String
        } catch _ {
            //debugPrint(myJSONError)
            return ""
        }
    }
    
    func showErrorLbl(message:String){
//        errorLbl.text = message
//        errorLbl.isHidden = false
//        Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { (_) in
//            self.errorLbl.isHidden = true
//        }
        NotificationCenter.default.post(name: Notification.Name(pdfcTemplateViewErrorNotification), object: message)
    }
    
}

extension UserValidationViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfFields.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserValidationCell") as! UserValidationCell
        cell.selectionStyle = .none
        
        cell.bgVTF.layer.borderWidth = 1.0
        cell.bgVTF.layer.cornerRadius = 4.0
        cell.bgVTF.layer.borderColor = UIColor.init(hexString: "#738794").cgColor
        cell.bgVTF.clipsToBounds = true
        cell.bgVTF.backgroundColor = UIColor(red: 0.973, green: 0.976, blue: 0.988, alpha: 1)
        
        cell.addressTF.font = UIFont(name: regularCustomFont, size: 14.0)
        cell.titleLbl.font = UIFont(name: semiBoldCustomFont, size: 14.0)
        
        cell.addressTF.isUserInteractionEnabled = true
        let fields = arrayOfFields[indexPath.row]
        if let required = fields.requireds, required == true{
            let str = "\(fields.label ?? "") *"
            let range = (str as NSString).range(of: "*")
            let attributedString = NSMutableAttributedString(string: str)
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: themeColor, range: range)
            cell.titleLbl.attributedText = attributedString
        }else{
            cell.titleLbl.text = fields.label
        }
        
        if let errorMsg = fields.errorMessage{
            if errorArray[indexPath.row] as? Bool == true{
                cell.errorLbl.text = ""
            }else{
                cell.errorLbl.text = errorMsg
            }
            
        }
        
        cell.addressTF.placeholder = fields.placeholder
        cell.addressTF.text = arrayOfTextFieldsText[indexPath.row] as? String
        
        cell.addressTF.delegate = self
        cell.addressTF.text = arrayOfTextFieldsText[indexPath.row] as? String
        cell.addressTF.addTarget(self, action: #selector(valueChanged), for: .editingChanged)
        cell.addressTF.tag = indexPath.row
        cell.addressTF.translatesAutoresizingMaskIntoConstraints = false
        
    
        
//        if fields.label == "CVV" || fields.label == "Credit or Debit Card Number"{
//            cell.addressTF.keyboardType = .numberPad
//        }else if fields.label == "Date of Birth" {
//            cell.addressTF.placeholder = "DD/MM/YYYY"
//            cell.addressTF.keyboardType = .default
//        }
//        else{
//            cell.addressTF.keyboardType = .default
//        }
        
        cell.addressTF.placeholder = ""
        cell.addressTF.tag = indexPath.row
        
        if !isWithOutCard{
            
        }else{
            if indexPath.row == 0{
                cell.addressTF.keyboardType = .numberPad
            }else if indexPath.row == 1{
                cell.addressTF.placeholder = "DD/MM/YYYY"
                cell.addressTF.keyboardType = .default
            }else if indexPath.row == 2{
                cell.addressTF.keyboardType = .default
            }
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 35
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .white
        submitBtn = UIButton(frame: CGRect.zero)
        submitBtn.backgroundColor = themeColor
        submitBtn.translatesAutoresizingMaskIntoConstraints = false
        submitBtn.clipsToBounds = true
        submitBtn.layer.cornerRadius = 5
        submitBtn.setTitleColor(.white, for: .normal)
        submitBtn.setTitleColor(Common.UIColorRGB(0x999999), for: .disabled)
        submitBtn.titleLabel?.font = UIFont(name: mediumCustomFont, size: 12.0)
        view.addSubview(submitBtn)
        submitBtn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
        submitBtn.addTarget(self, action: #selector(self.submitButtonAction(_:)), for: .touchUpInside)
        submitBtn.setTitle(submitBtnTitle, for: .normal)
        submitBtn.layer.borderWidth = 1
        submitBtn.layer.borderColor = themeColor.cgColor
        
        let views: [String: UIView] = ["submitBtn": submitBtn]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[submitBtn(\(35))]", options:[], metrics:nil, views:views))
         if (templateLanguage?.caseInsensitiveCompare(preferred_language_Type) == .orderedSame){
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[submitBtn(\(130))]" , options:[], metrics:nil, views:views))
        }else{
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[submitBtn(\(100))]-0-|", options:[], metrics:nil, views:views))
        }
        return view
    }
    
    @objc func valueChanged(_ textField: UITextField){
        arrayOfTextFieldsText.replaceObject(at: textField.tag, with: textField.text ?? "")
    }
}
extension UserValidationViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var maxLength = 40
        let currentString = (textField.text ?? "") as NSString
        let newString = currentString.replacingCharacters(in: range, with: string)
        
        if !isWithOutCard{
            if textField.tag == 0{
                maxLength = 16
                if maxLength > newString.count{
                    accountNoErrorLbl.isHidden = false
                    accountNoErrorLbl.text = accountNoErrorStr
                    isAccountText = false
                }else{
                   accountNoErrorLbl.isHidden = true
                    accountNoErrorLbl.text = ""
                    isAccountText = true
                }
                if (string == " ") {
                    return false
                }
            }else if textField.tag == 1{
                maxLength = 3
                if maxLength > newString.count{
                    cvvErrorLbl.isHidden = false
                    cvvErrorLbl.text = cvvErrorStr
                    isCVVText = false
                }else{
                    cvvErrorLbl.isHidden = true
                    cvvErrorLbl.text = ""
                    isCVVText = true
                }
                if (string == " ") {
                    return false
                }
            }else if textField.tag == 2{
                maxLength = 10
                if maxLength > newString.count{
                    DOBErrorLbl.isHidden = false
                    DOBErrorLbl.text = DOBErrorStr
                    isDOBText = false
                }else{
                    let DOBStr = dateOfBirthValidation(dateString: newString, withFormat: "dd/MM/yyyy")
                    if DOBStr == nil{
                        DOBErrorLbl.isHidden = false
                        DOBErrorLbl.text = DOBErrorStr
                        isDOBText = false
                    }else{
                        DOBErrorLbl.isHidden = true
                        DOBErrorLbl.text = ""
                        isDOBText = true
                    }
                    
                }
                if (string == " ") {
                    return false
                }
            }else if textField.tag == 3{
                if 1 > newString.count{
                    UserNameErrorLbl.isHidden = false
                    UserNameErrorLbl.text = UserNameErrorStr
                    isUserNameText = false
                }else{
                    UserNameErrorLbl.isHidden = true
                    UserNameErrorLbl.text = ""
                    isUserNameText = true
                }
                if (string == " ") {
                    return false
                }
            }
            
            if isAccountText == true &&  isCVVText == true && isDOBText == true && isUserNameText == true{
                submitbtn.alpha = 1.0
            }else{
                submitbtn.alpha = 0.5
            }
            
        }else{
            if textField.tag == 0{
                maxLength = 12
                if maxLength > newString.count{
                    if newString.count == 9{
                        accountNoErrorLbl.isHidden = true
                         accountNoErrorLbl.text = ""
                         isAccountText = true
                    }else{
                        accountNoErrorLbl.isHidden = false
                        accountNoErrorLbl.text = accountNoErrorStr
                        isAccountText = false
                    }
                    
                }else{
                   accountNoErrorLbl.isHidden = true
                    accountNoErrorLbl.text = ""
                    isAccountText = true
                }
                if (string == " ") {
                    return false
                }
            }else if textField.tag == 1{
                maxLength = 10
                if maxLength > newString.count{
                    DOBErrorLbl.isHidden = false
                    DOBErrorLbl.text = DOBErrorStr
                    isDOBText = false
                }else{
                    let DOBStr = dateOfBirthValidation(dateString: newString, withFormat: "dd/MM/yyyy")
                    if DOBStr == nil{
                        DOBErrorLbl.isHidden = false
                        DOBErrorLbl.text = DOBErrorStr
                        isDOBText = false
                    }else{
                        DOBErrorLbl.isHidden = true
                        DOBErrorLbl.text = ""
                        isDOBText = true
                    }
                    
                }
                if (string == " ") {
                    return false
                }
            }else if textField.tag == 2{
                if 1 > newString.count{
                    UserNameErrorLbl.isHidden = false
                    UserNameErrorLbl.text = UserNameErrorStr
                    isUserNameText = false
                }else{
                    UserNameErrorLbl.isHidden = true
                    UserNameErrorLbl.text = ""
                    isUserNameText = true
                }
                if (string == " ") {
                    return false
                }
            }
            
            if isAccountText == true && isDOBText == true && isUserNameText == true{
                submitbtn.alpha = 1.0
            }else{
                submitbtn.alpha = 0.5
            }
            
        }
        return newString.count <= maxLength
    }
}
