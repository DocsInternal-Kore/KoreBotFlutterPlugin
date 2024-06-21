//
//  UserValidationCell.swift
//  react-native-kore-bot-sdk
//
//  Created by Kartheek Pagidimarri on 23/03/23.
//

import UIKit

class UserValidationCell: UITableViewCell {
    
    @IBOutlet weak var bgVTF: UIView!
    @IBOutlet weak var addressTF: UITextField!
    @IBOutlet weak var titleLbl: UILabel!

    @IBOutlet var errorLbl: UILabel!
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
        errorLbl.font = UIFont(name: regularCustomFont, size: 12.0)
        errorLbl.textColor = UIColor.init(hexString: "#B00020")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
