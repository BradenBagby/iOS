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
    @IBOutlet weak var noEventsView: UIView!
    
    
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
        
        if self.numberOfSections(in: self.eventListTableView) == 0 {
            self.noEventsView.isHidden = false
            return
        } else {
            self.noEventsView.isHidden = true
        }
        
        self.eventListTableView.reloadData()
    }
    
    
    func newOrganizationData(_: Notification? = nil) {
        
        if self.numberOfSections(in: self.eventListTableView) == 0 {
            self.noEventsView.isHidden = false
            return
        } else {
            self.noEventsView.isHidden = true
        }
        
        self.eventListTableView.reloadData()
    }
    

    func newEventData(_: Notification? = nil) {
        
        if self.numberOfSections(in: self.eventListTableView) == 0 {
            self.noEventsView.isHidden = false
            return
        } else {
            self.noEventsView.isHidden = true
        }
        
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
        event.subscribe(using: self.newEventData)
        if let tv = self.eventListTableView {
            tv.reloadData()
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEventDetail" {
            if let destVC = segue.destination as? EventDetailViewController, let event = self.eventToOpen  {
                destVC.event = event
            }
        }
    }
}


extension EventListViewController: UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        guard let paceUser = UserModel.sharedInstance() else {
            return 0
        }
        
        var count = 0
        
        for org in paceUser.organizations {
            if org.events.count > 0 {
                count += 1
            }
        }
        
        return count + (paceUser.savedEvents.count > 0 ? 1 : 0) + (recentEvents.count > 0 ? 1 : 0)
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        guard let paceUser = UserModel.sharedInstance() else {
            return nil
        }
        
        var sectionsLeft = section
        
        for org in paceUser.organizations {
            if org.events.count > 0 {
                if sectionsLeft == 0 {
                    return org.title
                }
                sectionsLeft = sectionsLeft - 1
            }
        }
        
        if sectionsLeft == 1 {
            return "Saved Events"
        } else if sectionsLeft == 0 {
            if self.recentEvents.count > 0 {
                return "Recent Events"
            } else {
                return "Saved Events"
            }
        }
        
        return "Error"
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let paceUser = UserModel.sharedInstance() else {
            return 0
        }
        
        var sectionsLeft = section
        
        for org in paceUser.organizations {
            if org.events.count > 0 {
                if sectionsLeft == 0 {
                    return org.events.count
                }
                sectionsLeft = sectionsLeft - 1
            }
        }
        
        if sectionsLeft == 1 {
            return paceUser.savedEvents.count
        } else if sectionsLeft == 0 {
            if self.recentEvents.count > 0 {
                return self.recentEvents.count
            } else {
                return paceUser.savedEvents.count
            }
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let default_cell = tableView.dequeueReusableCell(withIdentifier: "default_cell", for: indexPath)
        
        guard let paceUser = UserModel.sharedInstance() else {
            default_cell.textLabel?.text = "Error: No user"
            return default_cell
        }
        
        var sectionsLeft = indexPath.section
        
        for org in paceUser.organizations {
            if org.events.count > 0 {
                if sectionsLeft == 0 {
                    default_cell.textLabel?.text = org.events[indexPath.row].title ?? "Error"
                    return default_cell
                }
                sectionsLeft = sectionsLeft - 1
            }
        }
        
        if sectionsLeft == 1 {
            guard indexPath.row < paceUser.savedEvents.count else {
                default_cell.textLabel?.text = "Error"
                return default_cell
            }
            default_cell.textLabel?.text = paceUser.savedEvents[indexPath.row].title
        } else if sectionsLeft == 0 {
            if indexPath.row < self.recentEvents.count {
                default_cell.textLabel?.text = self.recentEvents[indexPath.row].title
            } else {
                guard indexPath.row < paceUser.savedEvents.count else {
                    default_cell.textLabel?.text = "Error"
                    return default_cell
                }
                default_cell.textLabel?.text = paceUser.savedEvents[indexPath.row].title
            }
        } else {
            default_cell.textLabel?.text = "Error"
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
        
        var sectionsLeft = indexPath.section
        
        for org in paceUser.organizations {
            if org.events.count > 0 {
                if sectionsLeft == 0 {
                    self.eventToOpen = org.events[indexPath.row]
                    self.performSegue(withIdentifier: "showEventDetail", sender: self)
                    return
                }
                sectionsLeft = sectionsLeft - 1
            }
        }
        
        if sectionsLeft == 1 {
            self.eventToOpen = paceUser.savedEvents[indexPath.row]
        } else if sectionsLeft == 0 {
            if self.recentEvents.count > 0 {
                self.eventToOpen = self.recentEvents[indexPath.row]
            } else {
                self.eventToOpen = paceUser.savedEvents[indexPath.row]
            }
        } else {
            return
        }
        
        self.performSegue(withIdentifier: "showEventDetail", sender: self)
    }
}
