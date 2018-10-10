//
//  OrganizationDetailViewController.swift
//  PaceRides
//
//  Created by Grant Broadwater on 10/10/18.
//  Copyright © 2018 PaceRides. All rights reserved.
//

import UIKit

class OrganizationDetailViewController: UIViewController {

    var organizationModel: OrganizationModel!
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = self.organizationModel.title ?? self.organizationModel.uid
        self.organizationModel.subscribe(using: self.newOrganizationData)
    }
    
    func newOrganizationData(_: Notification? = nil) {
        
        guard let paceUser = UserModel.sharedInstance() else {
            print("No user")
            return
        }
        
        self.title = self.organizationModel.title
        
        if let orgAdmin = self.organizationModel.administrators {
            for admin in orgAdmin {
                if paceUser.uid == admin.uid {
                    print("User is admin")
                    break
                }
            }
        }
        
    }
}
