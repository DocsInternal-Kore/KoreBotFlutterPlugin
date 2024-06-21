//
//  DetailsListCell.swift
//  KoreBotSDKFrameWork
//
//  Created by Kartheek Pagidimarri on 19/01/23.
//  Copyright © 2023 Kartheek.Pagidimarri. All rights reserved.
//

import UIKit

class DetailsListCell: UITableViewCell {
    @IBOutlet weak var bgV: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var detailsLbl: UILabel!
    
    @IBOutlet weak var underLineLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleLbl.font =  UIFont(name: semiBoldCustomFont, size: 14.0)
        detailsLbl.font = UIFont(name: mediumCustomFont, size: 12.0)
    }

    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
