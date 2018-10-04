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
        if let paceUser = UserModel.sharedInstance() {
            paceUser.reload() { error in
                
                guard error == nil else {
                    print(error!.localizedDescription)
                    return
                }
                
                NotificationCenter.default.post(
                    name: .NewPaceUserData,
                    object: self
                )
                
            }
        }
    }
    
    @IBAction func resendVerificationEmailButtonPressed() {
        if let paceUser = UserModel.sharedInstance(), let paceUserSchoolProfile = paceUser.schoolProfile() {
            paceUserSchoolProfile.sendEmailVerification() { error in
                
                guard error == nil else {
                    
                    print("Error resending verification email")
                    print(error?.localizedDescription)
                    
                    return
                }
            }
        }
    }

}
