//
//  ButtonWithImage.swift
//  PaceRides
//
//  Created by Grant Broadwater on 10/17/18.
//  Copyright © 2018 PaceRides. All rights reserved.
//

import UIKit

class ButtonWithImage: UIButton {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if imageView != nil {
            imageEdgeInsets = UIEdgeInsets(top: 24, left: (bounds.width - 35), bottom: 24, right: 5)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: (imageView?.frame.width)!)
        }
    }
}
