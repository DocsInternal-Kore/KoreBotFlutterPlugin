//
//  ComposeBarView.swift
//  KoreBotSDKDemo
//
//  Created by Anoop Dhiman on 26/07/17.
//  Copyright © 2017 Kore. All rights reserved.
//

import UIKit

protocol ComposeBarViewDelegate {
    func composeBarView(_: ComposeBarView, sendButtonAction text: String)
    func composeBarViewSpeechToTextButtonAction(_: ComposeBarView)
    func composeBarViewDidBecomeFirstResponder(_: ComposeBarView)
    func composeBarTaskMenuButtonAction(_: ComposeBarView)
    func composeBarAttachmentButtonAction(_: ComposeBarView)
    func showTypingToAgent(_: ComposeBarView)
    func stopTypingToAgent(_: ComposeBarView)
}

class ComposeBarView: UIView {
    let bundle = Bundle.sdkModule
    public var delegate: ComposeBarViewDelegate?
    
    fileprivate var topLineView: UIView!
    fileprivate var bottomLineView: UIView!
    public var growingTextView: KREGrowingTextView!
    fileprivate var sendButton: UIButton!
    fileprivate var menuButton: UIButton!
    fileprivate var attachmentButton: UIButton!
    fileprivate var speechToTextButton: UIButton!

    fileprivate var textViewTrailingConstraint: NSLayoutConstraint!
    fileprivate(set) public var isKeyboardEnabled: Bool = false
    
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

    private func androidVectorIconImage(size: CGSize, viewport: CGSize, padding: UIEdgeInsets, path: UIBezierPath) -> UIImage {
        let contentRect = CGRect(
            x: padding.left,
            y: padding.top,
            width: size.width - padding.left - padding.right,
            height: size.height - padding.top - padding.bottom
        )
        let scale = min(contentRect.width / viewport.width, contentRect.height / viewport.height)
        let drawSize = CGSize(width: viewport.width * scale, height: viewport.height * scale)
        let drawOrigin = CGPoint(
            x: contentRect.minX + (contentRect.width - drawSize.width) / 2.0,
            y: contentRect.minY + (contentRect.height - drawSize.height) / 2.0
        )

        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { _ in
            UIColor.black.setFill()
            let context = UIGraphicsGetCurrentContext()
            context?.saveGState()
            context?.translateBy(x: drawOrigin.x, y: drawOrigin.y)
            context?.scaleBy(x: scale, y: scale)
            path.fill()
            context?.restoreGState()
        }

        return image.withRenderingMode(.alwaysTemplate)
    }

    private func androidAttachmentIconImage() -> UIImage {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 5.0, y: 0.5))
        path.addCurve(to: CGPoint(x: 10.0, y: 5.614), controlPoint1: CGPoint(x: 7.773, y: 0.5), controlPoint2: CGPoint(x: 10.0, y: 2.8))
        path.addLine(to: CGPoint(x: 10.0, y: 11.341))
        path.addCurve(to: CGPoint(x: 9.313, y: 12.0), controlPoint1: CGPoint(x: 10.0, y: 11.705), controlPoint2: CGPoint(x: 9.692, y: 12.0))
        path.addCurve(to: CGPoint(x: 8.629, y: 11.401), controlPoint1: CGPoint(x: 8.955, y: 12.0), controlPoint2: CGPoint(x: 8.66, y: 11.737))
        path.addLine(to: CGPoint(x: 8.626, y: 11.341))
        path.addLine(to: CGPoint(x: 8.626, y: 5.614))
        path.addCurve(to: CGPoint(x: 5.0, y: 1.818), controlPoint1: CGPoint(x: 8.626, y: 3.507), controlPoint2: CGPoint(x: 6.991, y: 1.818))
        path.addCurve(to: CGPoint(x: 1.374, y: 5.614), controlPoint1: CGPoint(x: 3.009, y: 1.818), controlPoint2: CGPoint(x: 1.374, y: 3.507))
        path.addLine(to: CGPoint(x: 1.374, y: 11.977))
        path.addCurve(to: CGPoint(x: 3.673, y: 14.182), controlPoint1: CGPoint(x: 1.374, y: 13.195), controlPoint2: CGPoint(x: 2.403, y: 14.182))
        path.addCurve(to: CGPoint(x: 5.972, y: 11.977), controlPoint1: CGPoint(x: 4.943, y: 14.182), controlPoint2: CGPoint(x: 5.972, y: 13.195))
        path.addLine(to: CGPoint(x: 5.972, y: 5.614))
        path.addCurve(to: CGPoint(x: 5.0, y: 4.681), controlPoint1: CGPoint(x: 5.972, y: 5.099), controlPoint2: CGPoint(x: 5.537, y: 4.681))
        path.addCurve(to: CGPoint(x: 4.03, y: 5.55), controlPoint1: CGPoint(x: 4.486, y: 4.681), controlPoint2: CGPoint(x: 4.065, y: 5.065))
        path.addLine(to: CGPoint(x: 4.028, y: 5.614))
        path.addLine(to: CGPoint(x: 4.028, y: 11.341))
        path.addCurve(to: CGPoint(x: 3.341, y: 12.0), controlPoint1: CGPoint(x: 4.028, y: 11.705), controlPoint2: CGPoint(x: 3.721, y: 12.0))
        path.addCurve(to: CGPoint(x: 2.657, y: 11.401), controlPoint1: CGPoint(x: 2.983, y: 12.0), controlPoint2: CGPoint(x: 2.689, y: 11.737))
        path.addLine(to: CGPoint(x: 2.654, y: 11.341))
        path.addLine(to: CGPoint(x: 2.654, y: 5.614))
        path.addCurve(to: CGPoint(x: 5.0, y: 3.364), controlPoint1: CGPoint(x: 2.654, y: 4.371), controlPoint2: CGPoint(x: 3.704, y: 3.364))
        path.addCurve(to: CGPoint(x: 7.346, y: 5.614), controlPoint1: CGPoint(x: 6.296, y: 3.364), controlPoint2: CGPoint(x: 7.346, y: 4.371))
        path.addLine(to: CGPoint(x: 7.346, y: 11.977))
        path.addCurve(to: CGPoint(x: 3.673, y: 15.5), controlPoint1: CGPoint(x: 7.345, y: 13.922), controlPoint2: CGPoint(x: 5.701, y: 15.5))
        path.addCurve(to: CGPoint(x: 0.0, y: 11.977), controlPoint1: CGPoint(x: 1.644, y: 15.5), controlPoint2: CGPoint(x: 0.0, y: 13.923))
        path.addLine(to: CGPoint(x: 0.0, y: 5.614))
        path.addCurve(to: CGPoint(x: 5.0, y: 0.5), controlPoint1: CGPoint(x: 0.0, y: 2.8), controlPoint2: CGPoint(x: 2.227, y: 0.5))
        path.close()

        return androidVectorIconImage(
            size: CGSize(width: 32.0, height: 32.0),
            viewport: CGSize(width: 10.0, height: 16.0),
            padding: UIEdgeInsets(top: 3.0, left: 3.0, bottom: 3.0, right: 3.0),
            path: path
        )
    }

    private func androidMicIconImage() -> UIImage {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 6.0, y: 0.875))
        path.addCurve(to: CGPoint(x: 2.875, y: 4.0), controlPoint1: CGPoint(x: 4.286, y: 0.875), controlPoint2: CGPoint(x: 2.875, y: 2.286))
        path.addLine(to: CGPoint(x: 2.875, y: 9.0))
        path.addCurve(to: CGPoint(x: 6.0, y: 12.125), controlPoint1: CGPoint(x: 2.875, y: 10.714), controlPoint2: CGPoint(x: 4.286, y: 12.125))
        path.addCurve(to: CGPoint(x: 9.125, y: 9.0), controlPoint1: CGPoint(x: 7.714, y: 12.125), controlPoint2: CGPoint(x: 9.125, y: 10.714))
        path.addLine(to: CGPoint(x: 9.125, y: 4.0))
        path.addCurve(to: CGPoint(x: 6.0, y: 0.875), controlPoint1: CGPoint(x: 9.125, y: 2.286), controlPoint2: CGPoint(x: 7.714, y: 0.875))
        path.close()
        path.move(to: CGPoint(x: 6.0, y: 2.125))
        path.addCurve(to: CGPoint(x: 7.875, y: 4.0), controlPoint1: CGPoint(x: 7.035, y: 2.125), controlPoint2: CGPoint(x: 7.875, y: 2.965))
        path.addLine(to: CGPoint(x: 7.875, y: 9.0))
        path.addCurve(to: CGPoint(x: 6.0, y: 10.875), controlPoint1: CGPoint(x: 7.875, y: 10.035), controlPoint2: CGPoint(x: 7.035, y: 10.875))
        path.addCurve(to: CGPoint(x: 4.125, y: 9.0), controlPoint1: CGPoint(x: 4.965, y: 10.875), controlPoint2: CGPoint(x: 4.125, y: 10.035))
        path.addLine(to: CGPoint(x: 4.125, y: 4.0))
        path.addCurve(to: CGPoint(x: 6.0, y: 2.125), controlPoint1: CGPoint(x: 4.125, y: 2.965), controlPoint2: CGPoint(x: 4.965, y: 2.125))
        path.close()
        path.move(to: CGPoint(x: 1.0, y: 8.375))
        path.addCurve(to: CGPoint(x: 0.375, y: 9.0), controlPoint1: CGPoint(x: 0.655, y: 8.375), controlPoint2: CGPoint(x: 0.375, y: 8.655))
        path.addCurve(to: CGPoint(x: 5.375, y: 14.561), controlPoint1: CGPoint(x: 0.375, y: 11.876), controlPoint2: CGPoint(x: 2.577, y: 14.244))
        path.addLine(to: CGPoint(x: 5.375, y: 15.875))
        path.addLine(to: CGPoint(x: 3.5, y: 15.875))
        path.addCurve(to: CGPoint(x: 2.875, y: 16.5), controlPoint1: CGPoint(x: 3.155, y: 15.875), controlPoint2: CGPoint(x: 2.875, y: 16.155))
        path.addCurve(to: CGPoint(x: 3.5, y: 17.125), controlPoint1: CGPoint(x: 2.875, y: 16.845), controlPoint2: CGPoint(x: 3.155, y: 17.125))
        path.addLine(to: CGPoint(x: 8.5, y: 17.125))
        path.addCurve(to: CGPoint(x: 9.125, y: 16.5), controlPoint1: CGPoint(x: 8.845, y: 17.125), controlPoint2: CGPoint(x: 9.125, y: 16.845))
        path.addCurve(to: CGPoint(x: 8.5, y: 15.875), controlPoint1: CGPoint(x: 9.125, y: 16.155), controlPoint2: CGPoint(x: 8.845, y: 15.875))
        path.addLine(to: CGPoint(x: 6.625, y: 15.875))
        path.addLine(to: CGPoint(x: 6.625, y: 14.561))
        path.addCurve(to: CGPoint(x: 11.625, y: 9.0), controlPoint1: CGPoint(x: 9.423, y: 14.244), controlPoint2: CGPoint(x: 11.625, y: 11.876))
        path.addCurve(to: CGPoint(x: 11.0, y: 8.375), controlPoint1: CGPoint(x: 11.625, y: 8.655), controlPoint2: CGPoint(x: 11.345, y: 8.375))
        path.addCurve(to: CGPoint(x: 10.375, y: 9.0), controlPoint1: CGPoint(x: 10.655, y: 8.375), controlPoint2: CGPoint(x: 10.375, y: 8.655))
        path.addCurve(to: CGPoint(x: 6.0, y: 13.375), controlPoint1: CGPoint(x: 10.375, y: 11.407), controlPoint2: CGPoint(x: 8.407, y: 13.375))
        path.addCurve(to: CGPoint(x: 1.625, y: 9.0), controlPoint1: CGPoint(x: 3.593, y: 13.375), controlPoint2: CGPoint(x: 1.625, y: 11.407))
        path.addCurve(to: CGPoint(x: 1.0, y: 8.375), controlPoint1: CGPoint(x: 1.625, y: 8.655), controlPoint2: CGPoint(x: 1.345, y: 8.375))
        path.close()

        return androidVectorIconImage(
            size: CGSize(width: 35.0, height: 30.0),
            viewport: CGSize(width: 12.0, height: 18.0),
            padding: .zero,
            path: path
        )
    }
    
    fileprivate func setupViews() {
        //self.backgroundColor = UIColor.init(hexString: "#eaeaea")
        
        self.growingTextView = KREGrowingTextView(frame: CGRect.zero)
        self.growingTextView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.growingTextView)
        self.growingTextView.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .horizontal)
        
        self.growingTextView.textView.tintColor = .black
        self.growingTextView.textView.textColor = UIColor.init(hexString: (brandingShared.widgetFooterTextColor) ?? "#26344A")
        self.growingTextView.textView.textAlignment = .right
        self.growingTextView.maxNumberOfLines = 10
        self.growingTextView.font = UIFont(name: regularCustomFont, size: 14.0) ?? UIFont.systemFont(ofSize: 14.0)
        self.growingTextView.textContainerInset = UIEdgeInsets(top: 7, left: 0, bottom: 7, right: 0)
        self.growingTextView.animateHeightChange = true
        self.growingTextView.backgroundColor = .white
        self.growingTextView.layer.cornerRadius = 4.0
        self.growingTextView.isUserInteractionEnabled = false
        //self.growingTextView.textView.text = ""
        
        let attributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font: UIFont(name: regularCustomFont, size: 14.0) ?? UIFont.systemFont(ofSize: 14.0), NSAttributedString.Key.foregroundColor: Common.UIColorRGB(0xB5B9BA)]
        self.growingTextView.placeholderAttributedText = NSAttributedString(string: composeBarPlaceholder, attributes:attributes)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.textDidBeginEditingNotification(_ :)), name: UITextView.textDidBeginEditingNotification, object: self.growingTextView.textView)
        NotificationCenter.default.addObserver(self, selector: #selector(self.textDidChangeNotification(_ :)), name: UITextView.textDidChangeNotification, object: self.growingTextView.textView)
        NotificationCenter.default.addObserver(self, selector: #selector(showAttachmentSendButton), name: NSNotification.Name(rawValue: showAttachmentSendButtonNotification), object: nil)
        
        self.menuButton = UIButton.init(frame: CGRect.zero)
        self.menuButton.translatesAutoresizingMaskIntoConstraints = false
        self.menuButton.layer.cornerRadius = 5
        self.menuButton.setTitleColor(Common.UIColorRGB(0xFFFFFF), for: .normal)
        self.menuButton.setTitleColor(Common.UIColorRGB(0x999999), for: .disabled)
        self.menuButton.setImage(UIImage(named: "Menu", in: bundle, compatibleWith: nil), for: .normal)
        self.menuButton.titleLabel?.font = UIFont(name: boldCustomFont, size: 14.0) ?? UIFont.boldSystemFont(ofSize: 14.0)
        self.menuButton.addTarget(self, action: #selector(self.taskMenuButtonAction(_:)), for: .touchUpInside)
        self.menuButton.isHidden = false
        self.menuButton.contentEdgeInsets = UIEdgeInsets(top: 9.0, left: 3.0, bottom: 7.0, right: 3.0)
        self.menuButton.clipsToBounds = true
        self.addSubview(self.menuButton)
        
        self.sendButton = UIButton.init(frame: CGRect.zero)
        self.sendButton.setImage(UIImage(named: "send", in: bundle, compatibleWith: nil), for: .normal)
        self.sendButton.translatesAutoresizingMaskIntoConstraints = false
        self.sendButton.backgroundColor = .clear
        self.sendButton.layer.cornerRadius = 4
        self.sendButton.setTitleColor(Common.UIColorRGB(0xFFFFFF), for: .normal)
        self.sendButton.setTitleColor(Common.UIColorRGB(0x999999), for: .disabled)
        self.sendButton.imageView?.contentMode = .scaleAspectFit
        self.sendButton.addTarget(self, action: #selector(self.sendButtonAction(_:)), for: .touchUpInside)
        self.sendButton.isHidden = true
        self.sendButton.contentEdgeInsets = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
        self.sendButton.clipsToBounds = true
        self.addSubview(self.sendButton)
        
        self.speechToTextButton = UIButton.init(frame: CGRect.zero)
        self.speechToTextButton.setTitle("", for: .normal)
        self.speechToTextButton.translatesAutoresizingMaskIntoConstraints = false
        self.speechToTextButton.layer.cornerRadius = 5.0
        self.speechToTextButton.backgroundColor = .clear
        self.speechToTextButton.imageView?.contentMode = .scaleAspectFit
        self.speechToTextButton.setImage(self.androidMicIconImage(), for: .normal)
        self.speechToTextButton.tintColor = UIColor.init(hexString: "#697586")
        self.speechToTextButton.addTarget(self, action: #selector(self.speechToTextButtonAction(_:)), for: .touchUpInside)
        self.speechToTextButton.isHidden = true
        self.speechToTextButton.contentEdgeInsets = .zero
        self.speechToTextButton.clipsToBounds = true
        self.addSubview(self.speechToTextButton)
        
        self.attachmentButton = UIButton.init(frame: CGRect.zero)
        self.attachmentButton.translatesAutoresizingMaskIntoConstraints = false
        self.attachmentButton.layer.cornerRadius = 5
        self.attachmentButton.setTitleColor(Common.UIColorRGB(0xFFFFFF), for: .normal)
        self.attachmentButton.setTitleColor(Common.UIColorRGB(0x999999), for: .disabled)
        self.attachmentButton.setImage(self.androidAttachmentIconImage(), for: .normal)
        self.attachmentButton.tintColor = UIColor.init(hexString: "#697586")
        self.attachmentButton.imageView?.contentMode = .scaleAspectFit
        self.attachmentButton.addTarget(self, action: #selector(self.composeBarAttachmentButtonAction(_:)), for: .touchUpInside)
        
        self.attachmentButton.contentEdgeInsets = .zero
        self.attachmentButton.clipsToBounds = true
        self.addSubview(self.attachmentButton)
        
        self.topLineView = UIView.init(frame: CGRect.zero)
        self.topLineView.backgroundColor = .clear
        self.topLineView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.topLineView)
        
        self.bottomLineView = UIView.init(frame: CGRect.zero)
        self.bottomLineView.backgroundColor = .clear
        self.bottomLineView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.bottomLineView)
        
        let views: [String : Any] = ["topLineView": self.topLineView, "bottomLineView": self.bottomLineView,"menuButton": self.menuButton, "growingTextView": self.growingTextView, "sendButton": self.sendButton, "speechToTextButton": self.speechToTextButton, "attachmentButton": attachmentButton]
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[topLineView]|", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[topLineView(0.5)]", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[bottomLineView]|", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[bottomLineView(0.5)]|", options:[], metrics:nil, views:views))
        
        var menuBtnWidth = 0
        menuBtnWidth = isShowComposeMenuBtn == true ? 30 : 0
        
        var attachmentBtnWidth = 0
        attachmentBtnWidth = SDKConfiguration.botConfig.isShowAttachmentIcon == true ? 32 : 0
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[attachmentButton(\(attachmentBtnWidth))]-5-[menuButton(\(menuBtnWidth))]-5-[growingTextView]-5-[sendButton(35)]-10-|", options:[], metrics:nil, views:views))
       self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[growingTextView]-5-[speechToTextButton(35)]-10-|", options:[], metrics:nil, views:views))
       self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-6-[growingTextView]-6-|", options:[], metrics:nil, views:views))
       self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[sendButton(35)]", options:[], metrics:nil, views:views))
       self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[speechToTextButton(30)]", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[menuButton(30)]", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[attachmentButton(32)]", options:[], metrics:nil, views:views))
       self.addConstraint(NSLayoutConstraint.init(item: self.sendButton as Any, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0))
       self.addConstraint(NSLayoutConstraint.init(item: self.speechToTextButton as Any, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint.init(item: self.menuButton as Any, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint.init(item: self.attachmentButton as Any, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0))
       self.speechToTextButton.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .horizontal)
       self.speechToTextButton.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .vertical)
       self.speechToTextButton.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .horizontal)
       self.speechToTextButton.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .vertical)
       
       self.textViewTrailingConstraint = NSLayoutConstraint.init(item: self, attribute: .trailing, relatedBy: .equal, toItem: self.growingTextView, attribute: .trailing, multiplier: 1.0, constant: 15.0)
       self.addConstraint(self.textViewTrailingConstraint)
    }
    
    func brandingChnages(){
        
        let attributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font: UIFont(name: regularCustomFont, size: 14.0) ?? UIFont.systemFont(ofSize: 14.0), NSAttributedString.Key.foregroundColor: UIColor.init(hexString: (brandingShared.widgetFooterPlaceholderColor) ?? "#000000")]
        self.growingTextView.placeholderAttributedText = NSAttributedString(string: composeBarPlaceholder, attributes:attributes)
        
        self.growingTextView.textView.tintColor = UIColor.init(hexString: (brandingShared.widgetFooterTextColor) ?? "#26344A")
        self.growingTextView.textView.textColor = UIColor.init(hexString: (brandingShared.widgetFooterTextColor) ?? "#26344A")
        self.growingTextView.layer.borderColor =  UIColor.init(hexString: (brandingShared.widgetFooterBorderColor) ?? "#000000").cgColor
        self.growingTextView.layer.borderWidth = 1.0
        self.growingTextView.clipsToBounds = true
        
        let botResponseTextTintHex = (brandingShared.botchatTextColor?.isEmpty == false) ? brandingShared.botchatTextColor! : "#26344A"
        let userResponseTextTintHex = (brandingShared.userchatTextColor?.isEmpty == false) ? brandingShared.userchatTextColor! : botResponseTextTintHex
        let userResponseBgTintHex = (brandingShared.userchatBgColor?.isEmpty == false) ? brandingShared.userchatBgColor! : "#0078cd"
        let botResponseTextTintColor = UIColor.init(hexString: botResponseTextTintHex)
        let userResponseTextTintColor = UIColor.init(hexString: userResponseTextTintHex)
        let userResponseBgTintColor = UIColor.init(hexString: userResponseBgTintHex)
        attachmentButton.setImage(self.androidAttachmentIconImage(), for: .normal)
        attachmentButton.tintColor = botResponseTextTintColor
    
        speechToTextButton.setImage(self.androidMicIconImage(), for: .normal)
        speechToTextButton.tintColor = botResponseTextTintColor
        
        
        let menuImage = UIImage(named: "Menu", in: bundle, compatibleWith: nil)
        let tintedMenuImage = menuImage?.withRenderingMode(.alwaysTemplate)
        menuButton.setImage(tintedMenuImage, for: .normal)
        menuButton.tintColor = botResponseTextTintColor
        
        let sendBtnImage = UIImage(named: "send", in: bundle, compatibleWith: nil)
        let tintedsendImage = sendBtnImage?.withRenderingMode(.alwaysTemplate)
        sendButton.setImage(tintedsendImage, for: .normal)
        sendButton.backgroundColor = userResponseBgTintColor
        sendButton.tintColor = userResponseTextTintColor
        sendButton.layer.cornerRadius = 4
        sendButton.clipsToBounds = true
        
    }
    
    //MARK: Public methods
    public func clear() {
        self.clearButtonAction(self)
    }
    
    public func configureViewForKeyboard(_ enable: Bool) {
        self.textViewTrailingConstraint.isActive = !enable
        self.isKeyboardEnabled = enable
        self.growingTextView.textView.textAlignment = enable ? .left : .right
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
        if attachmentKeybord{
            self.delegate?.composeBarView(self, sendButtonAction: text ?? "")
        }else{
            if ((text?.count)! > 0) {
                self.delegate?.composeBarView(self, sendButtonAction: text!)
            }
        }
        
    }
    @objc fileprivate func taskMenuButtonAction(_ sender: UIButton!) {
        self.delegate?.composeBarTaskMenuButtonAction(self)
        self.menuButton.setImage(UIImage(named: "Menu", in: bundle, compatibleWith: nil), for: .normal)
        self.growingTextView.isUserInteractionEnabled = true
        self.sendButton.isUserInteractionEnabled = true
        self.speechToTextButton.isUserInteractionEnabled = true
    }
    @objc fileprivate func composeBarAttachmentButtonAction(_ sender: UIButton!) {
        self.delegate?.composeBarAttachmentButtonAction(self)
    }
    
    
    @objc fileprivate func speechToTextButtonAction(_ sender: AnyObject) {
        self.delegate?.composeBarViewSpeechToTextButtonAction(self)
    }
    
    fileprivate func valueChanged() {
        let hasText = self.growingTextView.textView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count > 0
        self.sendButton.isEnabled = hasText
        if self.isKeyboardEnabled {
            self.attachmentButton.isHidden = false
            if attachmentKeybord{
                self.sendButton.isHidden = false
                self.sendButton.isEnabled = true
                self.speechToTextButton.isHidden = true
            }else{
                if SDKConfiguration.botConfig.isShowSpeachToTextIcon{
                    self.sendButton.isHidden = !hasText
                    self.speechToTextButton.isHidden = hasText
                }else{
                    self.sendButton.isHidden = false
                    self.speechToTextButton.isHidden = true
                }
            }
            self.menuButton.isHidden = false
        }else{
            self.sendButton.isHidden = true
            self.speechToTextButton.isHidden = true
            self.menuButton.isHidden = true
            self.attachmentButton.isHidden = true
        }
    }
    
    // MARK: Notification handler
    @objc fileprivate func textDidBeginEditingNotification(_ notification: Notification) {
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
        return self.growingTextView.isFirstResponder
    }
    
    open override func becomeFirstResponder() -> Bool {
        return self.growingTextView.becomeFirstResponder()
    }
    
    open override func resignFirstResponder() -> Bool {
        return self.growingTextView.resignFirstResponder()
    }
    @objc func showAttachmentSendButton(notification:Notification){
        self.valueChanged()
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
}
