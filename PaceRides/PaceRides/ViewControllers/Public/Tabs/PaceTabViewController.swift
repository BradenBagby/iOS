//
//  PublicTabViewController.swift
//  PaceRides
//
//  Created by Grant Broadwater on 10/9/18.
//  Copyright © 2018 PaceRides. All rights reserved.
//

import UIKit

class PaceTabViewController: UIViewController {
    
    @IBOutlet weak var openMenuBarButtonItem: UIBarButtonItem!
    
    func viewDidLoad(_ view: UIView) {
        super.viewDidLoad()
        
        self.setAsRearNavigationItem(self.openMenuBarButtonItem, forView: view)
        
        self.setNavigationBarColors()
        UserModel.notificationCenter.addObserver(
            forName: .PaceUserUniversityDataDidChanged,
            object: nil,
            queue: OperationQueue.main,
            using: self.setNavigationBarColors
        )
        
    }
}
