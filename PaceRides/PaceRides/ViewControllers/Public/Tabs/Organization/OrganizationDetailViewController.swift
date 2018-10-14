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
    @IBOutlet weak var btnCopyLink: UIButton!
    @IBOutlet weak var btnManageMembers: UIButton!
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = self.organizationModel.title ?? self.organizationModel.uid
        
        OrganizationModel.notificationCenter.addObserver(
            forName: OrganizationModel.NewMemberData,
            object: self.organizationModel,
            queue: OperationQueue.main,
            using: self.newOrganizationMemberData
        )
        self.organizationModel.subscribe(using: self.newOrganizationData)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "externalEmbed" {
            if let destVC = segue.destination as? OrganizationExternalViewController {
                destVC.organization = self.organizationModel
            } else {
                print("destVC not OrgExtVC")
            }
        } else if segue.identifier == "memberEmbed" {
            if let destVC = segue.destination as? OrganizationMemberViewController {
                destVC.organization = self.organizationModel
            } else {
                print("DestVC not OrganizationMemberVC")
            }
        } else if segue.identifier == "showOrganizationMembers" {
            if let destVC = segue.destination as? OrganizationMembersTableViewController {
                destVC.organization = self.organizationModel
            } else {
                print("destVC not OrgMemberVC")
            }
        }
    }
    
    
    func newOrganizationData(_: Notification? = nil) {
        
        guard let paceUser = UserModel.sharedInstance() else {
            print("No user")
            return
        }
        
        self.title = self.organizationModel.title
        self.primaryLabel.text = self.organizationModel.title
        
        self._userIsAdmin = false
        self._userIsMember = false
        for admin in self.organizationModel.administrators {
            if paceUser.uid == admin.uid {
                self._userIsAdmin = true
                break
            }
        }
        
        if !_userIsAdmin {
            for member in organizationModel.members {
                if paceUser.uid == member.uid {
                    self._userIsMember = true
                    break
                }
            }
        }
        
        self.updateUI()
    }
    
    
    func newOrganizationMemberData(_: Notification? = nil) {
        
        guard let paceUser = UserModel.sharedInstance() else {
            return
        }
        
        self.newOrganizationData()
        
        if self.organizationModel.administrators.count > 0 && !_userIsAdmin && !_userIsMember {
            paceUser.removeFromOrganizationList(organization: self.organizationModel) { error in
                guard error == nil else {
                    print(error!.localizedDescription)
                    return
                }
            }
            return
        }
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
    
    @IBAction func copyLinkButtonPressed() {
        UIPasteboard.general.string = self.organizationModel.link
        self.btnCopyLink.setTitle("✔️ Link Copied!", for: .normal)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.btnCopyLink.setTitle("Copy Link", for: .normal)
        }
    }
    
    
    @IBAction func manageMembersButtonPressed() {
        self.performSegue(withIdentifier: "showOrganizationMembers", sender: self)
    }
}
