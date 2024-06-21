//
//  ResetPasswordVC.swift
//  KoreBotSDKFrameWork
//
//  Created by Kartheek Pagidimarri on 09/01/23.
//  Copyright © 2023 Kartheek.Pagidimarri. All rights reserved.
//

import UIKit
protocol resetPasswordDelegate {
    func optionsButtonTapNewAction(text:String, payload:String)
}
class ResetPasswordVC: UIViewController {
    let bundle = KREResourceLoader.shared.resourceBundle()
    var viewDelegate: resetPasswordDelegate?
    var dataString: String!
    
    
    @IBOutlet weak var headingLbl: UILabel!
    @IBOutlet weak var passwordBgV: UIView!
    @IBOutlet weak var reEnterPasswordBgV: UIView!
    
    @IBOutlet var oldPasswordBgv: UIView!
    @IBOutlet var oldPasswordTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var reEnterPasswordTF: UITextField!
    
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var errorLbl: UILabel!
    
    @IBOutlet weak var bgV: UIView!
    @IBOutlet weak var infoView: UIView!
    
    @IBOutlet weak var infoSubV: UIView!
    
    @IBOutlet weak var infoHeadingLbl: UILabel!
    
    @IBOutlet var hideOldPasswordBtn: UIButton!
    @IBOutlet var hidePasswordBtn: UIButton!
    @IBOutlet var hideRePasswordBtn: UIButton!
    
    @IBOutlet weak var infoDescLbl: UILabel!
    @IBOutlet weak var tableV: UITableView!
    var errorMessage = "Pin Miss match"
    var warningMessage = "Pin Miss match"
    
    @IBOutlet var oldPwdLbl: UILabel!
    @IBOutlet var newPwdLbl: UILabel!
    @IBOutlet var rePwdLbl: UILabel!
    
    var infoArray = [String]()
    
    @IBOutlet var passwordValidationView: UIView!
    
    @IBOutlet var passwordValidationVHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var passwordValidationTopConstraint: NSLayoutConstraint!
    
    @IBOutlet var validationLbl1: UILabel!
    @IBOutlet var validationImg1: UIImageView!
    
    @IBOutlet var validationLbl2: UILabel!
    @IBOutlet var validationImg2: UIImageView!
    
    @IBOutlet var validationLbl3: UILabel!
    
    @IBOutlet var validationImg3: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        submitBtn.isUserInteractionEnabled = false
        validationLbl1.text = "1 lowercase character"
        validationLbl1.font = UIFont(name: regularCustomFont, size: 12.0)
        validationLbl2.text = "1 numeric character"
        validationLbl2.font = UIFont(name: regularCustomFont, size: 12.0)
        validationLbl3.text = "Between 8 & 20 characters"
        validationLbl3.font = UIFont(name: regularCustomFont, size: 12.0)
        
        oldPwdLbl.font = UIFont(name: semiBoldCustomFont, size: 14.0)
        newPwdLbl.font = UIFont(name: semiBoldCustomFont, size: 14.0)
        rePwdLbl.font = UIFont(name: semiBoldCustomFont, size: 14.0)
        
        // Do any additional setup after loading the view.
        oldPasswordBgv.layer.borderWidth = 1.0
        oldPasswordBgv.layer.cornerRadius = 4.0
        oldPasswordBgv.layer.borderColor = UIColor.init(hexString: "#738794").cgColor
        oldPasswordBgv.clipsToBounds = true
        
        passwordBgV.layer.borderWidth = 1.0
        passwordBgV.layer.cornerRadius = 4.0
        passwordBgV.layer.borderColor = UIColor.init(hexString: "#738794").cgColor
        passwordBgV.clipsToBounds = true
        
        reEnterPasswordBgV.layer.borderWidth = 1.0
        reEnterPasswordBgV.layer.cornerRadius = 4.0
        reEnterPasswordBgV.layer.borderColor = UIColor.init(hexString: "#738794").cgColor
        reEnterPasswordBgV.clipsToBounds = true
        
        oldPasswordTF.font = UIFont(name: regularCustomFont, size: 14.0)
        passwordTF.font = UIFont(name: regularCustomFont, size: 14.0)
        reEnterPasswordTF.font = UIFont(name: regularCustomFont, size: 14.0)
        oldPasswordTF.textColor = .black
        passwordTF.textColor = .black
        reEnterPasswordTF.textColor = .black
        
        submitBtn.titleLabel?.font = UIFont(name: semiBoldCustomFont, size: 14.0)
        submitBtn.titleLabel?.textColor = UIColor.white
        submitBtn.backgroundColor = themeColor
        submitBtn.layer.cornerRadius = 4.0
        submitBtn.clipsToBounds = true
        submitBtn.alpha = 0.5
        
        errorLbl.isHidden = true
        infoView.isHidden = false
        if #available(iOS 11.0, *) {
            self.bgV.roundCorners([ .layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 15.0, borderColor: UIColor.lightGray, borderWidth: 0)
            self.infoSubV.roundCorners([ .layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 15.0, borderColor: UIColor.lightGray, borderWidth: 0)
        }
        
        infoHeadingLbl.font = UIFont(name: semiBoldCustomFont, size: 22.0)
        infoDescLbl.font = UIFont(name: regularCustomFont, size: 14.0)
        
        tableV.register(UINib.init(nibName: "ResetPasswordCell", bundle: bundle), forCellReuseIdentifier: "ResetPasswordCell")
        
        getData()
    }
    
    func getData(){
        let jsonDic: NSDictionary = Utilities.jsonObjectFromString(jsonString: dataString!) as! NSDictionary
        print(jsonDic)
        let title = jsonDic["title"] as? String
        let enterpinPlaceholder = jsonDic["enterTitle"] as? String
        let renterPinPlaceholder = jsonDic["reEnterTitle"] as? String
        let oldPasswordPlaceholder = jsonDic["oldTitle"] as? String
        errorMessage = jsonDic["errorMessage"] as? String ?? "No two consecutive numbers should not be same"
        warningMessage = jsonDic["warningMessage"] as? String ?? "No two consecutive numbers should not be same"
        headingLbl.text = title
        
        oldPwdLbl.text = oldPasswordPlaceholder
        newPwdLbl.text = enterpinPlaceholder
        rePwdLbl.text = renterPinPlaceholder
        
        oldPasswordTF.placeholder = "Enter here"
        passwordTF.placeholder = "Enter here"
        reEnterPasswordTF.placeholder = "Enter here"
        if let btnTitle = jsonDic["submit_button"] as? String{
            submitBtn.setTitle(btnTitle, for: .normal)
        }
        
        if let infoDic = jsonDic["error_info_screen"] as? [String: Any]{
            if let infoTitle = infoDic["title"] as? String{
                infoHeadingLbl.text = infoTitle
            }
            if let infoDesc = infoDic["subtitle"] as? String{
                infoDescLbl.text = infoDesc
            }
            infoArray = infoDic["error_info"] as? Array ?? []
        }
        tableV.reloadData()
    }

    // MARK: init
    init(dataString: String) {
        super.init(nibName: "ResetPasswordVC", bundle: bundle)
        self.dataString = dataString
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func closeBtnAct(_ sender: Any) {
        self.view.endEditing(true)
        self.viewDelegate?.optionsButtonTapNewAction(text: "cancel", payload: "cancel")
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func submitBtnAct(_ sender: Any) {
        let oldPasswordTxt = oldPasswordTF.text
        let passwordTxt = passwordTF.text
        let reEnterPasswordTxt = reEnterPasswordTF.text
        if oldPasswordTxt?.count == 0{
            showErrorLbl(message: "Please enter old password")
        }
        else if passwordTxt?.count == 0 || reEnterPasswordTxt?.count == 0{
            showErrorLbl(message: errorMessage)
        }
        else if passwordTxt != reEnterPasswordTxt{
           showErrorLbl(message: warningMessage)
       }else{
           self.view.endEditing(true)
           let secureTxt = passwordTxt!.regEx()
           self.viewDelegate?.optionsButtonTapNewAction(text: secureTxt, payload: "\(oldPasswordTxt!) \(passwordTxt!)")
           self.dismiss(animated: true, completion: nil)
       }
    }
    
    func showErrorLbl(message:String){
        errorLbl.text = message
        errorLbl.isHidden = false
        Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { (_) in
            self.errorLbl.isHidden = true
        }
    }
    
    @IBAction func infoBtnAction(_ sender: Any) {
        self.view.endEditing(true)
        infoView.isHidden = false
    }
    
    @IBAction func infoCancelBtnAct(_ sender: Any) {
        infoView.isHidden = true
    }
    
    @IBAction func oldPasswordShowHideBtnAct(_ sender: UIButton) {
        if sender.isSelected{
            sender.isSelected = false
            hideOldPasswordBtn.setImage(UIImage(named: "hide", in: bundle, compatibleWith: nil), for: .normal)
            oldPasswordTF.isSecureTextEntry = true
        }else{
            sender.isSelected = true
            hideOldPasswordBtn.setImage(UIImage(named: "view", in: bundle, compatibleWith: nil), for: .normal)
            oldPasswordTF.isSecureTextEntry = false
        }
        
    }
    @IBAction func showHidePasswordBtnAct(_ sender: UIButton) {
        if sender.isSelected{
            sender.isSelected = false
            hidePasswordBtn.setImage(UIImage(named: "hide", in: bundle, compatibleWith: nil), for: .normal)
            passwordTF.isSecureTextEntry = true
        }else{
            sender.isSelected = true
            hidePasswordBtn.setImage(UIImage(named: "view", in: bundle, compatibleWith: nil), for: .normal)
            passwordTF.isSecureTextEntry = false
        }
        
    }
    
    @IBAction func reEnterShowHidePasswordBtnAct(_ sender: UIButton) {
        if sender.isSelected{
            sender.isSelected = false
            hideRePasswordBtn.setImage(UIImage(named: "hide", in: bundle, compatibleWith: nil), for: .normal)
            reEnterPasswordTF.isSecureTextEntry = true
        }else{
            sender.isSelected = true
            hideRePasswordBtn.setImage(UIImage(named: "view", in: bundle, compatibleWith: nil), for: .normal)
            reEnterPasswordTF.isSecureTextEntry = false
        }
    }
    
}

extension ResetPasswordVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infoArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResetPasswordCell") as! ResetPasswordCell
        cell.selectionStyle = .none
        cell.titleLbl.text = infoArray[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension ResetPasswordVC: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func validatePassword(_ password: String) -> Bool {
        print(password)
        //At least one digit
//        if password.range(of: #"\d+"#, options: .regularExpression) == nil {
//            return false
//        }
//        validationImg1.image = UIImage(named: "correct", in: bundle, compatibleWith: nil)
//
//        //At least one letter
//        if password.range(of: #"\p{Alphabetic}+"#, options: .regularExpression) == nil {
//            return false
//        }
//        validationImg2.image = UIImage(named: "correct", in: bundle, compatibleWith: nil)
//
//        //At least 8 characters
//        if password.count < 8 {
//            return false
//        }
//        validationImg3.image = UIImage(named: "correct", in: bundle, compatibleWith: nil)
//
////        //No whitespace charcters
////        if password.range(of: #"\s+"#, options: .regularExpression) != nil {
////            return false
////        }
////

        return true
    }
    

    func isValidPassword(_ password:String) -> Bool {

//       let nonUpperCase = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZ").inverted
//       let letters = password.components(separatedBy: nonUpperCase)
//       let strUpper: String = letters.joined()

        validationImg1.image = UIImage(named: "correctD", in: bundle, compatibleWith: nil)
        validationImg2.image = UIImage(named: "correctD", in: bundle, compatibleWith: nil)
        validationImg3.image = UIImage(named: "correctD", in: bundle, compatibleWith: nil)
        submitBtn.alpha = 0.5
        submitBtn.isUserInteractionEnabled = false
        var validCount = 0
        if(password.count > 7 && password.count <= 20) {
            validationImg3.image = UIImage(named: "correct", in: bundle, compatibleWith: nil)
            validCount = validCount + 1
        }
        
       let smallLetterRegEx  = ".*[a-z]+.*"
       let samlltest = NSPredicate(format:"SELF MATCHES %@", smallLetterRegEx)
       let smallresult = samlltest.evaluate(with: password)
        if smallresult{
            validationImg1.image = UIImage(named: "correct", in: bundle, compatibleWith: nil)
            validCount = validCount + 1
        }

       let numberRegEx  = ".*[0-9]+.*"
       let numbertest = NSPredicate(format:"SELF MATCHES %@", numberRegEx)
       let numberresult = numbertest.evaluate(with: password)
        
        if numberresult{
            validationImg2.image = UIImage(named: "correct", in: bundle, compatibleWith: nil)
            validCount = validCount + 1
        }

       let regex = try! NSRegularExpression(pattern: ".*[^A-Za-z0-9].*", options: NSRegularExpression.Options())
       var isSpecial :Bool = false
       if regex.firstMatch(in: password, options: NSRegularExpression.MatchingOptions(), range:NSMakeRange(0, password.count)) != nil {
        print("could not handle special characters")
           isSpecial = true
       }else{
           isSpecial = false
       }
       //return (strUpper.count >= 1) && smallresult && numberresult && isSpecial
        if validCount == 3{
            submitBtn.alpha = 1.0
            submitBtn.isUserInteractionEnabled = true
        }
        return smallresult && numberresult
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let maxLength = 20
        if (string == " ") {
             return false
        }
        let currentString = (textField.text ?? "") as NSString
        if textField == passwordTF{
            if let text = textField.text as NSString? {
                let txtAfterUpdate = text.replacingCharacters(in: range, with: string)
                if  txtAfterUpdate.count <= 20{
                    _ = isValidPassword(txtAfterUpdate )
                }
                
        }
           
        }
        let newString = currentString.replacingCharacters(in: range, with: string)
        return newString.count <= maxLength
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
            print("TextField did end editing method called\(textField.text!)")
        
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
            print("TextField should end editing method called")
            return true;
    }
}
