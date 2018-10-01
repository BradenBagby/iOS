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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.userSchoolProfileDidChange()
        UserModel.sharedInstance.notificationCenter.addObserver(
            forName: .UserSchoolProfileDidChange,
            object: UserModel.sharedInstance,
            queue: OperationQueue.main,
            using: self.userSchoolProfileDidChange
        )
    }
    
    func userSchoolProfileDidChange(_: Notification? = nil) {
        
        if let userSchoolProfile = UserModel.sharedInstance.schoolProfile {
            self.signInView.isHidden = true
            
            self.primaryLabel.text = userSchoolProfile.displayName
                ?? userSchoolProfile.providerId
                ?? userSchoolProfile.uid
        } else {
            self.signInView.isHidden = false
        }
        
    }
}
