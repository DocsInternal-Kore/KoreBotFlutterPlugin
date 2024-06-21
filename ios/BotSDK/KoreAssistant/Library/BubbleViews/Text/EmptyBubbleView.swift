//
//  EmptyBubbleView.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek.Pagidimarri on 11/11/22.
//  Copyright © 2022 Kore. All rights reserved.
//

import UIKit

class EmptyBubbleView: BubbleView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override var intrinsicContentSize : CGSize {
        return CGSize(width: 0.0, height: 0.0)
    }

}
