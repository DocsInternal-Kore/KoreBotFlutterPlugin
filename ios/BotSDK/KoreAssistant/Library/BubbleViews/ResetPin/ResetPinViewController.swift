//
//  ResetPinViewController.swift
//  KoreBotSDKFrameWork
//
//  Created by Kartheek.Pagidimarri on 14/07/22.
//  Copyright © 2022 Kartheek.Pagidimarri. All rights reserved.
//

import UIKit
protocol resetPinDelegate {
    func optionsButtonTapNewAction(text:String, payload:String)
}
class ResetPinViewController: UIViewController, UITextFieldDelegate {
    let bundle = KREResourceLoader.shared.resourceBundle()
    var viewDelegate: resetPinDelegate?
    var dataString: String!
    @IBOutlet weak var HeadingLbl: UILabel!
    @IBOutlet weak var bgV: UIView!
    @IBOutlet weak var errorLbl: UILabel!
    
    @IBOutlet weak var enterPinlbl: UILabel!
    @IBOutlet weak var reEnterPinLbl: UILabel!
    
    @IBOutlet weak var firstTF: UITextField!
    @IBOutlet weak var secondTF: UITextField!
    @IBOutlet weak var thirdTF: UITextField!
    @IBOutlet weak var foruthTF: UITextField!
    
    @IBOutlet weak var firstTFre: UITextField!
    @IBOutlet weak var secondTFre: UITextField!
    @IBOutlet weak var thirdTFre: UITextField!
    @IBOutlet weak var foruthTFre: UITextField!
    var textfeildViews = "EnterPinV"
    var errorMessage = "Pin mismatch"
    var WarningMessage = "Pin mismatch"
    
    @IBOutlet weak var underToplineLbl: UILabel!
    
    
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var infoSubV: UIView!
    @IBOutlet weak var infoHeadingLbl: UILabel!
    @IBOutlet weak var infoDescLbl: UILabel!
    @IBOutlet weak var tableV: UITableView!
    var infoArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        underToplineLbl.layer.cornerRadius = 3.0
        underToplineLbl.clipsToBounds = true
        
        HeadingLbl.font = UIFont(name: boldCustomFont, size: 22.0)
        enterPinlbl.font = UIFont(name: regularCustomFont, size: 14.0)
        reEnterPinLbl.font = UIFont(name: regularCustomFont, size: 14.0)
        errorLbl.font = UIFont(name: semiBoldCustomFont, size: 14.0)
        errorLbl.textColor = themeColor
        
        firstTF.font = UIFont(name: semiBoldCustomFont, size: 20.0)
        secondTF.font = UIFont(name: semiBoldCustomFont, size: 20.0)
        thirdTF.font = UIFont(name: semiBoldCustomFont, size: 20.0)
        foruthTF.font = UIFont(name: semiBoldCustomFont, size: 20.0)
        
        firstTFre.font = UIFont(name: semiBoldCustomFont, size: 20.0)
        secondTFre.font = UIFont(name: semiBoldCustomFont, size: 20.0)
        thirdTFre.font = UIFont(name: semiBoldCustomFont, size: 20.0)
        foruthTFre.font = UIFont(name: semiBoldCustomFont, size: 20.0)
        
        firstTF.layer.cornerRadius = 4.0
        firstTF.layer.borderWidth = 1.0
        firstTF.layer.borderColor = UIColor.init(hexString: "#738794").cgColor
        firstTF.backgroundColor = UIColor.init(hexString: "#FBFBFB")
        firstTF.clipsToBounds = true
        
        secondTF.layer.cornerRadius = 4.0
        secondTF.layer.borderWidth = 1.0
        secondTF.layer.borderColor = UIColor.init(hexString: "#738794").cgColor
        secondTF.backgroundColor = UIColor.init(hexString: "#FBFBFB")
        secondTF.clipsToBounds = true
        
        thirdTF.layer.cornerRadius = 4.0
        thirdTF.layer.borderWidth = 1.0
        thirdTF.layer.borderColor = UIColor.init(hexString: "#738794").cgColor
        thirdTF.backgroundColor = UIColor.init(hexString: "#FBFBFB")
        thirdTF.clipsToBounds = true
        
        foruthTF.layer.cornerRadius = 4.0
        foruthTF.layer.borderWidth = 1.0
        foruthTF.layer.borderColor = UIColor.init(hexString: "#738794").cgColor
        foruthTF.backgroundColor = UIColor.init(hexString: "#FBFBFB")
        foruthTF.clipsToBounds = true
        
        firstTFre.layer.cornerRadius = 4.0
        firstTFre.layer.borderWidth = 1.0
        firstTFre.layer.borderColor = UIColor.init(hexString: "#738794").cgColor
        firstTFre.backgroundColor = UIColor.init(hexString: "#FBFBFB")
        firstTFre.clipsToBounds = true
        
        secondTFre.layer.cornerRadius = 4.0
        secondTFre.layer.borderWidth = 1.0
        secondTFre.layer.borderColor = UIColor.init(hexString: "#738794").cgColor
        secondTFre.backgroundColor = UIColor.init(hexString: "#FBFBFB")
        secondTFre.clipsToBounds = true
        
        thirdTFre.layer.cornerRadius = 4.0
        thirdTFre.layer.borderWidth = 1.0
        thirdTFre.layer.borderColor = UIColor.init(hexString: "#738794").cgColor
        thirdTFre.backgroundColor = UIColor.init(hexString: "#FBFBFB")
        thirdTFre.clipsToBounds = true
        
        foruthTFre.layer.cornerRadius = 4.0
        foruthTFre.layer.borderWidth = 1.0
        foruthTFre.layer.borderColor = UIColor.init(hexString: "#738794").cgColor
        foruthTFre.backgroundColor = UIColor.init(hexString: "#FBFBFB")
        foruthTFre.clipsToBounds = true
        
        
        // Do any additional setup after loading the view.
        firstTF.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        secondTF.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        thirdTF.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        foruthTF.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        
        firstTFre.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        secondTFre.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        thirdTFre.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        foruthTFre.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        
       
        if #available(iOS 11.0, *) {
            self.bgV.roundCorners([ .layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 15.0, borderColor: UIColor.lightGray, borderWidth: 0)
            self.infoSubV.roundCorners([ .layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 15.0, borderColor: UIColor.lightGray, borderWidth: 0)
        } else {
            // Fallback on earlier versions
        }
        
        infoView.isHidden = false
        infoHeadingLbl.font = UIFont(name: semiBoldCustomFont, size: 22.0)
        infoDescLbl.font = UIFont(name: regularCustomFont, size: 14.0)
        
        tableV.register(UINib.init(nibName: "ResetPasswordCell", bundle: bundle), forCellReuseIdentifier: "ResetPasswordCell")
        errorLbl.isHidden = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        infoView.addGestureRecognizer(tap)
        
        getData()
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        // handling code
        infoView.isHidden = true
    }
    
    // MARK: init
    init(dataString: String) {
        super.init(nibName: "ResetPinViewController", bundle: bundle)
        self.dataString = dataString
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override func viewDidAppear(_ animated: Bool) {
        //firstTF.becomeFirstResponder()
    }
    @IBAction func closeBtnAct(_ sender: Any) {
        self.view.endEditing(true)
        self.viewDelegate?.optionsButtonTapNewAction(text: "cancel", payload: "cancel")
        self.dismiss(animated: true, completion: nil)
    }
    
    func getData(){
        let jsonDic: NSDictionary = Utilities.jsonObjectFromString(jsonString: dataString!) as! NSDictionary
        print(jsonDic)
        let title = jsonDic["title"] as? String
        let enterpin = jsonDic["enterPinTitle"] as? String
        let renterPin = jsonDic["reEnterPinTitle"] as? String
        WarningMessage = jsonDic["warningMessage"] as? String ?? "Pin mismatch"
        errorMessage = jsonDic["errorMessage"] as? String ?? "Do not use repetitive numbers like 1234 or 1111."
        HeadingLbl.text = title
        enterPinlbl.text = enterpin
        reEnterPinLbl.text = renterPin
        
        if let infoDic = jsonDic["error_info_screen"] as? [String: Any]{
            let infoTitle = infoDic["title"] as? String
            let infoDesc = infoDic["subtitle"] as? String
            infoHeadingLbl.text = infoTitle
            infoDescLbl.text = infoDesc
            infoArray = infoDic["error_info"] as? Array ?? []
        }
    }
    
   
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 1
        let currentString = (textField.text ?? "") as NSString
        let newString = currentString.replacingCharacters(in: range, with: string)
        
        return newString.count <= maxLength
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
            print("TextField did begin editing method called")
        if firstTF == textField || secondTF == textField || thirdTF == textField || foruthTF == textField{
            textfeildViews = "EnterPinV"
        }else{
            textfeildViews = "ReEnterPinV"
        }
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
            firstTF.layer.borderColor = UIColor.init(hexString: "#738794").cgColor
            firstTF.backgroundColor = UIColor.init(hexString: "#FBFBFB")
            firstTF.layer.borderWidth = 1.0
            secondTF.layer.borderColor = UIColor.init(hexString: "#738794").cgColor
            secondTF.backgroundColor = UIColor.init(hexString: "#FBFBFB")
            secondTF.layer.borderWidth = 1.0
            thirdTF.layer.borderColor = UIColor.init(hexString: "#738794").cgColor
            thirdTF.backgroundColor = UIColor.init(hexString: "#FBFBFB")
            thirdTF.layer.borderWidth = 1.0
            foruthTF.layer.borderColor = UIColor.init(hexString: "#738794").cgColor
            foruthTF.backgroundColor = UIColor.init(hexString: "#FBFBFB")
            foruthTF.layer.borderWidth = 1.0
            
            firstTFre.layer.borderColor = UIColor.init(hexString: "#738794").cgColor
            firstTFre.backgroundColor = UIColor.init(hexString: "#FBFBFB")
            firstTFre.layer.borderWidth = 1.0
            secondTFre.layer.borderColor = UIColor.init(hexString: "#738794").cgColor
            secondTFre.backgroundColor = UIColor.init(hexString: "#FBFBFB")
            secondTFre.layer.borderWidth = 1.0
            thirdTFre.layer.borderColor = UIColor.init(hexString: "#738794").cgColor
            thirdTFre.backgroundColor = UIColor.init(hexString: "#FBFBFB")
            thirdTFre.layer.borderWidth = 1.0
            foruthTFre.layer.borderColor = UIColor.init(hexString: "#738794").cgColor
            foruthTFre.backgroundColor = UIColor.init(hexString: "#FBFBFB")
            foruthTFre.layer.borderWidth = 1.0
            
          
                    switch textField{
                    case firstTF:
                        firstTF.layer.borderColor = UIColor.init(hexString: "#333333").cgColor
                        firstTF.backgroundColor = UIColor.init(hexString: "#FFFFFF")
                        firstTF.layer.borderWidth = 2.0
                    case secondTF:
                        secondTF.layer.borderColor = UIColor.init(hexString: "#333333").cgColor
                        secondTF.backgroundColor = UIColor.init(hexString: "#FFFFFF")
                        secondTF.layer.borderWidth = 2.0
                       
                    case thirdTF:
                        thirdTF.layer.borderColor = UIColor.init(hexString: "#333333").cgColor
                        thirdTF.backgroundColor = UIColor.init(hexString: "#FFFFFF")
                        thirdTF.layer.borderWidth = 2.0
                        
                    case foruthTF:
                        foruthTF.layer.borderColor = UIColor.init(hexString: "#333333").cgColor
                        foruthTF.backgroundColor = UIColor.init(hexString: "#FFFFFF")
                        foruthTF.layer.borderWidth = 2.0
                        
                    case firstTFre:
                        firstTFre.layer.borderColor = UIColor.init(hexString: "#333333").cgColor
                        firstTFre.backgroundColor = UIColor.init(hexString: "#FFFFFF")
                        firstTFre.layer.borderWidth = 2.0
                    case secondTFre:
                        secondTFre.layer.borderColor = UIColor.init(hexString: "#333333").cgColor
                        secondTFre.backgroundColor = UIColor.init(hexString: "#FFFFFF")
                        secondTFre.layer.borderWidth = 2.0
                    case thirdTFre:
                        thirdTFre.layer.borderColor = UIColor.init(hexString: "#333333").cgColor
                        thirdTFre.backgroundColor = UIColor.init(hexString: "#FFFFFF")
                        thirdTFre.layer.borderWidth = 2.0
                    case foruthTFre:
                        foruthTFre.layer.borderColor = UIColor.init(hexString: "#333333").cgColor
                        foruthTFre.backgroundColor = UIColor.init(hexString: "#FFFFFF")
                        foruthTFre.layer.borderWidth = 2.0
                    default:
                        break
                    }
           return true
    }
    
    @objc func textFieldDidChange(textField: UITextField){

//        firstTF.layer.borderColor = UIColor.init(hexString: "#738794").cgColor
//        firstTF.backgroundColor = UIColor.init(hexString: "#FBFBFB")
//        firstTF.layer.borderWidth = 1.0
//        secondTF.layer.borderColor = UIColor.init(hexString: "#738794").cgColor
//        secondTF.backgroundColor = UIColor.init(hexString: "#FBFBFB")
//        secondTF.layer.borderWidth = 1.0
//        thirdTF.layer.borderColor = UIColor.init(hexString: "#738794").cgColor
//        thirdTF.backgroundColor = UIColor.init(hexString: "#FBFBFB")
//        thirdTF.layer.borderWidth = 1.0
//        foruthTF.layer.borderColor = UIColor.init(hexString: "#738794").cgColor
//        foruthTF.backgroundColor = UIColor.init(hexString: "#FBFBFB")
//        foruthTF.layer.borderWidth = 1.0
//
//        firstTFre.layer.borderColor = UIColor.init(hexString: "#738794").cgColor
//        firstTFre.backgroundColor = UIColor.init(hexString: "#FBFBFB")
//        firstTFre.layer.borderWidth = 1.0
//        secondTFre.layer.borderColor = UIColor.init(hexString: "#738794").cgColor
//        secondTFre.backgroundColor = UIColor.init(hexString: "#FBFBFB")
//        secondTFre.layer.borderWidth = 1.0
//        thirdTFre.layer.borderColor = UIColor.init(hexString: "#738794").cgColor
//        thirdTFre.backgroundColor = UIColor.init(hexString: "#FBFBFB")
//        thirdTFre.layer.borderWidth = 1.0
//        foruthTFre.layer.borderColor = UIColor.init(hexString: "#738794").cgColor
//        foruthTFre.backgroundColor = UIColor.init(hexString: "#FBFBFB")
//        foruthTFre.layer.borderWidth = 1.0
        
        let text = textField.text
        if textfeildViews == "EnterPinV"{
            
            if  text?.count == 1 {
                switch textField{
                case firstTF:
                    secondTF.layer.borderColor = UIColor.init(hexString: "#333333").cgColor
                    secondTF.backgroundColor = UIColor.init(hexString: "#FFFFFF")
                    secondTF.layer.borderWidth = 2.0
                    secondTF.becomeFirstResponder()
                case secondTF:
                    thirdTF.layer.borderColor = UIColor.init(hexString: "#333333").cgColor
                    thirdTF.backgroundColor = UIColor.init(hexString: "#FFFFFF")
                    thirdTF.layer.borderWidth = 2.0
                    thirdTF.becomeFirstResponder()
                case thirdTF:
                    foruthTF.layer.borderColor = UIColor.init(hexString: "#333333").cgColor
                    foruthTF.backgroundColor = UIColor.init(hexString: "#FFFFFF")
                    foruthTF.layer.borderWidth = 2.0
                    foruthTF.becomeFirstResponder()
                case foruthTF:
                    foruthTF.becomeFirstResponder()
                    firstTFre.layer.borderColor = UIColor.init(hexString: "#333333").cgColor
                    firstTFre.backgroundColor = UIColor.init(hexString: "#FFFFFF")
                    firstTFre.layer.borderWidth = 2.0
                    firstTFre.becomeFirstResponder()
                    //self.view.endEditing(true)
                default:
                    break
                }
            }
            if  text?.count == 0 {
                switch textField{
                case firstTF:
                    firstTF.layer.borderColor = UIColor.init(hexString: "#333333").cgColor
                    firstTF.backgroundColor = UIColor.init(hexString: "#FFFFFF")
                    firstTF.layer.borderWidth = 2.0
                    firstTF.becomeFirstResponder()
                case secondTF:
                    firstTF.layer.borderColor = UIColor.init(hexString: "#333333").cgColor
                    firstTF.backgroundColor = UIColor.init(hexString: "#FFFFFF")
                    firstTF.layer.borderWidth = 2.0
                    firstTF.becomeFirstResponder()
                case thirdTF:
                    secondTF.layer.borderColor = UIColor.init(hexString: "#333333").cgColor
                    secondTF.backgroundColor = UIColor.init(hexString: "#FFFFFF")
                    secondTF.layer.borderWidth = 2.0
                    secondTF.becomeFirstResponder()
                case foruthTF:
                    thirdTF.layer.borderColor = UIColor.init(hexString: "#333333").cgColor
                    thirdTF.backgroundColor = UIColor.init(hexString: "#FFFFFF")
                    thirdTF.layer.borderWidth = 2.0
                    thirdTF.becomeFirstResponder()
                default:
                    break
                }
            }
            
        }else{ //ReEnterPinV
            if  text?.count == 1 {
                switch textField{
                case firstTFre:
                    secondTFre.layer.borderColor = UIColor.init(hexString: "#333333").cgColor
                    secondTFre.backgroundColor = UIColor.init(hexString: "#FFFFFF")
                    secondTFre.layer.borderWidth = 2.0
                    secondTFre.becomeFirstResponder()
                case secondTFre:
                    thirdTFre.layer.borderColor = UIColor.init(hexString: "#333333").cgColor
                    thirdTFre.backgroundColor = UIColor.init(hexString: "#FFFFFF")
                    thirdTFre.layer.borderWidth = 2.0
                    thirdTFre.becomeFirstResponder()
                case thirdTFre:
                    foruthTFre.layer.borderColor = UIColor.init(hexString: "#333333").cgColor
                    foruthTFre.backgroundColor = UIColor.init(hexString: "#FFFFFF")
                    foruthTFre.layer.borderWidth = 2.0
                    foruthTFre.becomeFirstResponder()
                case foruthTFre:
                    foruthTFre.layer.borderColor = UIColor.init(hexString: "#333333").cgColor
                    foruthTFre.backgroundColor = UIColor.init(hexString: "#FFFFFF")
                    foruthTFre.layer.borderWidth = 2.0
                    foruthTFre.becomeFirstResponder()
                    self.dismissKeyboard()
                default:
                    break
                }
            }
            if  text?.count == 0 {
                switch textField{
                case firstTFre:
                    firstTFre.layer.borderColor = UIColor.init(hexString: "#333333").cgColor
                    firstTFre.backgroundColor = UIColor.init(hexString: "#FFFFFF")
                    firstTFre.layer.borderWidth = 2.0
                    firstTFre.becomeFirstResponder()
                case secondTFre:
                    firstTFre.layer.borderColor = UIColor.init(hexString: "#333333").cgColor
                    firstTFre.backgroundColor = UIColor.init(hexString: "#FFFFFF")
                    firstTFre.layer.borderWidth = 2.0
                    firstTFre.becomeFirstResponder()
                case thirdTFre:
                    secondTFre.layer.borderColor = UIColor.init(hexString: "#333333").cgColor
                    secondTFre.backgroundColor = UIColor.init(hexString: "#FFFFFF")
                    secondTFre.layer.borderWidth = 2.0
                    secondTFre.becomeFirstResponder()
                case foruthTFre:
                    thirdTFre.layer.borderColor = UIColor.init(hexString: "#333333").cgColor
                    thirdTFre.backgroundColor = UIColor.init(hexString: "#FFFFFF")
                    thirdTFre.layer.borderWidth = 2.0
                    thirdTFre.becomeFirstResponder()
                default:
                    break
                }
            }
        }
        
    }
    
    func dismissKeyboard(){
        let otpText = "\(self.firstTF.text ?? "")\(self.secondTF.text ?? "")\(self.thirdTF.text ?? "")\(self.foruthTF.text ?? "")"
        print(otpText)
        let otpReText = "\(self.firstTFre.text ?? "")\(self.secondTFre.text ?? "")\(self.thirdTFre.text ?? "")\(self.foruthTFre.text ?? "")"
        print(otpReText)
        
//        if self.firstTF.text == "" || self.secondTF.text == "" || self.thirdTF.text == "" || self.foruthTF.text == ""{
//            print("not matching")
//        }else if self.firstTF.text == "" || self.secondTF.text == "" || self.thirdTF.text == "" || self.foruthTF.text == ""{
//            print("not matching")
//        }else
        
        let rules: [ValidationRule] = [ FourDigitNumberRule(), NoConsecutiveDigitsRule() ] //, NotYearRule(), NonRepeatRule()
        let test = [ otpText ]
        var isValid = "invalid"
        for string in test {
             isValid = string.isValid(rules: rules) ? "valid" : "invalid"
            print("\(string) is \(isValid)")
        }
        
         if otpText != otpReText{
            showErrorLbl(message: WarningMessage)
         }else if isValid == "invalid" {
             showErrorLbl(message: errorMessage)
         }
        else if self.firstTF.text == self.secondTF.text && self.firstTF.text == self.thirdTF.text && self.firstTF.text == self.foruthTF.text{
            showErrorLbl(message: errorMessage)
        }else if self.firstTFre.text == self.secondTFre.text && self.firstTFre.text == self.thirdTFre.text && self.firstTFre.text == self.foruthTFre.text{
            showErrorLbl(message: errorMessage)
        }
        else{
            self.view.endEditing(true)
            let secureTxt = otpText.regEx()
            self.viewDelegate?.optionsButtonTapNewAction(text: secureTxt, payload: otpText)
            self.dismiss(animated: true, completion: nil)
        }
        

    }
    
    func showErrorLbl(message:String){
        firstTF.text = ""
        secondTF.text = ""
        thirdTF.text = ""
        foruthTF.text = ""
        
        firstTFre.text = ""
        secondTFre.text = ""
        thirdTFre.text = ""
        foruthTFre.text = ""
        firstTF.becomeFirstResponder()
        
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
    

}

extension ResetPinViewController: UITableViewDelegate, UITableViewDataSource{
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

protocol ValidationRule {

    func isValid(for number: Int) -> Bool
}

class FourDigitNumberRule: ValidationRule {
    let allowedRange = 1000...9999
    func isValid(for number: Int) -> Bool {
        return allowedRange.contains(number)
    }
}

class NoConsecutiveDigitsRule: ValidationRule {
    func isValid(for number: Int) -> Bool {
        let coef = 10
        var remainder = number
        var curr: Int? = nil
        var prev: Int? = nil
        var diff: Int?

        while remainder > 0 {

            defer { remainder = Int(remainder / coef) }
            prev = curr
            curr = remainder % coef
            guard let p = prev, let c = curr else { continue }
            let lastDiff = diff
            diff = p - c
            guard let ld = lastDiff else { continue }
            if ld != diff { return true }
            if diff != 1 && diff != -1 { return true }
        }
        return false
    }
}

class NotYearRule: ValidationRule {

    func isValid(for number: Int) -> Bool {
        let hundreds = number / 100
        if hundreds == 19 || hundreds == 20 {
            return false
        }
        return true
    }
}

class NonRepeatRule: ValidationRule {

    func isValid(for number: Int) -> Bool {
        let coef = 10
        var map = [Int: Int]()
        for i in 0...9 {

            map[i] = 0
        }
        var remainder = number
        while remainder > 0 {
            let i = remainder % coef
            map[i]! += 1
            remainder = Int(remainder / coef)
        }
        for i in 0...9 {
            if map[i]! > 2 { return false }
        }
        return true
    }
}

extension String {

    func isValid(rules: [ValidationRule]) -> Bool {

        guard let number = Int(self) else { return false }

        for rule in rules {

            if !rule.isValid(for: number) { return false }
        }

        return true
    }
}
