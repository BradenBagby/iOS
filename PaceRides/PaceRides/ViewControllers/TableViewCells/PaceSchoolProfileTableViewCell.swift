//
//  PaceSchoolProfileTableViewCell.swift
//  PaceRides
//
//  Created by Grant Broadwater on 10/4/18.
//  Copyright © 2018 PaceRides. All rights reserved.
//

import UIKit

class PaceSchoolProfileTableViewCell: UITableViewCell {

    var userSchoolProfile: PaceSchoolProfile? = nil {
        didSet {
            if let profile = userSchoolProfile {
                self.iconImageView.image = UIImage(named: "emailIcon")
                self.primaryLabel.text = profile.email ?? "Error"
            } else {
                self.iconImageView.image = nil
                self.primaryLabel.text = nil
            }
        }
    }
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var primaryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
