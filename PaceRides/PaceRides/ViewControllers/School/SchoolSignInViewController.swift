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
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
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
            
            self.emailTextField.isEnabled = false
            self.passwordTextField.isEnabled = false
            self.loadingIndicator.isHidden = false
            self.loadingIndicator.startAnimating()
            UserModel.createUser(fromEmail: emailText, andPassword: passwordText) { paceUser, error in
                
                self.emailTextField.isEnabled = true
                self.passwordTextField.isEnabled = true
                self.passwordTextField.text = ""
                self.loadingIndicator.stopAnimating()
                
                guard error == nil else {
                    // TODO: Handle
                    print("Error creating user from email")
                    print(error!.localizedDescription)
                    return
                }
                
                if let paceUser = paceUser, let userSchoolProfile = paceUser.schoolProfile() {
                    
                    // Check if verification email needs to be sent
                    if !userSchoolProfile.isEmailVerified {
                        userSchoolProfile.sendEmailVerification(completion: nil)
                    }
                    
                    // Indicate that pace user auth data has changed
                    UserModel.notificationCenter.post(
                        name: .NewPaceUserAuthData,
                        object: nil
                    )
                    
                } else {
                    
                }
                
            }
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
