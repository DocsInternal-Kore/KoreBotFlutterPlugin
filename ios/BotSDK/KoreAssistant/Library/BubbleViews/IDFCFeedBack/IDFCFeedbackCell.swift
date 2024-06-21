//
//  IDFCFeedbackCell.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek.Pagidimarri on 06/12/21.
//  Copyright © 2021 Kore. All rights reserved.
//

import UIKit

class IDFCFeedbackCell: UICollectionViewCell {
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var imagV: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bgView.layer.cornerRadius = 8.0
        bgView.clipsToBounds = true
    }

}
