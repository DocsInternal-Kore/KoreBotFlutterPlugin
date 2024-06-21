//
//  OTPValidationVC.swift
//  KoreBotSDKFrameWork
//
//  Created by Kartheek.Pagidimarri on 11/07/22.
//  Copyright © 2022 Kartheek.Pagidimarri. All rights reserved.
//

import UIKit
protocol OTPValidationDelegate {
    func optionsButtonTapNewAction(text:String, payload:String)
}

class OTPValidationVC: UIViewController, UITextFieldDelegate {
    let bundle = KREResourceLoader.shared.resourceBundle()
    var dataString: String!
    @IBOutlet weak var HeadingLbl: UILabel!
    @IBOutlet weak var bgV: UIView!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var mobileNoLbl: UILabel!
    @IBOutlet var notRecivedotpLbl: UILabel!
    
    @IBOutlet weak var firstTF: UITextField!
    @IBOutlet weak var secondTF: UITextField!
    @IBOutlet weak var thirdTF: UITextField!
    @IBOutlet weak var foruthTF: UITextField!
    @IBOutlet weak var fifthTF: UITextField!
    @IBOutlet weak var sixthTF: UITextField!
    var viewDelegate: OTPValidationDelegate?
    
    @IBOutlet var reSendLbl: UILabel!
    @IBOutlet var secondsLbl: UILabel!
    @IBOutlet var underToplineLbl: UILabel!
    
    @IBOutlet var textFeildsView: UIView!
    var timerCount = 0
    var timerType:String?
    var timer : Timer?
    @IBOutlet var resendBtn: UIButton!
    var resendPayload:String?
    
    @IBOutlet var cellImgBg: UIImageView!
    @IBOutlet var cellImgv: UIImageView!
    
    // MARK: init
    init(dataString: String) {
        super.init(nibName: "OTPValidationVC", bundle: bundle)
        self.dataString = dataString
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        underToplineLbl.layer.cornerRadius = 3.0
        underToplineLbl.clipsToBounds = true
        
        let bgimgV = UIImage.init(named: "otpVBg", in: bundle, compatibleWith: nil)
        cellImgBg.image = bgimgV?.withRenderingMode(.alwaysTemplate)
        cellImgBg.tintColor = BubbleViewLeftTint
        
        let cellimgV = UIImage.init(named: "otpMobile", in: bundle, compatibleWith: nil)
        cellImgv.image = cellimgV?.withRenderingMode(.alwaysTemplate)
        cellImgv.tintColor = themeColor
        
        
        HeadingLbl.font = UIFont(name: semiBoldCustomFont, size: 22.0)
        descLbl.font = UIFont(name: regularCustomFont, size: 14.0)
        notRecivedotpLbl.font = UIFont(name: semiBoldCustomFont, size: 14.0)
        notRecivedotpLbl.textColor = themeColor
        secondsLbl.textColor = themeColor
        mobileNoLbl.font = UIFont(name: regularCustomFont, size: 16.0)
        firstTF.font = UIFont(name: semiBoldCustomFont, size: 20.0)
        secondTF.font = UIFont(name: semiBoldCustomFont, size: 20.0)
        thirdTF.font = UIFont(name: semiBoldCustomFont, size: 20.0)
        foruthTF.font = UIFont(name: semiBoldCustomFont, size: 20.0)
        fifthTF.font = UIFont(name: semiBoldCustomFont, size: 20.0)
        sixthTF.font = UIFont(name: semiBoldCustomFont, size: 20.0)
        
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
        
        fifthTF.layer.cornerRadius = 4.0
        fifthTF.layer.borderWidth = 1.0
        fifthTF.layer.borderColor = UIColor.init(hexString: "#738794").cgColor
        fifthTF.backgroundColor = UIColor.init(hexString: "#FBFBFB")
        fifthTF.clipsToBounds = true
        
        sixthTF.layer.cornerRadius = 4.0
        sixthTF.layer.borderWidth = 1.0
        sixthTF.layer.borderColor = UIColor.init(hexString: "#738794").cgColor
        sixthTF.backgroundColor = UIColor.init(hexString: "#FBFBFB")
        sixthTF.clipsToBounds = true
        
        if #available(iOS 12.0, *) {
            firstTF.textContentType = .oneTimeCode
            secondTF.textContentType = .oneTimeCode
            thirdTF.textContentType = .oneTimeCode
            foruthTF.textContentType = .oneTimeCode
            fifthTF.textContentType = .oneTimeCode
            sixthTF.textContentType = .oneTimeCode
        }
        
        firstTF.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        secondTF.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        thirdTF.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        foruthTF.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        fifthTF.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        sixthTF.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        
        
        if #available(iOS 11.0, *) {
            self.bgV.roundCorners([ .layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 15.0, borderColor: UIColor.lightGray, borderWidth: 0)
        } else {
            // Fallback on earlier versions
        }
        
        // Do any additional setup after loading the view.
        if preferred_language_Type == preferredLanguage{
            bgV.semanticContentAttribute = .forceRightToLeft
            HeadingLbl.textAlignment = .right
            descLbl.textAlignment = .right
            mobileNoLbl.textAlignment = .right
            notRecivedotpLbl.textAlignment = .right
            reSendLbl.textAlignment = .right
            secondsLbl.textAlignment = .right
            reSendLbl.text = "يمكن إعادة الإرسال في"
            secondsLbl.text = "90 ثانية."
            textFeildsView.semanticContentAttribute = .forceRightToLeft
        }
        
        resendBtn.isHidden = true
        resendBtn.titleLabel?.font = UIFont(name: semiBoldCustomFont, size: 14.0)
        resendBtn.setTitleColor(themeColor, for: .normal)
        resendBtn.backgroundColor = .clear
        resendBtn.layer.cornerRadius = 4.0
        resendBtn.clipsToBounds = true
        
        getData()
    }
    override func viewDidAppear(_ animated: Bool) {
        firstTF.becomeFirstResponder()
    }
    @IBAction func closeBtnAct(_ sender: Any) {
        stopTimer()
        self.view.endEditing(true)
        self.viewDelegate?.optionsButtonTapNewAction(text: "cancel", payload: "cancel")
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
    
    func getData(){
        let jsonDic: NSDictionary = Utilities.jsonObjectFromString(jsonString: dataString!) as! NSDictionary
        print(jsonDic)
        let title = jsonDic["title"] as? String
        let description = jsonDic["description"] as? String
        let mobileNumber = jsonDic["mobileNumber"] as? String
        HeadingLbl.text = title
        descLbl.text = description
        mobileNoLbl.text = mobileNumber
        
        reSendLbl.text = ""
        secondsLbl.text = ""
        resendPayload = jsonDic["resend_payload"] as? String
        if let response_timeDic = jsonDic["response_time"] as? [String: Any]{
            reSendLbl.text = response_timeDic["title"] as? String
            
            if let time = response_timeDic["time"] as? Int{
                timerCount = time
                timerType = response_timeDic["time_type"] as? String
                secondsLbl.text = "\(timerCount) \(timerType ?? "")"
                
                timerFire()
            }
            
        }
    }
    
    @objc func updateCounter(){
        if(timerCount > 0) {
            timerCount -= 1
            secondsLbl.text = "\(timerCount) \(timerType ?? "")"
            print("\(String(describing: secondsLbl.text))")
        }else{
            stopTimer()
            self.view.endEditing(true)
            reSendLbl.isHidden = true
            secondsLbl.isHidden = true
            if resendPayload != nil{
                resendBtn.setTitle("Resend OTP", for: .normal)
                resendBtn.isHidden = false
            }
        }
    }
    
    func timerFire(){
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
    }
    func stopTimer(){
        if timer != nil {
            timer!.invalidate()
            timer = nil
        }
    }
    
    @IBAction func resendBtnAct(_ sender: Any) {
        self.view.endEditing(true)
        self.viewDelegate?.optionsButtonTapNewAction(text: resendPayload ?? "", payload: resendPayload ?? "" )
        self.dismiss(animated: true, completion: nil)
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 1
        let currentString = (textField.text ?? "") as NSString
        let newString = currentString.replacingCharacters(in: range, with: string)
        
        return newString.count <= maxLength
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
        fifthTF.layer.borderColor = UIColor.init(hexString: "#738794").cgColor
        fifthTF.backgroundColor = UIColor.init(hexString: "#FBFBFB")
        fifthTF.layer.borderWidth = 1.0
        sixthTF.layer.borderColor = UIColor.init(hexString: "#738794").cgColor
        sixthTF.backgroundColor = UIColor.init(hexString: "#FBFBFB")
        sixthTF.layer.borderWidth = 1.0
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
                fifthTF.layer.borderColor = UIColor.init(hexString: "#333333").cgColor
                fifthTF.backgroundColor = UIColor.init(hexString: "#FFFFFF")
                fifthTF.layer.borderWidth = 2.0
                fifthTF.becomeFirstResponder()
            case fifthTF:
                sixthTF.layer.borderColor = UIColor.init(hexString: "#333333").cgColor
                sixthTF.backgroundColor = UIColor.init(hexString: "#FFFFFF")
                sixthTF.layer.borderWidth = 2.0
                sixthTF.becomeFirstResponder()
            case sixthTF:
                sixthTF.layer.borderColor = UIColor.init(hexString: "#333333").cgColor
                sixthTF.backgroundColor = UIColor.init(hexString: "#FFFFFF")
                sixthTF.layer.borderWidth = 2.0
                sixthTF.resignFirstResponder()
                self.dismissKeyboard()
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
            case fifthTF:
                foruthTF.layer.borderColor = UIColor.init(hexString: "#333333").cgColor
                foruthTF.backgroundColor = UIColor.init(hexString: "#FFFFFF")
                foruthTF.layer.borderWidth = 2.0
                foruthTF.becomeFirstResponder()
            case sixthTF:
                fifthTF.layer.borderColor = UIColor.init(hexString: "#333333").cgColor
                fifthTF.backgroundColor = UIColor.init(hexString: "#FFFFFF")
                fifthTF.layer.borderWidth = 2.0
                fifthTF.becomeFirstResponder()
            default:
                break
            }
        }
        else{
            
        }
    }
    
    func dismissKeyboard(){
        if self.firstTF.text?.count == 0 || self.secondTF.text?.count == 0 || self.thirdTF.text?.count == 0 || self.foruthTF.text?.count == 0 || self.fifthTF.text?.count == 0 || self.sixthTF.text?.count == 0{
            NotificationCenter.default.post(name: Notification.Name(pdfcTemplateViewErrorNotification), object: "Umm...looks like your input is invalid. Please check and try again")
        }else{
            stopTimer()
            let otpText = "\(self.firstTF.text ?? "")\(self.secondTF.text ?? "")\(self.thirdTF.text ?? "")\(self.foruthTF.text ?? "")\(self.fifthTF.text ?? "")\(self.sixthTF.text ?? "")"
            print(otpText)
            self.view.endEditing(true)
            let secureTxt = otpText.regEx()
            self.viewDelegate?.optionsButtonTapNewAction(text: secureTxt, payload: otpText)
            self.dismiss(animated: true, completion: nil)
        }
       
    }
}
