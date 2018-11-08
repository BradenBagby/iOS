//
//  FacebookLoginCollectionViewCell.swift
//  PaceRides
//
//  Created by Grant Broadwater on 11/6/18.
//  Copyright © 2018 PaceRides. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class FacebookLoginCollectionViewCell: WelcomeCollectionViewCellInterface {
    
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton! {
        didSet {
            if let fbLoginButton = self.fbLoginButton {
                fbLoginButton.delegate = UserModel.fbLoginDelegate
            }
        }
    }
    
    static var reuseIdentifier: String = "FacebookLoginCollectionViewCell"
    
    override func layoutSubviews() {
        
    }
    
}

extension NSLayoutConstraint {
    
    func getDescription() -> String? {
        
        guard let firstItem = self.firstItem else {
            return nil
        }
        
        
        return type(of: firstItem).description()
    }
    
}
