//
//  MenuItemTableViewCell.swift
//  PaceRides
//
//  Created by Grant Broadwater on 10/8/18.
//  Copyright © 2018 PaceRides. All rights reserved.
//

import UIKit

class MenuItemTableViewCell: UITableViewCell {

    @IBOutlet weak var menuItemImageView: UIImageView!
    @IBOutlet weak var menuItemLabel: UILabel!
    
    var menuItem: MenuItem? = nil {
        didSet {
            if let menuItem = self.menuItem {
                self.menuItemLabel.text = menuItem.text
                self.menuItemImageView.image = menuItem.image
                self.accessoryType = accessoryType
            } else {
                self.menuItemLabel.text = nil
                self.menuItemImageView.image = nil
                self.accessoryType = .none
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
