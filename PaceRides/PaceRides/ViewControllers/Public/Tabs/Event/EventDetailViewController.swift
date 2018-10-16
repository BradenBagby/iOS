//
//  EventViewController.swift
//  PaceRides
//
//  Created by Grant Broadwater on 10/16/18.
//  Copyright © 2018 PaceRides. All rights reserved.
//

import UIKit

class EventDetailViewController: UIViewController {

    var eventRef: EventModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = eventRef.title
    }
}
