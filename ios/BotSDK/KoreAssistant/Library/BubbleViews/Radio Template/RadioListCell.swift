//
//  RadioListCell.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek.Pagidimarri on 10/11/21.
//  Copyright © 2021 Kore. All rights reserved.
//

import UIKit

class RadioListCell: UITableViewCell {

    @IBOutlet weak var priceLblWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLblTopConstarint: NSLayoutConstraint!
    @IBOutlet weak var checkBtn: UIButton!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
