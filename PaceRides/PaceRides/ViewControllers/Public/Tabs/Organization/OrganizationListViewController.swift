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
    
    private var selectedOrganization: OrganizationModel?
    
    override func viewDidLoad() {
        super.viewDidLoad(self.view)
        
        if let transitionDestination = self.appDelegate().transitionDestination {
            switch transitionDestination {
            case .organization(let orgId):
                self.selectedOrganization = OrganizationModel(withId: orgId)
                self.performSegue(withIdentifier: "showOrganizationDetail", sender: self)
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
        self.tableView.reloadData()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showOrganizationDetail" {
            
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
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let paceUser = UserModel.sharedInstance(), let userPublicProfile = paceUser.publicProfile() {
            return userPublicProfile.organizations().count
        }
        
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "default_cell", for: indexPath)
        
        if let paceUser = UserModel.sharedInstance() {
            if let userPublicProfile = paceUser.publicProfile() {
                cell.textLabel?.text = userPublicProfile.organizations()[indexPath.row].title
            }
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
