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
    @IBOutlet weak var signInView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.OpenMenuBarButtonItem.target = self.revealViewController()
        self.OpenMenuBarButtonItem.action = #selector(SWRevealViewController.revealToggle(_:))
        
        view.addGestureRecognizer(self.revealViewController()!.panGestureRecognizer())
        view.addGestureRecognizer(self.revealViewController()!.tapGestureRecognizer())
    }
}
