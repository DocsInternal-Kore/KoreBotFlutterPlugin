//
//  SalaamPointsCardCell.swift
//  KoreBotSDKFrameWork
//
//  Created by Kartheek.Pagidimarri on 09/08/22.
//  Copyright © 2022 Kartheek.Pagidimarri. All rights reserved.
//

import UIKit

class SalaamPointsCardCell: UITableViewCell {
    
    @IBOutlet var bgView: UIView!
    @IBOutlet weak var offersLbl: UILabel!
    @IBOutlet weak var cardLbl: KREAttributedLabel!
    @IBOutlet var copyBtn: UIButton!
    @IBOutlet var copyBtnWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet var cardTxtV: KREAttributedTextView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        offersLbl.font =  UIFont(name: semiBoldCustomFont, size: 14.0)
        cardLbl.font = UIFont(name: mediumCustomFont, size: 12.0)
        
        cardTxtV.font = UIFont(name: mediumCustomFont, size: 12.0)
        cardTxtV.backgroundColor = .clear
        cardTxtV.isEditable = false
        cardTxtV.isScrollEnabled = false
        cardTxtV.textContainer.lineBreakMode = NSLineBreakMode.byWordWrapping
        cardTxtV.isUserInteractionEnabled = true
        cardTxtV.contentMode = UIView.ContentMode.scaleAspectFit
        cardTxtV.linkTextColor = .black
        cardTxtV.mentionTextColor = .black
        cardTxtV.hashtagTextColor = .black
        cardTxtV.tintColor = .black
        
        copyBtn.setTitleColor(themeColor, for: .normal)
        copyBtn.titleLabel?.font = UIFont(name: mediumCustomFont, size: 12.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
