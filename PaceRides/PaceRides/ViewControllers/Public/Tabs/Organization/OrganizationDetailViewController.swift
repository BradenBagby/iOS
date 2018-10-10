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
        
        self.title = self.organizationModel.title
        print("Subscription: \(self.organizationModel.subscription ?? -1)")
        
    }
}
