//
//  OrganizationExternalViewController.swift
//  PaceRides
//
//  Created by Grant Broadwater on 10/12/18.
//  Copyright © 2018 PaceRides. All rights reserved.
//

import UIKit

class OrganizationExternalViewController: UIViewController {

    var organization: OrganizationModel!
    
    private var userHasRequestedMembership = false
    
    @IBOutlet weak var btnRequestMember: UIButton!
    private enum RequsetButtonTitles: String {
        case NoRequest = "Request to Be a Member"
        case Sending = "Sending..."
        case Error = "Error!"
        case CancelRequest = "Cancel Membership Request"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.newOrganizationData()
        OrganizationModel.notificationCenter.addObserver(
            forName: OrganizationModel.NewData,
            object: self.organization,
            queue: OperationQueue.main,
            using: self.newOrganizationData
        )
        
    }
    
    
    func newOrganizationData(_: Notification? = nil) {
        
        self.userHasRequestedMembership = false
        if let paceUser = UserModel.sharedInstance() {
            if let membershipRequest = self.organization.membershipRequests {
                for request in membershipRequest {
                    if request.uid == paceUser.uid {
                        self.userHasRequestedMembership = true
                        break
                    }
                }
            }
        }
        
        self.updateUI()
        
    }
    
    func updateUI() {
        
        if !userHasRequestedMembership {
            self.btnRequestMember.setTitle(RequsetButtonTitles.NoRequest.rawValue, for: .normal)
            self.btnRequestMember.setTitleColor(nil, for: .normal)
        } else {
            self.btnRequestMember.setTitle(RequsetButtonTitles.CancelRequest.rawValue, for: .normal)
            self.btnRequestMember.setTitleColor(.red, for: .normal)
        }
        
    }
    
    
    @IBAction func requestMemberButtonPressed() {
        
        if let paceUser = UserModel.sharedInstance(), let userPublicProfile = paceUser.publicProfile() {
            
            if !self.userHasRequestedMembership {
                
                self.btnRequestMember.setTitle(RequsetButtonTitles.Sending.rawValue, for: .normal)
                self.organization.requestMember(userPublicProfile) { error in
                    
                    guard error == nil else {
                        
                        print("Error requesting membership.")
                        print(error!.localizedDescription)
                        self.btnRequestMember.setTitle(RequsetButtonTitles.Error.rawValue, for: .normal)
                        
                        return
                    }
                }
                
            } else {
                
                self.btnRequestMember.setTitle(RequsetButtonTitles.Sending.rawValue, for: .normal)
                self.organization.cancelRequest(userPublicProfile) { error in
                    
                    guard error == nil else {
                        
                        print("Error canceling membership request.")
                        print(error!.localizedDescription)
                        self.btnRequestMember.setTitle(RequsetButtonTitles.Error.rawValue, for: .normal)
                        
                        return
                    }
                }
                
            }
        }
    }
}
