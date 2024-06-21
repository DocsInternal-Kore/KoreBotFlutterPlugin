//
//  IDFCCarouselCell.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek.Pagidimarri on 17/12/21.
//  Copyright © 2021 Kore. All rights reserved.
//

import UIKit

class IDFCCarouselCell: UICollectionViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var titleLbl: KREAttributedLabel!
    @IBOutlet weak var imagView: UIImageView!
    @IBOutlet weak var imagVHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var titlelblHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var carouselBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
