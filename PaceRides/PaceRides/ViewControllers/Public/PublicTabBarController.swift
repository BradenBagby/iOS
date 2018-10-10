//
//  PublicTabBarController.swift
//  PaceRides
//
//  Created by Grant Broadwater on 10/9/18.
//  Copyright © 2018 PaceRides. All rights reserved.
//

import UIKit

class PublicTabBarController: UITabBarController {

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
        
        self.paceUserUniversityDataDidChange()
        UserModel.notificationCenter.addObserver(
            forName: .PaceUserUniversityDataDidChanged,
            object: nil,
            queue: OperationQueue.main,
            using: self.paceUserUniversityDataDidChange
        )
    }
    
    func userPublicProfileDidChange(_: Notification? = nil) {
        
        if let paceUser = UserModel.sharedInstance(), let _ = paceUser.publicProfile() {
            
        } else {
            self.performSegue(withIdentifier: "showSignIn", sender: self)
        }
        
    }
    
    func paceUserUniversityDataDidChange(_ : Notification? = nil) {
        
        self.tabBar.backgroundColor = nil
        self.tabBar.barTintColor = nil
        
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
                
                if let primaryColor = university.primaryColor,
                    let accentColor = university.accentColor,
                    let unselectedColor = university.unselectedColor,
                    let textColor = university.textColor {
                    
                    self.tabBar.barTintColor = primaryColor
                    self.tabBar.tintColor = accentColor
                    if #available(iOS 10.0, *) {
                        self.tabBar.unselectedItemTintColor = unselectedColor
                    }
                    
                    if let navCon = self.navigationController {
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
    }
}
