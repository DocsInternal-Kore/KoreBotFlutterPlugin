//
//  IDFCFeedbackSugggestionCell.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek.Pagidimarri on 06/12/21.
//  Copyright © 2021 Kore. All rights reserved.
//

import UIKit

class IDFCFeedbackSugggestionCell: UITableViewCell {
    //@IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var textlabel: EdgeInsetLabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        textlabel.layer.cornerRadius = 20.0
        textlabel.clipsToBounds = true
        textlabel.layer.borderWidth = 1.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
         
        // Configure the view for the selected state
        
    }
    
}
