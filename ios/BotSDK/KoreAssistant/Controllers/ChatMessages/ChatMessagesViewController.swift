//
//  ChatMessagesViewController.swift
//  KoreBotSDKDemo
//
//  Created by Anoop Dhiman on 26/07/17.
//  Copyright © 2017 Kore. All rights reserved.
//

import UIKit
import AVFoundation
import SafariServices
import korebotplugin
import Alamofire
//import AlamofireImage
import CoreData
import ObjectMapper

class ChatMessagesViewController: UIViewController, BotMessagesViewDelegate, ComposeBarViewDelegate, KREGrowingTextViewDelegate, NewListViewDelegate, TaskMenuNewDelegate, calenderSelectDelegate, ListWidgetViewDelegate, feedbackViewDelegate, InfoViewDelegate, OTPValidationDelegate, resetPinDelegate, salikPinDelegate, timeSlotDelegate, customDropDownDelegate, resetPasswordDelegate, FormTemplateDelegate, UIGestureRecognizerDelegate , userValidationDelegate{
    // MARK: properties
    let bundle = KREResourceLoader.shared.resourceBundle()
    var messagesRequestInProgress: Bool = false
    var historyRequestInProgress: Bool = false
    var thread: KREThread?
    var botClient: BotClient!
    var tapToDismissGestureRecognizer: UITapGestureRecognizer!
    
    @IBOutlet var chatHistoryImg: UIImageView!
    @IBOutlet weak var topTiltlLbl: UILabel!
    @IBOutlet weak var threadContainerView: UIView!
    @IBOutlet weak var quickSelectContainerView: UIView!
    @IBOutlet weak var composeBarContainerView: UIView!
    @IBOutlet weak var audioComposeContainerView: UIView!
    @IBOutlet weak var panelCollectionViewContainerView: UIView!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet var backBtn: UIButton!
    
    @IBOutlet var headerView: UIView!
    @IBOutlet weak var quickSelectContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var composeBarContainerHeightConstraint: NSLayoutConstraint!
    var composeViewBottomConstraint: NSLayoutConstraint!
    var audioComposeContainerHeightConstraint: NSLayoutConstraint!
    var botMessagesView: BotMessagesView!
    var composeView: ComposeBarView!
    var audioComposeView: AudioComposeView!
    var quickReplyView: KREQuickSelectView!
    var typingStatusView: KRETypingStatusView!
    var webViewController: SFSafariViewController!
    var disableComposeView: UIView!
    var disableAudioView: UIView!
    
    var taskMenuKeyBoard = true
    @IBOutlet weak var taskMenuContainerView: UIView!
    @IBOutlet weak var taskMenuContainerHeightConstant: NSLayoutConstraint!
    var taskMenuHeight = 0
    
    var panelCollectionView: KAPanelCollectionView!
    var launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    
    let sttClient = KoraASRService.shared
    var speechSynthesizer: AVSpeechSynthesizer!
    
    public var authInfoModel: AuthInfoModel?
    public var userInfoModel: UserModel?
    public var user: KREUser?
    public var sheetController: KABottomSheetController?
    var isShowAudioComposeView = false
    var insets: UIEdgeInsets = .zero
    @IBOutlet weak var panelCollectionViewContainerHeightConstraint: NSLayoutConstraint!
    var offSet = 0
    
    
    @IBOutlet weak var backgroungImageView: UIImageView!
    @IBOutlet weak var dropDownBtn: UIButton!
    let colorDropDown = DropDown()
    lazy var dropDowns: [DropDown] = {
        return [
            self.colorDropDown
        ]
    }()
    
    public var maxPanelHeight: CGFloat {
        var maxHeight = UIScreen.main.bounds.height
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        let delta: CGFloat = 15.0
        maxHeight -= statusBarHeight
        maxHeight -= delta
        return maxHeight
    }
    
    public var panelHeight: CGFloat {
        var maxHeight = maxPanelHeight
        maxHeight -= self.isShowAudioComposeView == true ? self.audioComposeView.bounds.height : self.composeView.bounds.height
        return maxHeight-panelCollectionViewContainerView.bounds.height - insets.bottom
    }
    
    let linerProgressBar: LinearProgressBar = {
        let progressBar = LinearProgressBar()
        progressBar.backgroundColor = .clear
        progressBar.progressBarColor = textlinkColor
        progressBar.progressBarWidth = 4
        progressBar.cornerRadius = 2
        
        return progressBar
    }()
    
    @IBOutlet var leftMenuContainerView: UIView!
    @IBOutlet weak var leftMenuContainerSubView: UIView!
    @IBOutlet weak var leftMenuBackBtn: UIButton!
    var leftMenuView: LeftMenuView!
    @IBOutlet var leftMenuTitleLbl: UILabel!
    
    @IBOutlet var chatMaskview: UIView!
    var kaBotClient = KABotClient()
    
    var quickReplySuggesstionLblHeightConstraint: NSLayoutConstraint!
    var quickReplyViewTopConstraint: NSLayoutConstraint!
    var  quickReplySuggesstionLbl: UILabel!
    var  quickReplySuggesstionLblHeight = 0
    @IBOutlet weak var quickreplyContainerViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet var chatHistoryV: UIView!
    @IBOutlet weak var chatHistoryHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var chatHistoryBtn: UIButton!
    @IBAction func tapsOnChatHistoryBtnAct(_ sender: Any) {
        fetchMessages()
    }
    
    // MARK: init
    public init() {
        super.init(nibName: "ChatMessagesViewController", bundle: bundle)
        //self.thread = thread
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func dummyMethod(){
        isSessionExpire = true
        Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { (_) in
            self.tapsOnBackBtnAction(self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isCallingHistoryApi = true
        
        linerProgressBar.frame = CGRect(x: 0, y: 0 , width: UIScreen.main.bounds.size.width, height:1)
        self.headerView.addSubview(linerProgressBar)
        
        ReactNativeEventMsg = ["event_code": "USER_CANCELLED", "event_message": "User Cancelled Event Occurred"]
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        isAlreadyConnectedBot = false
        self.botConnectingMethod()
        
        isSessionExpire = false
        //Initialize elements
        self.configureComposeBar()
        self.configureAudioComposer()
        self.configureQuickReplyView()
        self.configureTypingStatusView()
        self.configureSTTClient()
        
        self.configureViewForKeyboard(true)
        
        if SDKConfiguration.widgetConfig.isPanelView {
            self.configurePanelCollectionView()
        } else {
            panelCollectionViewContainerHeightConstraint.constant = 0
        }
        
        isSpeakingEnabled = false
        self.speechSynthesizer = AVSpeechSynthesizer()
        ConfigureDropDownView()
        
        self.setUpNavigationBar()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        self.languageChangeNotification()
    }
    
    @objc func monitoringForReachability() {
        let networkReachabilityManager = NetworkReachabilityManager.default
        networkReachabilityManager?.startListening(onUpdatePerforming: { (status) in
            print("reachability: \(status)")
            switch status {
            case .reachable(.ethernetOrWiFi), .reachable(.cellular):
                if !isAlreadyConnectedBot{
                    self.botConnectingMethod()
                }
                break
            case .notReachable:
                let alertController = UIAlertController(title: alertName, message: "Internet Connection not Available", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                    self.monitoringForReachability()
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                fallthrough
            default:
                break
            }
        })
    }
    
    
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addNotifications()
        
        if SDKConfiguration.widgetConfig.isPanelView {
            populatePanelItems()
        }
        
    }
    
    func setUpNavigationBar(){
        let urlString = brandingShared.bankLogo?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let url = URL(string: urlString ?? "")
        var data : Data?
        if url != nil {
            data = try? Data(contentsOf: url!)
        }
        var image = UIImage(named: "Logo", in: bundle, compatibleWith: nil)
        if let imageData = data {
            image = UIImage(data: imageData)
        }
        //navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(cancel(_:)))
        
        let button = UIButton(type: .custom)
        button.setImage(image, for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        let barButton = UIBarButtonItem(customView: button)
        NSLayoutConstraint.activate([(barButton.customView!.widthAnchor.constraint(equalToConstant: 50)),(barButton.customView!.heightAnchor.constraint(equalToConstant: 50))])
        self.navigationItem.leftBarButtonItem = barButton
        
        let rightImage = UIImage(named: "Group", in: bundle, compatibleWith: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: rightImage, style: .plain, target: self, action: #selector(cancel(_:)))
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func brandingValues(){
        let widgetTxtColor = UIColor.init(hexString: (brandingShared.widgetTextColor) ?? "#26344A")
        let font:UIFont? = UIFont(name: semiBoldCustomFont, size:16)
        let titleStr = brandingShared.botName ?? SDKConfiguration.botConfig.chatBotName
        let attString:NSMutableAttributedString = NSMutableAttributedString(string: titleStr , attributes: [.font:font!])
        let titleLabel = UILabel()
        titleLabel.textColor = widgetTxtColor
        titleLabel.attributedText = attString
        self.title = ""
        
        topTiltlLbl.text = titleStr
        topTiltlLbl.font = font
        topTiltlLbl.textColor = widgetTxtColor
        headerView.backgroundColor = UIColor.init(hexString: (brandingShared.widgetHeaderColor) ?? "#ffffff")
        
        navigationController?.navigationBar.barTintColor = UIColor.init(hexString: (brandingShared.widgetHeaderColor) ?? "#ffffff")
        navigationController?.navigationBar.tintColor = .orange
        
        if let bgUrlString = brandingShared.widgetBgImage!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed){
            if let bgUrl = URL(string: bgUrlString){
                backgroungImageView.af_setImage(withURL: bgUrl, placeholderImage: UIImage(named: ""))
                backgroungImageView.contentMode = .scaleAspectFit
            }else{
                self.view.backgroundColor = UIColor.init(hexString: (brandingShared.widgetBodyColor) ?? "#f3f3f5")
            }
        }
        
        composeView.backgroundColor = UIColor.init(hexString: (brandingShared.widgetFooterColor) ?? "#FFFFFF")
        botMessagesView.tableView.layer.borderColor = UIColor.init(hexString: (brandingShared.widgetDividerColor) ?? "#E5E8EC").cgColor
        botMessagesView.tableView.layer.borderWidth = 0.0
        UserDefaults.standard.set(brandingShared.buttonActiveTextColor, forKey: "ButtonTextColor")
        UserDefaults.standard.set(brandingShared.buttonActiveBgColor, forKey: "ButtonBgColor")
        UserDefaults.standard.set(brandingShared.widgetBorderColor, forKey: "widgetBorderColor")
        
        let bubbleViewRightTint = (brandingShared.userchatBgColor) ?? "#26344A"
        BubbleViewRightTint = UIColor.init(hexString: bubbleViewRightTint)
        BubbleViewLeftTint = UIColor.init(hexString: (brandingShared.botchatBgColor) ?? "#F4F4F4")
        BubbleViewUserChatTextColor = UIColor.init(hexString: (brandingShared.userchatTextColor) ?? "#000000")
        let BotChatTextColor = (brandingShared.botchatTextColor) ?? "#313131"
        BubbleViewBotChatTextColor = UIColor.init(hexString: BotChatTextColor)
        
        let btnActiveTextColor = (brandingShared.buttonActiveTextColor) ?? "#26344A"
        bubbleViewBotChatButtonTextColor = UIColor.init(hexString: btnActiveTextColor)
        
        
        bubbleViewBotChatButtonBgColor = UIColor.init(hexString: brandingShared.buttonActiveBgColor ?? "#FFFFFF")
        bubbleViewBotChatButtonInactiveTextColor = UIColor.init(hexString: (brandingShared.buttonInactiveTextColor) ?? "#ff5e00")
        
        //UserDefaults.standard.set(bubbleViewRightTint, forKey: "ThemeColor")
        themeColor = UIColor.init(hexString: bubbleViewRightTint)
        
        let chatHisImg = UIImage.init(named: "chatHistory", in: bundle, compatibleWith: nil)
        chatHistoryImg.image = chatHisImg?.withRenderingMode(.alwaysTemplate)
        chatHistoryImg.tintColor = themeColor
        
        let backImage = UIImage(named: "keyboard-arrow-left", in: bundle, compatibleWith: nil)
        let tintedBackImage = backImage?.withRenderingMode(.alwaysTemplate)
        self.backBtn.setBackgroundImage(tintedBackImage, for: .normal)
        self.backBtn.tintColor = widgetTxtColor
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeNotifications()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK:- deinit
    deinit {
        NSLog("ChatMessagesViewController dealloc")
        self.thread = nil
        self.botClient = nil
        self.speechSynthesizer = nil
        self.composeView = nil
        self.audioComposeView = nil
        self.botMessagesView = nil
        self.quickReplyView = nil
        self.typingStatusView = nil
        self.tapToDismissGestureRecognizer = nil
    }
    
    //MARK:- removing refernces to elements
    func prepareForDeinit(){
        if(self.botClient != nil){
            self.botClient.disconnect()
        }
        
        KABotClient.shared.deConfigureBotClient()
        self.deConfigureSTTClient()
        self.stopTTS()
        self.composeView.growingTextView.viewDelegate = nil
        self.composeView.delegate = nil
        self.audioComposeView.prepareForDeinit()
        if botMessagesView != nil{
            self.botMessagesView.prepareForDeinit()
            self.botMessagesView.viewDelegate = nil
        }
        self.quickReplyView.sendQuickReplyAction = nil
        self.quickReplyView.sendQuickReplyLinkAction = nil
    }
    
    // MARK: cancel
    @objc func cancel(_ sender: Any) {
        prepareForDeinit()
        navigationController?.setNavigationBarHidden(true, animated: false) //kk
        //navigationController?.popViewController(animated: true)
        navigationController?.dismiss(animated: false)
    }
    
    // MARK: More
    @objc func more(_ sender: Any) {
        //colorDropDown.show()
    }
    
    @IBAction func tapsOnBackBtnAction(_ sender: Any) {
        let dic = ["event_code": "BotClosed", "event_message": "Bot closed by the user"]
        let jsonString = Utilities.stringFromJSONObject(object: dic)
        NotificationCenter.default.post(name: Notification.Name(CallbacksNotification), object: jsonString)
        if !isCallChatHistory{
            showWelcomeMsg = true
        }
        botClosed()
    }
    
    public func botClosed(){
        rowIndex = 1000
        prepareForDeinit()
        navigationController?.setNavigationBarHidden(true, animated: false)
        //navigationController?.popViewController(animated: true)
        navigationController?.dismiss(animated: false)
    }
    
    @IBAction func leftMenuBackBtnAct(_ sender: Any) {
        let frame = UIScreen.main.bounds.size
        if preferred_language_Type == preferredLanguage{
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                let rightLeft = CGAffineTransform(translationX: frame.width * 1, y: 0.0)
                self.leftMenuContainerView.transform = rightLeft
            }) { (finished) in
                self.leftMenuContainerView.isHidden = true
            }
        }else{
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                let moveLeft = CGAffineTransform(translationX: frame.width * -1, y: 0.0)
                self.leftMenuContainerView.transform = moveLeft
            }) { (finished) in
                self.leftMenuContainerView.isHidden = true
            }
        }
    }
    
    //MARK: Menu Button Action
    @IBAction func menuButtonAction(_ sender: Any) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        var string = NSLocalizedString("Enable Playback", comment: "Default action")
        if isSpeakingEnabled {
            string = NSLocalizedString("Disable Playback", comment: "Default action")
        }
        actionSheet.addAction(UIAlertAction(title: string, style: .`default`, handler: { [weak self] _ in
            if isSpeakingEnabled {
                self?.stopTTS()
            }
            isSpeakingEnabled = !isSpeakingEnabled
            self?.audioComposeView.enablePlayback(enable: isSpeakingEnabled)
        }))
        
        // Add close Action
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "close action sheet"), style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    // MARK: configuring views
    
    func configureThreadView() {
        self.botMessagesView = BotMessagesView()
        self.botMessagesView.translatesAutoresizingMaskIntoConstraints = false
        self.botMessagesView.backgroundColor = .clear
        self.botMessagesView.thread = self.thread
        self.botMessagesView.viewDelegate = self
        self.botMessagesView.clearBackground = true
        self.threadContainerView.addSubview(self.botMessagesView!)
        
        self.threadContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[botMessagesView]|", options:[], metrics:nil, views:["botMessagesView" : self.botMessagesView!]))
        self.threadContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[botMessagesView]|", options:[], metrics:nil, views:["botMessagesView" : self.botMessagesView!]))
    }
    
    func disableComposeView(isHide: Bool){
        if isHide {
            self.disableComposeView.isHidden = false
            self.disableAudioView.isHidden = false
            if (self.composeView.isFirstResponder) {
                _ = self.composeView.resignFirstResponder()
            }
        }else{
            self.disableComposeView.isHidden = true
            self.disableAudioView.isHidden = true
        }
    }
    
    
    
    
    func configureComposeBar() {
        self.composeView = ComposeBarView()
        self.composeView.translatesAutoresizingMaskIntoConstraints = false
        self.composeView.growingTextView.viewDelegate = self
        self.composeView.delegate = self
        self.composeBarContainerView.addSubview(self.composeView!)
        
        self.disableComposeView = UIView(frame:.zero)
        self.disableComposeView.translatesAutoresizingMaskIntoConstraints = false
        self.composeBarContainerView.addSubview(self.disableComposeView)
        self.disableComposeView.isHidden = true
        disableComposeView.backgroundColor = UIColor(white: 1, alpha: 0.5)
        
        self.composeBarContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[composeView]|", options:[], metrics:nil, views:["composeView" : self.composeView!]))
        self.composeBarContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[composeView]", options:[], metrics:nil, views:["composeView" : self.composeView!]))
        
        self.composeBarContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[disableComposeView]|", options:[], metrics:nil, views:["disableComposeView" : self.disableComposeView!]))
        self.composeBarContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[disableComposeView]|", options:[], metrics:nil, views:["disableComposeView" : self.disableComposeView!]))
        
        self.composeViewBottomConstraint = NSLayoutConstraint.init(item: self.composeBarContainerView, attribute: .bottom, relatedBy: .equal, toItem: self.composeView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        self.composeBarContainerView.addConstraint(self.composeViewBottomConstraint)
        self.composeViewBottomConstraint.isActive = false
        
        self.composeBarContainerHeightConstraint = NSLayoutConstraint.init(item: self.composeBarContainerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0.0)
        self.view.addConstraint(self.composeBarContainerHeightConstraint)
    }
    
    func configureAudioComposer()  {
        self.audioComposeView = AudioComposeView()
        self.audioComposeView.translatesAutoresizingMaskIntoConstraints = false
        self.audioComposeContainerView.addSubview(self.audioComposeView!)
        
        self.disableAudioView = UIView(frame:.zero)
        self.disableAudioView.translatesAutoresizingMaskIntoConstraints = false
        self.audioComposeContainerView.addSubview(self.disableAudioView)
        self.disableAudioView.isHidden = true
        disableAudioView.backgroundColor = UIColor(white: 1, alpha: 0.5)
        
        self.audioComposeContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[audioComposeView]|", options:[], metrics:nil, views:["audioComposeView" : self.audioComposeView!]))
        self.audioComposeContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[audioComposeView]|", options:[], metrics:nil, views:["audioComposeView" : self.audioComposeView!]))
        
        self.audioComposeContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[disableAudioView]|", options:[], metrics:nil, views:["disableAudioView" : self.disableAudioView!]))
        self.audioComposeContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[disableAudioView]|", options:[], metrics:nil, views:["disableAudioView" : self.disableAudioView!]))
        
        self.audioComposeContainerHeightConstraint = NSLayoutConstraint.init(item: self.audioComposeContainerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0.0)
        self.view.addConstraint(self.audioComposeContainerHeightConstraint)
        self.audioComposeContainerHeightConstraint.isActive = false
        
        self.audioComposeView.voiceRecordingStarted = { [weak self] (composeBar) in
            self?.stopTTS()
            //self?.composeView.isHidden = true
        }
        self.audioComposeView.voiceRecordingStopped = { [weak self] (composeBar) in
            self?.sttClient.stopRecording()
        }
        self.audioComposeView.getAudioPeakOutputPower = { () in
            return 0.0
        }
        self.audioComposeView.onKeyboardButtonAction = { [weak self] () in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ClosePanel"), object: nil)
            self?.isShowAudioComposeView = false
            _ = self?.composeView.becomeFirstResponder()
            self?.configureViewForKeyboard(true)
        }
    }
    
    func configureQuickReplyView() {
            self.quickReplyView = KREQuickSelectView()
            self.quickReplyView.translatesAutoresizingMaskIntoConstraints = false
            self.quickSelectContainerView.addSubview(self.quickReplyView)
            let bgColor = (brandingShared.buttonActiveBgColor) ?? "#f3f3f5"
            let textColor = (brandingShared.buttonActiveTextColor) ?? "#2881DF"
            self.quickReplyView.bgColor = bgColor
            self.quickReplyView.textColor = textColor
            self.quickReplyView.boarderColor = textColor
            self.quickReplyView.fontName = mediumCustomFont
            self.quickSelectContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[quickReplyView]|", options:[], metrics:nil, views:["quickReplyView" : self.quickReplyView as Any]))
            self.quickSelectContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[quickReplyView(60)]", options:[], metrics:nil, views:["quickReplyView" : self.quickReplyView as Any]))
            
            self.quickReplyView.sendQuickReplyAction = { [weak self] (text, payload) in
                if let text = text, let payload = payload {
                    self?.sendTextMessage(text, options: ["body": payload])
                }
            }
    }
    
    func configurePanelCollectionView() {
        
        self.panelCollectionView = KAPanelCollectionView()
        self.panelCollectionView?.translatesAutoresizingMaskIntoConstraints = false
        self.panelCollectionViewContainerView.addSubview(self.panelCollectionView!)
        
        self.panelCollectionViewContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[panelCollectionView]|", options:[], metrics:nil, views:["panelCollectionView" : self.panelCollectionView!]))
        self.panelCollectionViewContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[panelCollectionView]|", options:[], metrics:nil, views:["panelCollectionView" : self.panelCollectionView!]))
        
        self.panelCollectionView.onPanelItemClickAction = { (item) in
        }
        
        self.panelCollectionView.retryAction = { [weak self] in
            self?.populatePanelItems()
        }
        
        self.panelCollectionView.panelItemHandler = { [weak self] (item, block) in
            guard let weakSelf = self else {
                return
            }
            
            switch item?.type {
            case "action":
                weakSelf.processActionPanelItem(item)
            default:
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "BringComposeBarToBottom"), object: nil)
                if #available(iOS 11.0, *) {
                    self?.insets = UIApplication.shared.delegate?.window??.safeAreaInsets ?? .zero
                }
                var inputViewHeight = self?.isShowAudioComposeView == true ? self!.audioComposeContainerView.bounds.height : self!.composeBarContainerView.bounds.height
                inputViewHeight = inputViewHeight + (self?.insets.bottom ?? 0.0) + (self?.panelCollectionViewContainerView.bounds.height)!
                let sizes: [SheetSize] = [.fixed(0.0), .fixed(weakSelf.panelHeight)]
                if weakSelf.sheetController == nil {
                    let panelItemViewController = KAPanelItemViewController()
                    panelItemViewController.panelId = item?.id
                    panelItemViewController.dismissAction = { [weak self] in
                        self?.sheetController = nil
                    }
                    if ((self?.composeView.isFirstResponder)!) {
                        _ = self!.composeView.resignFirstResponder()
                    }
                    
                    let bottomSheetController = KABottomSheetController(controller: panelItemViewController, sizes: sizes)
                    bottomSheetController.inputViewHeight = CGFloat(inputViewHeight)
                    bottomSheetController.willSheetSizeChange = { [weak self] (controller, newSize) in
                        switch newSize {
                        case .fixed(weakSelf.panelHeight):
                            controller.overlayColor = .clear
                            panelItemViewController.showPanelHeader(true)
                        default:
                            controller.overlayColor = .clear
                            panelItemViewController.showPanelHeader(false)
                            bottomSheetController.closeSheet(true)
                            
                            self?.sheetController = nil
                        }
                    }
                    bottomSheetController.modalPresentationStyle = .overCurrentContext
                    weakSelf.present(bottomSheetController, animated: true, completion: block)
                    weakSelf.sheetController = bottomSheetController
                } else if let bottomSheetController = weakSelf.sheetController,
                          let panelItemViewController = bottomSheetController.childViewController as? KAPanelItemViewController {
                    panelItemViewController.panelId = item?.id
                    
                    if bottomSheetController.presentingViewController == nil {
                        weakSelf.present(bottomSheetController, animated: true, completion: block)
                    } else {
                        block?()
                    }
                }
            }
        }
    }
    
    func configureTypingStatusView() {
        self.typingStatusView = KRETypingStatusView()
        self.typingStatusView?.isHidden = true
        self.typingStatusView?.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.typingStatusView!)
        
        let views: [String: Any] = ["typingStatusView" : self.typingStatusView as Any, "composeBarContainerView" : self.composeBarContainerView as Any]
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[typingStatusView]", options:[], metrics:nil, views: views)) //-20
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[typingStatusView(40)][composeBarContainerView]", options:[], metrics:nil, views: views))
    }
    
    
    func ConfigureDropDownView(){
        //DropDown
        dropDowns.forEach { $0.dismissMode = .onTap }
        dropDowns.forEach { $0.direction = .any }
        
        colorDropDown.backgroundColor = UIColor(white: 1, alpha: 1)
        colorDropDown.selectionBackgroundColor = UIColor(red: 0.6494, green: 0.8155, blue: 1.0, alpha: 0.2)
        colorDropDown.separatorColor = UIColor(white: 0.7, alpha: 0.8)
        colorDropDown.cornerRadius = 10
        colorDropDown.shadowColor = UIColor(white: 0.6, alpha: 1)
        colorDropDown.shadowOpacity = 0.9
        colorDropDown.shadowRadius = 25
        colorDropDown.animationduration = 0.25
        colorDropDown.textColor = .darkGray
        
        setupColorDropDown()
    }
    // MARK: Setup DropDown
    func setupColorDropDown() {
        colorDropDown.anchorView = dropDownBtn
        
        colorDropDown.bottomOffset = CGPoint(x: 0, y: dropDownBtn.bounds.height)
        colorDropDown.dataSource = [
            "Theme Logo",
            "Theme Shopping"
        ]
        colorDropDown.selectRow(0)
        // Action triggered on selection
        colorDropDown.selectionAction = { [weak self] (index, item) in
            if item == "Theme Logo" {
                selectedTheme = "Theme 1"
            }else{
                selectedTheme = "Theme 2"
            }
            
            if selectedTheme == "Theme 1"{
                let urlString = brandingShared.widgetBgImage ?? "".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                if let url = URL(string: urlString!){
                    self!.backgroungImageView.af_setImage(withURL: url, placeholderImage: UIImage(named: ""))
                }else{
                    self!.backgroungImageView.image = UIImage.init(named: "")
                    self!.view.backgroundColor = UIColor.init(hexString: (brandingShared.widgetBodyColor) ?? "#f3f3f5")
                }
                self!.backgroungImageView.contentMode = .scaleAspectFit
            }else{
                self!.backgroungImageView.image = UIImage.init(named: "Shoppingbackground", in: frameworkBundle, compatibleWith: nil)
                self!.backgroungImageView.contentMode = .scaleAspectFit
            }
            NotificationCenter.default.post(name: Notification.Name(reloadTableNotification), object: nil)
        }
        
    }
    
    func getComponentType(_ templateType: String,_ tabledesign: String) -> ComponentType {
        if (templateType == "quick_repliess") {
            return .quickReply
        } else if (templateType == "buttonn") {
            return .options
        }else if (templateType == "list") {
            return .list
        }else if (templateType == "carousel") {
            return .carousel
        }else if (templateType == "piechart" || templateType == "linechart" || templateType == "barchart") {
            return .chart
        }else if (templateType == "table"  && tabledesign == "regular") {
            return .table
        }
        else if (templateType == "table"  && tabledesign == "responsive") {
            return .responsiveTable
        }
        else if (templateType == "mini_table") {
            return .minitable
        }
        else if (templateType == "menu") {
            return .menu
        }
        else if (templateType == "listView") {
            return .newList
        }
        else if (templateType == "tableList") {
            return .tableList
        }
        else if (templateType == "daterange" || templateType == "dateTemplate") {
            return .calendarView
        }
        else if (templateType == "quick_replies_welcome" || templateType == "button" || templateType == "quick_replies"){
            return .quick_replies_welcome
        }
        else if (templateType == "Notification") {
            return .notification
        }
        else if (templateType == "multi_select") {
            return .multiSelect
        }
        else if (templateType == "List_widget" || templateType == "listWidget") {
            return .list_widget
        }
        else if (templateType == "feedbackTemplate") {
            return .feedbackTemplate
        }
        else if (templateType == "form_template") {
            return .inlineForm
        }
        else if (templateType == "dropdown_template") {
            return .dropdown_template
        }
        else if (templateType == "transactionSuccessTemplate"){
            return .transactionSuccessTemplate
        }
        else if (templateType == "contactCardTemplate"){
            return .contactCardTemplate
        }
        else if (templateType == "radioListTemplate"){
            isExpandRadioTableBubbleView = false
            radioTableSelectedIndex = 1000
            return .radioListTemplate
        }
        else if (templateType == "pdfdownload"){
            return .pdfdownload
        }
        else if (templateType == "updatedIdfcCarousel"){
            return .updatedIdfcCarousel
        }else if (templateType == "buttonLinkTemplate"){
            return .buttonLinkTemplate
        }
        else if (templateType == "idfcFeedbackTemplate"){
            return .idfcFeedbackTemplate
        }else if (templateType == "statusTemplate"){
            return .statusTemplate
        }else if (templateType == "serviceListTemplate"){
            return .serviceListTemplate
        }else if (templateType == "idfcAgentTemplate"){
            return .idfcAgentTemplate
        }else if (templateType == "idfcCarouselType2"){
            return .idfcCarouselType2
        }
        else if (templateType == "cardSelection"){
            return .cardSelection
        }else if (templateType == "beneficiaryTemplate"){
            return .beneficiaryTemplate
        }else if (templateType == "advanced_multi_select"){
            return .advanced_multi_select
        }else if (templateType == "salaampointsTemplate" || templateType == "listView_custom1"){
            return .salaampointsTemplate
        }else if (templateType == "welcome_template"){
            return .welcome_template
        }else if (templateType == "boldtextTemplate"){
            return .boldtextTemplate
        }else if (templateType == "emptyBubble"){
            return .emptyBubbleTemplate
        }else if (templateType == "custom_dropdown_template"){
            return .custom_dropdown_template
        }else if (templateType == "details_list"){
            return .details_list_template
        }else if (templateType == "search"){
            return .search_template
        }else if (templateType == "bankingFeedbackTemplate"){
            return .bankingFeedbackTemplate
        }
        return .text
    }
    
    func onReceiveMessage(object: BotMessageModel?) -> (Message?, String?) {
        isOTPValidationTemplate = false
        timerCounter = maxiumTimeCount
        
        var ttsBody: String?
        var textMessage: Message! = nil
        let message: Message = Message()
        message.messageType = .reply
        if let type = object?.type, type == "incoming" {
            message.messageType = .default
        }
        message.sentDate = object?.createdOn
        message.messageId = object?.messageId
        messageIdIndexForHistory = messageIdIndexForHistory - 1
        message.messageIdIndex = NSNumber(value: messageIdIndexForHistory)
        
        if (object?.iconUrl != nil) {
            message.iconUrl = object?.iconUrl
        }
        
        if (webViewController != nil) {
            webViewController.dismiss(animated: true, completion: nil)
            webViewController = nil
        }
        
        let messageObject = ((object?.messages.count)! > 0) ? (object?.messages[0]) : nil
        if (messageObject?.component == nil) {
            
        } else {
            let componentModel: ComponentModel = messageObject!.component!
            if (componentModel.type == "text") {
                let payload: NSDictionary = componentModel.payload! as! NSDictionary
                let text: NSString = payload["text"] as! NSString
                let textComponent: Component = Component()
                textComponent.payload = text as String
                ttsBody = text as String
                
                if(text.contains("use a web form")){
//                    let range: NSRange = text.range(of: "use a web form - ")
//                    let urlString: String? = text.substring(with: NSMakeRange(range.location+range.length, 44))
//                    if (urlString != nil) {
//                        let url: URL = URL(string: urlString!)!
//                        webViewController = SFSafariViewController(url: url)
//                        webViewController.modalPresentationStyle = .custom
//                        present(webViewController, animated: true, completion:nil)
//                    }
//                    ttsBody = "Ok, Please fill in the details and submit"
                }
                //message.addComponent(textComponent)
                let string = text as String
                let character: Character = "*"
                if string.contains(character) {
                    if message.messageType == .default{
                        message.addComponent(textComponent)
                    }else{
                        let textComponent: Component = Component(.boldtextTemplate)
                        textComponent.payload = text as String
                        message.addComponent(textComponent)
                    }
                } else {
                    message.addComponent(textComponent)
                }
                return (message, ttsBody)
            } else if (componentModel.type == "template") {
                let payload: NSDictionary = componentModel.payload! as! NSDictionary
                let text: String = payload["text"] != nil ? payload["text"] as! String : ""
                let type: String = payload["type"] != nil ? payload["type"] as! String : ""
                ttsBody = payload["speech_hint"] != nil ? payload["speech_hint"] as? String : nil
                
                if (type == "template") {
                    let dictionary: NSDictionary = payload["payload"] as! NSDictionary
                    let templateType: String = dictionary["template_type"] as! String
                    var tabledesign: String
                    
                    tabledesign  = (dictionary["table_design"] != nil ? dictionary["table_design"] as? String : "responsive")!
                    //let componentType = self.getComponentType(templateType,tabledesign)
                    var componentType:ComponentType!
                    if let displayButtonTemplate = dictionary["url_present"] as? Bool, displayButtonTemplate == true {
                        componentType = getComponentType("buttonn", tabledesign)
                    }else{
                        componentType = getComponentType(templateType, tabledesign)
                    }
                    
                    if componentType != .quickReply {
                        
                    }
                    
                    if componentType == .quickReply {
                        let quickReplyTitle = dictionary["text"] as? String
                        if quickReplyTitle == nil{
                            componentType = getComponentType("emptyBubble", tabledesign)
                        }
                    }
                    
                    if templateType == "otpValidationTemplate"{
                        isOTPValidationTemplate = true
                        OTPValidationRemoveCount += 1
                    }else if templateType == "salikpinTemplate"{
                        isOTPValidationTemplate = true
                        OTPValidationRemoveCount += 1
                    }else if templateType == "date_with_time_selector"{
                        isOTPValidationTemplate = true
                        OTPValidationRemoveCount += 1
                    }else if templateType == "transition_template"{
                        isOTPValidationTemplate = true
                        OTPValidationRemoveCount += 1
                    }
                    else if templateType == "custom_form_template"{
                        isOTPValidationTemplate = true
                        OTPValidationRemoveCount += 1
                    }else if templateType == "user_validation_template"{
                        isOTPValidationTemplate = true
                        OTPValidationRemoveCount += 1
                    }
                    
                    let tText: String = dictionary["text"] != nil ? dictionary["text"] as! String : ""
                    ttsBody = dictionary["speech_hint"] != nil ? dictionary["speech_hint"] as? String : nil
                    
                    if tText.count > 0 && (componentType == .carousel || componentType == .chart || componentType == .table || componentType == .minitable || componentType == .responsiveTable) {
                        textMessage = Message()
                        textMessage?.messageType = .reply
                        textMessage?.sentDate = message.sentDate
                        textMessage?.messageId = message.messageId
                        if (object?.iconUrl != nil) {
                            textMessage?.iconUrl = object?.iconUrl
                        }
                        let textComponent: Component = Component()
                        textComponent.payload = tText
                        textMessage?.addComponent(textComponent)
                    }
                    if templateType == "SYSTEM" || templateType == "live_agent" || templateType == "liveagent" || templateType == "sessionExpiry"{
                        let textComponent = Component(.text)
                        let text = dictionary["text"] as? String ?? ""
                        textComponent.payload = text
                        ttsBody = text
                        message.addComponent(textComponent)
                    }else{
                        let optionsComponent: Component = Component(componentType)
                        optionsComponent.payload = Utilities.stringFromJSONObject(object: dictionary)
                        message.sentDate = object?.createdOn
                        message.addComponent(optionsComponent)
                    }
                    
                } else if (type == "image"){
                    
                    if let dictionary = payload["payload"] as? [String: Any] {
                        let optionsComponent: Component = Component(.image)
                        optionsComponent.payload = Utilities.stringFromJSONObject(object: dictionary)
                        message.sentDate = object?.createdOn
                        message.addComponent(optionsComponent)
                    }
                }
                else if (type == "message"){
                    
                    if let dictionary = payload["payload"] as? [String: Any] {
                        let  componentType = dictionary["audioUrl"] != nil ? Component(.audio) : Component(.video)
                        let optionsComponent: Component = componentType
                        if let speechText = dictionary["text"] as? String{
                            ttsBody = speechText
                        }
                        optionsComponent.payload = Utilities.stringFromJSONObject(object: dictionary)
                        message.sentDate = object?.createdOn
                        message.addComponent(optionsComponent)
                    }
                }
                else if (type == "video"){
                    
                    if let _ = payload["payload"] as? [String: Any] {
                        let  componentType = Component(.video)
                        let optionsComponent: Component = componentType
                        optionsComponent.payload = Utilities.stringFromJSONObject(object: payload)
                        message.sentDate = object?.createdOn
                        message.addComponent(optionsComponent)
                    }
                }
                else if (type == "audio"){
                    
                    if let dictionary = payload["payload"] as? [String: Any] {
                        let  componentType = Component(.audio)
                        let optionsComponent: Component = componentType
                        optionsComponent.payload = Utilities.stringFromJSONObject(object: dictionary)
                        message.sentDate = object?.createdOn
                        message.addComponent(optionsComponent)
                    }
                }
                else if (type == "error") {
                    let dictionary: NSDictionary = payload["payload"] as! NSDictionary
                    let errorComponent: Component = Component(.error)
                    errorComponent.payload = Utilities.stringFromJSONObject(object: dictionary)
                    message.addComponent(errorComponent)
                } else if text.count > 0 {
                    //                    let textComponent: Component = Component()
                    //                    textComponent.payload = text
                    //                    message.addComponent(textComponent)
                    let character: Character = "*"
                    let htmlcharacter = "</b>"
                    if text.contains(character) || text.contains(htmlcharacter) {
                        let textComponent: Component = Component(.boldtextTemplate)
                        textComponent.payload = text
                        message.addComponent(textComponent)
                    }else{
                        let textComponent =  Component()
                        textComponent.payload = text
                        message.addComponent(textComponent)
                    }
                }
                return (message, ttsBody)
            }
        }
        return (nil, ttsBody)
    }
    
    func addMessages(_ message: Message?, _ ttsBody: String?) {
        if let m = message, m.components.count > 0 {
            showTypingStatusForBotsAction()
            let delayInMilliSeconds = 500
            DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(delayInMilliSeconds)) {
                let dataStoreManager = DataStoreManager.sharedManager
                dataStoreManager.createNewMessageIn(thread: self.thread, message: m, completion: { (success) in
                    
                })
                
                if let tts = ttsBody {
                    NotificationCenter.default.post(name: Notification.Name(startSpeakingNotification), object: tts)
                }
            }
        }
    }
    
    func configureSTTClient() {
        self.sttClient.onError = { [weak self] (error, userInfo) in
            guard let strongSelf = self else {
                return
            }
            strongSelf.audioComposeView.stopRecording()
            strongSelf.composeView.setText("")
            strongSelf.composeViewBottomConstraint.isActive = false
            strongSelf.composeBarContainerHeightConstraint.isActive = true
            strongSelf.composeBarContainerView.isHidden = true
            
            if let message = userInfo?["message"] as? String {
                let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
                
                if let navigateToSettings = userInfo?["settings"] as? Bool, navigateToSettings {
                    let settingsAction = UIAlertAction(title: "Settings", style: .default, handler: { (action) in
                        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
                        }
                    })
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                        self?.configureViewForKeyboard(true)
                    })
                    alert.addAction(settingsAction)
                    alert.addAction(cancelAction)
                } else {
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
                        
                    })
                    alert.addAction(cancelAction)
                }
                self?.present(alert, animated: true, completion: nil)
            }
        }
        self.sttClient.onResponse = { [weak self] (transcript, isFinal) in
            guard let strongSelf = self else {
                return
            }
            print("Got transcript: \(transcript) isFinal:\(isFinal)")
            if isFinal {
                strongSelf.composeView.setText(transcript)
                if !strongSelf.composeView.isKeyboardEnabled {
                    strongSelf.audioComposeView.stopRecording()
                    if isMasking {
                        let secureTxt = transcript.regEx()
                        strongSelf.sendTextMessage(secureTxt, options: ["body": transcript])
                    }else{
                        strongSelf.sendTextMessage(transcript, options: nil)
                    }
                    strongSelf.composeView.setText("")
                    strongSelf.composeViewBottomConstraint.isActive = false
                    strongSelf.composeBarContainerHeightConstraint.isActive = true
                    strongSelf.composeBarContainerView.isHidden = true
                }
            }else{
                strongSelf.composeView.setText(transcript)
                strongSelf.composeBarContainerHeightConstraint.isActive = false
                strongSelf.composeViewBottomConstraint.isActive = true
                strongSelf.composeBarContainerView.isHidden = false
            }
        }
    }
    
    func configureleftMenu(){
        self.leftMenuTitleLbl.font = UIFont(name: regularCustomFont, size: 14.0)
        self.leftMenuView = LeftMenuView()
        self.leftMenuView.translatesAutoresizingMaskIntoConstraints = false
        self.leftMenuView.backgroundColor = .clear
        self.leftMenuView.viewDelegate = self
        self.leftMenuContainerSubView.addSubview(self.leftMenuView!)
        
        self.leftMenuContainerSubView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[leftMenuView]|", options:[], metrics:nil, views:["leftMenuView" : self.leftMenuView!]))
        self.leftMenuContainerSubView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-90-[leftMenuView]|", options:[], metrics:nil, views:["leftMenuView" : self.leftMenuView!]))
        
    }
    
    func deConfigureSTTClient() {
        self.sttClient.onError = nil
        self.sttClient.onResponse = nil
    }
    
    func updateNavBarPrompt() {
        self.navigationItem.leftBarButtonItem?.isEnabled = true
        switch self.botClient.connectionState {
        case .CONNECTING:
            self.navigationItem.leftBarButtonItem?.isEnabled = false
            self.navigationItem.prompt = "Connecting..."
            break
        case .CONNECTED:
            self.navigationItem.prompt = "Connected"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                self.navigationItem.prompt = nil
            })
            break
        case .FAILED:
            self.navigationItem.prompt = "Connection Failed"
            break
        case .CLOSED:
            self.navigationItem.prompt = "Connection Closed"
            break
        case .NO_NETWORK:
            self.navigationItem.prompt = "No Network"
            break
        case .NONE, .CLOSING:
            self.navigationItem.prompt = nil
            break
        }
    }
    
    // MARK: notifications
    func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(_:)), name: UIResponder.keyboardDidHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willTerminate(_:)), name: UIApplication.willTerminateNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(startSpeaking), name: NSNotification.Name(rawValue: startSpeakingNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopSpeaking), name: NSNotification.Name(rawValue: stopSpeakingNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showTableTemplateView), name: NSNotification.Name(rawValue: showTableTemplateNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTable(notification:)), name: NSNotification.Name(rawValue: reloadTableNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showListViewTemplateView), name: NSNotification.Name(rawValue: showListViewTemplateNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(processDynamicUpdates(_:)), name: KoraNotification.Widget.update.notification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(processPanelEvents(_:)), name: KoraNotification.Panel.event.notification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(navigateToComposeBar(_:)), name: KREMessageAction.navigateToComposeBar.notification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showListWidgetViewTemplateView), name: NSNotification.Name(rawValue: showListWidgetViewTemplateNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(startTypingStatusForBot), name: NSNotification.Name(rawValue: "StartTyping"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopTypingStatusForBot), name: NSNotification.Name(rawValue: "StopTyping"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(dropDownTemplateActtion), name: NSNotification.Name(rawValue: dropDownTemplateNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showActivityViewController), name: NSNotification.Name(rawValue: activityViewControllerNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(autoDirectingToWebV), name: NSNotification.Name(rawValue: autoDirectingWebVNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(botClosedNotificationAction), name: NSNotification.Name(rawValue: botClosedNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sessionExpiryNotificationAction), name: NSNotification.Name(rawValue: sessionExpiryNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showPDFViewController), name: NSNotification.Name(rawValue: pdfcTemplateViewNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(tokenExpiry), name: NSNotification.Name(rawValue: tokenExipryNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(OTPvalidateTemplateActtion), name: NSNotification.Name(rawValue: otpValidationTemplateNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(resetPinTemplateActtion), name: NSNotification.Name(rawValue: resetpinTemplateNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loginNotificationActtion), name: NSNotification.Name(rawValue: loginNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(languageChangeNotification), name: NSNotification.Name(rawValue: langaugeChangeNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showPDFErrorMeesage), name: NSNotification.Name(rawValue: pdfcTemplateViewErrorNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showSalamPointsTemplateView), name: NSNotification.Name(rawValue: salaamPointsDetailsNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(salikTemplateActtion), name: NSNotification.Name(rawValue: salikTemplateNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(timeSlotTemplateActtion), name: NSNotification.Name(rawValue: timeSlotTemplateNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(customDropDownTemplateAction), name: NSNotification.Name(rawValue: customDropDownTemplateNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(custom_DropDown_TextAppendAction), name: NSNotification.Name(rawValue: customDropDownTextAppendNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(resetPasswordTemplateActtion), name: NSNotification.Name(rawValue: resetPasswordTemplateNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(customFormTemplateAction), name: NSNotification.Name(rawValue: customFormTemplateNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userValidationTemplateAction), name: NSNotification.Name(rawValue: UserValidationTemplateNotification), object: nil)
    }
    
    func removeNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: startSpeakingNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: stopSpeakingNotification), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: showTableTemplateNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: reloadTableNotification), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: showListViewTemplateNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: showListWidgetViewTemplateNotification), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: KREMessageAction.navigateToComposeBar.notification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "StartTyping"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "StopTyping"), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: dropDownTemplateNotification), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: activityViewControllerNotification), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: autoDirectingWebVNotification), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: btnlinkTempMaskViewNotification), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: newListTempMaskViewNotification), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: carouselTempMaskViewNotification), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: botClosedNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: sessionExpiryNotification), object: nil)
        
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: pdfcTemplateViewNotification), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: tokenExipryNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: otpValidationTemplateNotification), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: resetpinTemplateNotification), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: loginNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: langaugeChangeNotification), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: pdfcTemplateViewErrorNotification), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: salaamPointsDetailsNotification), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: salikTemplateNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: timeSlotTemplateNotification), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: customDropDownTemplateNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: customDropDownTextAppendNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: resetPasswordTemplateNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: customFormTemplateNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: UserValidationTemplateNotification), object: nil)
        
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
        self.bottomConstraint.constant = keyboardHeight
        taskMenuHeight = Int(keyboardHeight)
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
        
        if taskMenuKeyBoard{
            self.bottomConstraint.constant = 0
            self.taskMenuContainerHeightConstant.constant = 0
        }
        
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            self.view.layoutIfNeeded()
        }, completion: { (Bool) in
            
        })
    }
    
    @objc func didBecomeActive(_ notification: Notification) {
        startMonitoringForReachability()
    }
    
    @objc func didEnterBackground(_ notification: Notification) {
        stopMonitoringForReachability()
        appEnterBackground = true
    }
    
    @objc func willTerminate(_ notification: Notification) {
        
        let userDefaults = UserDefaults.standard
        if userDefaults.string(forKey: "UUID") != nil {
            print("App clear UDID")
            userDefaults.removeObject(forKey: "UUID")
        }
    }
    
    @objc func startMonitoringForReachability() {
        let networkReachabilityManager = NetworkReachabilityManager.default
        networkReachabilityManager?.startListening(onUpdatePerforming: { (status) in
            print("Network reachability: \(status)")
            switch status {
            case .reachable(.ethernetOrWiFi), .reachable(.cellular):
                 self.establishBotConnection()
                break
            case .notReachable:
                fallthrough
            default:
                break
            }
            
            KABotClient.shared.setReachabilityStatusChange(status)
        })
    }
    
    @objc func stopMonitoringForReachability() {
        NetworkReachabilityManager.default?.stopListening()
    }
    
    @objc func navigateToComposeBar(_ notification: Notification) {
        DispatchQueue.main.async {
            self.minimizePanelWindow(false)
        }
        
        guard let params = notification.object as? [String: Any] else {
            return
        }
        
        if let utterance = params["utterance"] as? String, let options = params["options"] as? [String: Any] {
            sendTextMessage(utterance, dictionary: options, options: options)
        }
    }
    
    // MARK: - establish BotSDK connection
    func establishBotConnection() {
        KABotClient.shared.tryConnect()
    }
    
    @objc func keyboardDidShow(_ notification: Notification) {
        if (self.tapToDismissGestureRecognizer == nil) {
            self.taskMenuContainerHeightConstant.constant = 0
            self.tapToDismissGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(ChatMessagesViewController.dismissKeyboard(_:)))
            //self.botMessagesView.addGestureRecognizer(tapToDismissGestureRecognizer)
            self.tapToDismissGestureRecognizer.delegate = self
            self.view.addGestureRecognizer(tapToDismissGestureRecognizer)
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view?.isDescendant(of: botMessagesView.tableView) == true || touch.view?.isDescendant(of: leftMenuView.tableView) == true || touch.view?.isDescendant(of: quickReplyView) == true{
            return false
        }
        return true
    }
    
    @objc func keyboardDidHide(_ notification: Notification) {
        if taskMenuKeyBoard{
            self.taskMenuContainerHeightConstant.constant = 0
            self.bottomConstraint.constant = 0
        }
        if (self.tapToDismissGestureRecognizer != nil) {
            self.botMessagesView.removeGestureRecognizer(tapToDismissGestureRecognizer)
            self.tapToDismissGestureRecognizer = nil
        }
    }
    
    @objc func dismissKeyboard(_ gesture: UITapGestureRecognizer) {
        timerCounter = maxiumTimeCount
        self.bottomConstraint.constant = 0
        self.taskMenuContainerHeightConstant.constant = 0
        if (self.composeView.isFirstResponder) {
            _ = self.composeView.resignFirstResponder()
        }else{
            UIApplication.shared.sendAction(#selector(self.resignFirstResponder), to:nil, from:nil, for:nil)
        }
    }
    
    // MARK: Helper functions
    func sendMessage(_ message: Message, dictionary: [String: Any]? = nil, options: [String: Any]?) {
        rowIndex = 0
        calenderCloseTag = false
        NotificationCenter.default.post(name: Notification.Name("StartTyping"), object: nil)
        NotificationCenter.default.post(name: Notification.Name(stopSpeakingNotification), object: nil)
        let composedMessage: Message = message
        if (composedMessage.components.count > 0) {
            let dataStoreManager: DataStoreManager = DataStoreManager.sharedManager
            dataStoreManager.createNewMessageIn(thread: self.thread, message: composedMessage, completion: { (success) in
                let textComponent = composedMessage.components[0] as? Component
                if let _ = self.botClient, let text = textComponent?.payload {
                    if isLogin{
                        self.botClient.sendMessage(text, options: options)
                    }else{
                        self.botClient.sendMessage(text, options: options)
                    }
                    historyLimit += 1
                }
                self.textMessageSent()
            })
        }
    }
    
    func sendTextMessage(_ text: String, dictionary: [String: Any]? = nil, options: [String: Any]?) {
        if showMaskVInBtnLink{
            showMaskVInBtnLink = false
        }
        if showMaskVInNewlist{
            showMaskVInNewlist = false
        }
        
        if showMaskVInCarousel{
            showMaskVInCarousel = false
        }
        
        if isAgentConnect{
            self.botClient.sendMessage("", options: [:])
        }
        
        let message: Message = Message()
        message.messageType = .default
        //message.sentDate = Date()
        message.sentDate = Calendar.current.date(byAdding: .day, value: 0, to: Date())
        message.messageId = UUID().uuidString
        
        messageIdIndex = messageIdIndex + 1
        message.messageIdIndex = NSNumber(value: messageIdIndex)
        
        let textComponent: Component = Component()
        textComponent.payload = text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        message.addComponent(textComponent)
        sendMessage(message, options: options)
        
    }
    func moveToRNScreen(){
        isSessionExpire = true
        sessionTimeoutMessage(messageString: "Your session has expired. Please re-login")
        Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { (_) in
            self.tapsOnBackBtnAction(self)
        }
    }
    
    func sessionTimeoutMessage(messageString:String){
        rowIndex = 0
        calenderCloseTag = false
        
        let message: Message = Message()
        message.messageType = .reply
        messageIdIndex = messageIdIndex + 1
        message.messageIdIndex = NSNumber(value: messageIdIndex)
        message.sentDate = Calendar.current.date(byAdding: .day, value: 0, to: Date())
        message.messageId = UUID().uuidString
        let textComponent: Component = Component()
        textComponent.payload = messageString
        message.addComponent(textComponent)
        addMessages(message, "")
        NotificationCenter.default.post(name: Notification.Name("StopTyping"), object: nil)
        self.textMessageSent()
    }
    
    func textMessageSent() {
        self.composeView.clear()
        self.botMessagesView.scrollToTop(animate: true)
    }
    
    func speechToTextButtonAction() {
        timerCounter = maxiumTimeCount
        self.configureViewForKeyboard(false)
        _ = self.composeView.resignFirstResponder()
        self.stopTTS()
        self.audioComposeView.startRecording()
        
        let options = UIView.AnimationOptions(rawValue: UInt(7 << 16))
        let duration = 0.25
        UIView.animate(withDuration: duration, delay: 0.0, options: options, animations: {
            self.view.layoutIfNeeded()
        }, completion: { (Bool) in
        })
    }
    
    func configureViewForKeyboard(_ prepare: Bool) {
        timerCounter = maxiumTimeCount
        if prepare {
            self.composeBarContainerHeightConstraint.isActive = false
            self.composeViewBottomConstraint.isActive = true
        } else {
            self.composeViewBottomConstraint.isActive = false
            self.composeBarContainerHeightConstraint.isActive = true
        }
        self.audioComposeContainerHeightConstraint.isActive = prepare
        self.audioComposeContainerView.clipsToBounds = prepare
        self.composeView.configureViewForKeyboard(prepare)
        self.composeBarContainerView.isHidden = !prepare
        self.audioComposeContainerView.isHidden = prepare
    }
    
    // MARK: BotMessagesDelegate methods
    func optionsButtonTapAction(text: String) {
        self.sendTextMessage(text, options: nil)
    }
    
    
    func optionsButtonTapNewAction(text:String, payload:String){
        print("helloooooo")
        if text == "****" || text == "******"{
            self.sendTextMessage(text, options: ["body": payload, "renderMsg": text])
        }else{
            self.sendTextMessage(text, options: ["body": payload])
        }
        
    }
    
    func sendSlientMessageTobot(text:String){
        self.botClient.sendMessage(text, options: [:])
    }
    
    func languageChange(text: String) {
        self.botClient.sendMessage(text, options: [:])
    }
    
    
    
    @objc func languageChangeNotification(){
        self.composeView.composeBarLanguageChange()
        if preferred_language_Type == preferredLanguage{
            self.headerView.semanticContentAttribute = .forceRightToLeft
            backBtn.setBackgroundImage(UIImage(named: "keyboard-arrow-right", in: bundle, compatibleWith: nil), for: .normal)
            leftMenuBackBtn.setBackgroundImage(UIImage(named: "keyboard-arrow-right", in: bundle, compatibleWith: nil), for: .normal)
            // botMessagesView.tableView.semanticContentAttribute = .forceRightToLeft
        }else{
            self.headerView.semanticContentAttribute = .forceLeftToRight
            backBtn.setBackgroundImage(UIImage(named: "keyboard-arrow-left", in: bundle, compatibleWith: nil), for: .normal)
            leftMenuBackBtn.setBackgroundImage(UIImage(named: "keyboard-arrow-left", in: bundle, compatibleWith: nil), for: .normal)
            //botMessagesView.tableView.semanticContentAttribute = .forceLeftToRight
        }
        // NotificationCenter.default.post(name: Notification.Name(reloadTableNotification), object: nil)
    }
    
    @objc func showPDFErrorMeesage(notification:Notification){
        let dataString: String = notification.object as? String ?? ""
        self.toastMessage(dataString)
    }
    
    func linkButtonTapAction(urlString: String) {
        
        let urlStr = urlString.replacingOccurrences(of: "%20", with: "")
        if verifyUrl(urlString: urlStr){
            if (urlStr.count > 0) {
                let url: URL = URL(string: urlStr)!
                let webViewController = SFSafariViewController(url: url)
                present(webViewController, animated: true, completion:nil)
            }
        }
        
    }
    
    func copyTextInComposeBar(text:String){
        self.composeView.setText(text)
    }
    
    func verifyUrl(urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = URL(string: urlString) {
                return UIApplication.shared.canOpenURL(url)
            }
        }
        return false
    }
    
    func infoTableViewSelectRow(text: String) {
        
    }
    func hideInfoView(){
        
    }
    
    func populateQuickReplyCards(with message: KREMessage?) {
        quickreplyContainerViewTopConstraint.constant = 0.0
        quickReplySuggesstionLblHeight = 32
        if message?.templateType == (ComponentType.quickReply.rawValue as NSNumber) {
            let component: KREComponent = message!.components![0] as! KREComponent
            if (!component.isKind(of: KREComponent.self)) {
                return;
            }
            if ((component.componentDesc) != nil) {
                let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: component.componentDesc!) as! NSDictionary
                
                var quickReplies: Array<Dictionary<String, Any>>
                if jsonObject["template_type"] as! String == "button"{
                    quickReplies = jsonObject["buttons"] as? Array<Dictionary<String, AnyObject>> ?? []
                }else{
                    quickReplies = jsonObject["quick_replies"] as? Array<Dictionary<String, AnyObject>> ?? []
                }
                
                var words: Array<Word> = Array<Word>()
                
                for dictionary in quickReplies {
                    let title: String = (dictionary["title"] != nil ? dictionary["title"] as? String : "") ?? String(dictionary["title"] as! Int)
                    var payload = ""
                    if let payloadStr = dictionary["payload"] as? [String: Any]{
                        payload = payloadStr["name"] as? String ?? ""
                    }else{
                        payload = dictionary["payload"] as? String ?? ""
                    }
                    let imageURL: String = (dictionary["image_url"] != nil ? dictionary["image_url"] as? String : "") ?? String(dictionary["image_url"] as! Int)
                    
                    let showMoreMessages: String = (dictionary["showMoreMessages"] != nil ? dictionary["showMoreMessages"] as? String : "") ?? String(dictionary["showMoreMessages"] as! Int)
                    let type: String = (dictionary["type"] != nil ? dictionary["type"] as? String : "") ?? String(dictionary["type"] as! Int)
                    let url: String = (dictionary["url"] != nil ? dictionary["url"] as? String : "") ?? String(dictionary["url"] as! Int)
                    
                    let word: Word = Word(title: title, payload: payload, imageURL: imageURL, showMoreMessages: showMoreMessages, type: type, url: url)
                    
                    //let word: Word = Word(title: title, payload: payload, imageURL: imageURL)
                    words.append(word)
                }
                self.quickReplyView.isLaguage = preferredLanguage
                let bgColor = (brandingShared.buttonActiveBgColor) ?? "#f3f3f5"
                let textColor = (brandingShared.buttonActiveTextColor) ?? "#2881DF"
                self.quickReplyView.bgColor = bgColor
                self.quickReplyView.textColor = textColor
                self.quickReplyView.boarderColor = textColor
                self.quickReplyView.fontName = mediumCustomFont
                if preferred_language_Type  == preferredLanguage{
                    self.quickReplyView.collectionView.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
                }else{
                    self.quickReplyView.collectionView.transform = CGAffineTransform.identity
                }
                self.quickReplyView.words = words
                if quickReplies.count > 0{
                    self.updateQuickSelectViewConstraints()
                }else{
                    self.closeQuickSelectViewConstraints()
                }
                
            }
        } else if message?.templateType == (ComponentType.welcome_template.rawValue as NSNumber) || message?.templateType == (ComponentType.emptyBubbleTemplate.rawValue as NSNumber) {
            let component: KREComponent = message!.components![0] as! KREComponent
            if (!component.isKind(of: KREComponent.self)) {
                return;
            }
            if ((component.componentDesc) != nil) {
                let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: component.componentDesc!) as! NSDictionary
                
                var quickReplies: Array<Dictionary<String, Any>>
                if jsonObject["template_type"] as! String == "button"{
                    quickReplies = jsonObject["buttons"] as? Array<Dictionary<String, AnyObject>> ?? []
                }else{
                    quickReplies = jsonObject["quick_replies"] as? Array<Dictionary<String, AnyObject>> ?? []
                    if let suggestionText = jsonObject["quick_reply_title"] as? String{
//                        quickReplySuggesstionLbl.text = suggestionText
//                        quickReplySuggesstionLblHeight = 50
//                        quickReplySuggesstionLblHeightConstraint.constant = 16.0
//                        quickReplyViewTopConstraint.constant = 16.0
//                        quickreplyContainerViewTopConstraint.constant = 32.0
                    }
                }
                
                var words: Array<Word> = Array<Word>()
                
                for dictionary in quickReplies {
                    let title: String = (dictionary["title"] != nil ? dictionary["title"] as? String : "") ?? String(dictionary["title"] as! Int)
                    let payload: String = (dictionary["payload"] != nil ? dictionary["payload"] as? String : "") ?? String(dictionary["payload"] as! Int)
                    let imageURL: String = (dictionary["image_url"] != nil ? dictionary["image_url"] as? String : "") ?? String(dictionary["image_url"] as! Int)
                    
                    let showMoreMessages: String = (dictionary["showMoreMessages"] != nil ? dictionary["showMoreMessages"] as? String : "") ?? String(dictionary["showMoreMessages"] as! Int)
                    let type: String = (dictionary["type"] != nil ? dictionary["type"] as? String : "") ?? String(dictionary["type"] as! Int)
                    let url: String = (dictionary["url"] != nil ? dictionary["url"] as? String : "") ?? String(dictionary["url"] as! Int)
                    
                    let word: Word = Word(title: title, payload: payload, imageURL: imageURL, showMoreMessages: showMoreMessages, type: type, url: url)
                    
                    //let word: Word = Word(title: title, payload: payload, imageURL: imageURL)
                    words.append(word)
                }
                self.quickReplyView.isLaguage = preferredLanguage
                if preferred_language_Type  == preferredLanguage{
                    self.quickReplyView.collectionView.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
                }else{
                    self.quickReplyView.collectionView.transform = CGAffineTransform.identity
                }
                self.quickReplyView.words = words
                if quickReplies.count > 0{
                    self.updateQuickSelectViewConstraints()
                }else{
                    self.closeQuickSelectViewConstraints()
                }
            }
        }else if(message != nil) {
            let words: Array<Word> = Array<Word>()
            self.quickReplyView.words = words
            self.closeQuickSelectViewConstraints()
        }
    }
    
    func closeQuickReplyCards(){
        self.closeQuickSelectViewConstraints()
    }
    
    func updateQuickSelectViewConstraints() {
        let height = self.quickReplyView.collectionView.collectionViewLayout.collectionViewContentSize.height
        let maxHeight = height > 198.0 ? 198.0 : height //248.0
        self.quickReplyView.collectionView.isScrollEnabled = false
        if  maxHeight >= 198.0{
            self.quickReplyView.collectionView.isScrollEnabled = true
        }
        var quickSelectCollVheight = maxHeight > 60.0 ? maxHeight : 60.0
        quickSelectCollVheight += CGFloat(quickReplySuggesstionLblHeight)
        if self.quickSelectContainerHeightConstraint.constant == quickSelectCollVheight {return}
        
        self.quickSelectContainerHeightConstraint.constant = quickSelectCollVheight
        UIView.animate(withDuration: 0.25, delay: 0.05, options: [], animations: {
            self.view.layoutIfNeeded()
        }) { (Bool) in
            
        }
    }
    
    func closeQuickSelectViewConstraints() {
        quickreplyContainerViewTopConstraint.constant = 0.0
        if self.quickSelectContainerHeightConstraint.constant == 0.0 {return}
        self.quickSelectContainerHeightConstraint.constant = 0.0
        UIView.animate(withDuration: 0.25, delay: 0.0, options: [], animations: {
            self.view.layoutIfNeeded()
        }) { (Bool) in
            
        }
    }
    
    func populateCalenderView(with message: KREMessage?) {
        var messageId = ""
        if message?.templateType == (ComponentType.calendarView.rawValue as NSNumber) {
            let component: KREComponent = message!.components![0] as! KREComponent
            print(component)
            if (!component.isKind(of: KREComponent.self)) {
                return;
            }
            if (component.message != nil) {
                messageId = component.message!.messageId!
            }
            if ((component.componentDesc) != nil) {
                let jsonString = component.componentDesc
                let calenderViewController = CalenderViewController(dataString: jsonString!, chatId: messageId, kreMessage: message!)
                calenderViewController.viewDelegate = self
                calenderViewController.modalPresentationStyle = .overFullScreen
                self.navigationController?.present(calenderViewController, animated: true, completion: nil)
            }
        }
    }
    
    func populateFeedbackSliderView(with message: KREMessage?) {
        var messageId = ""
        if message?.templateType == (ComponentType.feedbackTemplate.rawValue as NSNumber) {
            let component: KREComponent = message!.components![0] as! KREComponent
            print(component)
            if (!component.isKind(of: KREComponent.self)) {
                return;
            }
            if (component.message != nil) {
                messageId = component.message!.messageId!
            }
            if ((component.componentDesc) != nil) {
                let jsonString = component.componentDesc
                let feedbackViewController = FeedbackSliderViewController(dataString: jsonString!)
                feedbackViewController.viewDelegate = self
                feedbackViewController.modalPresentationStyle = .overFullScreen
                self.navigationController?.present(feedbackViewController, animated: true, completion: nil)
            }
        }
    }
    
    func populateIDFCAgentDetails(with message: KREMessage?) {
        var messageId = ""
        if message?.templateType == (ComponentType.idfcAgentTemplate.rawValue as NSNumber) {
            let component: KREComponent = message!.components![0] as! KREComponent
            print(component)
            if (!component.isKind(of: KREComponent.self)) {
                return;
            }
            if (component.message != nil) {
                messageId = component.message!.messageId!
            }
            if ((component.componentDesc) != nil) {
                let jsonString = component.componentDesc
                if let jsonObject: [String: Any] = Utilities.jsonObjectFromString(jsonString: jsonString ?? "") as? [String : Any] {
                    // print("Agent Details\(jsonObject)")
                    if let dictionary = jsonObject["payload"] as? [String: Any] {
                        //print("Agent Details dictionary \(dictionary)")
                        
                        if dictionary["isAgent"] as? Bool == true{
                            
                        }else{
                        }
                    }
                }
            }
        }
    }
    
    // MARK: ComposeBarViewDelegate methods
    
    func composeBarView(_: ComposeBarView, sendButtonAction text: String) {
        if isMasking {
            let secureTxt = text.regEx()
            self.sendTextMessage(secureTxt, options: ["body": text])
        }else{
            self.sendTextMessage(text, options: nil)
        }
    }
    
    func composeBarViewSpeechToTextButtonAction(_: ComposeBarView) {
        KoraASRService.shared.checkAudioRecordPermission({ [weak self] in
            self?.isShowAudioComposeView = true
            self?.speechToTextButtonAction()
        })
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ClosePanel"), object: nil)
    }
    
    func composeBarViewDidBecomeFirstResponder(_: ComposeBarView) {
        self.audioComposeView.stopRecording()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ClosePanel"), object: nil)
    }
    func showTypingToAgent(_: ComposeBarView){
        if isAgentConnect{
            self.botClient.sendMessage("", options: [:])
        }
    }
    func stopTypingToAgent(_: ComposeBarView){
        if isAgentConnect{
            self.botClient.sendMessage("", options: [:])
        }
    }
    
    
    func composeBarTaskMenuButtonAction(_: ComposeBarView) {
        self.bottomConstraint.constant = 0
        self.taskMenuContainerHeightConstant.constant = 0
        if (self.composeView.isFirstResponder) {
            _ = self.composeView.resignFirstResponder()
        }
        
        //        let taskMenuViewController = TaskMenuViewController()
        //        taskMenuViewController.modalPresentationStyle = .overFullScreen
        //        taskMenuViewController.viewDelegate = self
        //        self.navigationController?.present(taskMenuViewController, animated: true, completion: nil)
        
        leftMenuContainerView.isHidden = false
        let zero = CGAffineTransform(translationX: 0.0, y: 0.0)
        self.leftMenuContainerView.transform = zero
        if preferred_language_Type == preferredLanguage{
            leftMenuContainerView.semanticContentAttribute = .forceRightToLeft
            leftMenuContainerSubView.semanticContentAttribute = .forceRightToLeft
            let transition = CATransition()
            transition.type = .push
            transition.subtype = .fromLeft
            self.leftMenuContainerView.layer.add(CATransition().segueFromRight(), forKey: nil)
            self.leftMenuView.leftMenuTableviewReload()
            leftMenuTitleLbl.text = "Menu"//"قائمة الطعام"
        }else{
            leftMenuContainerView.semanticContentAttribute = .forceLeftToRight
            leftMenuContainerSubView.semanticContentAttribute = .forceLeftToRight
            let transition = CATransition()
            transition.type = .push
            transition.subtype = .fromLeft
            self.leftMenuContainerView.layer.add(CATransition().segueFromLeft(), forKey: nil)
            self.leftMenuView.leftMenuTableviewReload()
            leftMenuTitleLbl.text = "Menu"
        }
    }
    
    // MARK: KREGrowingTextViewDelegate methods
    func growingTextView(_: KREGrowingTextView, changingHeight height: CGFloat, animate: Bool) {
        UIView.animate(withDuration: animate ? 0.25: 0.0) {
            self.view.layoutIfNeeded()
        }
    }
    
    func growingTextView(_: KREGrowingTextView, willChangeHeight height: CGFloat) {
        
    }
    
    func growingTextView(_: KREGrowingTextView, didChangeHeight height: CGFloat) {
        
    }
    
    // MARK: TTS Functionality
    @objc func startSpeaking(notification:Notification) {
        if(isSpeakingEnabled){
            var string: String = notification.object! as! String
            string = KREUtilities.getHTMLStrippedString(from: string)
            self.readOutText(text: string)
        }
    }
    
    @objc func stopSpeaking(notification:Notification) {
        self.stopTTS()
    }
    
    func readOutText(text:String) {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
            try audioSession.setMode(AVAudioSession.Mode.default)
        } catch {
            
        }
        let string = text
        print("Reading text: ", string);
        let speechUtterance = AVSpeechUtterance(string: string)
        self.speechSynthesizer.speak(speechUtterance)
    }
    
    func stopTTS(){
        if(self.speechSynthesizer.isSpeaking){
            self.speechSynthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        }
    }
    
    // MARK: show tying status view
    func showTypingStatusForBotsAction() {
        let botId:String = "u-40d2bdc2-822a-51a2-bdcd-95bdf4po8331c9";
        let info:NSMutableDictionary = NSMutableDictionary.init()
        info.setValue(botId, forKey: "botId");
        info.setValue("kore", forKey: "imageName");
        self.typingStatusView?.startTypingStatus(using: botHistoryIcon,dotColor: themeColor)
    }
    
    // MARK: show TableTemplateView
    @objc func showTableTemplateView(notification:Notification) {
        //        let dataString: String = notification.object as! String
        //        let tableTemplateViewController = TableTemplateViewController(dataString: dataString)
        //        self.navigationController?.present(tableTemplateViewController, animated: true, completion: nil)
    }
    
    @objc func reloadTable(notification:Notification){
        if botMessagesView != nil{
            botMessagesView.tableView.reloadData()
        }
    }
    
    // MARK: show NewListViewDetailsTemplateView
    @objc func showListViewTemplateView(notification:Notification) {
        let dataString: String = notification.object as! String
        let listViewDetailsViewController = ListViewDetailsViewController(dataString: dataString)
        listViewDetailsViewController.viewDelegate = self
        listViewDetailsViewController.modalPresentationStyle = .overFullScreen
        self.navigationController?.present(listViewDetailsViewController, animated: true, completion: nil)
    }
    
    @objc func showSalamPointsTemplateView(notification:Notification) {
        let dataString: String = notification.object as! String
        let listViewDetailsViewController = SalaamPointsDetailsViewController(dataString: dataString)
        //listViewDetailsViewController.viewDelegate = self
        listViewDetailsViewController.modalPresentationStyle = .overFullScreen
        self.navigationController?.present(listViewDetailsViewController, animated: true, completion: nil)
    }
    
    @objc func showListWidgetViewTemplateView(notification:Notification){
        let dataString: String = notification.object as! String
        let listViewDetailsViewController = ListWidgetDetailsViewController(dataString: dataString)
        listViewDetailsViewController.viewDelegate = self
        listViewDetailsViewController.modalPresentationStyle = .overFullScreen
        listViewDetailsViewController.view.backgroundColor = .white
        self.navigationController?.present(listViewDetailsViewController, animated: true, completion: nil)
    }
    
    @objc func dropDownTemplateActtion(notification:Notification){
        let dataString: String = notification.object as! String
        composeView.setText(dataString)
    }
    
    @objc func custom_DropDown_TextAppendAction(notification:Notification){
        let dataString: String = notification.object as! String
        composeView.setText(dataString)
        customDropDownSeletct = dataString
        //NotificationCenter.default.post(name: Notification.Name(customDDTextAppendInTemplateNotification), object: nil)
    }
    
    @objc func showActivityViewController(notification:Notification){
        let dataString: String = notification.object as? String ?? ""
        if dataString == "Copy"{
            self.toastMessage("Copied")
        }else{
            let textToShare = [shareAndCopyStr]
            let activityViewController = UIActivityViewController(activityItems: textToShare as [Any], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
            
            // exclude some activity types from the list (optional)
            activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
            
            // present the view controller
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    @objc func showPDFViewController(notification:Notification){
        let dataString: String = notification.object as? String ?? ""
        if dataString == "Show"{
            self.toastMessage("Statement saved successfully under Files")
        }else{
            if #available(iOS 11.0, *) {
                let vc = PdfShowViewController(dataString: dataString)
                vc.pdfUrl = URL(string: dataString)
                vc.modalPresentationStyle = .overFullScreen
                self.navigationController?.present(vc, animated: true, completion: nil)
            } else {
                // Fallback on earlier versions
            }
            
        }
    }
    
    @objc func tokenExpiry(notification:Notification){
        
        if isErrorType == "STS"{
            let dic = ["event_code": "Error_STS", "event_message": "STS call failed"]
            let jsonString = Utilities.stringFromJSONObject(object: dic)
            NotificationCenter.default.post(name: Notification.Name(CallbacksNotification), object: jsonString)
            
            isSessionExpire = true
            
        }else{
            let dic = ["event_code": "Error_Socket", "event_message": "Socket connection failed"]
            let jsonString = Utilities.stringFromJSONObject(object: dic)
            NotificationCenter.default.post(name: Notification.Name(CallbacksNotification), object: jsonString)
            isSessionExpire = true
        }
    }
    
    @objc func autoDirectingToWebV(notification:Notification) {
        if let urlString  = notification.object as? String{
            if (urlString.count > 0) {
                Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { (_) in
                    let url: URL = URL(string: urlString)!
                    let webViewController = SFSafariViewController(url: url)
                    self.present(webViewController, animated: true, completion:nil)
                }
            }
        }
    }
    
    @objc func OTPvalidateTemplateActtion(notification:Notification){
        let dataString: String = notification.object as! String
        let otpValidationVC = OTPValidationVC(dataString: dataString)
        otpValidationVC.viewDelegate = self
        otpValidationVC.modalPresentationStyle = .overFullScreen
        self.navigationController?.present(otpValidationVC, animated: true, completion: nil)
    }
    
    @objc func resetPinTemplateActtion(notification:Notification){
        let dataString: String = notification.object as! String
        let oresetPinVC = ResetPinViewController(dataString: dataString)
        oresetPinVC.viewDelegate = self
        oresetPinVC.modalPresentationStyle = .overFullScreen
        self.navigationController?.present(oresetPinVC, animated: true, completion: nil)
    }
    @objc func resetPasswordTemplateActtion(notification:Notification){
        let dataString: String = notification.object as! String
        let oresetPinVC = ResetPasswordVC(dataString: dataString)
        oresetPinVC.viewDelegate = self
        oresetPinVC.modalPresentationStyle = .overFullScreen
        self.navigationController?.present(oresetPinVC, animated: true, completion: nil)
    }
    
    @objc func customFormTemplateAction(notification:Notification){
        let dataString: String = notification.object as! String
        let oresetPinVC = FormTemplateVC(dataString: dataString)
        oresetPinVC.viewDelegate = self
        oresetPinVC.modalPresentationStyle = .overFullScreen
        self.navigationController?.present(oresetPinVC, animated: true, completion: nil)
    }
    
    @objc func userValidationTemplateAction(notification:Notification){
        let dataString: String = notification.object as! String
        let userValidationVC = UserValidationViewController(dataString: dataString)
        userValidationVC.viewDelegate = self
        userValidationVC.modalPresentationStyle = .overFullScreen
        self.navigationController?.present(userValidationVC, animated: true, completion: nil)
    }
    
    @objc func salikTemplateActtion(notification:Notification){
        let dataString: String = notification.object as! String
        let presetPinVC = SalikPinViewController(dataString: dataString)
        presetPinVC.viewDelegate = self
        presetPinVC.modalPresentationStyle = .overFullScreen
        self.navigationController?.present(presetPinVC, animated: true, completion: nil)
    }
    @objc func timeSlotTemplateActtion(notification:Notification){
        let dataString: String = notification.object as! String
        let presetVC = TimeSlotViewController(dataString: dataString)
        presetVC.viewDelegate = self
        presetVC.modalPresentationStyle = .overFullScreen
        self.navigationController?.present(presetVC, animated: true, completion: nil)
    }
    @objc func customDropDownTemplateAction(notification:Notification){
        let dataString: String = notification.object as! String
        let presetVC = CustomDropDownDetailsVC(dataString: dataString)
        presetVC.viewDelegate = self
        presetVC.modalPresentationStyle = .overFullScreen
        self.navigationController?.present(presetVC, animated: true, completion: nil)
    }
    
    @objc func loginNotificationActtion(notification:Notification){
        
        if let dataString: String = notification.object as? String{
            print("Login Failed\(dataString)")
            self.toastMessage("Invalid Username or Password")
        }else{
            print("Login Sucess")
            let chatBotName: String = SDKConfiguration.botConfig.chatBotName
            let botId: String = SDKConfiguration.botConfig.botId
            //            authorizationToken = loginAccessToken ?? ""
            //            xAuthToken = loginXauthToken ?? ""
            let customData: [String: Any] = ["accessToken": loginAccessToken ?? "", "xAuthToken": loginXauthToken ?? "","userId": loginUserId ?? "", "userType": loginUserType ?? "", "rtmType": "mobile", "customerCif": loginCustomerCif ?? "", "customerName": loginCustomerName ?? "", "loginId": loginID ?? "", "userSegments": loginUserSegments ?? "", "customerEmailId": loginEmailId ?? "","mobileNumber": loginMobileNo ?? ""]
            let botInfo: [String: Any] = ["chatBot": chatBotName, "taskBotId": botId, "customData": customData]
            loginParameters = botInfo
            self.botClient.sendMessage("*****************", options: ["body": "User provided login inputs", "renderMsg": "*****************"])
        }
        
    }
    
    @objc func botClosedNotificationAction(notification:Notification) {
        self.botClosed()
    }
    @objc func sessionExpiryNotificationAction(notification:Notification) {
        let dic = ["event_code": "SESSION_EXPIRED", "event_message": "Your session has been expired. Please re-login."]
        let jsonString = Utilities.stringFromJSONObject(object: dic)
        NotificationCenter.default.post(name: Notification.Name(CallbacksNotification), object: jsonString)
        self.botClosed()
    }
    
    
    // MARK: -
    public func maximizePanelWindow() {
        
    }
    
    public func minimizePanelWindow(_ canValidateSession: Bool = true) {
        sheetController?.dismissAllPresentedViewControllers { [weak self] in
            self?.sheetController?.closeSheet(completion: {
                self?.sheetController = nil
            })
        }
    }
}

// MARK: -
extension ChatMessagesViewController {
    // MARK: - get history
    public func getMessages(offset: Int) {
        guard historyRequestInProgress == false else {
            return
        }
        self.botMessagesView.spinner.startAnimating()
        botClient.getHistory(offset: offset,limit: 20, success: { [weak self] (responseObj) in
            if let responseObject = responseObj as? [String: Any], let messages = responseObject["messages"] as? Array<[String: Any]> {
                let reverse: Array<[String: Any]> = messages.reversed()
                if reverse.count == 0{
                    //self?.chatHistoryHeightConstraint.constant = 0.0
                    self?.toastMessage("No History available")
                }
                self?.insertOrUpdateHistoryMessages(reverse)
                //self?.insertOrUpdateHistoryMessages(messages)
                self?.botMessagesView.spinner.stopAnimating()
            }
            self?.historyRequestInProgress = false
        }, failure: { [weak self] (error) in
            self?.historyRequestInProgress = false
            print("Unable to fetch messges \(error?.localizedDescription ?? "")")
            self?.botMessagesView.spinner.stopAnimating()
        })
    }
    
    public func getRecentHistory() {
        guard messagesRequestInProgress == false else {
            return
        }
        
        let dataStoreManager = DataStoreManager.sharedManager
        let context = dataStoreManager.coreDataManager.workerContext
        messagesRequestInProgress = true
        let request: NSFetchRequest<KREMessage> = KREMessage.fetchRequest()
        let isSenderPredicate = NSPredicate(format: "isSender == \(false)")
        request.predicate = isSenderPredicate
        //let sortDates = NSSortDescriptor(key: "sentOn", ascending: false)
        let sortDates = NSSortDescriptor(key: "messageIdIndex", ascending: false)
        request.sortDescriptors = [sortDates]
        request.fetchLimit = 1
        
        context.perform { [weak self] in
            guard let array = try? context.fetch(request), array.count > 0 else {
                self?.messagesRequestInProgress = false
                return
            }
            
            guard let messageId = array.first?.messageId else {
                self?.messagesRequestInProgress = false
                return
            }
            
            self?.botClient.getMessages(after: messageId, direction: 1, success: { (responseObj) in
                if let responseObject = responseObj as? [String: Any]{
                    if let messages = responseObject["messages"] as? Array<[String: Any]> {
                        self?.insertOrUpdateHistoryMessages(messages)
                    }
                }
                self?.messagesRequestInProgress = false
            }, failure: { (error) in
                self?.messagesRequestInProgress = false
                print("Unable to fetch history \(error?.localizedDescription ?? "")")
            })
        }
    }
    
    // MARK: - insert or update messages
    func insertOrUpdateHistoryMessages(_ messages: Array<[String: Any]>) {
        guard let botMessages = Mapper<BotMessages>().mapArray(JSONArray: messages) as? [BotMessages], botMessages.count > 0 else {
            return
        }
        var removeRemoveQuickReplies = false
        var allMessages: [Message] = [Message]()
        for message in botMessages {
            removeRemoveQuickReplies = false
            if message.type == "outgoing" || message.type == "incoming" {
                guard let components = message.components, let data = components.first?.data else {
                    continue
                }
                
                guard let jsonString = data["text"] as? String else {
                    continue
                }
                
                let botMessage: BotMessageModel = BotMessageModel()
                botMessage.createdOn = message.createdOn
                botMessage.messageId = message.messageId
                botMessage.type = message.type
                
                let messageModel: MessageModel = MessageModel()
                let componentModel: ComponentModel = ComponentModel()
                if jsonString.contains("payload"), let jsonObject: [String: Any] = Utilities.jsonObjectFromString(jsonString: jsonString) as? [String : Any] {
                    componentModel.type = jsonObject["type"] as? String
                    
                    var payloadObj: [String: Any] = [String: Any]()
                    payloadObj["payload"] = jsonObject["payload"] as? [String : Any] ?? [:]
                    payloadObj["type"] = jsonObject["type"]
                    componentModel.payload = payloadObj
                } else {
                    removeRemoveQuickReplies = false
                    var payloadObj: [String: Any] = [String: Any]()
                    payloadObj["text"] = jsonString
                    payloadObj["type"] = "text"
                    componentModel.type = "text"
                    componentModel.payload = payloadObj
                    if jsonString == "User provided login inputs"{
                        removeRemoveQuickReplies = true
                        welcomeMsgRemoveCount += 1
                    }else if jsonString.contains("§§"){
                        removeRemoveQuickReplies = true
                        welcomeMsgRemoveCount += 1
                    }else if Utilities.isValidJson(check: jsonString) == true{
                        removeRemoveQuickReplies = true
                        welcomeMsgRemoveCount += 1
                    }
                }
                
                messageModel.type = "text"
                messageModel.component = componentModel
                botMessage.messages = [messageModel]
                let messageTuple = onReceiveMessage(object: botMessage)
                if let object = messageTuple.0 {
                    if !removeRemoveQuickReplies{
                        if !isOTPValidationTemplate{
                            allMessages.append(object)
                        }
                    }
                }
            }
        }
        
        // insert all messages
        if allMessages.count > 0 {
            let dataStoreManager = DataStoreManager.sharedManager
            dataStoreManager.insertMessages(allMessages, in: thread, completion: nil)
        }
    }
    
    // MARK: - fetch messages
    func fetchMessages() {
        let dataStoreManager = DataStoreManager.sharedManager
        dataStoreManager.getMessagesCount(completion: { [weak self] (count) in
            if count == 0 {
                self?.getMessages(offset: 0)
            }else{
                self?.offSet =  count + welcomeMsgRemoveCount + OTPValidationRemoveCount
                if (self?.botMessagesView.spinner.isHidden)!{
                    self?.getMessages(offset: self!.offSet)
                }
            }
        })
    }
    
    func tableviewScrollDidEnd(){
        if isCallChatHistory{
            fetchMessages()
        }
    }
}
extension ChatMessagesViewController: KABotClientDelegate {
    func showTypingStatusForBot() {
        self.typingStatusView?.isHidden = true
        self.typingStatusView?.startTypingStatus(using: botHistoryIcon,dotColor: themeColor)
    }
    
    // MARK: - KABotlientDelegate methods
    open func botConnection(with connectionState: BotClientConnectionState) {
        updateNavBarPrompt()
    }
    
    @objc func startTypingStatusForBot() {
        self.typingStatusView?.isHidden = true
        let botId:String = SDKConfiguration.botConfig.botId
        let info:NSMutableDictionary = NSMutableDictionary.init()
        info.setValue(botId, forKey: "botId");
        let urlString = brandingShared.bankLogo
        info.setValue(urlString ?? "kora", forKey: "imageName");
        self.typingStatusView?.isLanguage = default_language
        self.typingStatusView?.startTypingStatus(using: botHistoryIcon,dotColor: themeColor)
    }
    
    @objc func stopTypingStatusForBot(){
        self.typingStatusView?.stopTypingStatus()
    }
}
// MARK: - requests
extension ChatMessagesViewController {
    func populatePanelItems() {
        let widgetManager = KREWidgetManager.shared
        panelCollectionView.startAnimating()
        widgetManager.getPanelItems { [weak self] (success, items, error) in
            DispatchQueue.main.async {
                self!.panelCollectionView.stopAnimating(error)
                guard let panelItems = items as? [KREPanelItem] else {
                    return
                }
                
                self?.showHomePanel(completion: {
                    
                })
                //KoraApplication.sharedInstance.account?.validateTimeZone()
                self!.panelCollectionView.items = panelItems
                widgetManager.getPriorityWidgets(from: panelItems, block: nil)
                NotificationCenter.default.post(name: KoraNotification.Panel.update.notification, object: nil)
                
                if let _ = error  {
                    
                }
            }
        }
    }
    
    @objc func processDynamicUpdates(_ notification: Notification?) {
        guard let dictionary = notification?.object as? [String: Any],
              let type = dictionary["t"] as? String, let _ = dictionary["uid"] as? String else {
            return
        }
        
        switch type {
        case "kaa":
            let panelItems = self.panelCollectionView.items
            guard let panelItem = panelItems?.filter({ $0.iconId == "announcement" }).first else {
                return
            }
            
            let widgetManager = KREWidgetManager.shared
            widgetManager.getWidgets(in: panelItem, forceReload: true, update: { [weak self] (success, widget) in
                DispatchQueue.main.async {
                    self?.updatePanel(with: panelItem)
                }
            }, completion: nil)
        default:
            break
        }
    }
    
    @objc func processPanelEvents(_ notification: Notification?) {
        guard let dictionary = notification?.object as? [String: Any],
              let type = dictionary["entity"] as? String else {
            return
        }
        
        switch type {
        case "panels":
            populatePanelItems()
            if let data = dictionary["data"] as? [String: Any] {
                KREWidgetManager.shared.pinOrUnpinWidget(data)
            }
        default:
            break
        }
    }
    
    public func showHomePanel(_ isOnboardingInProgress: Bool = false, completion block:(()->Void)? = nil) {
        let panelItems = KREWidgetManager.shared.panelItems
        guard launchOptions == nil else {
            return
        }
        
        let panelBar = panelCollectionView
        switch panelBar!.panelState {
        case .loaded:
            guard let panelItem = panelItems?.filter({ $0.name == "Quick Summar" }).first else {
                return
            }
            
            panelCollectionView.panelItemHandler?(panelItem) { [weak self] in
                if !isOnboardingInProgress {
                    self?.startTryOut()
                }
                block?()
            }
            
        default:
            break
        }
    }
    
    func updatePanel(with panelItem: KREPanelItem) {
        guard let panelItemViewController = sheetController?.childViewController as? KAPanelItemViewController else {
            return
        }
        
        panelItemViewController.updatePanel(with: panelItem)
    }
    // MARK: - tryout
    open func startTryOut() {
        
    }
    // MARK: -
    func processActionPanelItem(_ item: KREPanelItem?) {
        if let uriString = item?.action?.uri, let url = URL(string: uriString + "?teamId=59196d5a0dd8e3a07ff6362b") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    
}

extension ChatMessagesViewController{
    func botConnectingMethod(){
        let clientId: String = SDKConfiguration.botConfig.clientId
        let clientSecret: String = SDKConfiguration.botConfig.clientSecret
        let isAnonymous: Bool = SDKConfiguration.botConfig.isAnonymous
        let chatBotName: String = SDKConfiguration.botConfig.chatBotName
        let botId: String = SDKConfiguration.botConfig.botId
        messageIdIndex = 5000
        messageIdIndexForHistory = 5000
        appEnterBackground = false
        reloadTabV = true
        
        let date: Date = Date()
        let xID = String(format: "email%ld%@", date.timeIntervalSince1970, "@domain.com")
        xcorelationID = xID
        
        var identity: String! = nil
        if (isAnonymous) {
            identity = self.getUUID()
        } else {
            identity = SDKConfiguration.botConfig.identity
        }
        
        
        let clientIdForWidget: String = SDKConfiguration.widgetConfig.clientId
        let clientSecretForWidget: String = SDKConfiguration.widgetConfig.clientSecret
        let isAnonymousForWidget: Bool = SDKConfiguration.widgetConfig.isAnonymous
        let chatBotNameForWidget: String = SDKConfiguration.widgetConfig.chatBotName
        let botIdForWidget: String = SDKConfiguration.widgetConfig.botId
        var identityForWidget: String! = nil
        if (isAnonymousForWidget) {
            identityForWidget = self.getUUID()
        } else {
            identityForWidget = SDKConfiguration.widgetConfig.identity
        }
        
        let dataStoreManager: DataStoreManager = DataStoreManager.sharedManager
        dataStoreManager.removeAllCoreData()
        
        if !clientId.hasPrefix("<") && !clientSecret.hasPrefix("<") && !chatBotName.hasPrefix("<") && !botId.hasPrefix("<") && !identity.hasPrefix("<")  {
            
            self.showLoader()
            kaBotClient.connect(block: { [weak self] (client, thread) in
                
                if !SDKConfiguration.widgetConfig.isPanelView {
                    self?.brandingApis(client: client, thread: thread)
                }else{
                    if !clientIdForWidget.hasPrefix("<") && !clientSecretForWidget.hasPrefix("<") && !chatBotNameForWidget.hasPrefix("<") && !botIdForWidget.hasPrefix("<") && !identityForWidget.hasPrefix("<") {
                        
                        self?.getWidgetJwTokenWithClientId(clientIdForWidget, clientSecret: clientSecretForWidget, identity: identityForWidget, isAnonymous: isAnonymousForWidget, success: { [weak self] (jwToken) in
                            
                            self?.brandingApis(client: client, thread: thread)
                            
                        }, failure: { (error) in
                            print(error.localizedDescription)
                            self!.stopLoader()
                        })
                        
                    }else{
                        self!.stopLoader()
                        self!.showAlert(title: alertName, message: "YOU MUST SET WIDGET 'clientId', 'clientSecret', 'chatBotName', 'identity' and 'botId'. Please check the documentation.")
                    }
                }
                
            }) { (error) in
                print(error.localizedDescription)
                self.stopLoader()
                if isErrorType == "STS"{
                    let dic = ["event_code": "Error_STS", "event_message": "STS call failed"]
                    let jsonString = Utilities.stringFromJSONObject(object: dic)
                    NotificationCenter.default.post(name: Notification.Name(CallbacksNotification), object: jsonString)
                    isSessionExpire = true
                    
                }else{
                    let dic = ["event_code": "Error_Socket", "event_message": "Socket connection failed"]
                    let jsonString = Utilities.stringFromJSONObject(object: dic)
                    NotificationCenter.default.post(name: Notification.Name(CallbacksNotification), object: jsonString)
                    
                    isSessionExpire = true
                }
            }
            
        } else {
            self.stopLoader()
            self.showAlert(title: alertName, message: "YOU MUST SET BOT 'clientId', 'clientSecret', 'chatBotName', 'identity' and 'botId'. Please check the documentation.")
            
        }
    }
    
    func brandingApis(client: BotClient?, thread: KREThread?){
        self.kaBotClient.brandingApiRequest(authInfoAccessToken,success: { [weak self] (brandingDic) in

                let jsonDecoder = JSONDecoder()
                guard let jsonData = try? JSONSerialization.data(withJSONObject: brandingDic as Any , options: .prettyPrinted),
                      let activeTheme = try? jsonDecoder.decode(ActiveTheme.self, from: jsonData) else {
                    return
                }
            
            let widgetBorderColor = activeTheme.widgetHeader?.bordercolor
            let widgetTextColor = activeTheme.widgetHeader?.fontcolor
            let buttonInactiveBgColor = activeTheme.buttons?.onHoverButtonColor
            let buttonInactiveTextColor = activeTheme.buttons?.onHoverFontColor
            let buttonActiveBgColor = activeTheme.buttons?.defaultButtonColor
            let buttonActiveTextColor = activeTheme.buttons?.defaultFontColor
            let widgetBgColor = activeTheme.widgetHeader?.backGroundColor
            let userchatBgColor = activeTheme.userMessage?.bubbleColor
            let userchatTextColor = activeTheme.userMessage?.fontcolor
            let theme = ""
            let botName = SDKConfiguration.botConfig.chatBotName
            let botchatBgColor = activeTheme.botMessage?.bubbleColor
            let botchatTextColor = activeTheme.botMessage?.fontcolor
             
            let widgetDividerColor = activeTheme.widgetFooter?.placeHolder
            let bankLogo = ""
             var widgetBgImage = ""
             if let userWidgetBgImage =  activeTheme.widgetBody?.useBackgroundImage, userWidgetBgImage == true{
                 widgetBgImage = activeTheme.widgetBody?.backGroundImage ?? ""
             }
            let widgetBodyColor = activeTheme.widgetBody?.backGroundColor
            let widgetFooterColor = activeTheme.widgetFooter?.backGroundColor
            let widgetHeaderColor = activeTheme.widgetHeader?.backGroundColor
            
            let widgetFooterTextColor = activeTheme.widgetFooter?.fontcolor
            let widgetFooterPlaceholderColor = activeTheme.widgetFooter?.placeHolder
            
            let brandingShared = BrandingSingleton.shared
            brandingShared.widgetBorderColor = widgetBorderColor
            brandingShared.widgetTextColor = widgetTextColor
            brandingShared.buttonInactiveBgColor = buttonInactiveBgColor
            brandingShared.buttonInactiveTextColor = buttonInactiveTextColor
            brandingShared.widgetBgColor = widgetBgColor
            brandingShared.botchatTextColor = botchatTextColor
            brandingShared.buttonActiveBgColor = buttonActiveBgColor
            brandingShared.buttonActiveTextColor = buttonActiveTextColor
            brandingShared.userchatBgColor = userchatBgColor
            brandingShared.theme = theme
            brandingShared.botName = botName
            brandingShared.botchatBgColor = botchatBgColor
            brandingShared.userchatTextColor = userchatTextColor
            brandingShared.widgetDividerColor = widgetDividerColor
            brandingShared.bankLogo = bankLogo
            brandingShared.widgetBgImage = widgetBgImage
            brandingShared.widgetBodyColor = widgetBodyColor
            brandingShared.widgetFooterColor = widgetFooterColor
            brandingShared.widgetHeaderColor = widgetHeaderColor
            brandingShared.widgetFooterTextColor = widgetFooterTextColor
            brandingShared.widgetFooterPlaceholderColor = widgetFooterPlaceholderColor
            
            self?.sucessMethod(client: client, thread: thread)
        }, failure: { (error) in
            print(error.localizedDescription)
            self.getOfflineBrandingData(client: client, thread: thread)
            
        })
    }
    
    func getOfflineBrandingData(client: BotClient?, thread: KREThread?){
        
        let brandingShared = BrandingSingleton.shared
        let jsonStr = brandingShared.brandingjsonStr
        let jsonResult = Utilities.jsonObjectFromString(jsonString: jsonStr)
        if let brandingArray = jsonResult as? NSArray {
            if brandingArray.count > 0{
                brandingShared.hamburgerOptions = (((brandingArray as AnyObject).object(at: 0) as AnyObject).object(forKey: "hamburgermenu") as Any) as? Dictionary<String, Any>
            }
            if brandingArray.count>1{
                let brandingDic = (((brandingArray as AnyObject).object(at: 1) as AnyObject).object(forKey: "brandingwidgetdesktop") as Any)
                let jsonDecoder = JSONDecoder()
                guard let jsonData = try? JSONSerialization.data(withJSONObject: brandingDic as Any , options: .prettyPrinted),
                      let brandingValues = try? jsonDecoder.decode(BrandingModel.self, from: jsonData) else {
                    return
                }
                
                brandingShared.brandingInfoModel = brandingValues
                brandingShared.widgetBorderColor = brandingShared.brandingInfoModel?.widgetBorderColor
                brandingShared.widgetTextColor = brandingShared.brandingInfoModel?.widgetTextColor
                brandingShared.buttonInactiveBgColor = brandingShared.brandingInfoModel?.buttonInactiveBgColor
                brandingShared.buttonInactiveTextColor = brandingShared.brandingInfoModel?.buttonInactiveTextColor
                brandingShared.widgetBgColor = brandingShared.brandingInfoModel?.widgetBgColor
                brandingShared.botchatTextColor = brandingShared.brandingInfoModel?.botchatTextColor
                brandingShared.buttonActiveBgColor = brandingShared.brandingInfoModel?.buttonActiveBgColor
                brandingShared.buttonActiveTextColor = brandingShared.brandingInfoModel?.buttonActiveTextColor
                brandingShared.userchatBgColor = brandingShared.brandingInfoModel?.userchatBgColor
                brandingShared.theme = brandingShared.brandingInfoModel?.theme
                brandingShared.botName = SDKConfiguration.botConfig.chatBotName
                brandingShared.botchatBgColor = brandingShared.brandingInfoModel?.botchatBgColor
                brandingShared.userchatTextColor = brandingShared.brandingInfoModel?.userchatTextColor
                brandingShared.widgetDividerColor = brandingShared.brandingInfoModel?.widgetDividerColor
                brandingShared.bankLogo = brandingShared.brandingInfoModel?.bankLogo
                brandingShared.widgetBgImage = brandingShared.brandingInfoModel?.widgetBgImage
                brandingShared.widgetBodyColor = brandingShared.brandingInfoModel?.widgetBodyColor
                brandingShared.widgetFooterColor = brandingShared.brandingInfoModel?.widgetFooterColor
                brandingShared.widgetHeaderColor = brandingShared.brandingInfoModel?.widgetHeaderColor
                brandingShared.widgetFooterTextColor = brandingShared.brandingInfoModel?.widgetFooterColor
                brandingShared.widgetFooterPlaceholderColor = brandingShared.brandingInfoModel?.widgetHeaderColor
                self.sucessMethod(client: client, thread: thread)
            }
            
        }
    }
    
    // MARK: Sucess Chat Window
    func sucessMethod(client: BotClient?, thread: KREThread?){
        isAlreadyConnectedBot = true
        let dic = ["event_code": "BotConnected", "event_message": "Bot connected successfully"]
        let jsonString = Utilities.stringFromJSONObject(object: dic)
        NotificationCenter.default.post(name: Notification.Name(CallbacksNotification), object: jsonString)
        
        self.stopLoader()
        self.thread = thread
        self.botClient = client
        self.configureThreadView()
        self.brandingValues()
        self.configureleftMenu()
        chatMaskview.isHidden = true
        chatHistoryV.isHidden = true
        chatHistoryHeightConstraint.constant = 5.0
        if showWelcomeMsg == true{
            NotificationCenter.default.post(name: Notification.Name("StartTyping"), object: nil)
        }
        
    }
    
    func showAlert(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        //**
        let titleAttributes = [NSAttributedString.Key.font: UIFont(name: mediumCustomFont, size: 15.0), NSAttributedString.Key.foregroundColor: UIColor.black]
        let titleString = NSAttributedString(string: alertController.title!, attributes: titleAttributes as [NSAttributedString.Key : Any])
        let messageAttributes = [NSAttributedString.Key.font: UIFont(name: mediumCustomFont, size: 14.0), NSAttributedString.Key.foregroundColor: UIColor.black]
        let messageString = NSAttributedString(string: alertController.message!, attributes: messageAttributes as [NSAttributedString.Key : Any])
        alertController.setValue(titleString, forKey: "attributedTitle")
        alertController.setValue(messageString, forKey: "attributedMessage")
        if #available(iOS 13.0, *) {
            alertController.overrideUserInterfaceStyle  = .light
        }
        //     **
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func getUUID() -> String {
        var id: String?
        let userDefaults = UserDefaults.standard
        if let UUID = userDefaults.string(forKey: "UUID") {
            id = UUID
        } else {
            let date: Date = Date()
            id = String(format: "email%ld%@", date.timeIntervalSince1970, "@domain.com")
            userDefaults.set(id, forKey: "UUID")
        }
        return id!
    }
    
    func showLoader(){
        [linerProgressBar].forEach {
            $0.startAnimating()
        }
    }
    
    func stopLoader(){
        [linerProgressBar].forEach {
            $0.stopAnimating()
        }
    }
    
    // MARK: Kore Widgets
    func getWidgetJwTokenWithClientId(_ clientId: String!, clientSecret: String!, identity: String!, isAnonymous: Bool!, success:((_ jwToken: String?) -> Void)?, failure:((_ error: Error) -> Void)?) {
        
        //        // Session Configuration
        //        let configuration = URLSessionConfiguration.default
        //
        //        //Manager
        //        sessionManager = AFHTTPSessionManager.init(baseURL: URL.init(string: SDKConfiguration.serverConfig.JWT_SERVER) as URL?, sessionConfiguration: configuration)
        //
        //        // NOTE: You must set your URL to generate JWT.
        //        let urlString: String = SDKConfiguration.serverConfig.koreJwtUrl()
        //        let requestSerializer = AFJSONRequestSerializer()
        //        requestSerializer.httpMethodsEncodingParametersInURI = Set.init(["GET"]) as Set<String>
        //        requestSerializer.setValue("Keep-Alive", forHTTPHeaderField:"Connection")
        //
        //        // Headers: {"alg": "RS256","typ": "JWT"}
        //        requestSerializer.setValue("RS256", forHTTPHeaderField:"alg")
        //        requestSerializer.setValue("JWT", forHTTPHeaderField:"typ")
        //
        //        let parameters: NSDictionary = ["clientId": clientId as String,
        //                                        "clientSecret": clientSecret as String,
        //                                        "identity": identity as String,
        //                                        "aud": "https://idproxy.kore.com/authorize",
        //                                        "isAnonymous": isAnonymous as Bool]
        //
        //
        //        sessionManager?.responseSerializer = AFJSONResponseSerializer.init()
        //        sessionManager?.requestSerializer = requestSerializer
        //        sessionManager?.post(urlString, parameters: parameters, headers: nil, progress: nil, success: { (sessionDataTask, responseObject) in
        //            if (responseObject is NSDictionary) {
        //                let dictionary: NSDictionary = responseObject as! NSDictionary
        //                let jwToken: String = dictionary["jwt"] as! String
        //                self.initializeWidgetManager(widgetJWTToken: jwToken)
        //                success?(jwToken)
        //
        //            } else {
        //                let error: NSError = NSError(domain: "bot", code: 100, userInfo: [:])
        //                failure?(error)
        //            }
        //        }) { (sessionDataTask, error) in
        //            failure?(error)
        //        }
        
    }
    
    func initializeWidgetManager(widgetJWTToken: String) {
        let widgetManager = KREWidgetManager.shared
        let user = KREUser()
        user.userId = SDKConfiguration.widgetConfig.botId //userId
        user.accessToken = widgetJWTToken
        user.server = SDKConfiguration.serverConfig.KORE_SERVER
        user.tokenType = "bearer"
        user.userEmail = SDKConfiguration.widgetConfig.identity
        user.headers = ["X-KORA-Client": KoraAssistant.shared.applicationHeader]
        widgetManager.initialize(with: user)
        self.user = user
        
        widgetManager.sessionExpiredAction = { (error) in
            DispatchQueue.main.async {
                // NotificationCenter.default.post(name: NSNotification.Name(rawValue: KoraNotification.EnforcementNotification), object: ["type": KoraNotification.EnforcementType.userSessionDidBecomeInvalid])
            }
        }
    }
}

extension ChatMessagesViewController: LeftMenuViewDelegate, LanguageChangeDelegate{
    func leftMenuSelectedText(text: String, payload: String) {
        leftMenuBackBtnAct(self as Any)
        Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { (_) in
            self.optionsButtonTapNewAction(text: text, payload: payload)
        }
    }
    
    func popUpChangeLanguageVC(){
        leftMenuBackBtnAct(self as Any)
        Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { (_) in
            let lanaguageVC = LanguageViewController()
            lanaguageVC.modalPresentationStyle = .overFullScreen
            lanaguageVC.viewDelegate = self
            self.navigationController?.present(lanaguageVC, animated: true, completion: nil)
        }
    }
}

extension ChatMessagesViewController {
    func toastMessage(_ message: String){
        guard let window = UIApplication.shared.keyWindow else {return}
        let messageLbl = UILabel()
        messageLbl.text = message
        messageLbl.textAlignment = .center
        messageLbl.font = UIFont.systemFont(ofSize: 12)
        messageLbl.textColor = .white
        messageLbl.backgroundColor = UIColor(white: 0, alpha: 0.5)
        
        let textSize:CGSize = messageLbl.intrinsicContentSize
        let labelWidth = min(textSize.width, window.frame.width - 40)
        //window.frame.height - 80
        let yaxis = self.composeBarContainerView.frame.origin.y + 10
        messageLbl.frame = CGRect(x: 20, y: yaxis, width: labelWidth + 30, height: textSize.height + 20)
        messageLbl.center.x = window.center.x
        messageLbl.layer.cornerRadius = messageLbl.frame.height/2
        messageLbl.layer.masksToBounds = true
        window.addSubview(messageLbl)
        self.view.bringSubviewToFront(messageLbl)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            
            UIView.animate(withDuration: 2.5, animations: {
                messageLbl.alpha = 0
            }) { (_) in
                messageLbl.removeFromSuperview()
            }
        }
    }}
