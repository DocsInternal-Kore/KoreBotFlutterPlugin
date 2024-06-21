//
//  BotMessagesView.swift
//  KoreBotSDKDemo
//
//  Created by Anoop Dhiman on 31/07/17.
//  Copyright © 2017 Kore. All rights reserved.
//

import UIKit
import CoreData

protocol BotMessagesViewDelegate {
    func optionsButtonTapAction(text:String)
    func linkButtonTapAction(urlString:String)
    func populateQuickReplyCards(with message: KREMessage?)
    func closeQuickReplyCards()
    func optionsButtonTapNewAction(text:String, payload:String)
    func populateCalenderView(with message: KREMessage?)
    func populateFeedbackSliderView(with message: KREMessage?)
    func tableviewScrollDidEnd()
    func disableComposeView(isHide: Bool)
    func populateIDFCAgentDetails(with message: KREMessage?)
    func copyTextInComposeBar(text:String)
    func sendSlientMessageTobot(text:String)
}

class BotMessagesView: UIView, UITableViewDelegate, UITableViewDataSource, KREFetchedResultsControllerDelegate {

    var tableView: UITableView
    var fetchedResultsController: KREFetchedResultsController!
    var viewDelegate: BotMessagesViewDelegate?
    var shouldScrollToBottom: Bool = false
    var clearBackground = false
    var userActive = false
    public let spinner = UIActivityIndicatorView(style: .gray)
    
    weak var thread: KREThread! {
        didSet{
            self.initializeFetchedResultsController()
        }
    }
    
    convenience init(){
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        self.tableView = UITableView(frame: frame, style: .grouped)
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.tableView = UITableView(frame: CGRect.zero, style: .grouped)
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup() {
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.separatorStyle = .none
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.addSubview(self.tableView)
        
        spinner.color = UIColor.darkGray
        spinner.hidesWhenStopped = true
        tableView.tableFooterView = spinner
        
        self.tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(-1)-[tableView]-(-1)-|", options:[], metrics:nil, views:["tableView" : self.tableView]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[tableView]|", options:[], metrics:nil, views:["tableView" : self.tableView]))
        
        //Register reusable cells
        self.tableView.register(MessageBubbleCell.self, forCellReuseIdentifier:"MessageBubbleCell")
        self.tableView.register(TextBubbleCell.self, forCellReuseIdentifier:"TextBubbleCell")
        self.tableView.register(ImageBubbleCell.self, forCellReuseIdentifier:"ImageBubbleCell")
        self.tableView.register(OptionsBubbleCell.self, forCellReuseIdentifier:"OptionsBubbleCell")
        self.tableView.register(ListBubbleCell.self, forCellReuseIdentifier:"ListBubbleCell")
        self.tableView.register(QuickReplyBubbleCell.self, forCellReuseIdentifier:"QuickReplyBubbleCell")
        self.tableView.register(CarouselBubbleCell.self, forCellReuseIdentifier:"CarouselBubbleCell")
        self.tableView.register(ErrorBubbleCell.self, forCellReuseIdentifier:"ErrorBubbleCell")
        self.tableView.register(PiechartBubbleCell.self, forCellReuseIdentifier:"PiechartBubbleCell")
        self.tableView.register(TableBubbleCell.self, forCellReuseIdentifier:"TableBubbleCell")
        self.tableView.register(MiniTableBubbleCell.self, forCellReuseIdentifier:"MiniTableBubbleCell")
        self.tableView.register(ResponsiveTableBubbleCell.self, forCellReuseIdentifier:"ResponsiveTableBubbleCell")
        self.tableView.register(MenuBubbleCell.self, forCellReuseIdentifier:"MenuBubbleCell")
        self.tableView.register(NewListBubbleCell.self, forCellReuseIdentifier:"NewListBubbleCell")
        self.tableView.register(TableListBubbleCell.self, forCellReuseIdentifier:"TableListBubbleCell")
        self.tableView.register(CalendarBubbleCell.self, forCellReuseIdentifier:"CalendarBubbleCell")
        self.tableView.register(QuickRepliesWelcomeCell.self, forCellReuseIdentifier:"QuickRepliesWelcomeCell")
        self.tableView.register(NotificationBubbleCell.self, forCellReuseIdentifier:"NotificationBubbleCell")
        self.tableView.register(MultiSelectBubbleCell.self, forCellReuseIdentifier:"MultiSelectBubbleCell")
        self.tableView.register(ListWidgetBubbleCell.self, forCellReuseIdentifier:"ListWidgetBubbleCell")
        self.tableView.register(FeedbackBubbleCell.self, forCellReuseIdentifier:"FeedbackBubbleCell")
        self.tableView.register(InLineFormCell.self, forCellReuseIdentifier:"InLineFormCell")
        self.tableView.register(DropDownell.self, forCellReuseIdentifier:"DropDownell")
        self.tableView.register(TransactionSuccessTemplateCell.self, forCellReuseIdentifier:"TransactionSuccessTemplateCell")
        self.tableView.register(ContactCardTemplateCell.self, forCellReuseIdentifier:"ContactCardTemplateCell")
        self.tableView.register(RadioListTemplateCell.self, forCellReuseIdentifier:"RadioListTemplateCell")
        self.tableView.register(PDFDownloadCell.self, forCellReuseIdentifier:"PDFDownloadCell")
        self.tableView.register(UpdatedIdfcCarouselCell.self, forCellReuseIdentifier:"UpdatedIdfcCarouselCell")
        self.tableView.register(ButtonLinkBubbleVCell.self, forCellReuseIdentifier:"ButtonLinkBubbleVCell")
        self.tableView.register(IDFCFeedbackBubbleCell.self, forCellReuseIdentifier:"IDFCFeedbackBubbleCell")
        self.tableView.register(StatusTemplateBubbleCell.self, forCellReuseIdentifier:"StatusTemplateBubbleCell")
        self.tableView.register(ServiceListTemplateBubbleCell.self, forCellReuseIdentifier:"ServiceListTemplateBubbleCell")
        self.tableView.register(IDFCAgentTemplateBubbleCell.self, forCellReuseIdentifier:"IDFCAgentTemplateBubbleCell")
        self.tableView.register(IDFCCarouselTemplateBubbleCell.self, forCellReuseIdentifier:"IDFCCarouselTemplateBubbleCell")
        self.tableView.register(CardSelectionCell.self, forCellReuseIdentifier:"CardSelectionCell")
        self.tableView.register(BeneficiaryBubbleCell.self, forCellReuseIdentifier:"BeneficiaryBubbleCell")
        self.tableView.register(AdvancedMultiSelectCell.self, forCellReuseIdentifier:"AdvancedMultiSelectCell")
        self.tableView.register(SalaamPointsCell.self, forCellReuseIdentifier:"SalaamPointsCell")
        self.tableView.register(WelcomeTemplateCell.self, forCellReuseIdentifier:"WelcomeTemplateCell")
        self.tableView.register(BoldTextTemplateBubbleCell.self, forCellReuseIdentifier:"BoldTextTemplateBubbleCell")
        self.tableView.register(EmptyBubbleTemplateCell.self, forCellReuseIdentifier:"EmptyBubbleTemplateCell")
        self.tableView.register(CustomDropdownTemplateCell.self, forCellReuseIdentifier:"CustomDropdownTemplateCell")
        self.tableView.register(DetailsListTemplateCell.self, forCellReuseIdentifier:"DetailsListTemplateCell")
        self.tableView.register(SearchTemplateCell.self, forCellReuseIdentifier:"SearchTemplateCell")
        self.tableView.register(BankingFeedbackTemplateCell.self, forCellReuseIdentifier:"BankingFeedbackTemplateCell")
        self.tableView.register(AudioBubbleCell.self, forCellReuseIdentifier:"AudioBubbleCell")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    //MARK:- removing refernces to elements
    func prepareForDeinit(){
        self.fetchedResultsController?.kreDelegate = nil
        self.fetchedResultsController.tableView = nil
    }
    
    func initializeFetchedResultsController() {
        if(self.thread != nil){
            let request: NSFetchRequest<KREMessage> = KREMessage.fetchRequest()
            request.predicate = NSPredicate(format: "thread.threadId == %@", self.thread.threadId!)
            //request.sortDescriptors = [NSSortDescriptor(key: "sentOn", ascending: false)]
            request.sortDescriptors = [NSSortDescriptor(key: "messageIdIndex", ascending: false)]
            
            let mainContext: NSManagedObjectContext = DataStoreManager.sharedManager.coreDataManager.mainContext
            fetchedResultsController = KREFetchedResultsController(fetchRequest: request as! NSFetchRequest<NSManagedObject>, managedObjectContext: mainContext, sectionNameKeyPath: nil, cacheName: nil)
            fetchedResultsController.tableView = self.tableView
            fetchedResultsController.kreDelegate = self
            do {
                try fetchedResultsController.performFetch()
            } catch {
                fatalError("Failed to initialize FetchedResultsController: \(error)")
            }
        }
    }
    
    // MARK: UITable view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController?.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message: KREMessage = fetchedResultsController!.object(at: indexPath) as! KREMessage
        
        var cellIdentifier: String! = nil
        if let componentType = ComponentType(rawValue: (message.templateType?.intValue)!) {
            switch componentType {
            case .text:
                cellIdentifier = "TextBubbleCell"
                break
            case .image, .video:
                cellIdentifier = "ImageBubbleCell"
                break
            case .audio:
                cellIdentifier = "AudioBubbleCell"
                break
            case .options:
                cellIdentifier = "OptionsBubbleCell"
                break
            case .quickReply:
                cellIdentifier = "QuickReplyBubbleCell"
                break
            case .list:
                cellIdentifier = "ListBubbleCell"
                break
            case .carousel:
                cellIdentifier = "CarouselBubbleCell"
                break
            case .error:
                cellIdentifier = "ErrorBubbleCell"
                break
            case .chart:
                cellIdentifier = "PiechartBubbleCell"
                break
            case .minitable:
                cellIdentifier = "MiniTableBubbleCell"
                break
            case .table:
                cellIdentifier = "TableBubbleCell"
                break
            case .responsiveTable:
                cellIdentifier = "ResponsiveTableBubbleCell"
                break
            case .menu:
                cellIdentifier = "MenuBubbleCell"
                break
            case .newList:
                cellIdentifier = "NewListBubbleCell"
                break
            case .tableList:
                cellIdentifier = "TableListBubbleCell"
                break
            case .calendarView:
                cellIdentifier = "CalendarBubbleCell"
                break
            case .quick_replies_welcome:
                cellIdentifier = "QuickRepliesWelcomeCell"
                break
            case .notification:
                cellIdentifier = "NotificationBubbleCell"
                break
            case .multiSelect:
                cellIdentifier = "MultiSelectBubbleCell"
                break
            case .list_widget:
                cellIdentifier = "ListWidgetBubbleCell"
                break
            case .feedbackTemplate:
                cellIdentifier = "FeedbackBubbleCell"
                break
            case .inlineForm:
                cellIdentifier = "InLineFormCell"
                break
            case .dropdown_template:
                cellIdentifier = "DropDownell"
                break
            case .transactionSuccessTemplate:
                cellIdentifier = "TransactionSuccessTemplateCell"
                break
            case .contactCardTemplate:
                cellIdentifier = "ContactCardTemplateCell"
                break
            case .radioListTemplate:
                cellIdentifier = "RadioListTemplateCell"
                break
            case .pdfdownload:
                cellIdentifier = "PDFDownloadCell"
                break
            case .updatedIdfcCarousel:
                cellIdentifier = "UpdatedIdfcCarouselCell"
                break
            case .buttonLinkTemplate:
                cellIdentifier = "ButtonLinkBubbleVCell"
                break
            case .idfcFeedbackTemplate:
                cellIdentifier = "IDFCFeedbackBubbleCell"
                break
            case .statusTemplate:
                cellIdentifier = "StatusTemplateBubbleCell"
                break
            case .serviceListTemplate:
                cellIdentifier = "ServiceListTemplateBubbleCell"
                break
            case .idfcAgentTemplate:
                cellIdentifier = "IDFCAgentTemplateBubbleCell"
                break
            case .idfcCarouselType2:
                cellIdentifier = "IDFCCarouselTemplateBubbleCell"
                break
            case .cardSelection:
                cellIdentifier = "CardSelectionCell"
                break
            case .beneficiaryTemplate:
                cellIdentifier = "BeneficiaryBubbleCell"
                break
            case .advanced_multi_select:
                cellIdentifier = "AdvancedMultiSelectCell"
                break
            case .salaampointsTemplate:
                cellIdentifier = "SalaamPointsCell"
                break
            case .welcome_template:
                cellIdentifier = "WelcomeTemplateCell"
                break
            case .boldtextTemplate:
                cellIdentifier = "BoldTextTemplateBubbleCell"
                break
            case .emptyBubbleTemplate:
                cellIdentifier = "EmptyBubbleTemplateCell"
                break
            case .custom_dropdown_template:
                cellIdentifier = "CustomDropdownTemplateCell"
                break
            case .details_list_template:
                cellIdentifier = "DetailsListTemplateCell"
                break
            case .search_template:
                cellIdentifier = "SearchTemplateCell"
                break
            case .bankingFeedbackTemplate:
                cellIdentifier = "BankingFeedbackTemplateCell"
                break
            }
            
        }
        
        let cell: MessageBubbleCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MessageBubbleCell
        cell.configureWithComponents(message.components?.array as! Array<KREComponent>)
        if self.clearBackground {
            cell.backgroundColor = .clear
        }
        
        var isQuickReply = false
        var isCalenderView = false
        var isFeedbackView = false
        
        
        switch (cell.bubbleView.bubbleType!) {
        case .text:
            
            let bubbleView: TextBubbleView = cell.bubbleView as! TextBubbleView
            
             self.textLinkDetection(textLabel: bubbleView.textLabel)
            //self.textViewLinkDetection(textLabel: bubbleView.textLabel)
            if(bubbleView.textLabel.attributedText?.string == "Welcome John, You already hold a Savings account with Kore bank."){
                userActive = true
            }
            if(userActive){
                self.updtaeUserImage()
            }
            
            bubbleView.onChange = { [weak self](reload) in
                self?.tableView.reloadRows(at: [indexPath], with: .none)
            }
            
//            bubbleView.copyText = {[weak self] (text) in
//                self?.viewDelegate?.copyTextInComposeBar(text: text ?? "")
//            }
            cell.bubbleView.drawBorder = true
            break
        case .image, .video, .audio:
            break
        case .options:
            let bubbleView: OptionsBubbleView = cell.bubbleView as! OptionsBubbleView
            self.textLinkDetection(textLabel: bubbleView.textLabel);
            bubbleView.optionsAction = {[weak self] (text, payload) in
                self?.viewDelegate?.optionsButtonTapNewAction(text: text!, payload: payload ?? text!)
            }
            bubbleView.linkAction = {[weak self] (text) in
                self?.viewDelegate?.linkButtonTapAction(urlString: text!)
            }
            
            cell.bubbleView.drawBorder = true
            break
        case .list:
            let bubbleView: ListBubbleView = cell.bubbleView as! ListBubbleView
            bubbleView.optionsAction = {[weak self] (text, payload) in
                self?.viewDelegate?.optionsButtonTapNewAction(text: text!, payload: payload ?? text!)
            }
            bubbleView.linkAction = {[weak self] (text) in
                self?.viewDelegate?.linkButtonTapAction(urlString: text!)
            }
            
            cell.bubbleView.drawBorder = true
            
            break
        case .quickReply:
            isQuickReply = true
            break
        case .carousel:
            let bubbleView: CarouselBubbleView = cell.bubbleView as! CarouselBubbleView
            bubbleView.optionsAction = {[weak self] (text, payload) in
                self?.viewDelegate?.optionsButtonTapNewAction(text: text!, payload: payload ?? text!)
            }
            bubbleView.linkAction = {[weak self] (text) in
                self?.viewDelegate?.linkButtonTapAction(urlString: text!)
            }
            
            break
        case .error:
            let bubbleView: ErrorBubbleView = cell.bubbleView as! ErrorBubbleView
            self.textLinkDetection(textLabel: bubbleView.textLabel)
            //self.textViewLinkDetection(textLabel: bubbleView.textLabel)
            break
        case .chart:
            
            break
        case .table:
            
            break
        case .minitable:
            
            break
        case .responsiveTable:
            break
        case .menu:
            let bubbleView: MenuBubbleView = cell.bubbleView as! MenuBubbleView
            bubbleView.optionsAction = {[weak self] (text) in
                self?.viewDelegate?.optionsButtonTapAction(text: text!)
            }
            bubbleView.linkAction = {[weak self] (text) in
                self?.viewDelegate?.linkButtonTapAction(urlString: text!)
            }
            
            cell.bubbleView.drawBorder = true
            break
        case .newList:
            let bubbleView: NewListBubbleView = cell.bubbleView as! NewListBubbleView
            bubbleView.optionsAction = {[weak self] (text, payload) in
                self?.viewDelegate?.optionsButtonTapNewAction(text: text!, payload: payload!)
            }
            bubbleView.linkAction = {[weak self] (text) in
                self?.viewDelegate?.linkButtonTapAction(urlString: text!)
            }
            cell.bubbleView.drawBorder = true
            let firstIndexPath:NSIndexPath = NSIndexPath.init(row: rowIndex, section: 0)
            let secondIndexPath:NSIndexPath = NSIndexPath.init(row: 1, section: 0)
            if firstIndexPath.isEqual(indexPath)  || secondIndexPath.isEqual(indexPath) {
                bubbleView.maskview.isHidden = true
            }else{
                bubbleView.maskview.isHidden = false
            }
            break
        case .tableList:
            let bubbleView: TableListBubbleView = cell.bubbleView as! TableListBubbleView
            bubbleView.optionsAction = {[weak self] (text, payload) in
                self?.viewDelegate?.optionsButtonTapNewAction(text: text!, payload: payload!)
            }
            bubbleView.linkAction = {[weak self] (text) in
                self?.viewDelegate?.linkButtonTapAction(urlString: text!)
            }
            
            cell.bubbleView.drawBorder = true
            break
        case .calendarView:
            isCalenderView = true
            cell.bubbleView.drawBorder = true
            break
        case .quick_replies_welcome:
            let bubbleView: QuickReplyWelcomeBubbleView = cell.bubbleView as! QuickReplyWelcomeBubbleView
            bubbleView.optionsAction = {[weak self] (text, payload) in
                self?.viewDelegate?.optionsButtonTapNewAction(text: text!, payload: payload ?? text ?? "")
            }
            bubbleView.linkAction = {[weak self] (text) in
                self?.viewDelegate?.linkButtonTapAction(urlString: text ?? "")
            }
            self.textViewLinkDetection(textLabel: bubbleView.titleLbl)
            cell.bubbleView.drawBorder = true
            let firstIndexPath:NSIndexPath = NSIndexPath.init(row: rowIndex, section: 0)
            let secondIndexPath:NSIndexPath = NSIndexPath.init(row: 1, section: 0) //kk
            if firstIndexPath.isEqual(indexPath) || secondIndexPath.isEqual(indexPath) {
                bubbleView.maskview.isHidden = true
            }else{
                bubbleView.maskview.isHidden = false
            }
            break
        case .notification:
            let bubbleView: NotificationBubbleView = cell.bubbleView as! NotificationBubbleView
            bubbleView.optionsAction = {[weak self] (text, payload) in
                self?.viewDelegate?.optionsButtonTapNewAction(text: text!, payload: payload!)
            }
            break
        case .multiSelect:
            let bubbleView: MultiSelectNewBubbleView = cell.bubbleView as! MultiSelectNewBubbleView
            bubbleView.optionsAction = {[weak self] (text, payload) in
                self?.viewDelegate?.optionsButtonTapNewAction(text: text!, payload: payload!)
            }
            cell.bubbleView.drawBorder = true
            break
        case .list_widget:
            let bubbleView: ListWidgetBubbleView = cell.bubbleView as! ListWidgetBubbleView
            bubbleView.optionsAction = {[weak self] (text, payload) in
                self?.viewDelegate?.optionsButtonTapNewAction(text: text!, payload: payload!)
            }
            bubbleView.linkAction = {[weak self] (text) in
                self?.viewDelegate?.linkButtonTapAction(urlString: text!)
            }
            cell.bubbleView.drawBorder = true
            break
        case .feedbackTemplate:
            let bubbleView: FeedbackBubbleView = cell.bubbleView as! FeedbackBubbleView
            bubbleView.optionsAction = {[weak self] (text, payload) in
                self?.viewDelegate?.optionsButtonTapNewAction(text: text!, payload: payload!)
            }
            isFeedbackView = true
            cell.bubbleView.drawBorder = true
            break
        case .inlineForm:
            let bubbleView: InLineFormBubbleView = cell.bubbleView as! InLineFormBubbleView
            bubbleView.optionsAction = {[weak self] (text, payload) in
                self?.viewDelegate?.optionsButtonTapNewAction(text: text!, payload: payload!)
            }
            cell.bubbleView.drawBorder = true
            //isDisableComposeView = true
            
            let firstIndexPath:NSIndexPath = NSIndexPath.init(row: rowIndex, section: 0)
            if firstIndexPath.isEqual(indexPath) {
                bubbleView.maskview.isHidden = true
            }else{
                bubbleView.maskview.isHidden = false
            }
            break
        case .dropdown_template:
            let bubbleView: DropDownBubbleView = cell.bubbleView as! DropDownBubbleView
            let firstIndexPath:NSIndexPath = NSIndexPath.init(row: rowIndex, section: 0)
            //let secondIndexPath:NSIndexPath = NSIndexPath.init(row: 1, section: 0)
            if firstIndexPath.isEqual(indexPath) {
                bubbleView.maskview.isHidden = true
            }else{
                bubbleView.maskview.isHidden = false
            }
            cell.bubbleView.drawBorder = true
            break
        case .transactionSuccessTemplate:
            //let bubbleView: CongratulationsBubbleView = cell.bubbleView as! CongratulationsBubbleView
            cell.bubbleView.drawBorder = true
            break
        case .contactCardTemplate:
            cell.bubbleView.drawBorder = true
            break
        case .radioListTemplate:
            let bubbleView: RadioListBubbleView = cell.bubbleView as! RadioListBubbleView
            cell.bubbleView.drawBorder = true
            bubbleView.optionsAction = {[weak self] (text, payload) in
                self?.viewDelegate?.optionsButtonTapNewAction(text: text!, payload: payload!)
            }
            let firstIndexPath:NSIndexPath = NSIndexPath.init(row: rowIndex, section: 0)
            if firstIndexPath.isEqual(indexPath)  {
                bubbleView.maskview.isHidden = true
            }else{
                bubbleView.maskview.isHidden = false
            }
            break
        case .pdfdownload:
            let bubbleView: PDFBubbleView = cell.bubbleView as! PDFBubbleView
            cell.bubbleView.drawBorder = true
            bubbleView.linkAction = {[weak self] (text) in
                self?.viewDelegate?.linkButtonTapAction(urlString: text!)
            }
            break
        case .updatedIdfcCarousel:
            let bubbleView: UpdatedCarouselBubbleView = cell.bubbleView as! UpdatedCarouselBubbleView
            bubbleView.optionsAction = {[weak self] (text, payload) in
                self?.viewDelegate?.optionsButtonTapNewAction(text: text!, payload: payload!)
            }
            cell.bubbleView.drawBorder = true
            let firstIndexPath:NSIndexPath = NSIndexPath.init(row: rowIndex, section: 0)
            if firstIndexPath.isEqual(indexPath)  {
                bubbleView.maskview.isHidden = true
            }else{
                bubbleView.maskview.isHidden = false
            }
            break
        case .buttonLinkTemplate:
            let bubbleView: ButtonLinkNBubbleView = cell.bubbleView as! ButtonLinkNBubbleView
            cell.bubbleView.drawBorder = true
            bubbleView.linkAction = {[weak self] (text) in
                self?.viewDelegate?.linkButtonTapAction(urlString: text!)
            }
            break
        case .idfcFeedbackTemplate:
            let bubbleView: IDFCFeedbackBubbleView = cell.bubbleView as! IDFCFeedbackBubbleView
            cell.bubbleView.drawBorder = true
            bubbleView.optionsAction = {[weak self] (text, payload) in
                self?.viewDelegate?.optionsButtonTapNewAction(text: text!, payload: payload!)
            }
            let firstIndexPath:NSIndexPath = NSIndexPath.init(row: rowIndex, section: 0)
            if firstIndexPath.isEqual(indexPath)  {
                bubbleView.maskview.isHidden = true
            }else{
                bubbleView.maskview.isHidden = false
            }
            break
        case .statusTemplate:
        //let bubbleView: StatusTemplateBubbleView = cell.bubbleView as! StatusTemplateBubbleView
        //cell.bubbleView.drawBorder = true
        break
        case .serviceListTemplate:
        //let bubbleView: StatusTemplateBubbleView = cell.bubbleView as! StatusTemplateBubbleView
        //cell.bubbleView.drawBorder = true
        break
        case .idfcAgentTemplate:
            let firstIndexPath:NSIndexPath = NSIndexPath.init(row: rowIndex, section: 0)
            let secondIndexPath:NSIndexPath = NSIndexPath.init(row: 1, section: 0)
            if firstIndexPath.isEqual(indexPath) || secondIndexPath.isEqual(indexPath){
                self.viewDelegate?.populateIDFCAgentDetails(with: message)
            }
            break
        case .idfcCarouselType2:
            let bubbleView: IDFCCarouselBubbleView = cell.bubbleView as! IDFCCarouselBubbleView
            bubbleView.optionsAction = {[weak self] (text, payload) in
                self?.viewDelegate?.optionsButtonTapNewAction(text: text!, payload: payload!)
            }
            bubbleView.linkAction = {[weak self] (text) in
                self?.viewDelegate?.linkButtonTapAction(urlString: text!)
            }
            cell.bubbleView.drawBorder = true
            let firstIndexPath:NSIndexPath = NSIndexPath.init(row: rowIndex, section: 0)
            if firstIndexPath.isEqual(indexPath)  {
                bubbleView.maskview.isHidden = true
            }else{
                bubbleView.maskview.isHidden = false
            }
            break
        case .cardSelection:
            let bubbleView: CardSelectionBubbleView = cell.bubbleView as! CardSelectionBubbleView
            cell.bubbleView.drawBorder = true
            bubbleView.optionsAction = {[weak self] (text, payload) in
                self?.viewDelegate?.optionsButtonTapNewAction(text: text!, payload: payload!)
            }
            cell.bubbleView.drawBorder = true
            let firstIndexPath:NSIndexPath = NSIndexPath.init(row: rowIndex, section: 0)
            //let secondIndexPath:NSIndexPath = NSIndexPath.init(row: 1, section: 0)
            if firstIndexPath.isEqual(indexPath) {
                bubbleView.maskview.isHidden = true
            }else{
                bubbleView.maskview.isHidden = false
            }
            
            break
        case .beneficiaryTemplate:
            let bubbleView: BeneficiaryBubbleView = cell.bubbleView as! BeneficiaryBubbleView
            cell.bubbleView.drawBorder = true
            break
        case .advanced_multi_select:
            let bubbleView: AdvancedMultiSelectBubbleView = cell.bubbleView as! AdvancedMultiSelectBubbleView
            cell.bubbleView.drawBorder = true
            bubbleView.optionsAction = {[weak self] (text, payload) in
                self?.viewDelegate?.optionsButtonTapNewAction(text: text!, payload: payload!)
            }
            cell.bubbleView.drawBorder = true
            let firstIndexPath:NSIndexPath = NSIndexPath.init(row: rowIndex, section: 0)
            //let secondIndexPath:NSIndexPath = NSIndexPath.init(row: 1, section: 0)
            if firstIndexPath.isEqual(indexPath) {
                bubbleView.maskview.isHidden = true
            }else{
                bubbleView.maskview.isHidden = false
            }
            break
        case .salaampointsTemplate:
            let bubbleView: SalaamPointsBubbleView = cell.bubbleView as! SalaamPointsBubbleView
            bubbleView.optionsAction = {[weak self] (text, payload) in
                self?.viewDelegate?.optionsButtonTapNewAction(text: text!, payload: payload!)
            }
            bubbleView.linkAction = {[weak self] (text) in
                self?.viewDelegate?.linkButtonTapAction(urlString: text!)
            }
            cell.bubbleView.drawBorder = true
            break
        case .welcome_template:
            //isQuickReply = true
            let bubbleView: WelcomeTemplateBubbleView = cell.bubbleView as! WelcomeTemplateBubbleView
            bubbleView.optionsAction = {[weak self] (text, payload) in
                self?.viewDelegate?.optionsButtonTapNewAction(text: text!, payload: payload!)
            }
            bubbleView.linkAction = {[weak self] (text) in
                self?.viewDelegate?.linkButtonTapAction(urlString: text!)
            }
            cell.bubbleView.drawBorder = true
            let firstIndexPath:NSIndexPath = NSIndexPath.init(row: rowIndex, section: 0)
            //let secondIndexPath:NSIndexPath = NSIndexPath.init(row: 1, section: 0)
            if firstIndexPath.isEqual(indexPath) {
                bubbleView.maskview.isHidden = true
            }else{
                bubbleView.maskview.isHidden = false
            }
            break
        case .boldtextTemplate:
            let bubbleView: BoldTextBubbleView = cell.bubbleView as! BoldTextBubbleView
            cell.bubbleView.drawBorder = true
            self.textViewLinkDetection(textLabel: bubbleView.titleLbl)
            break
        case .emptyBubbleTemplate:
          isQuickReply = true
            break
        case .custom_dropdown_template:
            let bubbleView: CustomDropDownTemplate = cell.bubbleView as! CustomDropDownTemplate
            bubbleView.optionsAction = {[weak self] (text, payload) in
                self?.viewDelegate?.optionsButtonTapNewAction(text: text!, payload: payload!)
            }
            let firstIndexPath:NSIndexPath = NSIndexPath.init(row: rowIndex, section: 0)
            //let secondIndexPath:NSIndexPath = NSIndexPath.init(row: 1, section: 0)
            if firstIndexPath.isEqual(indexPath) {
                bubbleView.maskview.isHidden = true
            }else{
                bubbleView.maskview.isHidden = false
            }
            break
        case .details_list_template:
            cell.bubbleView.drawBorder = true
            break
        case .search_template:
            let bubbleView: SearchBubbleView = cell.bubbleView as! SearchBubbleView
            self.textViewLinkDetection(textLabel: bubbleView.urlLbl)
            bubbleView.optionsAction = {[weak self] (text, payload) in
                self?.viewDelegate?.optionsButtonTapNewAction(text: text ?? "", payload: payload ?? "")
            }
            bubbleView.linkAction = {[weak self] (text) in
                self?.viewDelegate?.linkButtonTapAction(urlString: text ?? "")
            }
            cell.bubbleView.drawBorder = true
            break
        case .bankingFeedbackTemplate:
            let bubbleView: BankingFeedbackBubbleView = cell.bubbleView as! BankingFeedbackBubbleView
            bubbleView.optionsAction = {[weak self] (text, payload) in
                self?.viewDelegate?.optionsButtonTapNewAction(text: text ?? "", payload: payload ?? "")
            }
            bubbleView.optionsSlientAction = {[weak self] (payload) in
                self?.viewDelegate?.sendSlientMessageTobot(text: payload ?? "")
            }
            bubbleView.linkAction = {[weak self] (text) in
                self?.viewDelegate?.linkButtonTapAction(urlString: text ?? "")
            }
            cell.bubbleView.drawBorder = true
            let firstIndexPath:NSIndexPath = NSIndexPath.init(row: rowIndex, section: 0)
            //let secondIndexPath:NSIndexPath = NSIndexPath.init(row: 1, section: 0)
            if firstIndexPath.isEqual(indexPath) {
                bubbleView.maskview.isHidden = true
            }else{
                bubbleView.maskview.isHidden = false
            }
            break
        }
        let firstIndexPath:NSIndexPath = NSIndexPath.init(row: 0, section: 0)
        if firstIndexPath.isEqual(indexPath) {
            if isQuickReply {
                self.viewDelegate?.populateQuickReplyCards(with: message)
            }else{
                self.viewDelegate?.closeQuickReplyCards()
            }
            
            if isCalenderView{
                if !calenderCloseTag{
                    self.viewDelegate?.populateCalenderView(with: message)
                }
            }
            
            if isFeedbackView{
                if message.templateType == (ComponentType.feedbackTemplate.rawValue as NSNumber) {
                    let component: KREComponent = message.components![0] as! KREComponent
                    if ((component.componentDesc) != nil) {
                        let jsonString = component.componentDesc
                        let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: jsonString!) as! NSDictionary
                        if jsonObject["sliderView"] as! Bool{
                            self.viewDelegate?.populateFeedbackSliderView(with: message)
                        }
                    }
                }
            }
        }
        return cell
    }
    
    // MARK: UITable view delegate source
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        return view
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {

        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 200))
        let imageV = UIImageView()
        imageV.frame = CGRect.init(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        let bundle = KREResourceLoader.shared.resourceBundle()
        imageV.image = UIImage.init(named: "Loan", in: bundle, compatibleWith: nil)
        imageV.transform = CGAffineTransform(scaleX: 1, y: -1)
        view.addSubview(imageV)
        return view
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5.0
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    // MARK:- KREFetchedResultsControllerDelegate methods
    func fetchedControllerWillChangeContent() {
        let visibleCelIndexPath: [IndexPath]? = self.tableView.indexPathsForVisibleRows
        let firstIndexPath:NSIndexPath = NSIndexPath.init(row: 0, section: 0)
        if (visibleCelIndexPath?.contains(firstIndexPath as IndexPath))!{
            self.shouldScrollToBottom = true
        }
    }
    
    func fetchedControllerDidChangeContent() {
        if (self.shouldScrollToBottom && !self.tableView.isDragging) {
            self.shouldScrollToBottom = false
            self.scrollToTop(animate: true)
        }
    }
    
    func scrollToTop(animate: Bool){
        self.tableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .bottom, animated: animate)
    }
    
    // MARK: - scrollTo related methods
    func getIndexPathForLastItem()->(NSIndexPath){
        var indexPath:NSIndexPath = NSIndexPath.init(row: 0, section: 0);
        let numberOfSections: Int = self.tableView.numberOfSections
        if numberOfSections > 0 {
            let numberOfRows: Int = self.tableView.numberOfRows(inSection: numberOfSections - 1)
            if numberOfRows > 0 {
                indexPath = NSIndexPath(row: numberOfRows - 1, section: numberOfSections - 1)
            }
        }
        return indexPath
    }
    
    // MARK: helper functions
    
    func textLinkDetection(textLabel:KREAttributedLabel) {
        textLabel.detectionBlock = {(hotword, string) in
            switch hotword {
            case KREAttributedHotWordLink:
                self.viewDelegate?.linkButtonTapAction(urlString: string!)
                break
            default:
                break
            }
        }
    }
    
    func textViewLinkDetection(textLabel:KREAttributedTextView) {
        textLabel.detectionBlock = {(hotword, string) in
            switch hotword {
            case KREAttributedHotWordLink:
                self.viewDelegate?.linkButtonTapAction(urlString: string)
                break
            default:
                break
            }
        }
    }
    
    @objc fileprivate func updtaeUserImage() {
        NotificationCenter.default.post(name: Notification.Name(updateUserImageNotification), object: nil)
    }
    
    
    // MARK:- deinit
    deinit {
        NSLog("BotMessagesView dealloc")
        self.fetchedResultsController = nil
    }
}
extension BotMessagesView: UIScrollViewDelegate{
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        timerCounter = maxiumTimeCount
        if scrollView.isEqual(tableView){
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveLinear], animations: {
               
            }, completion: { _ in
                
                let height = scrollView.frame.size.height
                let contentYoffset = scrollView.contentOffset.y
                let distanceFromBottom = scrollView.contentSize.height - contentYoffset
                if distanceFromBottom < height || Int(distanceFromBottom) == Int(height) {
                   self.viewDelegate?.tableviewScrollDidEnd()
                }
            })
        }
    }
}
extension String {
    func regEx() -> String {
        return self.replacingOccurrences(of: "[A-Za-z0-9 !\"#$%&'()*+,-./:;<=>?@\\[\\\\\\]^_`{|}~]", with: "*", options: .regularExpression, range: nil)
    }
}
