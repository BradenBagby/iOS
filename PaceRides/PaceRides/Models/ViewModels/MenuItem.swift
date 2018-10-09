//
//  MenuItem.swift
//  PaceRides
//
//  Created by Grant Broadwater on 10/8/18.
//  Copyright © 2018 PaceRides. All rights reserved.
//

import Foundation


class MenuItem {
    
    var image: UIImage
    var text: String
    var accessoryType: UITableViewCell.AccessoryType = UITableViewCell.AccessoryType.none
    

    init(
        withText text: String,
        andImage image: UIImage = UIImage(named: "grayDot")!,
        andAccessoryType accessoryType: UITableViewCell.AccessoryType = UITableViewCell.AccessoryType.none
        ) {
        self.text = text
        self.image = image
        self.accessoryType = accessoryType
    }
    
}
