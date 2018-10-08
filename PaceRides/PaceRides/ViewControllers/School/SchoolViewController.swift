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
            
            if let userEmail = paceUserSchoolProfile.email {
                self.primaryLabel.text = userEmail
                
                paceUserSchoolProfile.getUniversityModel() { university, error in
                    
                    guard error == nil else {
                        self.primaryLabel.text = error!.localizedDescription
                        return
                    }
                    
                    guard let university = university else {
                        self.primaryLabel.text = "No university data"
                        return
                    }
                    
                    self.primaryLabel.text = university.shorthand ?? "nil"
                    
                }
            } else {
                self.primaryLabel.text = "Error"
            }
        } else {
            self.signInView.isHidden = false
            self.verifyEmailView.isHidden = true
        }
        
    }
}
