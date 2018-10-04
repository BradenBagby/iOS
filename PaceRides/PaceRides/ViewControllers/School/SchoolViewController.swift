//
//  SchoolViewController.swift
//  PaceRides
//
//  Created by Grant Broadwater on 10/1/18.
//  Copyright © 2018 PaceRides. All rights reserved.
//

import UIKit

class SchoolViewController: FrontViewController {
    
    @IBOutlet weak var primaryLabel: UILabel!
    @IBOutlet weak var verifyEmailView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.userSchoolProfileDidChange()
        UserModel.notificationCenter.addObserver(
            forName: .NewPaceUserData,
            object: nil,
            queue: OperationQueue.main,
            using: self.userSchoolProfileDidChange
        )
    }
    
    func userSchoolProfileDidChange(_: Notification? = nil) {
        
        if let paceUser = UserModel.sharedInstance(), let paceUserSchoolProfile = paceUser.schoolProfile() {
            self.signInView.isHidden = true
            
            if paceUserSchoolProfile.isEmailVerified {
                self.verifyEmailView.isHidden = true
            } else {
                self.verifyEmailView.isHidden = false
                return
            }
            
            self.primaryLabel.text
                = paceUserSchoolProfile.email
                ?? paceUserSchoolProfile.displayName
                ?? paceUserSchoolProfile.uid
        } else {
            self.signInView.isHidden = false
            self.verifyEmailView.isHidden = true
        }
        
    }
}
