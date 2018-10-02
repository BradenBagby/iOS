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
        UserModel.sharedInstance.notificationCenter.addObserver(
            forName: .UserSchoolProfileDidChange,
            object: UserModel.sharedInstance,
            queue: OperationQueue.main,
            using: self.userSchoolProfileDidChange
        )
        
        NotificationCenter.default.addObserver(
            forName: .UserSchoolEmailVerifiedDidChange,
            object: nil,
            queue: OperationQueue.main,
            using: self.userSchoolProfileDidChange
        )
    }
    
    func userSchoolProfileDidChange(_: Notification? = nil) {
        
        if let userSchoolProfile = UserModel.sharedInstance.schoolProfile {
            self.signInView.isHidden = true
            
            if userSchoolProfile.emailVerified {
                self.verifyEmailView.isHidden = true
            } else {
                self.verifyEmailView.isHidden = false
                return
            }
            
            self.primaryLabel.text = userSchoolProfile.displayName
                ?? userSchoolProfile.providerId
                ?? userSchoolProfile.uid
        } else {
            self.signInView.isHidden = false
            self.verifyEmailView.isHidden = true
        }
        
    }
}
