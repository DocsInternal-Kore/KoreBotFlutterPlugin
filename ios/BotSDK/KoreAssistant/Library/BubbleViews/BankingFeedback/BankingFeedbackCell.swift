//
//  BankingFeedbackCell.swift
//  KoreBotSDKFrameWork
//
//  Created by Kartheek Pagidimarri on 05/05/23.
//  Copyright © 2023 Kartheek.Pagidimarri. All rights reserved.
//

import UIKit

class BankingFeedbackCell: UITableViewCell {

    @IBOutlet weak var bgV: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var checkBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleLbl.font = UIFont(name: regularCustomFont, size: 12)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
