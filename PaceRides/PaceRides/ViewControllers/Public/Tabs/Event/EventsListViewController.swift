//
//  EventsViewController.swift
//  PaceRides
//
//  Created by Grant Broadwater on 10/9/18.
//  Copyright © 2018 PaceRides. All rights reserved.
//

import UIKit

class EventListViewController: PaceTabViewController {

    private var eventRefToOpen: EventModel?
    
    override func viewDidLoad() {
        super.viewDidLoad(self.view)
    }

    
    func open(event: EventModel) {
        self.navigationController!.popToRootViewController(animated: false)
        self.eventRefToOpen = event
        self.performSegue(withIdentifier: "showEventDetail", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEventDetail" {
            if let destVC = segue.destination as? EventDetailViewController, let event = self.eventRefToOpen  {
                destVC.eventRef = event
            }
        }
    }
}
