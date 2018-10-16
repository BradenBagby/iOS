//
//  EventViewController.swift
//  PaceRides
//
//  Created by Grant Broadwater on 10/16/18.
//  Copyright © 2018 PaceRides. All rights reserved.
//

import UIKit

class EventDetailViewController: UIViewController {

    var event: EventModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.event.subscribe(using: self.newEventData)
    }
    
    
    func newEventData(_: Notification? = nil) {
        self.updateUI()
    }
    
    
    func updateUI() {
        self.title = event.title
    }
}
