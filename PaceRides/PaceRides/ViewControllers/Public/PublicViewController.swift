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
        
        self.userPublicProfileDidChange()
        UserModel.notificationCenter.addObserver(
            forName: .NewPaceUserData,
            object: nil,
            queue: OperationQueue.main,
            using: self.userPublicProfileDidChange
        )
    }
    
    func userPublicProfileDidChange(_: Notification? = nil) {
        
        if let paceUser = UserModel.sharedInstance(), let paceUserPublicProfile = paceUser.publicProfile() {
            
            print("Public user info")
            print("Display Name: \(paceUserPublicProfile.displayName)")
            print("Facebook Id: \(paceUserPublicProfile.facebookId)")
            print("Uid: \(paceUserPublicProfile.uid)")
            
            self.signInView.isHidden = true
            self.primaryLabel.text
                = paceUserPublicProfile.displayName
                ?? paceUser.uid
        } else {
            self.signInView.isHidden = false
        }
        
    }

}
