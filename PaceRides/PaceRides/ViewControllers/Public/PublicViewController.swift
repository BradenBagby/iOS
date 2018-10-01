//
//  PublicViewController.swift
//  PaceRides
//
//  Created by Grant Broadwater on 9/30/18.
//  Copyright © 2018 PaceRides. All rights reserved.
//

import UIKit

class PublicViewController: FrontViewController {
    
    @IBOutlet weak var primaryLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.UserPublicProfileDidChange()
        UserModel.sharedInstance.notificationCenter.addObserver(
            forName: .UserPublicProfileDidChange,
            object: UserModel.sharedInstance,
            queue: OperationQueue.main,
            using: self.UserPublicProfileDidChange
        )
    }
    
    func UserPublicProfileDidChange(_: Notification? = nil) {
        
        if let userPublicProfile = UserModel.sharedInstance.publicProfile {
            self.signInView.isHidden = true
            self.primaryLabel.text = userPublicProfile.displayName ?? userPublicProfile.uid
        } else {
            self.signInView.isHidden = false
        }
        
    }

}
