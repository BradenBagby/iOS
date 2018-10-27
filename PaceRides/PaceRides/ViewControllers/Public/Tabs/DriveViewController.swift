//
//  DriveViewController.swift
//  PaceRides
//
//  Created by Grant Broadwater on 10/9/18.
//  Copyright © 2018 PaceRides. All rights reserved.
//

import UIKit

class DriveViewController: PaceTabViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad(self.view)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.setRearGestureRecognizer()
    }
}

