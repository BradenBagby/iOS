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
    private var _userIsAdmin = false
    private var _userIsMember = false
    
    @IBOutlet weak var primaryLabel: UILabel!
    @IBOutlet weak var memberView: UIView!
    @IBOutlet weak var externalView: UIView!
    
    
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
        
        self._userIsAdmin = false
        self._userIsMember = false
        if let orgAdmin = self.organizationModel.administrators {
            for admin in orgAdmin {
                if paceUser.uid == admin.uid {
                    self._userIsAdmin = true
                    break
                }
            }
        }
        
        if !_userIsAdmin {
            // TODO: Check for member
        }
        
        self.updateUI()
    }
    
    func updateUI() {
        
        if self._userIsAdmin {
         
            self.externalView.isHidden = true
            self.memberView.isHidden = true
            
            
            
        } else if self._userIsMember {
            
            self.externalView.isHidden = true
            self.memberView.isHidden = false
            
        } else {
            
            self.externalView.isHidden = false
            self.memberView.isHidden = true
            
        }
    }
}
