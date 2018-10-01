//
//  PublicSignInViewController.swift
//  PaceRides
//
//  Created by Grant Broadwater on 10/1/18.
//  Copyright © 2018 PaceRides. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class PublicSignInViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let loginButton = FBSDKLoginButton()
        loginButton.readPermissions = ["public_profile"]
        loginButton.center = self.view.center
        loginButton.delegate = UserModel.sharedInstance
        self.view.addSubview(loginButton)
    }
}
