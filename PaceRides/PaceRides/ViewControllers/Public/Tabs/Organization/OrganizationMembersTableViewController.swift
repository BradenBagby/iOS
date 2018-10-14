//
//  OrganizationMembersTableViewController.swift
//  PaceRides
//
//  Created by Grant Broadwater on 10/12/18.
//  Copyright © 2018 PaceRides. All rights reserved.
//

import UIKit

class OrganizationMembersTableViewController: UITableViewController {

    var organization: OrganizationModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Members"
        
        OrganizationModel.notificationCenter.addObserver(
            forName: OrganizationModel.NewData,
            object: self.organization,
            queue: OperationQueue.main,
            using: self.newOrganizationData
        )
    }
    
    func newOrganizationData(_: Notification? = nil) {
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.organization.administrators.count
        case 1:
            return self.organization.members.count
        case 2:
            return self.organization.membershipRequests.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Administrators"
        case 1:
            return "Members"
        case 2:
            return "Membership Requests"
        default:
            return nil
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "default_cell", for: indexPath)

        cell.textLabel?.textColor = nil
        cell.tintColor = nil
        
        guard let paceUser = UserModel.sharedInstance() else {
            cell.textLabel?.text = "Error"
            return cell
        }
        
        switch indexPath.section {
        case 0:
            let administrators = self.organization.administrators
            if administrators.count > indexPath.row {
                cell.textLabel?.text = administrators[indexPath.row].displayName ?? "Error"
                
                if administrators[indexPath.row].uid == paceUser.uid {
                    cell.textLabel?.textColor = .lightGray
                    cell.tintColor = .lightGray
                }
            }
        case 1:
            if self.organization.members.count > indexPath.row {
                cell.textLabel?.text = self.organization.members[indexPath.row].displayName ?? "Error"
            }
        case 2:
            let membershipRequests = self.organization.membershipRequests
            if membershipRequests.count > indexPath.row {
                cell.textLabel?.text = membershipRequests[indexPath.row].displayName ?? "Error"
            }
        default:
            break
        }

        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let paceUser = UserModel.sharedInstance() else {
            return
        }
        
        let administrators = self.organization.administrators
        let members = self.organization.members
        let memReq = self.organization.membershipRequests
        
        var optionMenu: UIAlertController!
        
        switch indexPath.section {
        case 0:
            
            if paceUser.uid == administrators[indexPath.row].uid {
                let alert = UIAlertController(
                    title: "Error",
                    message: "You cannot remove yourself as an administrator.",
                    preferredStyle: .alert
                )
                alert.addAction(
                    UIAlertAction(
                        title: "Okay",
                        style: .default,
                        handler: nil
                    )
                )
                self.present(alert, animated: true)
                return
            }
            
            optionMenu = UIAlertController(
                title: "Remove",
                message: "Remove \(administrators[indexPath.row].displayName ?? "Error") as an administrator?",
                preferredStyle: .actionSheet
            )
            
            optionMenu.addAction(
                UIAlertAction(
                    title: "Remove",
                    style: .destructive
                ) { alertAction in
                    self.organization.removeAdministrator(administrators[indexPath.row]) { error in
                        
                        if let error = error as NSError? {
                            
                            if error.code == PaceOrganizationErrors.AdminSelfRemoveError.errorCode {
                                let alert = UIAlertController(
                                    title: "Error",
                                    message: "You cannot remove yourself as an administrator.",
                                    preferredStyle: .alert
                                )
                                alert.addAction(
                                    UIAlertAction(
                                        title: "Okay",
                                        style: .default,
                                        handler: nil
                                    )
                                )
                                self.present(alert, animated: true)
                            }
                        }
                    }
                }
            )
            
        case 1:
            
            optionMenu = UIAlertController(
                title: "\(members[indexPath.row].displayName ?? "Error")",
                message: "Manage \(members[indexPath.row].displayName ?? "Error").",
                preferredStyle: .actionSheet
            )
            
            optionMenu.addAction(
                UIAlertAction(
                    title: "Make Administrator",
                    style: .default
                ) { _ in
                    self.organization.makeAdministrator(members[indexPath.row]) { error in
                        if let error = error {
                            print(error.localizedDescription)
                        }
                    }
                }
            )
            
            optionMenu.addAction(
                UIAlertAction(
                    title: "Remove Membership",
                    style: .destructive
                ) { _ in
                    self.organization.removeMember(uid: members[indexPath.row].uid) { error in
                        if let error = error {
                            print(error.localizedDescription)
                        }
                    }
                }
            )
            
        case 2:
            
            optionMenu = UIAlertController(
                title: "\(memReq[indexPath.row].displayName ?? "Error")",
                message: "Respond to \(memReq[indexPath.row].displayName ?? "Error")'s request for membership.",
                preferredStyle: .actionSheet
            )
            
            optionMenu.addAction(
                UIAlertAction(
                title: "Accept Membership Request",
                style: .default
                ) { alertAction in
                    self.organization.acceptMembershipRequest(memReq[indexPath.row])
                }
            )
            
            optionMenu.addAction(
                UIAlertAction(
                    title: "Reject Membership Request",
                    style: .destructive
                ) { _ in
                    self.organization.rejectMembershipRequest(memReq[indexPath.row])
                }
            )
            
        default:
            break
        }
        
        optionMenu.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .cancel,
                handler: nil
            )
        )
        
        self.present(optionMenu, animated: true)
    }
}
