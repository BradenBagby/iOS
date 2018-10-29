//
//  OrganizationMemberViewController.swift
//  PaceRides
//
//  Created by Grant Broadwater on 10/12/18.
//  Copyright © 2018 PaceRides. All rights reserved.
//

import UIKit

class OrganizationMemberViewController: UIViewController {

    var organization: OrganizationModel!
    
    @IBOutlet weak var btnCopyLink: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func copyLinkButtonPressed() {
        UIPasteboard.general.string = self.organization.link
        self.btnCopyLink.setTitle("✔️ Link Copied!", for: .normal)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.btnCopyLink.setTitle("Copy Link", for: .normal)
        }
    }
    
    
    @IBAction func leaveOrganizationButtonPressed() {
        guard let paceUser = UserModel.sharedInstance() else {
            return
        }
        
        let actionSheet = UIAlertController(
            title: "Leave Organization",
            message: "Are you sure you want to leave this organization?",
            preferredStyle: .actionSheet
        )
        
        actionSheet.addAction(UIAlertAction(
            title: "Leave Organization",
            style: .destructive
            ) { _ in
        
            self.organization.removeMember(uid: paceUser.uid) { error in
                
                guard error == nil else {
                    print(error!.localizedDescription)
                    return
                }
                
                paceUser.removeFromOrganizationList(organization: self.organization) { error in
                    
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                }
            }
        })
        
        actionSheet.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil
        ))
        
        self.present(actionSheet, animated: true)
    }
}
