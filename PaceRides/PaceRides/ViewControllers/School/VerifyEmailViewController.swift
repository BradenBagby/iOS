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
        UserModel.sharedInstance.sendVerificationEmail()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
