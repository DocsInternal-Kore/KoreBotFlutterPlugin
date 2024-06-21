//
//  MessageBubbleCell.swift
//  KoreBotSDKDemo
//
//  Created by developer@kore.com on 09/05/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit
//import AlamofireImage

class MessageBubbleCell : UITableViewCell {
    let bundle = KREResourceLoader.shared.resourceBundle()
    var bubbleContainerView: UIView!
    var senderImageView: UIImageView!
    var userImageView: UIImageView!
    var bubbleView: BubbleView!

    var bubbleLeadingConstraint: NSLayoutConstraint!
    var bubbleTrailingConstraint: NSLayoutConstraint!
    var bubbleBottomConstraint: NSLayoutConstraint!
    
    lazy var dateLabel: UILabel = {
        let dateLabel = UILabel(frame: .zero)
        dateLabel.numberOfLines = 0
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = UIFont(name: regularCustomFont, size: 10.0)
        dateLabel.textColor = .lightGray
        dateLabel.isHidden = false
        return dateLabel
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: properties with observers
    var tailPosition: BubbleMaskTailPosition {
        get {
            return self.bubbleView.tailPosition
        }
        set {
            if (tailPosition == .left) {
                self.bubbleLeadingConstraint.priority = UILayoutPriority.defaultHigh
                self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultLow
                self.senderImageView.isHidden = true
                self.userImageView.isHidden = true

            } else {
                self.bubbleLeadingConstraint.priority = UILayoutPriority.defaultLow
                self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
                self.senderImageView.isHidden = true
                self.userImageView.isHidden = true
            }
            
            self.bubbleView.tailPosition = tailPosition
            self.setNeedsUpdateConstraints()
        }
    }
    
    override func prepareForReuse() {
        self.senderImageView.image = nil;
        self.userImageView.image = nil
        self.bubbleView.prepareForReuse();
        self.bubbleView.invalidateIntrinsicContentSize()
    }

    func initialize() {
        self.selectionStyle = .none
        self.clipsToBounds = true
        self.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)

        // Create the sender imageView
        self.senderImageView = UIImageView()
        self.senderImageView.contentMode = .scaleAspectFit
        self.senderImageView.clipsToBounds = true
        self.senderImageView.layer.cornerRadius = 15
        self.senderImageView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.senderImageView)
        
        self.userImageView = UIImageView()
        self.userImageView.contentMode = .scaleAspectFit
        self.userImageView.clipsToBounds = true
        self.userImageView.layer.cornerRadius = 15
        self.userImageView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.userImageView)
        
        // Create the container view
        /*
         The bubble container view has fixed top and bottom constraints
         The left and right constraints have opposite priorities 1-999 or 999-1
         This sets the container position horizontally in the cell based on the tail position
         The bubbleView that is contained within the bubbleViewContainer has a fixed top,bottom,left,right constraint of 0
         so it will force the cell to resize dynamically based on the intrinsicContentSize of the bubbleView
         */

        self.bubbleContainerView = UIView()
        self.bubbleContainerView.backgroundColor = UIColor.clear
        self.bubbleContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.bubbleContainerView)
        //dateLabel
        self.contentView.addSubview(dateLabel)
        
        // Setting Constraints
        let views: [String: UIView] = ["senderImageView": senderImageView, "bubbleContainerView": bubbleContainerView, "userImageView": userImageView,"dateLabel":dateLabel]
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[dateLabel]-20-|", options:[], metrics:nil, views:views))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[senderImageView(0)]", options:[], metrics:nil, views:views))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[senderImageView(0)]-4-|", options:[], metrics:nil, views:views))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[userImageView(0)]-8-|", options:[], metrics:nil, views:views))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[userImageView(0)]-4-|", options:[], metrics:nil, views:views))
        //self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[bubbleContainerView]", options:[], metrics:nil, views:views))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[dateLabel(21)]-0-[bubbleContainerView]", options:[], metrics:nil, views:views)) //21
        //self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[bubbleContainerView]-0-[dateLabel(21)]|", options:[], metrics:nil, views:views))

        self.bubbleBottomConstraint = NSLayoutConstraint(item:self.contentView, attribute:.bottom, relatedBy:.equal, toItem:self.bubbleContainerView, attribute:.bottom, multiplier:1.0, constant:4.0)
        self.bubbleBottomConstraint.priority = UILayoutPriority.defaultHigh
        self.bubbleLeadingConstraint = NSLayoutConstraint(item:self.bubbleContainerView, attribute:.leading, relatedBy:.equal, toItem:self.contentView, attribute:.leading, multiplier:1.0, constant:20.0)
        self.bubbleLeadingConstraint.priority = UILayoutPriority.defaultHigh
        self.bubbleTrailingConstraint = NSLayoutConstraint(item:self.contentView, attribute:.trailing, relatedBy:.equal, toItem:self.bubbleContainerView, attribute:.trailing, multiplier:1.0, constant:7.0)
        self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultLow
        
        self.contentView.addConstraints([self.bubbleTrailingConstraint, self.bubbleLeadingConstraint, self.bubbleBottomConstraint])
    }

    func bubbleType() -> ComponentType {
        return .text
    }

    static func setComponents(_ components: Array<KREComponent>, bubbleView: BubbleView) {
        let component: KREComponent = components.first!
        if (component.message?.isSender == true) {
            bubbleView.tailPosition = .right
        } else {
            bubbleView.tailPosition = .left
        }
    
        bubbleView.components = components as NSArray?
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configureWithComponents(_ components: Array<KREComponent>) {
        if (self.bubbleView == nil) {
            self.bubbleView = BubbleView.bubbleWithType(bubbleType())
            self.bubbleContainerView.addSubview(self.bubbleView)
            
            self.bubbleContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[bubbleView]|", options:[], metrics:nil, views:["bubbleView": self.bubbleView]))
            self.bubbleContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[bubbleView]|", options:[], metrics:nil, views:["bubbleView": self.bubbleView]))
        }
        
        MessageBubbleCell.setComponents(components, bubbleView:self.bubbleView)
        self.tailPosition = self.bubbleView.tailPosition
        
       
//        if let message = components.first?.message, let sentOn = message.sentOn as Date? {
//                let dateFormatter = DateFormatter()
//                dateFormatter.dateFormat = "EE, MMM dd yyyy 'at' hh:mm:ss a"
//                dateLabel.text = dateFormatter.string(from: sentOn)
//        }
//        if self.tailPosition == .left{
//            dateLabel.textAlignment = .left
//        }else{
//            dateLabel.textAlignment = .right
//        }
        
        let component: KREComponent = components.first!
        let message: KREMessage = component.message!
        
        if let sentOn = message.sentOn as Date? {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EE, MMM dd yyyy 'at' hh:mm:ss a"
                dateLabel.text = dateFormatter.string(from: sentOn)
        }
        if self.tailPosition == .left{
            dateLabel.textAlignment = .left
        }else{
            dateLabel.textAlignment = .right
        }
        
        
//        let placeHolderIcon : UIImage = UIImage(named: "kora", in: bundle, compatibleWith: nil)!
//        self.senderImageView.image = placeHolderIcon
        if(self.userImageView.image == nil){
            self.userImageView.image = UIImage(named: "faceIcon", in: bundle, compatibleWith: nil)
        }
        
        if (message.iconUrl != nil) {
            //            if let fileUrl = URL(string: message.iconUrl!) { //kk
            //                self.senderImageView.af.setImage(withURL: fileUrl, placeholderImage: placeHolderIcon)
            //            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(MessageBubbleCell.updateImage(notification:)), name: NSNotification.Name(rawValue: updateUserImageNotification), object: nil)
    }

    func components() -> NSArray {
        return self.bubbleView.components
    }
    
    func getEstimatedHeightForComponents(_ components: Array<KREComponent>, bubbleType:ComponentType) -> CGFloat {
        let bubbleView = BubbleView.bubbleWithType(bubbleType)
        bubbleView.components = components as NSArray?
        let height = bubbleView.intrinsicContentSize.height
        
        return height + 12.0
    }
    @objc func updateImage(notification:Notification){
        self.userImageView.image = UIImage(named:"john")!
    }
    
    // MARK:- deinit
    deinit {
        self.bubbleContainerView = nil
        self.senderImageView = nil
        self.userImageView = nil
        self.bubbleLeadingConstraint = nil
        self.bubbleTrailingConstraint = nil
        self.bubbleBottomConstraint = nil
        self.bubbleView = nil
    }
}

class TextBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .text
    }
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            
            self.bubbleTrailingConstraint.constant = 20
            if (tailPosition == .left) {
                self.bubbleLeadingConstraint.priority = UILayoutPriority.defaultHigh
                self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultLow
            } else {
                self.bubbleLeadingConstraint.priority = UILayoutPriority.defaultLow
                self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
                
            }
        }
    }
}

class QuickReplyBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .quickReply
    }
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleTrailingConstraint.constant = 20
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
    }
}

class ErrorBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .error
    }
}

class ImageBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .image
    }
}

class OptionsBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .options
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleTrailingConstraint.constant = 20
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
    }
}

class ListBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .list
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleTrailingConstraint.constant = 20
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
    }
}

class CarouselBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .carousel
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleLeadingConstraint.constant = 0
            self.bubbleTrailingConstraint.constant = 0
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
    }
}

class PiechartBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .chart
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleLeadingConstraint.constant = 0
            self.bubbleTrailingConstraint.constant = 0
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
    }
    
    override func configureWithComponents(_ components: Array<KREComponent>) {
        super.configureWithComponents(components)
        self.senderImageView.isHidden = true
    }
}

class TableBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .table
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleLeadingConstraint.constant = 20
            self.bubbleTrailingConstraint.constant = 20
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
    }
    
    override func configureWithComponents(_ components: Array<KREComponent>) {
        super.configureWithComponents(components)
        self.senderImageView.isHidden = true
    }
}

class MiniTableBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .minitable
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleLeadingConstraint.constant = 0
            self.bubbleTrailingConstraint.constant = 0
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
    }
    
    override func configureWithComponents(_ components: Array<KREComponent>) {
        super.configureWithComponents(components)
        self.senderImageView.isHidden = true
    }
}
class MenuBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .menu
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleLeadingConstraint.constant = 20
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
    }
    
   
}
class ResponsiveTableBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .responsiveTable
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleLeadingConstraint.constant = 0
            self.bubbleTrailingConstraint.constant = 0
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
    }
    
    override func configureWithComponents(_ components: Array<KREComponent>) {
        super.configureWithComponents(components)
        self.senderImageView.isHidden = true
    }
    
}

class NewListBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .newList
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleTrailingConstraint.constant = 20
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
    }
}
class TableListBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .tableList
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleTrailingConstraint.constant = 20
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
    }
}

class CalendarBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .calendarView
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleTrailingConstraint.constant = 20
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
    }
}

class QuickRepliesWelcomeCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .quick_replies_welcome
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleTrailingConstraint.constant = 20
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
    }
}

class NotificationBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .notification
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleLeadingConstraint.constant = 0
            self.bubbleTrailingConstraint.constant = 0
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
    }
    
    override func configureWithComponents(_ components: Array<KREComponent>) {
        super.configureWithComponents(components)
        self.senderImageView.isHidden = true
    }
}

class MultiSelectBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .multiSelect
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleTrailingConstraint.constant = 20
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
    }
}

class ListWidgetBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .list_widget
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleTrailingConstraint.constant = 20
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
    }
}
class FeedbackBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .feedbackTemplate
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleTrailingConstraint.constant = 20
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
    }
}

class InLineFormCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .inlineForm
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleTrailingConstraint.constant = 20
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
    }
}

class DropDownell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .dropdown_template
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleTrailingConstraint.constant = 20
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
    }
}

class TransactionSuccessTemplateCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .transactionSuccessTemplate
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleTrailingConstraint.constant = 130
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
    }
}

class ContactCardTemplateCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .contactCardTemplate
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleTrailingConstraint.constant = 80 //100
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
    }
}

class RadioListTemplateCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .radioListTemplate
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleTrailingConstraint.constant = 20
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
    }
}

class PDFDownloadCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .pdfdownload
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleTrailingConstraint.constant = 130
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
    }
}

class UpdatedIdfcCarouselCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .updatedIdfcCarousel
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleLeadingConstraint.constant = 0
            self.bubbleTrailingConstraint.constant = 0
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
    }
}

class ButtonLinkBubbleVCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .buttonLinkTemplate
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleTrailingConstraint.constant = 20
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
    }
}

class IDFCFeedbackBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .idfcFeedbackTemplate
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleLeadingConstraint.constant = 0
            self.bubbleTrailingConstraint.constant = 0
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
    }
}
class StatusTemplateBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .statusTemplate
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleTrailingConstraint.constant = 90
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
    }
}
class ServiceListTemplateBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .serviceListTemplate
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleLeadingConstraint.constant = 0
            self.bubbleTrailingConstraint.constant = 0
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
    }
}

class IDFCAgentTemplateBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .idfcAgentTemplate
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleLeadingConstraint.constant = 0
            self.bubbleTrailingConstraint.constant = 0
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
    }
}

class IDFCCarouselTemplateBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .idfcCarouselType2
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleLeadingConstraint.constant = 0
            self.bubbleTrailingConstraint.constant = 0
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
    }
}

class CardSelectionCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .cardSelection
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleTrailingConstraint.constant = 20
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
    }
}

class BeneficiaryBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .beneficiaryTemplate
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleTrailingConstraint.constant = 20
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
    }
}

class AdvancedMultiSelectCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .advanced_multi_select
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleTrailingConstraint.constant = 20
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
    }
}

class SalaamPointsCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .salaampointsTemplate
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleTrailingConstraint.constant = 20
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
    }
}

class WelcomeTemplateCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .welcome_template
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleTrailingConstraint.constant = 20
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
            dateLabel.isHidden = true
        }
    }
}

class BoldTextTemplateBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .boldtextTemplate
    }
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleTrailingConstraint.constant = 20
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
    }
}
class EmptyBubbleTemplateCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        dateLabel.isHidden = true
        return .emptyBubbleTemplate
    }
}
class CustomDropdownTemplateCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .custom_dropdown_template
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleTrailingConstraint.constant = 20
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
    }
}

class DetailsListTemplateCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .details_list_template
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleTrailingConstraint.constant = 20
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
    }
}
class SearchTemplateCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .search_template
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleTrailingConstraint.constant = 20
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
    }
}
class BankingFeedbackTemplateCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .bankingFeedbackTemplate
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleTrailingConstraint.constant = 20
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
    }
}
class AudioBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .audio
    }
}
