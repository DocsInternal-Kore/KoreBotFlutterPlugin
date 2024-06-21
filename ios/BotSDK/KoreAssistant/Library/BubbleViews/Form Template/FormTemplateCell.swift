//
//  FormTemplateCell.swift
//  KoreBotSDKFrameWork
//
//  Created by Kartheek Pagidimarri on 13/01/23.
//  Copyright © 2023 Kartheek.Pagidimarri. All rights reserved.
//

import UIKit

class FormTemplateCell: UITableViewCell {

    @IBOutlet weak var imagV: UIImageView!
    @IBOutlet weak var arrowBtn: UIButton!
    @IBOutlet weak var bgVTF: UIView!
    @IBOutlet weak var addressTF: UITextField!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var imagVWidthConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        bgVTF.layer.borderWidth = 1.0
        bgVTF.layer.cornerRadius = 4.0
        bgVTF.layer.borderColor = UIColor.init(hexString: "#7C7C7C").cgColor
        bgVTF.clipsToBounds = true

        addressTF.textColor = .black
        addressTF.font = UIFont(name: regularCustomFont, size: 14.0)
        titleLbl.font = UIFont(name: semiBoldCustomFont, size: 14.0)
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
