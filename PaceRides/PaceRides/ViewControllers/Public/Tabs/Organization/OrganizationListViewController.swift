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
        
        if let transitionDestination = self.appDelegate().transitionDestination {
            switch transitionDestination {
            case .organization(let orgId):
                
                let transitionOrgModel = OrganizationModel(withId: orgId)
                self.selectedOrganization = transitionOrgModel
                self.performSegue(withIdentifier: "showOrganizationDetail", sender: self)
                
                self.recentOrganizations.append(transitionOrgModel)
                self.tableView.reloadData()
                self.appDelegate().transitionDestination = nil
                
                return
            }
        }
        
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
            
            if userPublicProfile.organizations().count == 0 && self.recentOrganizations.count == 0 {
                self.noOrganizationsView.isHidden = false
                return
            } else if userPublicProfile.organizations().count == 1  && self.recentOrganizations.count == 0 {
                self.selectedOrganization = userPublicProfile.organizations()[0]
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
        return 1 + (self.recentOrganizations.count > 0 ? 1 : 0)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Your Organizations"
        case 1:
            return "Recent Organizations"
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            if let paceUser = UserModel.sharedInstance(), let userPublicProfile = paceUser.publicProfile() {
                return userPublicProfile.organizations().count
            }
            break
        case 1:
            return self.recentOrganizations.count
        default:
            return 0
        }
        
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "default_cell", for: indexPath)
        
        switch indexPath.section {
        case 0:
            if let paceUser = UserModel.sharedInstance() {
                if let userPublicProfile = paceUser.publicProfile() {
                    cell.textLabel?.text = userPublicProfile.organizations()[indexPath.row].title
                }
            }
            break
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
        if let paceUser = UserModel.sharedInstance(), let userPublicProfile = paceUser.publicProfile() {
            self.selectedOrganization = userPublicProfile.organizations()[indexPath.row]
            self.performSegue(withIdentifier: "showOrganizationDetail", sender: self)
        }
    }
    
}
