//
//  ContactCardCell.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek.Pagidimarri on 08/11/21.
//  Copyright © 2021 Kore. All rights reserved.
//

import UIKit

class ContactCardCell: UITableViewCell {

    @IBOutlet weak var profilePicWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var bgV: UIView!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var phonenoLbl: UITextView!
    @IBOutlet var titleLblTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var phoneLblHeightConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bgV.layer.cornerRadius = 4.0
        bgV.clipsToBounds = true
        
        profilePic.layer.cornerRadius = profilePic.frame.size.width/2
        profilePic.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
