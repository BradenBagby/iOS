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

    @IBOutlet weak var openMenuBarButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setAsRearNavigationItem(self.openMenuBarButtonItem, forView: self.view)
        
        self.userPublicProfileDidChange()
        UserModel.notificationCenter.addObserver(
            forName: .NewPaceUserAuthData,
            object: nil,
            queue: OperationQueue.main,
            using: self.userPublicProfileDidChange
        )
        
        self.setNavigationBarColors()
        UserModel.notificationCenter.addObserver(
            forName: .PaceUserUniversityDataDidChanged,
            object: nil,
            queue: OperationQueue.main,
            using: self.setNavigationBarColors
        )
        
        let loginButton = FBSDKLoginButton()
        loginButton.readPermissions = ["public_profile"]
        loginButton.center = self.view.center
        loginButton.delegate = UserModel.fbLoginDelegate
        self.view.addSubview(loginButton)
    }
    
    
    func userPublicProfileDidChange(_: Notification? = nil) {
        if let paceUser = UserModel.sharedInstance(), let _ = paceUser.publicProfile() {
            self.performSegue(withIdentifier: "showPublicTabBarController", sender: self)
        }
    }
}
