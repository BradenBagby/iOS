//
//  PacePublicProfileTableViewCell.swift
//  PaceRides
//
//  Created by Grant Broadwater on 10/4/18.
//  Copyright © 2018 PaceRides. All rights reserved.
//

import UIKit

class PacePublicProfileTableViewCell: UITableViewCell {

    var userPublicProfile: PacePublicProfile? = nil {
        didSet {
            if let profile = userPublicProfile {
                self.iconImageView.image = UIImage(named: "facebookIcon")
                self.primaryLabel.text = profile.displayName ?? profile.facebookId ?? "Error"
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
