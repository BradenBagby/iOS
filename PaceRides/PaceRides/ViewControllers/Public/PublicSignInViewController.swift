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
        
        self.revealViewController()!.rearViewRevealWidth = 300
        if let openMenuBarButtonItem = self.openMenuBarButtonItem {
            openMenuBarButtonItem.target = self.revealViewController()
            openMenuBarButtonItem.action = #selector(SWRevealViewController.revealToggle(_:))
        }
        
        view.addGestureRecognizer(self.revealViewController()!.panGestureRecognizer())
        view.addGestureRecognizer(self.revealViewController()!.tapGestureRecognizer())
        
        self.userPublicProfileDidChange()
        UserModel.notificationCenter.addObserver(
            forName: .NewPaceUserAuthData,
            object: nil,
            queue: OperationQueue.main,
            using: self.userPublicProfileDidChange
        )
        
        self.paceUserUniversityDataDidChanged()
        UserModel.notificationCenter.addObserver(
            forName: .PaceUserUniversityDataDidChanged,
            object: nil,
            queue: OperationQueue.main,
            using: self.paceUserUniversityDataDidChanged
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
    
    
    func paceUserUniversityDataDidChanged(_ : Notification? = nil) {
        
        if let navCon = self.navigationController {
            navCon.navigationBar.barTintColor = nil
            navCon.navigationBar.tintColor = self.view.tintColor
            navCon.navigationBar.titleTextAttributes
                = [NSAttributedString.Key.foregroundColor: UIColor.darkText]
            if #available(iOS 11.0, *) {
                navCon.navigationBar.largeTitleTextAttributes
                    = [NSAttributedString.Key.foregroundColor: UIColor.darkText]
            }
        }
        
        if let paceUser = UserModel.sharedInstance(), let userSchoolProfile = paceUser.schoolProfile() {
            userSchoolProfile.getUniversityModel() { university, _ in
                
                guard let university = university else {
                    return
                }
                
                if let navCon = self.navigationController,
                    let primaryColor = university.primaryColor,
                    let accentColor = university.accentColor,
                    let textColor = university.textColor {
                    navCon.navigationBar.barTintColor = primaryColor
                    navCon.navigationBar.tintColor = accentColor
                    navCon.navigationBar.titleTextAttributes
                        = [NSAttributedString.Key.foregroundColor: textColor]
                    if #available(iOS 11.0, *) {
                        navCon.navigationBar.largeTitleTextAttributes
                            = [NSAttributedString.Key.foregroundColor: textColor]
                    }
                    
                }
                
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prepare for segue")
    }
}
