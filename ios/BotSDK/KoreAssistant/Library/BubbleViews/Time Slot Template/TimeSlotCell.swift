//
//  TimeSlotCell.swift
//  KoreBotSDKFrameWork
//
//  Created by Kartheek Pagidimarri on 19/12/22.
//  Copyright © 2022 Kartheek.Pagidimarri. All rights reserved.
//

import UIKit

class TimeSlotCell: UICollectionViewCell {

    @IBOutlet weak var bgV: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleLbl.textColor = .black
        titleLbl.font = UIFont(name: semiBoldCustomFont, size: 14.0)
    }

}
