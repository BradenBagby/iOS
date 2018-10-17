//
//  OrganizationListViewController.swift
//  PaceRides
//
//  Created by Grant Broadwater on 10/9/18.
//  Copyright © 2018 PaceRides. All rights reserved.
//

import UIKit

class OrganizationListViewController: PaceTabViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noOrganizationsView: UIView!
    
    private var selectedOrganization: OrganizationModel?
    private var recentOrganizations: [OrganizationModel] = []
    
    private var hasAlreadyDisplayedDetailPage = false
    
    override func viewDidLoad() {
        super.viewDidLoad(self.view)
        
        self.newPaceUserData()
        UserModel.notificationCenter.addObserver(
            forName: .NewPaceUserData,
            object: nil,
            queue: OperationQueue.main,
            using: self.newPaceUserData
        )
    }
    
    func newPaceUserData(_: Notification? = nil) {
        
        self.noOrganizationsView.isHidden = true
        if let paceUser = UserModel.sharedInstance(), let userPublicProfile = paceUser.publicProfile() {
            
            if userPublicProfile.organizations.count == 0 && self.recentOrganizations.count == 0 {
                self.noOrganizationsView.isHidden = false
                return
            } else if userPublicProfile.organizations.count == 1  && self.recentOrganizations.count == 0 {
                self.selectedOrganization = userPublicProfile.organizations[0]
                if !self.hasAlreadyDisplayedDetailPage {
                    self.performSegue(withIdentifier: "showOrganizationDetail", sender: self)
                }
            }
        }
        
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.newPaceUserData()
    }
    
    
    func open(organization: OrganizationModel) {
        
        self.navigationController!.popToRootViewController(animated: false)
        self.selectedOrganization = organization
        self.performSegue(withIdentifier: "showOrganizationDetail", sender: self)
        
        for recentOrganization in self.recentOrganizations {
            if recentOrganization.uid == organization.uid {
                return
            }
        }
        self.recentOrganizations.append(organization)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showOrganizationDetail" {
            
            self.hasAlreadyDisplayedDetailPage = true
            if let destinationVC = segue.destination as? OrganizationDetailViewController {
                
                destinationVC.organizationModel = self.selectedOrganization
                
            } else {
                print("Could not cast destination to OrganizationDetailVC")
                return
            }
        }
    }
}


extension OrganizationListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        guard let paceUser = UserModel.sharedInstance() else {
            return 0
        }
        
        return (paceUser.organizations.count > 0 ? 1 : 0) + (self.recentOrganizations.count > 0 ? 1 : 0)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        guard let paceUser = UserModel.sharedInstance() else {
            return nil
        }
        
        switch section {
        case 0:
            return (paceUser.organizations.count > 0 ? "Your Organizations" : "Recent Organizations")
        case 1:
            return "Recent Organizations"
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let paceUser = UserModel.sharedInstance() else {
            return 0
        }
        
        switch section {
        case 0:
            return (paceUser.organizations.count > 0 ? paceUser.organizations.count : self.recentOrganizations.count)
        case 1:
            return self.recentOrganizations.count
        default:
            return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "default_cell", for: indexPath)
        
        guard let paceUser = UserModel.sharedInstance() else {
            cell.textLabel?.text = "Error"
            return cell
        }
        
        switch indexPath.section {
        case 0:
            if paceUser.organizations.count > 0 {
                cell.textLabel?.text = paceUser.organizations[indexPath.row].title
                break
            }
            fallthrough
        case 1:
            cell.textLabel?.text = self.recentOrganizations[indexPath.row].title
            break
        default:
            cell.textLabel?.text = "Error"
            break
        }
        
        return cell
    }
}


extension OrganizationListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let paceUser = UserModel.sharedInstance() else {
            return
        }
        
        switch indexPath.section {
        case 0:
            if paceUser.organizations.count > 0 {
                self.selectedOrganization = paceUser.organizations[indexPath.row]
                break
            }
            fallthrough
        case 1:
            self.selectedOrganization = recentOrganizations[indexPath.row]
            break
        default:
            return
        }
        
        self.performSegue(withIdentifier: "showOrganizationDetail", sender: self)
    }
    
}
