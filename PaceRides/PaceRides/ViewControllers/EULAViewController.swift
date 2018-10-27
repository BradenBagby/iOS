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
    
    override func viewDidLoad() {
        
        let eulaAgreementSeconds
            = UserDefaults.standard.object(forKey: UserDefaultsKeys.EULAAgreementSeconds.rawValue) as? NSNumber
        
        if let eulaAgreementSeconds = eulaAgreementSeconds, eulaAgreementSeconds.int64Value > 0 {
            
            print(eulaAgreementSeconds.int64Value)
            
            Firestore.firestore().collection(DataDBKeys.data.rawValue)
                .document(DataDBKeys.eula.rawValue).getDocument() { document, error in
                    
                    // TODO: Handle errors
                    guard error == nil else {
                        print(error!.localizedDescription)
                        return
                    }
                    
                    guard let data = document?.data() else {
                        print("No data in eula")
                        return
                    }
                    
                    guard let eulaTimestamp = data[EULADBKeys.timestamp.rawValue] as? Timestamp else {
                        print("No eula text")
                        return
                    }
                    
                    if eulaAgreementSeconds.int64Value > eulaTimestamp.seconds {
                        self.performSegue(withIdentifier: "startApplication", sender: self)
                    }
            }
            
        }
        
        let eulaRef = Firestore.firestore().collection(DataDBKeys.data.rawValue).document(DataDBKeys.eula.rawValue)
        eulaRef.getDocument() { document, error in
            
            // TODO: Handle errors
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            guard let data = document?.data() else {
                print("No data in eula")
                return
            }
            
            guard let eulaText = data[EULADBKeys.text.rawValue] as? String else {
                print("No eula text")
                return
            }
            
            self.textView.text = eulaText
        }
    }
    
    @IBAction func acceptButtonPressed() {
        
        UserDefaults.standard.set(
            NSNumber(value: Timestamp().seconds),
            forKey: UserDefaultsKeys.EULAAgreementSeconds.rawValue
        )
        
        self.performSegue(withIdentifier: "startApplication", sender: self)
    }
    
}
