//
//  IDFCUpdatedCaroselCell.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek.Pagidimarri on 04/01/22.
//  Copyright © 2022 Kore. All rights reserved.
//

import UIKit

class IDFCUpdatedCaroselCell: UICollectionViewCell {
    
    @IBOutlet weak var tagLblWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var tagLbl: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var titleLbl: KREAttributedLabel!
    @IBOutlet weak var imagView: UIImageView!
    @IBOutlet weak var imagVHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var titlelblHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var carouselBtn: UIButton!
    @IBOutlet weak var IdfcDownloadBtn: UIButton!
    @IBOutlet weak var idfcMailBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.tagLbl.font = UIFont(name: semiBoldCustomFont, size: 12.0)
        self.tagLbl.numberOfLines = 0
        self.tagLbl.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.tagLbl.isUserInteractionEnabled = true
        self.tagLbl.layer.cornerRadius = 10
        self.tagLbl.clipsToBounds = true
        
        self.tagLbl.textAlignment = .center
    }

}
