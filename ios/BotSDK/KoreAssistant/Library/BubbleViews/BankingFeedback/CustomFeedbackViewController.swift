//
//  CustomFeedbackViewController.swift
//  KoreBotSDKFrameWork
//
//  Created by Kartheek Pagidimarri on 15/06/23.
//  Copyright © 2023 Kartheek.Pagidimarri. All rights reserved.
//

import UIKit
protocol customFeedbackDelegate {
    func optionsButtonTapNewAction(text:String, payload:String)
    func sendSlientMessageTobot(text:String)
}

class CustomFeedbackViewController: UIViewController, UIGestureRecognizerDelegate {
    let bundle = KREResourceLoader.shared.resourceBundle()
    var viewDelegate: customFeedbackDelegate?
    @IBOutlet weak var emojiView: UIView!
    @IBOutlet weak var emojiTitleLbl: UILabel!
    @IBOutlet weak var emojiNotNowBtn: UIButton!
    
    @IBOutlet weak var emojiBtn1: UIButton!
    @IBOutlet weak var emojiBtn2: UIButton!
    @IBOutlet weak var emojiBtn3: UIButton!
    @IBOutlet weak var emojiBtn4: UIButton!
    @IBOutlet weak var emojiBtn5: UIButton!
    
    var experienceContentArray: [[String:Any]] = [[ : ]]
    var emojifeedbackcancelTitle:String?
    var emojifeedbackcancelPayload :String?
    
    @IBOutlet weak var feedbackV: UIView!
    @IBOutlet weak var feedbackTitleLbl: UILabel!
    @IBOutlet weak var feedbacktxtV: UITextView!
    @IBOutlet weak var feedbackPlaceholderLbl: UILabel!
    @IBOutlet weak var feedbackNotNowBtn: UIButton!
    @IBOutlet weak var feedbackSubmitBtn: UIButton!
    @IBOutlet var FeedbackBgVBottomConstraint: NSLayoutConstraint!
    
    var feedbackSurveycancelTitle:String?
    var feedbackSurveycancelPayload:String?
    var allowCharacterLimit = 50
    
    @IBOutlet weak var thanksView: UIView!
    @IBOutlet weak var thanksTitleLbl: UILabel!
    @IBOutlet weak var closeBtn: UIButton!
    
    @IBOutlet weak var collV: UICollectionView!
    let cellIdentifire = "CustomFeedbackCell"
    @IBOutlet weak var collVWidthConstraint: NSLayoutConstraint!
    var dataString: String!
    
    var selectFeedbackValue = ""
    var selectFeedbackId = ""
    var userComment = ""
    var prefixStr = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if #available(iOS 11.0, *) {
            emojiView.roundCorners([ .layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 15.0, borderColor: UIColor.lightGray, borderWidth: 0)
        }
        emojiTitleLbl.font = UIFont(name: semiBoldCustomFont, size: 22.0)
        emojiNotNowBtn.titleLabel?.font = UIFont(name: semiBoldCustomFont, size: 14.0)
        emojiNotNowBtn.setTitleColor(themeColor, for: .normal)
        
        feedbackV.isHidden = true
        if #available(iOS 11.0, *) {
            feedbackV.roundCorners([ .layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 15.0, borderColor: UIColor.lightGray, borderWidth: 0)
        }
        feedbackTitleLbl.font = UIFont(name: semiBoldCustomFont, size: 22.0)
        feedbacktxtV.font = UIFont(name: regularCustomFont, size: 14.0)
        feedbackPlaceholderLbl.font = UIFont(name: regularCustomFont, size: 14.0)
        feedbackPlaceholderLbl.textColor = .lightGray
        feedbackNotNowBtn.titleLabel?.font = UIFont(name: semiBoldCustomFont, size: 14.0)
        feedbackNotNowBtn.setTitleColor(themeColor, for: .normal)
        
        feedbacktxtV.layer.cornerRadius = 4.0
        feedbacktxtV.layer.borderWidth = 1.0
        feedbacktxtV.layer.borderColor = UIColor.init(hexString: "#738794").cgColor
        feedbacktxtV.clipsToBounds = true
        
        feedbackSubmitBtn.layer.cornerRadius = 4.0
        feedbackSubmitBtn.clipsToBounds = true
        feedbackSubmitBtn.isUserInteractionEnabled = false
        feedbackSubmitBtn.titleLabel?.font = UIFont(name: semiBoldCustomFont, size: 14.0)
        
        thanksView.isHidden = true
        if #available(iOS 11.0, *) {
            thanksView.roundCorners([ .layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 15.0, borderColor: UIColor.lightGray, borderWidth: 0)
        }
        thanksTitleLbl.font = UIFont(name: semiBoldCustomFont, size: 22.0)
        closeBtn.titleLabel?.font = UIFont(name: semiBoldCustomFont, size: 14.0)
        closeBtn.backgroundColor = themeColor
        closeBtn.layer.cornerRadius = 4.0
        closeBtn.clipsToBounds = true
        
        
        collV.register(UINib.init(nibName: "CustomFeedbackCell", bundle: bundle), forCellWithReuseIdentifier: "CustomFeedbackCell")
        
        getData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
       
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        tap.delegate = self
        self.feedbackV.addGestureRecognizer(tap)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view?.isDescendant(of: collV) == true{
            return false
        }
        return true
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        self.view.endEditing(true)
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
        
        self.FeedbackBgVBottomConstraint.constant = 10 - keyboardHeight - 10
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
       
        self.FeedbackBgVBottomConstraint.constant = 0
        //self.scrollV.contentSize = CGSize(width: self.view.frame.size.width - 48, height: 0)
        
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            self.view.layoutIfNeeded()
        }, completion: { (Bool) in
            
        })
    }


    // MARK: init
    init(dataString: String) {
        super.init(nibName: "CustomFeedbackViewController", bundle: bundle)
        self.dataString = dataString
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getData(){
        let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: dataString!) as! NSDictionary
        //print(jsonObject)
        prefixStr = jsonObject["prefix"] as? String ?? ""
        if let emojifeedback = jsonObject["emojisFeedback"] as? [String: Any]{
            emojiTitleLbl.text = emojifeedback["header"] as? String
            experienceContentArray = []
            if let arrayOfEmojis = emojifeedback["experienceContent"] as? [[String:Any]]{
                experienceContentArray = arrayOfEmojis
                let cellwidth = experienceContentArray.count * 48
                let cellspacing = experienceContentArray.count * 10
                self.collVWidthConstraint.constant = CGFloat(cellwidth) + CGFloat(cellspacing)
            }
             emojifeedbackcancelTitle = emojifeedback["cancelTitle"] as? String
             emojifeedbackcancelPayload = emojifeedback["cancelPayload"] as? String
        }
        
        if let feedbackSurvey = jsonObject["feedbackSurvey"] as? [String: Any]{
            feedbackTitleLbl.text = feedbackSurvey["header"] as? String
            feedbackPlaceholderLbl.text = feedbackSurvey["textareaPlaceholder"] as? String
            feedbackSurveycancelTitle = feedbackSurvey["cancelTitle"] as? String
            feedbackSurveycancelPayload = feedbackSurvey["cancelPayload"] as? String
            allowCharacterLimit = feedbackSurvey["allowCharacterLimit"] as? Int ?? 50
            feedbackSubmitBtn.setTitle(feedbackSurvey["submitTitle"] as? String, for: .normal)
        }
        
        if let submittedScreen = jsonObject["submittedScreen"] as? [String: Any]{
            thanksTitleLbl.text = submittedScreen["header"] as? String
            let closeBtnTitle = submittedScreen["closeBtn"] as? String
            closeBtn.setTitle(closeBtnTitle, for: .normal)
        }
        collV.reloadData()

    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func terribleBtnAct(_ sender: Any) {
        emojiView.isHidden = true
        feedbackV.isHidden = false
    }
    @IBAction func emojiNotNowBtnAct(_ sender: Any) {
        self.view.endEditing(true)
        //self.viewDelegate?.optionsButtonTapNewAction(text: emojifeedbackcancelTitle ?? "", payload: emojifeedbackcancelPayload ?? "")
        self.viewDelegate?.sendSlientMessageTobot(text: emojifeedbackcancelPayload ?? "")
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func feedbackNotNowBtnAct(_ sender: Any) {
        self.view.endEditing(true)
        //self.viewDelegate?.optionsButtonTapNewAction(text: feedbackSurveycancelTitle ?? "", payload: feedbackSurveycancelPayload ?? "")
        self.viewDelegate?.sendSlientMessageTobot(text: feedbackSurveycancelPayload ?? "")
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func feedbackSubmitBtnAct(_ sender: Any) {
        self.view.endEditing(true)
        feedbackV.isHidden = true
        let dic = ["value": selectFeedbackValue] as [String : Any]
        let jsonStr = jsonToString(json: dic)
        var removeStr = jsonStr.replacingOccurrences(of: "\\", with: "")
        removeStr = removeStr.replacingOccurrences(of: "\n", with: "")
        
        //self.viewDelegate?.sendSlientMessageTobot(text: removeStr )
        self.viewDelegate?.optionsButtonTapNewAction(text: selectFeedbackValue, payload: "\(prefixStr) \(selectFeedbackId)")
        
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { (_) in
            let dic = ["userComment": self.feedbacktxtV.text ?? ""] as [String : Any]
            let jsonStr = self.jsonToString(json: dic)
            var removeStr = jsonStr.replacingOccurrences(of: "\\", with: "")
            removeStr = removeStr.replacingOccurrences(of: "\n", with: "")
            
            //self.viewDelegate?.sendSlientMessageTobot(text: removeStr )
            self.viewDelegate?.optionsButtonTapNewAction(text: self.feedbacktxtV.text ?? "", payload: "\(self.prefixStr) \(self.feedbacktxtV.text ?? "")")
        }
        thanksView.isHidden = false
    }
    
    
    @IBAction func closeBtnAct(_ sender: Any) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
}
extension CustomFeedbackViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
       return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return experienceContentArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifire, for: indexPath) as! CustomFeedbackCell
        cell.backgroundColor = .clear
        let details = experienceContentArray[indexPath.row]
        if let gifUrl = details["emojiURL"] as? String{
            if gifUrl.contains("base64"){
                let image = Utilities.base64ToImage(base64String: gifUrl)
                cell.imagV.image = image
            }else{
                if let url = URL(string: gifUrl){
                    cell.imagV.af_setImage(withURL: url, placeholderImage: UIImage(named: ""))
                }
            }
            
        }else{
            cell.imagV.image = UIImage.init(named: "")
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let details = experienceContentArray[indexPath.row]
        selectFeedbackValue = details["value"] as? String ?? ""
        if let emojiId = details["emojiId"] as? Int{
            selectFeedbackId = String(emojiId)
        }
        if indexPath.item == 3 || indexPath.item == 4{
            emojiView.isHidden = true
            feedbackV.isHidden = true
            thanksView.isHidden = false
            let dic = ["value": selectFeedbackValue]
            let jsonStr = jsonToString(json: dic)
            var removeStr = jsonStr.replacingOccurrences(of: "\\", with: "")
            removeStr = removeStr.replacingOccurrences(of: "\n", with: "")
            //self.viewDelegate?.sendSlientMessageTobot(text: removeStr)
            self.viewDelegate?.optionsButtonTapNewAction(text: selectFeedbackValue, payload: "\(prefixStr) \(selectFeedbackId)")
            
            Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { (_) in
                self.viewDelegate?.sendSlientMessageTobot(text: "\(self.prefixStr) -")
            }
            
        }else{
            emojiView.isHidden = true
            feedbackV.isHidden = false
        }
        
    }
    
    func jsonToString(json: [String: Any]) -> String{
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
}


extension CustomFeedbackViewController: UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty{
            feedbackPlaceholderLbl.isHidden = false
            feedbackSubmitBtn.backgroundColor = UIColor.init(hexString: "#D7D7D7")
            feedbackSubmitBtn.setTitleColor(.black, for: .normal)
            feedbackSubmitBtn.isUserInteractionEnabled = false
        }else{
            feedbackPlaceholderLbl.isHidden = true
            feedbackSubmitBtn.backgroundColor = themeColor
            feedbackSubmitBtn.setTitleColor(.white, for: .normal)
            feedbackSubmitBtn.isUserInteractionEnabled = true
        }
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars <= allowCharacterLimit
    }
}
