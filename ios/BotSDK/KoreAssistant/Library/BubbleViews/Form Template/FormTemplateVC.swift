//
//  FormTemplateVC.swift
//  KoreBotSDKFrameWork
//
//  Created by Kartheek Pagidimarri on 13/01/23.
//  Copyright © 2023 Kartheek.Pagidimarri. All rights reserved.
//

import UIKit
protocol FormTemplateDelegate {
    func optionsButtonTapNewAction(text:String, payload:String)
    func sendSlientMessageTobot(text:String)
}
class FormTemplateVC: UIViewController {
    @IBOutlet weak var errorLbl: UILabel!
    var arrayOfFields = [FormFields]()
    var arrayOfTextFieldsText = NSMutableArray()
    var arrayOfcountries = [ComponentElements]()
    var arrayOfElements = NSMutableArray()
    var viewDelegate: FormTemplateDelegate?
    var dataString: String!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var bgV: UIView!
    @IBOutlet weak var tabV: UITableView!
    @IBOutlet weak var cancelBtn: UIButton!
    var submitBtn: UIButton!
    var countryHeading = ""
    var selectCountry = ""
    var selectCountryValue = ""
    var selectCountryFalg = ""
    @IBOutlet weak var bgVBottomConstraint: NSLayoutConstraint!
    var templateLanguage:String?
    
    
    var arrayOfCountriesElements = [ComponentElements]()
    var arraySearchOfElements = [ComponentElements]()
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var searchV: UIView!
    @IBOutlet weak var headingLbl: UILabel!
    @IBOutlet weak var searchTabV: UITableView!
    var isSearch = false
    @IBOutlet weak var tabVBottomConstraint: NSLayoutConstraint!
    
    let dropDown = DropDown()
          lazy var dropDowns: [DropDown] = {
              return [
                  self.dropDown
              ]
    }()
    let bundle = KREResourceLoader.shared.resourceBundle()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        errorLbl.font = UIFont(name: semiBoldCustomFont, size: 14.0)
        errorLbl.isHidden = true
        tabV.register(UINib.init(nibName: "FormTemplateCell", bundle: bundle), forCellReuseIdentifier: "FormTemplateCell")
        if #available(iOS 11.0, *) {
            self.bgV.roundCorners([ .layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 15.0, borderColor: UIColor.lightGray, borderWidth: 0)
        } else {
            // Fallback on earlier versions
        }
        
        //SearchView
        searchView.isHidden = true
        headingLbl.font = UIFont(name: mediumCustomFont, size: 14.0)
        headingLbl.textColor = .black
        
        searchV.layer.cornerRadius = 4.0
        searchV.layer.borderWidth = 1.0
        searchV.layer.borderColor = UIColor.init(hexString: "#7C7C7C").cgColor
        
        searchTF.font = UIFont(name: regularCustomFont, size: 14.0)
        searchTF.textColor =  UIColor.init(hexString: "#333333")
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.lightGray,
            NSAttributedString.Key.font : UIFont(name: regularCustomFont, size: 14)
        ]
        self.searchTF.attributedPlaceholder = NSAttributedString(string: "Search", attributes:attributes as [NSAttributedString.Key : Any])
        
        searchTabV.register(UINib.init(nibName: "CustomDropDownCell", bundle: bundle), forCellReuseIdentifier: "CustomDropDownCell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        getCountriesData()
        getData()
        
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
        if searchView.isHidden == false{
            self.tabVBottomConstraint.constant = keyboardHeight//10 - keyboardHeight - 10
        }else{
            self.bgVBottomConstraint.constant =  keyboardHeight//10 - keyboardHeight - 10
        }
        
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
        if searchView.isHidden == false{
            self.tabVBottomConstraint.constant = 0
        }else{
            self.bgVBottomConstraint.constant = 0
        }
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            self.view.layoutIfNeeded()
        }, completion: { (Bool) in
            
        })
    }
    
    // MARK: init
    init(dataString: String) {
        super.init(nibName: "FormTemplateVC", bundle: bundle)
        self.dataString = dataString
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    @IBAction func closeBtnAct(_ sender: Any) {
        self.view.endEditing(true)
        self.viewDelegate?.optionsButtonTapNewAction(text: "cancel", payload: "cancel")
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func searchBackBtnAct(_ sender: Any) {
        self.view.endEditing(true)
        searchView.isHidden = true
    }
    
    func getData(){
        let jsonDic: NSDictionary = Utilities.jsonObjectFromString(jsonString: dataString!) as! NSDictionary
        print(jsonDic)
        let title = jsonDic["heading"] as? String
        
        let jsonDecoder = JSONDecoder()
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonDic as Any , options: .prettyPrinted),
            let allItems = try? jsonDecoder.decode(Componentss.self, from: jsonData) else {
                return
        }
        titleLbl.text = title
        templateLanguage = allItems.lang ?? default_language
        arrayOfFields = allItems.form_fields ?? []
        arrayOfTextFieldsText = []
        for i in 0..<arrayOfFields.count{
            let field = arrayOfFields[i]
            let feildTxt = field.text ?? ""
            arrayOfTextFieldsText.add(feildTxt)
        }
        
        arrayOfElements = []
        arrayOfcountries = allItems.dropdown?.elements ?? []
        countryHeading = allItems.dropdown?.heading ?? ""
//        for i in 0..<arrayOfcountries.count{
//            let countries = arrayOfcountries[i]
//            if i == 0{
//                selectCountry = countries.title ?? ""
//                selectCountryValue = countries.value ?? ""
//            }
//            arrayOfElements.add(countries.title ?? "")
//        }
        let countryCode  = allItems.dropdown?.countrycode ?? "AE"
        let countryArray = self.arrayOfCountriesElements.filter({(($0.country_code!).localizedCaseInsensitiveContains(countryCode))})
        if countryArray.count > 0{
            let country = countryArray[0]
            selectCountry = country.country_name ?? ""
            selectCountryValue = country.country_code ?? ""
            selectCountryFalg = country.flag ?? ""
             
        }else{
            selectCountry = "UAE"
            selectCountryValue = "AE"
            selectCountryFalg = "https://contentdelivery.mashreqbank.com/assisted-channels/national-flags/AE.png"
        }
        tabV.reloadData()
    }
    
    func getCountriesData(){
        //print(countriesData)
        let jsonDic: NSDictionary = Utilities.jsonObjectFromString(jsonString: countriesData) as! NSDictionary
        //print(jsonDic)
        let jsonDecoder = JSONDecoder()
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonDic as Any , options: .prettyPrinted),
            let allItems = try? jsonDecoder.decode(Componentss.self, from: jsonData) else {
                return
        }
        headingLbl.text = "Countries"
        arraySearchOfElements = allItems.elements ?? []
        arrayOfCountriesElements = allItems.elements ?? []
        searchTabV.reloadData()
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    func showErrorLbl(message:String){
//        errorLbl.text = message
//        errorLbl.isHidden = false
//        Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { (_) in
//            self.errorLbl.isHidden = true
//        }
        NotificationCenter.default.post(name: Notification.Name(pdfcTemplateViewErrorNotification), object: message)
    }
    
    func jsonToString(json: AnyObject) -> String{
        do {
            let data1 = try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted)
            let convertedString = String(data: data1, encoding: String.Encoding.utf8) as NSString? ?? ""
            //debugPrint(convertedString)
            return convertedString as String
        } catch let myJSONError {
            //debugPrint(myJSONError)
            return ""
        }
    }
    @objc fileprivate func contriesButtonAction(_ sender: AnyObject!) {
        self.view.endEditing(true)
        //print("county")
        //dropDown.show()
        isSearch = false
        searchView.isHidden = false
        searchTF.text = ""
        getCountriesData()
    }
    
    @objc fileprivate func submitButtonAction(_ sender: AnyObject!) {
        //print("Submit \(arrayOfTextFieldsText)")
        
        submitBtn.setTitleColor(.white, for: .normal)
        submitBtn.backgroundColor = themeColor
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { (_) in
            self.submitBtn.setTitleColor(themeColor, for: .normal)
            self.submitBtn.backgroundColor = .white
        }
        
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
                }else{
                    //let textStr = arrayOfTextFieldsText[i] as? String
                    finalString.append("\(textStr!) ")
                }
            }else{
                finalString.append("\(textStr!) ")
            }
            payloadDic.setObject("\(textStr!)", forKey: "addressline\(i+1)" as NSCopying)
        }
        payloadDic.setObject("\(selectCountryValue)", forKey: "addressline\((arrayOfTextFieldsText.count+1))" as NSCopying)
        let jsonStr = jsonToString(json: payloadDic)
        
        if isempty == false{
            self.view.endEditing(true)
            self.dismiss(animated: true, completion: nil)
            //self.viewDelegate?.optionsButtonTapNewAction(text: "Address updated successfully", payload: jsonStr)
            var removeStr = jsonStr.replacingOccurrences(of: "\\", with: "")
            removeStr = removeStr.replacingOccurrences(of: "\n", with: "")
            self.viewDelegate?.sendSlientMessageTobot(text: removeStr)
        }else{
            showErrorLbl(message: "Please enter required feilds.")
        }
    }
}

extension FormTemplateVC: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == self.searchTabV{
            return 1
        }else{
            return 2
        }
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.searchTabV{
            return arraySearchOfElements.count
        }else{
            if section == 0{
                return arrayOfFields.count
            }
            return 1
        }
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.searchTabV{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CustomDropDownCell") as! CustomDropDownCell
            cell.selectionStyle = .none
            let element = arraySearchOfElements[indexPath.row]
            cell.titleLbl.text = element.country_name
            cell.imageV.image = UIImage.init(named: "")
            if let flag = element.flag{
                //cell.imageV.setImageWith(URL.init(string: flag)!, placeholderImage: UIImage(named: "placeholder_image"))
                let url = URL(string:flag)
                cell.imageV.af_setImage(withURL: url!, placeholderImage: UIImage(named: "placeholder_image"))
            }
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "FormTemplateCell") as! FormTemplateCell
            cell.selectionStyle = .none
            if indexPath.section == 0{
                cell.bgVTF.layer.borderWidth = 1.0
                cell.bgVTF.layer.cornerRadius = 4.0
                cell.bgVTF.layer.borderColor = UIColor.init(hexString: "#738794").cgColor
                cell.bgVTF.clipsToBounds = true
                cell.bgVTF.backgroundColor = UIColor(red: 0.973, green: 0.976, blue: 0.988, alpha: 1)
                
                cell.addressTF.font = UIFont(name: regularCustomFont, size: 14.0)
                cell.titleLbl.font = UIFont(name: semiBoldCustomFont, size: 14.0)
                cell.arrowBtn.isHidden = true
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
                cell.addressTF.placeholder = fields.placeholder
                cell.addressTF.text = arrayOfTextFieldsText[indexPath.row] as? String
                
                cell.addressTF.delegate = self
                cell.addressTF.text = arrayOfTextFieldsText[indexPath.row] as? String
                cell.addressTF.addTarget(self, action: #selector(valueChanged), for: .editingChanged)
                cell.addressTF.tag = indexPath.row
                cell.addressTF.translatesAutoresizingMaskIntoConstraints = false
                cell.imagVWidthConstraint.constant = 0.0
            }else{
                cell.bgVTF.layer.borderWidth = 1.0
                cell.bgVTF.layer.cornerRadius = 4.0
                cell.bgVTF.layer.borderColor = UIColor.init(hexString: "#7C7C7C").cgColor
                cell.bgVTF.clipsToBounds = true

                cell.addressTF.font = UIFont(name: regularCustomFont, size: 14.0)
                cell.titleLbl.font = UIFont(name: semiBoldCustomFont, size: 14.0)
                cell.arrowBtn.isHidden = false
                cell.addressTF.isUserInteractionEnabled = false
                cell.arrowBtn.addTarget(self, action: #selector(self.contriesButtonAction(_:)), for: .touchUpInside)
                cell.addressTF.text = selectCountry
                let str = "\(countryHeading) *"
                let range = (str as NSString).range(of: "*")
                let attributedString = NSMutableAttributedString(string: str)
                attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: themeColor, range: range)
                cell.titleLbl.attributedText = attributedString
                cell.imagVWidthConstraint.constant = 45.0
                //cell.imagV.setImageWith(URL.init(string: selectCountryFalg)!, placeholderImage: UIImage(named: "placeholder_image"))
                let url = URL(string:selectCountryFalg)
                cell.imagV.af_setImage(withURL: url!, placeholderImage: UIImage(named: "placeholder_image"))
                
            }
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchView.isHidden == false{
            searchView.isHidden = true
            let element = arraySearchOfElements[indexPath.row]
            self.view.endEditing(true)
            self.selectCountry =  element.country_name ?? ""
            self.selectCountryValue  = element.country_code ?? ""
            self.selectCountryFalg = element.flag ?? ""
            self.tabV.reloadData()
        }
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.searchTabV{
            return UITableView.automaticDimension
        }else{
        return 115
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.searchTabV{
            return UITableView.automaticDimension
        }else{
        return 115
        }
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if tableView == self.searchTabV{
            return 0
        }else{
            if section == 0{
                return 0
            }
            return 35
        }
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .white
        submitBtn = UIButton(frame: CGRect.zero)
        submitBtn.backgroundColor = .clear
        submitBtn.translatesAutoresizingMaskIntoConstraints = false
        submitBtn.clipsToBounds = true
        submitBtn.layer.cornerRadius = 5
        submitBtn.setTitleColor(themeColor, for: .normal)
        submitBtn.setTitleColor(Common.UIColorRGB(0x999999), for: .disabled)
        submitBtn.titleLabel?.font = UIFont(name: mediumCustomFont, size: 12.0)!
        view.addSubview(submitBtn)
        submitBtn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
        submitBtn.addTarget(self, action: #selector(self.submitButtonAction(_:)), for: .touchUpInside)
        submitBtn.setTitle("Submit", for: .normal)
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

extension FormTemplateVC {
    func ConfigureDropDownView(){
        //DropDown
        dropDowns.forEach { $0.dismissMode = .onTap }
        dropDowns.forEach { $0.direction = .any }
        
        dropDown.backgroundColor = UIColor(white: 1, alpha: 1)
        dropDown.selectionBackgroundColor = .clear//UIColor(red: 0.6494, green: 0.8155, blue: 1.0, alpha: 0.2)
        dropDown.separatorColor = UIColor(white: 0.7, alpha: 0.8)
        dropDown.cornerRadius = 10
        dropDown.shadowColor = UIColor(white: 0.6, alpha: 1)
        dropDown.shadowOpacity = 0.9
        dropDown.shadowRadius = 25
        dropDown.animationduration = 0.25
        dropDown.textColor = .darkGray
        dropDown.textFont  = UIFont(name: mediumCustomFont, size: 14.0)
        setupColorDropDown()
    }
    // MARK: Setup DropDown
    func setupColorDropDown() {
        dropDown.anchorView = tabV
        dropDown.bottomOffset = CGPoint(x: 0, y: tabV.bounds.height)
        dropDown.dataSource = arrayOfElements as! [String]
        //colorDropDown.selectRow(0)
        // Action triggered on selection
        dropDown.selectionAction = { (index, item) in
            //print("\(item)")
            self.selectCountry = item
            let countries = self.arrayOfcountries[index]
            self.selectCountryValue  = countries.value ?? ""
            self.selectCountryFalg = countries.flag ?? ""
            self.tabV.reloadData()
        }
        
    }
}
extension FormTemplateVC: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if searchView.isHidden == false{
            //input text
            let searchText = textField.text!.replacingCharacters(in: Range(range, in: textField.text!)!, with: string)
             //print("\(searchText)")
             
           //add matching text to arrya
             self.arraySearchOfElements = self.arrayOfCountriesElements.filter({(($0.country_name!).localizedCaseInsensitiveContains(searchText))})
           if(searchText.count == 0){
               isSearch = false
               self.arraySearchOfElements  = self.arrayOfCountriesElements
           }else{
               isSearch = true
          }
           self.searchTabV.reloadData();

           return true
        }else{
//            if string == " " {
//                return false
//            }
            let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string) as NSString
            return newString.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines).location != 0
        }
    }
}

