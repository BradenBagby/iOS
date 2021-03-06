//
//  ViewController.swift
//  PaceRides
//
//  Created by Grant Broadwater on 10/9/18.
//  Copyright © 2018 PaceRides. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func setAsRearNavigationItem(_ openMenuBarButtonItem: UIBarButtonItem?, forView view: UIView) {
     
        self.revealViewController()!.rearViewRevealWidth = 300
        if let openMenuBarButtonItem = openMenuBarButtonItem {
            openMenuBarButtonItem.target = self.revealViewController()
            openMenuBarButtonItem.action = #selector(SWRevealViewController.revealToggle(_:))
        }
        
        self.setRearGestureRecognizer()
    }
    
    func setRearGestureRecognizer() {
        
        if let revealVC = self.revealViewController() {
            self.view.addGestureRecognizer(revealVC.panGestureRecognizer())
            self.view.addGestureRecognizer(revealVC.tapGestureRecognizer())
        }
        
    }
    
    func setNavigationBarColors(_: Notification? = nil) {
        
        if let navCon = self.navigationController {
            navCon.navigationBar.barTintColor = .tiffanyBlue
            navCon.navigationBar.tintColor = .coral
            navCon.navigationBar.titleTextAttributes
                = [NSAttributedString.Key.foregroundColor: UIColor.white]
            if #available(iOS 11.0, *) {
                navCon.navigationBar.largeTitleTextAttributes
                    = [NSAttributedString.Key.foregroundColor: UIColor.white]
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
    
    func appDelegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
}
