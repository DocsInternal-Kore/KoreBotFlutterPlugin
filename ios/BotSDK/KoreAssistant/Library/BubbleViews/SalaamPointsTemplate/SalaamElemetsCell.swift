//
//  SalaamElemetsCell.swift
//  KoreBotSDKFrameWork
//
//  Created by Kartheek.Pagidimarri on 09/08/22.
//  Copyright © 2022 Kartheek.Pagidimarri. All rights reserved.
//

import UIKit

class SalaamElemetsCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var valueLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bgView.backgroundColor = .white
        titleLbl.font =  UIFont(name: regularCustomFont, size: 14.0)
        valueLbl.font = UIFont(name: semiBoldCustomFont, size: 18.0)
        bgView.layer.cornerRadius = 5.0
        bgView.layer.borderWidth = 1.0
        bgView.layer.borderColor = UIColor.init(hexString:"#DDE0E9").cgColor//UIColor.lightGray.cgColor
        bgView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
