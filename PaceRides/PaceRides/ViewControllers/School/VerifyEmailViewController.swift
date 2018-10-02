//
//  VerifyEmailViewController.swift
//  PaceRides
//
//  Created by Grant Broadwater on 10/1/18.
//  Copyright © 2018 PaceRides. All rights reserved.
//

import UIKit

class VerifyEmailViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func verifiedButtonPressed() {
        UserModel.sharedInstance.reloadFirebaseUser() { error in
            
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            NotificationCenter.default.post(
                name: .UserSchoolEmailVerifiedDidChange,
                object: self
            )
            
        }
    }
    
    @IBAction func resendVerificationEmailButtonPressed() {
        UserModel.sharedInstance.sendVerificationEmail(reloadFirst: true)
    }

}
