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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        UserModel.notificationCenter.addObserver(
            forName: .NewPaceUserData,
            object: nil,
            queue: OperationQueue.main,
            using: self.userProfileDataChanged
        )
        
        profileImageView.layer.borderWidth = 1
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.clipsToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        var userDisplayName: String? = nil
        
        if let paceUser = UserModel.sharedInstance() {
            if let paceUserPublicProfile = paceUser.publicProfile() {
                if let userProfileImageUrl = paceUserPublicProfile.photoUrl {
                    getData(from: userProfileImageUrl) { data, response, error in
                        
                        guard error == nil else {
                            print(error!.localizedDescription)
                            return
                        }
                        
                        guard let data = data else {
                            print("No data returned from image url")
                            return
                        }
                        
                        DispatchQueue.main.async {
                            self.profileImageView.image = UIImage(data: data)
                        }
                    }
                }
            
                if let userPublicDisplayName = paceUserPublicProfile.displayName {
                    userDisplayName = userPublicDisplayName
                }
                
                if userDisplayName == nil,
                    let userSchoolProfile = paceUser.schoolProfile(),
                    let userSchoolDisplayName = userSchoolProfile.displayName {
                    userDisplayName = userSchoolDisplayName
                }
            }
        }
        
        
        
        self.nameLabel.text = userDisplayName
    }
    
    func userProfileDataChanged(_: Notification? = nil) {
        self.tableView.reloadData()
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
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
