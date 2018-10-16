//
//  EventsViewController.swift
//  PaceRides
//
//  Created by Grant Broadwater on 10/9/18.
//  Copyright © 2018 PaceRides. All rights reserved.
//

import UIKit

class EventListViewController: PaceTabViewController {

    private var eventToOpen: EventModel?
    private var recentEvents = [EventModel]()
    
    @IBOutlet weak var eventListTableView: UITableView!
    
    
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
        
        guard let paceUser = UserModel.sharedInstance() else {
            return
        }
        
        for org in paceUser.organizations {
            org.subscribe(using: self.newOrganizationData)
        }
        
        self.eventListTableView.reloadData()
    }
    
    func newOrganizationData(_: Notification? = nil) {
        self.eventListTableView.reloadData()
    }

    
    func open(event: EventModel) {
        
        self.navigationController!.popToRootViewController(animated: false)
        self.eventToOpen = event
        self.performSegue(withIdentifier: "showEventDetail", sender: self)
        
        for recentEvent in self.recentEvents {
            if recentEvent.uid == event.uid {
                return
            }
        }
        self.recentEvents.append(event)
        if let tv = self.eventListTableView {
            tv.reloadData()
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEventDetail" {
            if let destVC = segue.destination as? EventDetailViewController, let event = self.eventToOpen  {
                destVC.eventRef = event
            }
        }
    }
}


extension EventListViewController: UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        guard let paceUser = UserModel.sharedInstance() else {
            return 0
        }
        
        return paceUser.organizations.count + (recentEvents.count > 0 ? 1 : 0)
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        guard let paceUser = UserModel.sharedInstance() else {
            return nil
        }
        
        if section < paceUser.organizations.count {
            if paceUser.organizations[section].events.count == 0 {
                return nil
            }
            return paceUser.organizations[section].title
        } else {
            return "Recent Events"
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let paceUser = UserModel.sharedInstance() else {
            return 0
        }
        
        if section < paceUser.organizations.count {
            return paceUser.organizations[section].events.count
        } else {
            return self.recentEvents.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let default_cell = tableView.dequeueReusableCell(withIdentifier: "default_cell", for: indexPath)
        
        guard let paceUser = UserModel.sharedInstance() else {
            default_cell.textLabel?.text = "Error: No user"
            return default_cell
        }
        
        if indexPath.section < paceUser.organizations.count {
           default_cell.textLabel?.text = paceUser.organizations[indexPath.section].events[indexPath.row].title ?? "Error"
        } else {
            default_cell.textLabel?.text = recentEvents[indexPath.row].title ?? "Error"
        }
        
        return default_cell
    }
    
}


extension EventListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let paceUser = UserModel.sharedInstance() else {
            return
        }
        
        if indexPath.section < paceUser.organizations.count {
            self.eventToOpen = paceUser.organizations[indexPath.section].events[indexPath.row]
        } else {
            self.eventToOpen = self.recentEvents[indexPath.row]
        }
        
        self.performSegue(withIdentifier: "showEventDetail", sender: self)
    }
    
}
