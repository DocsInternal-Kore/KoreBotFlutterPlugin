import UIKit
import korebotplugin

protocol ComposeBarViewDelegate {
    func composeBarView(_: ComposeBarView, sendButtonAction text: String)
    func composeBarViewSpeechToTextButtonAction(_: ComposeBarView)
    func composeBarViewDidBecomeFirstResponder(_: ComposeBarView)
    func composeBarTaskMenuButtonAction(_: ComposeBarView)
    func showTypingToAgent(_: ComposeBarView)
    func stopTypingToAgent(_: ComposeBarView)
}


class ComposeBarView: UIView {
    let bundle = KREResourceLoader.shared.resourceBundle()
    
    public var delegate: ComposeBarViewDelegate?
    
    fileprivate var topLineView: UIView!
    fileprivate var bottomLineView: UIView!
    public var growingTextView: KREGrowingTextView!
    fileprivate var sendButton: UIButton!
    fileprivate var menuButton: UIButton!
    fileprivate var speechToTextButton: UIButton!
    
    fileprivate var textViewTrailingConstraint: NSLayoutConstraint!
    fileprivate(set) public var isKeyboardEnabled: Bool = false
    var attributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font: UIFont(name: regularCustomFont, size: 14.0) as Any, NSAttributedString.Key.foregroundColor: UIColor.init(hexString:"#7C7C7C")]
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupViews()
    }
    
    fileprivate func setupViews() {
        self.backgroundColor = UIColor.init(hexString: "#f8f9fc")
        //loadCustomFonts()
        
        self.growingTextView = KREGrowingTextView(frame: CGRect.zero)
        self.growingTextView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.growingTextView)
        self.growingTextView.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .horizontal)
        
        let composeBarTextColor = UIColor.init(hexString: (brandingShared.widgetFooterTextColor) ?? "#26344A")
        self.growingTextView.textView.tintColor = composeBarTextColor
        self.growingTextView.textView.textColor = composeBarTextColor
        self.growingTextView.textView.textAlignment = .right
        self.growingTextView.maxNumberOfLines = 10
        
        self.growingTextView.font = UIFont(name: regularCustomFont, size: 15.0) ?? UIFont.systemFont(ofSize: 15.0)
        self.growingTextView.textView.textColor = .black
        self.growingTextView.animateHeightChange = true
        self.growingTextView.backgroundColor = .clear
        self.growingTextView.layer.cornerRadius = 10.0
        self.growingTextView.isUserInteractionEnabled = false
        
        attributes = [NSAttributedString.Key.font: UIFont(name: regularCustomFont, size: 14.0) ?? UIFont.systemFont(ofSize: 15.0), NSAttributedString.Key.foregroundColor: UIColor.init(hexString: (brandingShared.widgetDividerColor) ?? "#7C7C7C")]
        
        self.growingTextView.placeholderAttributedText = NSAttributedString(string: "Type your Message here", attributes:attributes)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.textDidBeginEditingNotification(_ :)), name: UITextView.textDidBeginEditingNotification, object: self.growingTextView.textView)
        NotificationCenter.default.addObserver(self, selector: #selector(self.textDidChangeNotification(_ :)), name: UITextView.textDidChangeNotification, object: self.growingTextView.textView)
        
        
        self.menuButton = UIButton.init(frame: CGRect.zero)
        self.menuButton.translatesAutoresizingMaskIntoConstraints = false
        self.menuButton.layer.cornerRadius = 5
        self.menuButton.setTitleColor(Common.UIColorRGB(0xFFFFFF), for: .normal)
        self.menuButton.setTitleColor(Common.UIColorRGB(0x999999), for: .disabled)
        //self.menuButton.setImage(UIImage(named: "Menu", in: bundle, compatibleWith: nil), for: .normal)
        let menuImage = UIImage(named: "Menu", in: bundle, compatibleWith: nil)
        let tintedMenuImage = menuImage?.withRenderingMode(.alwaysTemplate)
        self.menuButton.setImage(tintedMenuImage, for: .normal)
        self.menuButton.tintColor = .black
        
        self.menuButton.titleLabel?.font = UIFont(name: boldCustomFont, size: 14.0)
        self.menuButton.addTarget(self, action: #selector(self.taskMenuButtonAction(_:)), for: .touchUpInside)
        self.menuButton.isHidden = false
        self.menuButton.contentEdgeInsets = UIEdgeInsets(top: 9.0, left: 3.0, bottom: 7.0, right: 3.0)
        self.menuButton.clipsToBounds = true
        self.addSubview(self.menuButton)
        
        
        self.sendButton = UIButton.init(frame: CGRect.zero)
        //self.sendButton.setTitle("Send", for: .normal)
        self.sendButton.translatesAutoresizingMaskIntoConstraints = false
        //self.sendButton.backgroundColor = widgetHeaderColor
        
        if preferred_language_Type == preferredLanguage{
            self.sendButton.setImage(UIImage(named: "sendAr", in: bundle, compatibleWith: nil), for: .normal)
        }else{
            self.sendButton.setImage(UIImage(named: "send", in: bundle, compatibleWith: nil), for: .normal)
        }
        
        self.sendButton.layer.cornerRadius = 5
        self.sendButton.setTitleColor(Common.UIColorRGB(0xFFFFFF), for: .normal)
        self.sendButton.setTitleColor(Common.UIColorRGB(0x999999), for: .disabled)
        self.sendButton.titleLabel?.font = UIFont(name: boldCustomFont, size: 14.0)
        self.sendButton.addTarget(self, action: #selector(self.sendButtonAction(_:)), for: .touchUpInside)
        self.sendButton.isHidden = true
        self.sendButton.contentEdgeInsets = UIEdgeInsets(top: 9.0, left: 3.0, bottom: 7.0, right: 3.0)
        self.sendButton.clipsToBounds = true
        self.addSubview(self.sendButton)
        
        self.speechToTextButton = UIButton.init(frame: CGRect.zero)
        self.speechToTextButton.setTitle("", for: .normal)
        self.speechToTextButton.translatesAutoresizingMaskIntoConstraints = false
        
        let audioImage = UIImage(named: "audio_icon", in: bundle, compatibleWith: nil)
        let tintedaudioImage = audioImage?.withRenderingMode(.alwaysTemplate)
        self.speechToTextButton.setImage(tintedaudioImage, for: .normal)
        self.speechToTextButton.tintColor = .black
        
        //self.speechToTextButton.setImage(UIImage(named: "audio_icon", in: bundle, compatibleWith: nil), for: .normal)
        self.speechToTextButton.layer.cornerRadius = 5.0
        self.speechToTextButton.backgroundColor = .clear
        self.speechToTextButton.imageView?.contentMode = .scaleAspectFit
        self.speechToTextButton.addTarget(self, action: #selector(self.speechToTextButtonAction(_:)), for: .touchUpInside)
        self.speechToTextButton.isHidden = true
        self.speechToTextButton.contentEdgeInsets = UIEdgeInsets(top: 6.0, left: 3.0, bottom: 5.0, right: 3.0)
        self.speechToTextButton.clipsToBounds = true
        self.addSubview(self.speechToTextButton)
        
        self.topLineView = UIView.init(frame: CGRect.zero)
        self.topLineView.backgroundColor = .lightGray
        self.topLineView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.topLineView)
        
        self.bottomLineView = UIView.init(frame: CGRect.zero)
        self.bottomLineView.backgroundColor = .clear
        self.bottomLineView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.bottomLineView)
        
        let views: [String : Any] = ["topLineView": self.topLineView, "bottomLineView": self.bottomLineView,"menuButton": self.menuButton, "growingTextView": self.growingTextView, "sendButton": self.sendButton, "speechToTextButton": self.speechToTextButton]
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[topLineView]|", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[topLineView(0.5)]", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[bottomLineView]|", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[bottomLineView(0.5)]|", options:[], metrics:nil, views:views))
        
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[menuButton(0)]-10-[growingTextView]-10-[sendButton(30)]-0-[speechToTextButton(30)]-15-|", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[growingTextView]-8-|", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|->=3-[sendButton]-12-|", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|->=3-[menuButton]-12-|", options:[], metrics:nil, views:views))
        self.addConstraint(NSLayoutConstraint.init(item: self.sendButton as Any, attribute: .centerY, relatedBy: .equal, toItem: self.speechToTextButton as Any, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint.init(item: self.sendButton as Any, attribute: .height, relatedBy: .equal, toItem: self.speechToTextButton as Any, attribute: .height, multiplier: 1.0, constant: 0.0))
        self.speechToTextButton.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .horizontal)
        self.speechToTextButton.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .vertical)
        self.speechToTextButton.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .horizontal)
        self.speechToTextButton.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .vertical)
        
        self.textViewTrailingConstraint = NSLayoutConstraint.init(item: self, attribute: .trailing, relatedBy: .equal, toItem: self.growingTextView, attribute: .trailing, multiplier: 1.0, constant: 15.0)
        self.addConstraint(self.textViewTrailingConstraint)
        
        self.growingTextView.placeholderLabel.frame = CGRect(x: self.growingTextView.placeholderLabel.frame.origin.x, y: self.growingTextView.placeholderLabel.frame.origin.y, width: UIScreen.main.bounds.size.width - 120, height: 21.0)

    }
    
    public func composeBarLanguageChange(){
        if preferred_language_Type == preferredLanguage{
            self.semanticContentAttribute = .forceRightToLeft
            self.growingTextView.textView.textAlignment = .right
            self.growingTextView.placeholderAttributedText = NSAttributedString(string: "اكتب رسالتك هنا", attributes:attributes)
            self.growingTextView.placeholderLabel.textAlignment = .right
            self.growingTextView.semanticContentAttribute = .forceRightToLeft
            self.sendButton.setImage(UIImage(named: "sendAr", in: bundle, compatibleWith: nil), for: .normal)
        }else{
            self.semanticContentAttribute = .forceLeftToRight
            self.growingTextView.textView.textAlignment = .left
            self.growingTextView.placeholderAttributedText = NSAttributedString(string: "Type your Message here", attributes:attributes)
              self.growingTextView.placeholderLabel.textAlignment = .left
            self.growingTextView.semanticContentAttribute = .forceLeftToRight
            self.sendButton.setImage(UIImage(named: "send", in: bundle, compatibleWith: nil), for: .normal)
        }
        
    }
    
    //MARK: Public methods
    public func clear() {
        self.clearButtonAction(self)
    }
    
    public func configureViewForKeyboard(_ enable: Bool) {
        self.textViewTrailingConstraint.isActive = !enable
        self.isKeyboardEnabled = enable
        //self.growingTextView.textView.textAlignment = enable ? .left : .right
        self.growingTextView.isUserInteractionEnabled = enable
        self.valueChanged()
    }
    
    public func setText(_ text: String) -> Void {
        self.growingTextView.textView.text = text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        self.textDidChangeNotification(Notification(name: UITextView.textDidChangeNotification))
    }
    
    //MARK: Private methods
    
    @objc fileprivate func clearButtonAction(_ sender: AnyObject!) {
        self.growingTextView.textView.text = "";
        self.textDidChangeNotification(Notification(name: UITextView.textDidChangeNotification))
    }
    
    @objc fileprivate func sendButtonAction(_ sender: AnyObject!) {
        var text = self.growingTextView.textView.text
        text = text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        // is there any text?
        if ((text?.count)! > 0) {
            self.delegate?.composeBarView(self, sendButtonAction: text!)
        }
    }
    @objc fileprivate func taskMenuButtonAction(_ sender: UIButton!) {
        self.delegate?.composeBarTaskMenuButtonAction(self)
        
        let menuImage = UIImage(named: "Menu", in: bundle, compatibleWith: nil)
        let tintedMenuImage = menuImage?.withRenderingMode(.alwaysTemplate)
        self.menuButton.setImage(tintedMenuImage, for: .normal)
        self.menuButton.tintColor = .black
        
        self.growingTextView.isUserInteractionEnabled = true
        self.sendButton.isUserInteractionEnabled = true
        self.speechToTextButton.isUserInteractionEnabled = true
    }
    
    @objc fileprivate func speechToTextButtonAction(_ sender: AnyObject) {
        self.delegate?.composeBarViewSpeechToTextButtonAction(self)
    }
    
    fileprivate func valueChanged() {
        let hasText = self.growingTextView.textView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count > 0
        //self.sendButton.isEnabled = hasText //kk
        if hasText{
            topLineView.backgroundColor = .black
            var sendImage = UIImage.init(named: "sendS")
            if preferred_language_Type == preferredLanguage{
                 sendImage = UIImage(named: "SendSAr", in: bundle, compatibleWith: nil)
            }else{
                 sendImage = UIImage(named: "sendS", in: bundle, compatibleWith: nil)
            }
            let tintedsendImage = sendImage?.withRenderingMode(.alwaysTemplate)
            self.sendButton.setImage(tintedsendImage, for: .normal)
            self.sendButton.tintColor = .black
            
        }else{
            self.sendButton.tintColor = .clear
            topLineView.backgroundColor = .lightGray
            if preferred_language_Type == preferredLanguage{
                self.sendButton.setImage(UIImage(named: "sendAr", in: bundle, compatibleWith: nil), for: .normal)
            }else{
                self.sendButton.setImage(UIImage(named: "send", in: bundle, compatibleWith: nil), for: .normal)
            }
        }
        
        if self.isKeyboardEnabled {
            self.sendButton.isHidden = false
            self.speechToTextButton.isHidden =  false
            self.menuButton.isHidden = false
        }else{
            self.sendButton.isHidden = true
            self.speechToTextButton.isHidden = true
            self.menuButton.isHidden = true
        }
    }
    
    // MARK: Notification handler
    @objc fileprivate func textDidBeginEditingNotification(_ notification: Notification) {
//        if preferred_language_Type == preferredLanguage{
//            self.sendButton.setImage(UIImage(named: "SendSAr", in: bundle, compatibleWith: nil), for: .normal)
//        }else{
//            self.sendButton.setImage(UIImage(named: "sendS", in: bundle, compatibleWith: nil), for: .normal)
//        }
        
        self.delegate?.composeBarViewDidBecomeFirstResponder(self)
    }
    
    @objc fileprivate func textDidChangeNotification(_ notification: Notification) {
        self.valueChanged()
        if isAgentConnect{
            var text = self.growingTextView.textView.text
            text = text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if text?.count == 0{
                self.delegate?.stopTypingToAgent(self)
            }else{
                self.delegate?.showTypingToAgent(self)
            }
        }
    }
    
    // MARK: UIResponder Methods
    
    open override var isFirstResponder: Bool {
//        if preferred_language_Type == preferredLanguage{
//            self.sendButton.setImage(UIImage(named: "sendAr", in: bundle, compatibleWith: nil), for: .normal)
//        }else{
//            self.sendButton.setImage(UIImage(named: "send", in: bundle, compatibleWith: nil), for: .normal)
//        }
        
        return self.growingTextView.isFirstResponder
    }
    
    open override func becomeFirstResponder() -> Bool {
        return self.growingTextView.becomeFirstResponder()
    }
    
    open override func resignFirstResponder() -> Bool {
//        if preferred_language_Type == preferredLanguage{
//            self.sendButton.setImage(UIImage(named: "sendAr", in: bundle, compatibleWith: nil), for: .normal)
//        }else{
//        self.sendButton.setImage(UIImage(named: "send", in: bundle, compatibleWith: nil), for: .normal)
//        }
        return self.growingTextView.resignFirstResponder()
    }
    
    // MARK:- deinit
    deinit {
        self.topLineView = nil
        self.bottomLineView = nil
        self.growingTextView = nil
        self.sendButton = nil
        self.speechToTextButton = nil
        self.textViewTrailingConstraint = nil
    }
    
    func loadCustomFonts() {
           let bundleName = "Gilroy"
           guard let bundleUrl = Bundle(for: Self.self).url(forResource: bundleName, withExtension: "bundle"),
               let bundle = Bundle(url: bundleUrl),
               let urls = bundle.urls(forResourcesWithExtension: "otf", subdirectory: nil) else {
                   return
           }
           
           for url in urls {
               loadFontFile(from: url)
           }
           
           
       }
       
       func loadInterFonts(){
           let bundleName = "Inter"
           guard let bundleUrl = Bundle(for: Self.self).url(forResource: bundleName, withExtension: "bundle"),
               let bundle = Bundle(url: bundleUrl),
               let urls = bundle.urls(forResourcesWithExtension: "ttf", subdirectory: nil) else {
                   return
           }
           
           for url in urls {
               loadFontFile(from: url)
           }
       }
       
       func loadFontFile(from fontUrl: URL) {
           debugPrint(fontUrl)
           guard let fontData = try? Data(contentsOf: fontUrl) else {
               return
           }
           
           guard let cfData = fontData as? CFData, let provider = CGDataProvider(data: cfData), let cgFont = CGFont(provider) else {
               return
           }
           
           var error: Unmanaged<CFError>?
           if !CTFontManagerRegisterGraphicsFont(cgFont, &error) {
               debugPrint("KREFontLoader : error loading Font")
           }
       }
   }

//public extension UITextView
//{
//    override var textInputMode: UITextInputMode?
//    {
//        var locale: Locale?
//        if preferredLanguage == preferred_language_Type{
//            locale = Locale(identifier: "ar-SA") // your preferred locale en_US
//        }else{
//            locale = Locale(identifier: "en_US") // your preferred locale en_US
//        }
//        return
//            UITextInputMode.activeInputModes.first(where: { $0.primaryLanguage == locale?.languageCode })
//            ??
//            super.textInputMode
//    }
//}
