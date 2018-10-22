//
//  EULAViewController.swift
//  PaceRides
//
//  Created by Grant Broadwater on 10/22/18.
//  Copyright © 2018 PaceRides. All rights reserved.
//

import UIKit

class EULAViewController: UIViewController {

    @IBAction func acceptButtonPressed() {
        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.UserAcceptedEULA.rawValue)
        self.performSegue(withIdentifier: "startApplication", sender: self)
    }
    
}
