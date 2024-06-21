//
//  CustomDropDownTemplate.swift
//  KoreBotSDKFrameWork
//
//  Created by Kartheek Pagidimarri on 02/01/23.
//  Copyright © 2023 Kartheek.Pagidimarri. All rights reserved.
//

import UIKit

class CustomDropDownTemplate: BubbleView {
    static let headerTextLimit: Int = 640
    var maskview : UIView!
    var headingLabel: KREAttributedLabel!
    var textFBgV: UIView!
    var inlineTextField: UITextField!
    var inlineButton: UIButton!
    var arrowImag: UIImageView!
    public var optionsAction: ((_ text: String?, _ payload: String?) -> Void)!

    var arrayOfComponents = [ComponentElements]()
    var arrayOfElements = NSMutableArray()
    
    override func prepareForReuse() {
        inlineTextField.text = ""
    }
    let bundle = KREResourceLoader.shared.resourceBundle()
    override func initialize() {
        super.initialize()
        
        self.headingLabel = KREAttributedLabel(frame: CGRect.zero)
        self.headingLabel.textColor = Common.UIColorRGB(0x444444)
        self.headingLabel.backgroundColor = UIColor.clear
        self.headingLabel.mentionTextColor = Common.UIColorRGB(0x8ac85a)
        self.headingLabel.hashtagTextColor = Common.UIColorRGB(0x8ac85a)
        self.headingLabel.linkTextColor = Common.UIColorRGB(0x0076FF)
        self.headingLabel.font = UIFont(name: mediumCustomFont, size: 14.0)
        self.headingLabel.numberOfLines = 0
        self.headingLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.headingLabel.isUserInteractionEnabled = true
        self.headingLabel.contentMode = UIView.ContentMode.topLeft
        self.headingLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.headingLabel)
        
        
        self.textFBgV = UIView(frame: CGRect.zero)
        self.textFBgV.layer.cornerRadius = 2.0
        self.textFBgV.layer.borderWidth = 1.0
        self.textFBgV.layer.borderColor = UIColor.gray.cgColor
        self.textFBgV.clipsToBounds = true
        self.textFBgV.backgroundColor = .white
        self.textFBgV.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.textFBgV)
        
        let views: [String: UIView] = ["headingLabel": headingLabel, "textFBgV": textFBgV]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[headingLabel]-5-[textFBgV(40)]-10-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[headingLabel]-15-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[textFBgV]-15-|", options: [], metrics: nil, views: views))
        
      
        self.inlineTextField = UITextField(frame: CGRect.zero)
        self.inlineTextField.borderStyle = .none
        self.inlineTextField.isSecureTextEntry = false
        inlineTextField.text = ""
        self.inlineTextField.translatesAutoresizingMaskIntoConstraints = false
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.lightGray,
            NSAttributedString.Key.font : UIFont(name: regularCustomFont, size: 14)
        ]
        self.inlineTextField.attributedPlaceholder = NSAttributedString(string: "Select", attributes:attributes)
        self.textFBgV.addSubview(self.inlineTextField)
        
        self.inlineButton = UIButton(frame: CGRect.zero)
        self.inlineButton.translatesAutoresizingMaskIntoConstraints = false
        self.inlineButton.clipsToBounds = true
        self.inlineButton.setImage(UIImage.init(named: ""), for: .normal)
        self.inlineButton.layer.cornerRadius = 5
        self.inlineButton.titleLabel?.font = UIFont(name: regularCustomFont, size: 14.0)
        self.textFBgV.addSubview(self.inlineButton)
        self.inlineButton.contentHorizontalAlignment = .right
        inlineButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        
        inlineButton.addTarget(self, action: #selector(tapsOnInlineFormBtn), for: .touchUpInside)
        
        self.arrowImag = UIImageView()
        self.arrowImag.contentMode = .scaleAspectFit
        //self.arrowImag.clipsToBounds = true
        //self.arrowImag.layer.cornerRadius = 15
        
        let imag : UIImage = UIImage(named: "Path", in: bundle, compatibleWith: nil)!
        self.arrowImag.image = imag
        arrowImag.contentMode = .scaleAspectFit
        self.arrowImag.translatesAutoresizingMaskIntoConstraints = false
        self.textFBgV.addSubview(self.arrowImag)
        
        self.maskview = UIView(frame:.zero)
        self.maskview.translatesAutoresizingMaskIntoConstraints = false
        self.textFBgV.addSubview(self.maskview)
        self.maskview.isHidden = true
        maskview.backgroundColor = .clear
        
        let subviews: [String: UIView] = ["inlineTextField": inlineTextField, "inlineButton": inlineButton, "arrowImag": arrowImag, "maskview": maskview]

        self.textFBgV.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[inlineTextField]-5-|", options: [], metrics: nil, views: subviews))
        self.textFBgV.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[inlineButton]-0-|", options: [], metrics: nil, views: subviews))
        self.textFBgV.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[inlineTextField]-5-|", options: [], metrics: nil, views: subviews))
        self.textFBgV.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[inlineButton]-0-|", options: [], metrics: nil, views: subviews))
        self.textFBgV.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-13-[arrowImag(15)]", options: [], metrics: nil, views: subviews))
        self.textFBgV.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[arrowImag(15)]-10-|", options: [], metrics: nil, views: subviews))
        self.textFBgV.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[maskview]-0-|", options: [], metrics: nil, views: subviews))
        self.textFBgV.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[maskview]-0-|", options: [], metrics: nil, views: subviews))
        
        
        customDropDownSeletct = ""
        inlineTextField.text = customDropDownSeletct
        NotificationCenter.default.addObserver(self, selector: #selector(custom_DropDown_TextAppendAction), name: NSNotification.Name(rawValue: customDDTextAppendInTemplateNotification), object: nil)
    }
    @objc func custom_DropDown_TextAppendAction(notification:Notification){
        inlineTextField.text = customDropDownText
        
        self.maskview.isHidden = false
        self.optionsAction(customDropDownText, customDropDownText)
    }
    
    // MARK: populate components
    override func populateComponents() {
        if (components.count > 0) {
            let component: KREComponent = components.firstObject as! KREComponent
            if (component.componentDesc != nil) {
                let jsonString = component.componentDesc
                let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: jsonString!) as! NSDictionary
                let str = jsonObject["heading"] != nil ? jsonObject["heading"] as! String : ""
                var headerText: String = str.replacingOccurrences(of: "\n", with: "")
                headerText = KREUtilities.formatHTMLEscapedString(headerText);
                
                if(headerText.count > InLineFormBubbleView.headerTextLimit){
                    headerText = String(headerText[..<headerText.index(headerText.startIndex, offsetBy: InLineFormBubbleView.headerTextLimit)]) + "..."
                }
                self.headingLabel.setHTMLString(headerText, withWidth: BubbleViewMaxWidth - 20)
                
                let jsonDecoder = JSONDecoder()
                guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject as Any , options: .prettyPrinted),
                    let allItems = try? jsonDecoder.decode(Componentss.self, from: jsonData) else {
                        return
                }
                arrayOfComponents = allItems.elements ?? []
                arrayOfElements = []
                for i in 0..<arrayOfComponents.count{
                    let elements = arrayOfComponents[i]
                    if i == 0{
                        let title = elements.title
                        customDropDownSeletct = "Select"//title ?? ""
                        inlineTextField.text = customDropDownSeletct
                        if customDropDownShowText{
                            customDropDownText = customDropDownSeletct
                            //NotificationCenter.default.post(name: Notification.Name(customDropDownTextAppendNotification), object: customDropDownSeletct)
                            customDropDownShowText = false
                        }else{
                            inlineTextField.text = customDropDownText
                        }
                        
                    }
                    arrayOfElements.add(elements.title ?? "")
                }
                
            }
        }
    }
    
    override var intrinsicContentSize : CGSize {
        let limitingSize: CGSize  = CGSize(width: BubbleViewMaxWidth - 20, height: CGFloat.greatestFiniteMagnitude)
        let headingLabelSize: CGSize = self.headingLabel.sizeThatFits(limitingSize)
        return CGSize(width: BubbleViewMaxWidth-60, height: headingLabelSize.height + 80)
    }
    
    @objc func tapsOnInlineFormBtn(_ sender:UIButton) {
        print("Hi")
        let component: KREComponent = components.firstObject as! KREComponent
        if (component.componentDesc != nil) {
            let jsonString = component.componentDesc
            NotificationCenter.default.post(name: Notification.Name(customDropDownTemplateNotification), object: jsonString)
        }
    }
    
}
