//
//  AdvancedListViewCell.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek.Pagidimarri on 04/02/22.
//  Copyright © 2022 Kore. All rights reserved.
//

import UIKit

class AdvancedListViewCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var cardNoLbl: UILabel!
    @IBOutlet weak var disbursalDateLbl: UILabel!
    @IBOutlet weak var disbursalAmountLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var amountLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        titleLbl.font =  UIFont(name: semiBoldCustomFont, size: 14.0)
        cardNoLbl.font = UIFont(name: regularCustomFont, size: 12.0)
        disbursalDateLbl.font = UIFont(name: regularCustomFont, size: 9.0)
        disbursalAmountLbl.font = UIFont(name: regularCustomFont, size: 9.0)
        dateLbl.font = UIFont(name: regularCustomFont, size: 12.0)
        amountLbl.font = UIFont(name: semiBoldCustomFont, size: 14.0)
        
        titleLbl.textColor = UIColor(red: 37/255, green: 36/255, blue: 59/255, alpha: 1)
        cardNoLbl.textColor = UIColor(red: 37/255, green: 36/255, blue: 59/255, alpha: 1)
        disbursalDateLbl.textColor = UIColor(red: 104/255, green: 104/255, blue: 115/255, alpha: 1)
        disbursalAmountLbl.textColor = UIColor(red: 104/255, green: 104/255, blue: 115/255, alpha: 1)
        dateLbl.textColor = UIColor(red: 37/255, green: 36/255, blue: 59/255, alpha: 1)
        amountLbl.textColor = UIColor(red: 37/255, green: 36/255, blue: 59/255, alpha: 1)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
