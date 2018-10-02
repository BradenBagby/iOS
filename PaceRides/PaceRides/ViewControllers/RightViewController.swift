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

        UserModel.sharedInstance.notificationCenter.addObserver(
            forName: .UserPublicProfileDidChange,
            object: UserModel.sharedInstance,
            queue: OperationQueue.main,
            using: self.userProfileDataChanged
        )
        
        UserModel.sharedInstance.notificationCenter.addObserver(
            forName: .UserSchoolProfileDidChange,
            object: UserModel.sharedInstance,
            queue: OperationQueue.main,
            using: self.userProfileDataChanged
        )
        
        var userDisplayName: String? = nil
        
        if let userPublicProfile = UserModel.sharedInstance.publicProfile {
            if let userProfileImageUrl = userPublicProfile.photoUrl {
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
            
            if let userPublicDisplayName = userPublicProfile.displayName {
                userDisplayName = userPublicDisplayName
            }
        }
        
        if userDisplayName == nil,
            let userSchoolProfile = UserModel.sharedInstance.schoolProfile,
            let userSchoolDisplayName = userSchoolProfile.displayName {
            userDisplayName = userSchoolDisplayName
        }
        
        self.nameLabel.text = userDisplayName
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let _ = Auth.auth().currentUser {
            print("current user exists")
        } else {
            print("No current user")
        }
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
        
        if let _ = UserModel.sharedInstance.publicProfile {
            totalCount += 1
        }
        
        if let _ = UserModel.sharedInstance.schoolProfile {
            totalCount += 1
        }
        
        return totalCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let defaultCell = tableView.dequeueReusableCell(withIdentifier: "default_cell", for: indexPath)
        
        if indexPath.row == 0 {
            
            if let userPublicProfile = UserModel.sharedInstance.publicProfile {
                defaultCell.textLabel!.text = userPublicProfile.displayName
                    ?? userPublicProfile.providerId
                    ?? userPublicProfile.uid
            } else if let userSchoolProfile = UserModel.sharedInstance.schoolProfile {
                defaultCell.textLabel!.text = userSchoolProfile.providerId
                    ?? "Email not verified"
            } else {
                print("Error")
            }
            
        } else if indexPath.row == 1 {
            if let userSchoolProfile = UserModel.sharedInstance.schoolProfile {
                defaultCell.textLabel!.text = userSchoolProfile.providerId
                    ?? "Email not verified"
            } else {
                print("Error")
            }
        }
        
        return defaultCell
    }
    
    
}
