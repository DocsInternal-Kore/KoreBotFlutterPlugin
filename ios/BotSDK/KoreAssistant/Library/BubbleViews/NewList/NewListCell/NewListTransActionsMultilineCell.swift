//
//  NewListTransActionsMultilineCell.swift
//  KoreBotSDKFrameWork
//
//  Created by Kartheek.Pagidimarri on 10/08/22.
//  Copyright © 2022 Kartheek.Pagidimarri. All rights reserved.
//

import UIKit

class NewListTransActionsMultilineCell: UITableViewCell {
    @IBOutlet var bgView: UIView!
    
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var titleLabl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    
    @IBOutlet var priceLblWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var underlineLbl: UILabel!
    @IBOutlet weak var dateTopConstaint: NSLayoutConstraint!
    @IBOutlet weak var dateHeightConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        dateLbl.font =  UIFont(name: semiBoldCustomFont, size: 16.0)
        titleLabl.font = UIFont(name: semiBoldCustomFont, size: 14.0)
        priceLbl.font = UIFont(name: semiBoldCustomFont, size: 14.0)
        subTitle.font = UIFont(name: mediumCustomFont, size: 12.0)
        underlineLbl.backgroundColor = UIColor.init(hexString:"#DDE0E9")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
