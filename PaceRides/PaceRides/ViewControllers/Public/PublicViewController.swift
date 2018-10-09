//
//  PublicViewController.swift
//  PaceRides
//
//  Created by Grant Broadwater on 9/30/18.
//  Copyright © 2018 PaceRides. All rights reserved.
//

import UIKit

class PublicViewController: FrontViewController {
    
    @IBOutlet weak var publicTabBarControllerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.userPublicProfileDidChange()
        UserModel.notificationCenter.addObserver(
            forName: .NewPaceUserData,
            object: nil,
            queue: OperationQueue.main,
            using: self.userPublicProfileDidChange
        )
        
    }
    
    func userPublicProfileDidChange(_: Notification? = nil) {
        
        if let paceUser = UserModel.sharedInstance(), let paceUserPublicProfile = paceUser.publicProfile() {
            
            // Fetch the profile picture for future use
            paceUserPublicProfile.getProfilePicture(completion: nil)
            
            self.signInView.isHidden = true
            self.publicTabBarControllerView.isHidden = false
        } else {
            self.signInView.isHidden = false
            self.publicTabBarControllerView.isHidden = true
        }
        
    }

}

extension PublicViewController: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print("Selected item \(item.title ?? "No title")")
    }
}
