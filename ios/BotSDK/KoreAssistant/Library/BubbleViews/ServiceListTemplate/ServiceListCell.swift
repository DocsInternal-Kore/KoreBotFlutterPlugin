//
//  ServiceListCell.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek.Pagidimarri on 07/12/21.
//  Copyright © 2021 Kore. All rights reserved.
//

import UIKit

class ServiceListCell: UITableViewCell {
    @IBOutlet weak var tagLblWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var underlineLbl: UILabel!
    @IBOutlet weak var titeLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
