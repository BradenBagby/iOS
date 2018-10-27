//
//  EULAViewController.swift
//  PaceRides
//
//  Created by Grant Broadwater on 10/22/18.
//  Copyright © 2018 PaceRides. All rights reserved.
//

import UIKit
import Firebase

class EULAViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    var eulaText: String!
    
    override func viewDidLoad() {
        self.textView.text = eulaText
    }
    
    @IBAction func acceptButtonPressed() {
        
        let seconds = Timestamp().seconds
        
        UserDefaults.standard.set(
            NSNumber(value: seconds),
            forKey: UserDefaultsKeys.EULAAgreementSeconds.rawValue
        )
        
        self.performSegue(withIdentifier: "startApplication", sender: self)
    }
    
}
