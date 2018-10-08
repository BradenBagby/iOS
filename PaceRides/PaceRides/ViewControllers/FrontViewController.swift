//
//  FrontViewController.swift
//  PaceRides
//
//  Created by Grant Broadwater on 10/1/18.
//  Copyright © 2018 PaceRides. All rights reserved.
//

import UIKit

class FrontViewController: UIViewController {

    @IBOutlet weak var OpenMenuBarButtonItem: UIBarButtonItem!
    @IBOutlet var profileBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var signInView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.revealViewController()!.rightViewRevealWidth = 250
        self.OpenMenuBarButtonItem.target = self.revealViewController()
        self.OpenMenuBarButtonItem.action = #selector(SWRevealViewController.revealToggle(_:))
        
        self.profileBarButtonItem.target = self.revealViewController()
        self.profileBarButtonItem.action = #selector(SWRevealViewController.rightRevealToggle(_:))
        
        view.addGestureRecognizer(self.revealViewController()!.panGestureRecognizer())
        view.addGestureRecognizer(self.revealViewController()!.tapGestureRecognizer())
        
        self.paceUserUniversityDataDidChanged()
        UserModel.notificationCenter.addObserver(
            forName: .PaceUserUniversityDataDidChanged,
            object: nil,
            queue: OperationQueue.main,
            using: self.paceUserUniversityDataDidChanged
        )
    }
    
    func paceUserUniversityDataDidChanged(_ : Notification? = nil) {
        if let paceUser = UserModel.sharedInstance(), let userSchoolProfile = paceUser.schoolProfile() {
            userSchoolProfile.getUniversityModel() { university, _ in
                
                guard let university = university else {
                    return
                }
                
                print("University shorthand: \(university.shorthand ?? "No Shorthand")")
                
            }
            
        }
    }
}
