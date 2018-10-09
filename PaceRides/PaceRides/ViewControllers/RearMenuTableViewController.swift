//
//  RearMenuTableViewController.swift
//  PaceRides
//
//  Created by Grant Broadwater on 9/30/18.
//  Copyright © 2018 PaceRides. All rights reserved.
//

import UIKit


class RearMenuTableViewController: UIViewController {

    var menuItems: [[MenuItem]] = [
        [
            MenuItem(
                withText: "Public",
                andAccessoryType: UITableViewCell.AccessoryType.disclosureIndicator
            ),
            MenuItem(
                withText: "School",
                andAccessoryType: UITableViewCell.AccessoryType.disclosureIndicator
            )
        ],
        []
    ]
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var signOutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.headerLabel.text = APPLICATION_TITLE
        
        // Make image view round
        profileImageView.layer.borderWidth = 1
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.clipsToBounds = true
        
        self.newPaceUserData()
        UserModel.notificationCenter.addObserver(
            forName: .NewPaceUserData,
            object: nil,
            queue: OperationQueue.main,
            using: self.newPaceUserData
        )
        
        self.paceUserUniversityDataDidChanged()
        UserModel.notificationCenter.addObserver(
            forName: .PaceUserUniversityDataDidChanged,
            object: nil,
            queue: OperationQueue.main,
            using: self.paceUserUniversityDataDidChanged
        )
    }
    
    func newPaceUserData(_: Notification? = nil) {
        
        self.menuItems[1].removeAll()
        self.headerLabel.text = APPLICATION_TITLE
        self.profileImageView.image = UIImage(named: "profileIcon")
        
        if let paceUser = UserModel.sharedInstance() {
            
            self.signOutButton.isHidden = false
            
            if let userPublicProfile = paceUser.publicProfile() {
                
                userPublicProfile.getProfilePicture() { userProfilePicture, _ in
                    
                    if let userProfilePicture = userProfilePicture {
                        self.profileImageView.image = userProfilePicture
                    } else {
                        // TODO: Handle nil profile picture
                        // Note: Might already be a valid image in profileImageView
                    }
                }
                
                if let displayName = userPublicProfile.displayName {
                    self.headerLabel.text = displayName
                } else if let userSchoolProfile = paceUser.schoolProfile() {
                    self.headerLabel.text = userSchoolProfile.email ?? "Error"
                } else {
                    self.headerLabel.text = "Error"
                }
                
                self.menuItems[1].append(
                    MenuItem(
                        withText: userPublicProfile.displayName ?? "Error",
                        andImage: UIImage(named: "facebookIcon")!
                    )
                )
            }
            
            if let userSchoolProfile = paceUser.schoolProfile() {
                self.menuItems[1].append(
                    MenuItem(
                        withText: userSchoolProfile.email ?? "Error",
                        andImage: UIImage(named: "emailIcon")!
                    )
                )
            }
            
        } else {
            self.signOutButton.isHidden = true
        }
        
        self.tableView.reloadData()
    }
    
    func paceUserUniversityDataDidChanged(_: Notification? = nil) {
        
        // TODO: reset
        self.menuItems[0][1].text = "School"
        self.view.backgroundColor = UIColor.groupTableViewBackground
        self.tableView.backgroundColor = UIColor.groupTableViewBackground
        self.profileImageView.layer.borderColor = UIColor.white.cgColor
        self.headerLabel.textColor = UIColor.darkText
        self.signOutButton.setTitleColor(self.view.tintColor, for: .normal)
        
        if let pU = UserModel.sharedInstance(), let userSchoolProfile = pU.schoolProfile() {
            userSchoolProfile.getUniversityModel() { university, error in
                
                guard error == nil else {
                    return
                }
                
                
                guard let university = university else {
                    return
                }
                
                if let primaryColor = university.primaryColor,
                    let accentColor = university.accentColor,
                    let textColor = university.textColor {
                    
                    self.view.backgroundColor = primaryColor
                    self.tableView.backgroundColor = primaryColor
                    self.profileImageView.layer.borderColor = accentColor.cgColor
                    self.headerLabel.textColor = textColor
                    self.signOutButton.setTitleColor(accentColor, for: .normal)
                    
                }
                
                if let universityShorthand = university.shorthand {
                    self.menuItems[0][1].text = universityShorthand
                    self.tableView.reloadData()
                }
            }
        }
        
        self.tableView.reloadData()
    }
    
    @IBAction func signOutButtonWasPressed() {
        if let paceUser = UserModel.sharedInstance() {
            if let err = paceUser.signOut() {
                print(err.localizedDescription)
            }
        }
    }
    
}

extension RearMenuTableViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.menuItems.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menuItems[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(
            withIdentifier: "MenuItemTableViewCell",
            for: indexPath
            ) as? MenuItemTableViewCell {
            
            cell.menuItem = self.menuItems[indexPath.section][indexPath.row]
            
            return cell
        } else {
            let default_cell = tableView.dequeueReusableCell(withIdentifier: "default_cell", for: indexPath)
            default_cell.textLabel?.text = "Error"
            return default_cell
        }
    }
    
}

extension RearMenuTableViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                self.performSegue(withIdentifier: "showPublic", sender: self)
            } else if indexPath.row == 1 {
                self.performSegue(withIdentifier: "showSchool", sender: self)
            }
        }
        
    }
}
