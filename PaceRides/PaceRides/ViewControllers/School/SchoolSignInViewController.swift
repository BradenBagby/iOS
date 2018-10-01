//
//  SchoolSignInViewController.swift
//  PaceRides
//
//  Created by Grant Broadwater on 10/1/18.
//  Copyright © 2018 PaceRides. All rights reserved.
//

import UIKit

class SchoolSignInViewController: UIViewController {
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func submitButtonPressed() {
        
        self.emailTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
        
        if let emailText = self.emailTextField.text, let passwordText = self.passwordTextField.text {
            
            if !emailText.contains("@") || !emailText.contains(".") {
                emailLabel.text = "Please enter your valid school email:"
                emailLabel.textColor = .red
                return
            } else {
                emailLabel.text = "School email:"
                emailLabel.textColor = .black
            }
            
            if passwordText.isEmpty {
                passwordLabel.text = "Enter a password:"
                passwordLabel.textColor = .red
                return
            } else {
                passwordLabel.text = "Password:"
                passwordLabel.textColor = .black
            }
            
            UserModel.sharedInstance.signIn(withEmail: emailText, andPassword: passwordText)
        }
    }
}

extension SchoolSignInViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == self.emailTextField {
            self.passwordTextField.resignFirstResponder()
        } else if textField == self.passwordTextField {
            self.submitButtonPressed()
        }
        
        return false
    }
    
}
