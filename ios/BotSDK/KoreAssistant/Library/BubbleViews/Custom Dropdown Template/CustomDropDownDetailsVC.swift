//
//  CustomDropDownDetailsVC.swift
//  KoreBotSDKFrameWork
//
//  Created by Kartheek Pagidimarri on 02/01/23.
//  Copyright © 2023 Kartheek.Pagidimarri. All rights reserved.
//

import UIKit
protocol customDropDownDelegate {
    func optionsButtonTapNewAction(text:String, payload:String)
}
class CustomDropDownDetailsVC: UIViewController {
    let bundle = KREResourceLoader.shared.resourceBundle()
    var viewDelegate: customDropDownDelegate?
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var searchV: UIView!
    @IBOutlet weak var headingLbl: UILabel!
    @IBOutlet weak var tabV: UITableView!
    var dataString: String!
    var arrayOfElements = [ComponentElements]()
    var arraySearchOfElements = [ComponentElements]()
    var headerStr = "All countries"
    @IBOutlet weak var tabVBottomConstraint: NSLayoutConstraint!
    var isSearch = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
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
        
        tabV.register(UINib.init(nibName: "CustomDropDownCell", bundle: bundle), forCellReuseIdentifier: "CustomDropDownCell")
        getData()
        
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
        self.tabVBottomConstraint.constant = keyboardHeight + 10
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
        self.tabVBottomConstraint.constant = 0
       
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            self.view.layoutIfNeeded()
        }, completion: { (Bool) in
            
        })
    }
    
    // MARK: init
    init(dataString: String) {
        super.init(nibName: "CustomDropDownDetailsVC", bundle: bundle)
        self.dataString = dataString
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getData(){
        //let jsonDic: NSDictionary = Utilities.jsonObjectFromString(jsonString: dataString!) as! NSDictionary
        let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: dataString!) as! NSDictionary
        let jsonDecoder = JSONDecoder()
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject as Any , options: .prettyPrinted),
              let allItems = try? jsonDecoder.decode(Componentss.self, from: jsonData) else {
            return
        }
        headerStr = allItems.heading ?? "All countries"
        arrayOfElements = allItems.elements ?? []
        arraySearchOfElements = allItems.elements ?? []
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    @IBAction func backBtnAct(_ sender: Any) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func closeBtnAct(_ sender: Any) {
        self.view.endEditing(true)
        self.viewDelegate?.optionsButtonTapNewAction(text: "cancel", payload: "cancel")
        self.dismiss(animated: true, completion: nil)
    }
}

extension CustomDropDownDetailsVC: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arraySearchOfElements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomDropDownCell") as! CustomDropDownCell
        cell.selectionStyle = .none
        let element = arraySearchOfElements[indexPath.row]
        cell.titleLbl.text = element.title
        //cell.imageV.image = UIImage.init(named: "")
        cell.imagVWidthConstaint.constant = 0.0
        if let flag = element.flag{
            cell.imagVWidthConstaint.constant = 4.0
            cell.imageV.af_setImage(withURL: URL.init(string: flag)!, placeholderImage: UIImage(named: "placeholder_image"))
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let element = arraySearchOfElements[indexPath.row]
        customDropDownText = element.value ?? ""
        //NotificationCenter.default.post(name: Notification.Name(customDropDownTextAppendNotification), object: element.value)
        NotificationCenter.default.post(name: Notification.Name(customDDTextAppendInTemplateNotification), object: nil)
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
        headerView.backgroundColor = .white
        let label = UILabel()
        label.frame = CGRect.init(x: 24, y: 5, width: headerView.frame.width-24, height: headerView.frame.height)
        label.text = headerStr
        label.numberOfLines = 2
        label.font = UIFont(name: semiBoldCustomFont, size: 16)
        label.textColor = .black
        headerView.addSubview(label)
        
        return headerView
    }
}

extension CustomDropDownDetailsVC: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
       //input text
       let searchText = textField.text!.replacingCharacters(in: Range(range, in: textField.text!)!, with: string)
        print("\(searchText)")
        
      //add matching text to arrya
        self.arraySearchOfElements = self.arrayOfElements.filter({(($0.title!).localizedCaseInsensitiveContains(searchText))})
      if(searchText.count == 0){
          isSearch = false
          self.arraySearchOfElements  = self.arrayOfElements
      }else{
          isSearch = true
     }
      self.tabV.reloadData();

      return true
    }

}
