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
    @IBOutlet weak var eventsTableView: UITableView!
    
    
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
        
        self.eventsTableView.isHidden = true
        if self._userIsAdmin {
         
            self.externalView.isHidden = true
            self.memberView.isHidden = true
            
            if self.organizationModel.hasEventPrivileges() {
                self.eventsTableView.isHidden = false
                self.eventsTableView.reloadData()
            }
            
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


extension OrganizationDetailViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 + (self.organizationModel.events.count > 0 ? 1 : 0)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Events"
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return self.organizationModel.events.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "default_cell", for: indexPath)

        switch indexPath.section {
        case 0:
            cell.textLabel?.text = "Create Event"
            cell.accessoryType = .none
        case 1:
            cell.textLabel?.text = self.organizationModel.events[indexPath.row].title
            cell.accessoryType = .disclosureIndicator
        default:
            cell.textLabel?.text = "Error"
        }
        
        return cell
    }
    
    
}


extension OrganizationDetailViewController: UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(
            style: .destructive,
            title: "Delete"
        ) { _, indexPath in
            
            let actionSheet = UIAlertController(
                title: "Delete",
                message: "Are you sure you want to delete this event?",
                preferredStyle: .actionSheet
            )
            
            actionSheet.addAction(
                UIAlertAction(
                    title: "Delete",
                    style: .destructive
                ) { _ in
                    
                    if indexPath.row < self.organizationModel.events.count {
                        self.organizationModel.events[indexPath.row].deleteEvent() { error in
                         
                            guard error == nil else {
                                print("Error")
                                print(error!.localizedDescription)
                                return
                            }
                            
                            self.eventsTableView.reloadData()
                        }
                    }
                    
                }
            )
            
            actionSheet.addAction(
                UIAlertAction(
                    title: "Cancel",
                    style: .cancel,
                    handler: nil
                )
            )
            
            
            self.present(actionSheet, animated: true)
        }
        
        return [deleteAction]
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0:
            let alert = UIAlertController(
                title: "Create Event",
                message: "Create a new event for this organization.",
                preferredStyle: .alert
            )
            alert.addTextField { (textField) in
                textField.placeholder = "Event Title"
            }
            alert.addAction(UIAlertAction(title: "Create", style: .default) { [weak alert] (_) in
                let textField = alert!.textFields![0] // Force unwrapping because we know it exists.
                if let text = textField.text, !text.isEmpty {
                    self.organizationModel.createEvent(withTitle: text)
                }
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
            self.present(alert, animated: true, completion: nil)
        case 1:
            if let tabBarController = self.tabBarController as? PublicTabBarController {
                tabBarController.open(event: self.organizationModel.events[indexPath.row])
                return
            }
        default:
            print("Error")
        }
    }
    
}
