//
//  PublicViewController.swift
//  PaceRides
//
//  Created by Grant Broadwater on 9/30/18.
//  Copyright © 2018 PaceRides. All rights reserved.
//

import UIKit
import Firebase

class PublicViewController: UIViewController {

    @IBOutlet weak var TitleLabel: UILabel!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db.collection("data").document("author").getDocument { (document, error) in
            
            if let document = document, document.exists {
                if let data = document.data(), let name = data["name"] as? String {
                    self.TitleLabel.text = name
                }
            }
            
        }
    }

}
