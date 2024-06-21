//
//  SearchListCell.swift
//  KoreBotSDKFrameWork
//
//  Created by Kartheek Pagidimarri on 12/04/23.
//  Copyright © 2023 Kartheek.Pagidimarri. All rights reserved.
//

import UIKit

class SearchListCell: UITableViewCell {

    @IBOutlet weak var imagV: UIImageView!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var bgV: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.bgV.layer.cornerRadius = 2.0
        self.bgV.clipsToBounds = true
        self.bgV.layer.masksToBounds = false
        self.bgV.layer.shadowColor = UIColor.lightGray.cgColor
        self.bgV.layer.shadowOffset =  CGSize.zero
        self.bgV.layer.shadowOpacity = 0.3
        self.bgV.layer.shadowRadius = 4
        self.bgV.layer.shadowOffset = CGSize(width: 0 , height:2)
        
        titleLbl.font = UIFont(name: semiBoldCustomFont, size: 14.0)
        descLbl.font = UIFont(name: regularCustomFont, size: 14.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
