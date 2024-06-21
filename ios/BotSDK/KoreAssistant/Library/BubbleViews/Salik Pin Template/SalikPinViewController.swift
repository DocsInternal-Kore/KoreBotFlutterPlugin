//
//  SalikPinViewController.swift
//  KoreBotSDKFrameWork
//
//  Created by Kartheek Pagidimarri on 15/12/22.
//  Copyright © 2022 Kartheek.Pagidimarri. All rights reserved.
//

import UIKit
protocol salikPinDelegate {
    func optionsButtonTapNewAction(text:String, payload:String)
}
class SalikPinViewController: UIViewController, UITextFieldDelegate {
    let bundle = KREResourceLoader.shared.resourceBundle()
    var viewDelegate: salikPinDelegate?
    var dataString: String!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var bgV: UIView!
    @IBOutlet weak var errorLbl: UILabel!
    
    @IBOutlet weak var walletIDBgv: UIView!
    @IBOutlet weak var walletIDTF: UITextField!
    
    @IBOutlet weak var desclbl: UILabel!
    @IBOutlet weak var pinTitleLbl: UILabel!
    
    @IBOutlet weak var firstTF: UITextField!
    @IBOutlet weak var secondTF: UITextField!
    @IBOutlet weak var thirdTF: UITextField!
    @IBOutlet weak var foruthTF: UITextField!
    
    var textfeildViews = "EnterPinV"
    var errorMessage = "Pin Miss match"
    var isAccountNoValid = false
    @IBOutlet weak var underToplineLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        underToplineLbl.layer.cornerRadius = 3.0
        underToplineLbl.clipsToBounds = true
        
        walletIDBgv.layer.borderWidth = 1.0
        walletIDBgv.layer.cornerRadius = 4.0
        walletIDBgv.layer.borderColor = UIColor.init(hexString: "#7C7C7C").cgColor
        walletIDBgv.clipsToBounds = true
        
        titleLbl.font = UIFont(name: semiBoldCustomFont, size: 22.0)
        walletIDTF.font = UIFont(name: regularCustomFont, size: 14.0)
        desclbl.font = UIFont(name: regularCustomFont, size: 12.0)
        pinTitleLbl.font = UIFont(name: semiBoldCustomFont, size: 22.0)
        errorLbl.font = UIFont(name: semiBoldCustomFont, size: 14.0)
        errorLbl.textColor = themeColor
        
        firstTF.font = UIFont(name: semiBoldCustomFont, size: 20.0)
        secondTF.font = UIFont(name: semiBoldCustomFont, size: 20.0)
        thirdTF.font = UIFont(name: semiBoldCustomFont, size: 20.0)
        foruthTF.font = UIFont(name: semiBoldCustomFont, size: 20.0)
        
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
        
       
        
        
        // Do any additional setup after loading the view.
        firstTF.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        secondTF.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        thirdTF.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        foruthTF.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
     
        getData()
        if #available(iOS 11.0, *) {
            self.bgV.roundCorners([ .layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 15.0, borderColor: UIColor.lightGray, borderWidth: 0)
        } else {
            // Fallback on earlier versions
        }
        errorLbl.isHidden = true
    }
    
    
    
    // MARK: init
    init(dataString: String) {
        super.init(nibName: "SalikPinViewController", bundle: bundle)
        self.dataString = dataString
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override func viewDidAppear(_ animated: Bool) {
        walletIDTF.becomeFirstResponder()
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
        let desc = jsonDic["description"] as? String
        let renterPin = jsonDic["pinTitle"] as? String
        let placeHolder = jsonDic["placeHolder"] as? String
        let walletId = jsonDic["existingSalikWalletId"] as? String ?? ""
        if walletId != ""{
            isAccountNoValid = true
        }
        errorMessage = jsonDic["error_message"] as? String ?? ""
        titleLbl.text = title
        walletIDTF.placeholder = placeHolder
        walletIDTF.text = walletId
        desclbl.text = desc
        pinTitleLbl.text = renterPin
        
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
        let maxLength = 8
        let currentString = (textField.text ?? "") as NSString
        let newString = currentString.replacingCharacters(in: range, with: string)
        if textField == walletIDTF{
            if (string == " ") {
                return false
            }
            if  newString.count >= 8{
                desclbl.textColor = UIColor.init(hexString: "#7C7C7C")
                isAccountNoValid = true
            }else{
                desclbl.textColor = themeColor
                isAccountNoValid = false
                
            }
        }
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
    
    @objc func textFieldDidChange(textField: UITextField){
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
        
        let text = textField.text
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
                    foruthTF.layer.borderColor = UIColor.init(hexString: "#333333").cgColor
                    foruthTF.backgroundColor = UIColor.init(hexString: "#FFFFFF")
                    foruthTF.layer.borderWidth = 2.0
                    foruthTF.becomeFirstResponder()
                    if isAccountNoValid{
                        self.dismissKeyboard()
                    }
                    self.view.endEditing(true)
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
      
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func dismissKeyboard(){
        let otpText = "\(self.firstTF.text ?? "")\(self.secondTF.text ?? "")\(self.thirdTF.text ?? "")\(self.foruthTF.text ?? "")"
        print(otpText)
        if walletIDTF.text?.count == 0{
            showErrorLbl(message: "Please enter wallet ID")
        }
        else if self.firstTF.text?.count == 0 || self.secondTF.text?.count == 0 || self.thirdTF.text?.count == 0 || self.foruthTF.text?.count == 0{
            self.firstTF.text = ""
            self.secondTF.text = ""
            self.thirdTF.text = ""
            self.foruthTF.text = ""
            
            firstTF.layer.cornerRadius = 4.0
            firstTF.layer.borderWidth = 2.0
            firstTF.layer.borderColor = UIColor.init(hexString: "#333333").cgColor
            firstTF.backgroundColor = UIColor.init(hexString: "#FFFFFF")
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
            
            self.firstTF.becomeFirstResponder()
            showErrorLbl(message: errorMessage)
        }else{
            self.view.endEditing(true)
            let secureTxt = otpText.regEx()
            let payLoadDic = ["walletID": walletIDTF.text ?? "","salikpin": otpText] as [String : Any]
            let PayloadJsonStr = Utilities.stringFromJSONObject(object: payLoadDic)
            let playLoadTxt = PayloadJsonStr ?? ""//"walletID:\(walletIDTF.text ?? ""),salikpin:\(otpText)"
            var removeStr = playLoadTxt.replacingOccurrences(of: "\\", with: "")
                 removeStr = removeStr.replacingOccurrences(of: "\n", with: "")
                 removeStr = removeStr.replacingOccurrences(of: "  ", with: "")
            let chatSecureTxt = "\(walletIDTF.text ?? "") \(secureTxt)"
            self.viewDelegate?.optionsButtonTapNewAction(text: chatSecureTxt, payload: removeStr)
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
    

}
