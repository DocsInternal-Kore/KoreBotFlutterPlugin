//
//  BenficiaryCell.swift
//  KoreBotSDKFrameWork
//
//  Created by Kartheek.Pagidimarri on 11/07/22.
//  Copyright © 2022 Kartheek.Pagidimarri. All rights reserved.
//

import UIKit

class BenficiaryCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imagV: UIImageView!
    @IBOutlet weak var descLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleLabel.font =  UIFont(name: semiBoldCustomFont, size: 14.0)
        descLbl.font = UIFont(name: regularCustomFont, size: 12.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        imagV.layer.cornerRadius = imagV.frame.width/2
        imagV.clipsToBounds = true
        // Configure the view for the selected state
    }
    
}
