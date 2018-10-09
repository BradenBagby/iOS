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
    @IBOutlet weak var signOutButton: UIButton!
    
    var profileCellPlaceholders = [ProfileCellType]()
    
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
            forName: .NewPaceUserAuthData,
            object: nil,
            queue: OperationQueue.main,
            using: self.userProfileDataChanged
        )
        
        self.paceUserUniversityDataDidChanged()
        UserModel.notificationCenter.addObserver(
            forName: .PaceUserUniversityDataDidChanged,
            object: nil,
            queue: OperationQueue.main,
            using: self.paceUserUniversityDataDidChanged
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
                        // TODO: Handle nil profile picture
                        // Note: Might already be a valid image in profileImageView
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
                
            } else if let userSchoolProfile = paceUser.schoolProfile() {
                self.nameLabel.text = userSchoolProfile.email ?? "Error"
            } else {
                // Signed in, but no public or school profile
            }
            
        } else {
            self.profileImageView.image = UIImage(named: "profileIcon")
            self.nameLabel.text = "Sign in"
        }
    }
    
    func paceUserUniversityDataDidChanged(_: Notification? = nil) {
        if let pU = UserModel.sharedInstance(), let userSchoolProfile = pU.schoolProfile() {
            userSchoolProfile.getUniversityModel() { university, error in
                
                guard error == nil else {
                    return
                }
                
                guard let university = university else {
                    return
                }
                
                if let primaryColor = university.primaryColor,
                        let textColor = university.textColor {
                    self.view.backgroundColor = primaryColor
                    
                    self.tableView.backgroundColor = primaryColor
                    self.nameLabel.textColor = textColor
                    self.signOutButton.setTitleColor(textColor, for: .normal)
                }
            }
        }
    }
    
    @IBAction func signOutButtonPressed() {
        if let paceUser = UserModel.sharedInstance() {
            if let err = paceUser.signOut() {
                print(err.localizedDescription)
            }
        }
    }
}


enum ProfileCellType {
    case Basic
    case PublicProfile
    case SchoolProfile
}


extension RightViewController: UITableViewDelegate {
    
}


extension RightViewController: UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        self.profileCellPlaceholders.removeAll()
        
        if let paceUser = UserModel.sharedInstance() {
            if let _ = paceUser.publicProfile() {
                profileCellPlaceholders.append(.PublicProfile)
            }
            
            if let _ = paceUser.schoolProfile() {
                profileCellPlaceholders.append(.SchoolProfile)
            }
        }
        
        return self.profileCellPlaceholders.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch self.profileCellPlaceholders[indexPath.row] {
        case .Basic:
            
            let basicCell = tableView.dequeueReusableCell(withIdentifier: "default_cell", for: indexPath)
            basicCell.textLabel!.text = "Error"
            return basicCell
            
        case .PublicProfile:
            
            let publicCell = tableView.dequeueReusableCell(
                withIdentifier: "PacePublicProfileTableViewCell",
                for: indexPath
            ) as! PacePublicProfileTableViewCell
            
            publicCell.userPublicProfile = UserModel.sharedInstance()!.publicProfile()
            
            return publicCell
            
        case .SchoolProfile:
            
            let schoolCell = tableView.dequeueReusableCell(
                withIdentifier: "PaceSchoolProfileTableViewCell",
                for: indexPath
                ) as! PaceSchoolProfileTableViewCell
            
            schoolCell.userSchoolProfile = UserModel.sharedInstance()!.schoolProfile()
            
            return schoolCell
        }
    }
}
