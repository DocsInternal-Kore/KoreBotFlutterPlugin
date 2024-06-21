//
//  ResetPasswordCell.swift
//  KoreBotSDKFrameWork
//
//  Created by Kartheek Pagidimarri on 09/01/23.
//  Copyright © 2023 Kartheek.Pagidimarri. All rights reserved.
//

import UIKit

class ResetPasswordCell: UITableViewCell {

    @IBOutlet weak var titleLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleLbl.font = UIFont(name: regularCustomFont, size: 14.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
