//
//  PublicViewController.swift
//  PaceRides
//
//  Created by Grant Broadwater on 9/30/18.
//  Copyright © 2018 PaceRides. All rights reserved.
//

import UIKit

class PublicViewController: UIViewController {
    
    @IBOutlet weak var OpenMenuBarButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.OpenMenuBarButtonItem.target = self.revealViewController()
        self.OpenMenuBarButtonItem.action = #selector(SWRevealViewController.revealToggle(_:))
        
        view.addGestureRecognizer(self.revealViewController()!.panGestureRecognizer())
        view.addGestureRecognizer(self.revealViewController()!.tapGestureRecognizer())
    }

}
