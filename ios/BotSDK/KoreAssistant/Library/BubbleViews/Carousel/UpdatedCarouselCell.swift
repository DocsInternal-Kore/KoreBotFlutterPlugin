//
//  UpdatedCarouselCell.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek.Pagidimarri on 17/11/21.
//  Copyright © 2021 Kore. All rights reserved.
//

import UIKit

class UpdatedCarouselCell: UICollectionViewCell {
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var carouselBtn: UIButton!
    @IBOutlet weak var titlelblHeightConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        carouselBtn.layer.cornerRadius = 10.0
        carouselBtn.layer.borderColor = UIColor.white.cgColor
        carouselBtn.layer.borderWidth = 1.0
        carouselBtn.clipsToBounds = true
        
        carouselBtn.titleLabel?.lineBreakMode = .byWordWrapping
        carouselBtn.titleLabel?.numberOfLines = 2
        carouselBtn.titleLabel?.textAlignment = .center
    }

}
