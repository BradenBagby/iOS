//
//  RightViewController.swift
//  PaceRides
//
//  Created by Grant Broadwater on 10/1/18.
//  Copyright © 2018 PaceRides. All rights reserved.
//

import UIKit
import Firebase

class RightViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Make image view round
        profileImageView.layer.borderWidth = 1
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.clipsToBounds = true
        
        // Update view when new data availible
        userProfileDataChanged()
        UserModel.notificationCenter.addObserver(
            forName: .NewPaceUserData,
            object: nil,
            queue: OperationQueue.main,
            using: self.userProfileDataChanged
        )
    }
    
    func userProfileDataChanged(_: Notification? = nil) {
        
        // Reload table view
        self.tableView.reloadData()
        
        // If there is a user
        if let paceUser = UserModel.sharedInstance() {
            
            // If the user has a public profile
            if let userPublicProfile = paceUser.publicProfile() {
                
                // Attempt to retrieve the user's profile picture
                self.loadingIndicator.isHidden = false
                self.loadingIndicator.startAnimating()
                userPublicProfile.getProfilePicture() { userProfilePicture, _ in
                    self.loadingIndicator.stopAnimating()
                    if let userProfilePicture = userProfilePicture {
                        self.profileImageView.image = userProfilePicture
                    } else {
                        // TODO: Handle
                    }
                }
                
                // Set the title to the user's name
                if let displayName = userPublicProfile.displayName {
                    self.nameLabel.text = displayName
                } else if let userSchoolProfile = paceUser.schoolProfile() {
                    self.nameLabel.text = userSchoolProfile.email
                } else if let fbId = userPublicProfile.facebookId {
                    self.nameLabel.text = fbId
                } else {
                    self.nameLabel.text = "Error"
                }
                
            } else {
                // TODO: Handle if no public profile
            }
            
        } else {
            // TODO: Handle if no user signed in
        }
    }
}

extension RightViewController: UITableViewDelegate {
    
}

extension RightViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var totalCount = 0
        
        if let paceUser = UserModel.sharedInstance() {
            if let _ = paceUser.publicProfile() {
                totalCount += 1
            }
            
            if let _ = paceUser.schoolProfile() {
                totalCount += 1
            }
        }
        
        return totalCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let defaultCell = tableView.dequeueReusableCell(withIdentifier: "default_cell", for: indexPath)
        
        if indexPath.row == 0 {
            
            if let paceUser = UserModel.sharedInstance() {
                if let userPublicProfile = paceUser.publicProfile() {
                    defaultCell.textLabel!.text = userPublicProfile.displayName
                        ?? userPublicProfile.facebookId
                        ?? userPublicProfile.uid
                } else if let userSchoolProfile = paceUser.schoolProfile() {
                    defaultCell.textLabel!.text
                        = (userSchoolProfile.isEmailVerified ? userSchoolProfile.email : "Email not verified")
                } else {
                    print("Error")
                    defaultCell.textLabel!.text = "Error"
                }
            }
            
        } else if indexPath.row == 1 {
            if let paceUser = UserModel.sharedInstance(), let userSchoolProfile = paceUser.schoolProfile() {
                defaultCell.textLabel!.text
                    = userSchoolProfile.email
                    ?? "Email error"
            } else {
                print("Error")
                defaultCell.textLabel!.text = "Error"
            }
        }
        
        return defaultCell
    }
    
    
}
