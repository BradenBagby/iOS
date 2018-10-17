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
    
    @IBOutlet weak var primaryLabel: UILabel!
    @IBOutlet weak var requestRideButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.event.subscribe(using: self.newEventData)
    }
    
    
    func newEventData(_: Notification? = nil) {
        self.updateUI()
    }
    
    
    func updateUI() {
        self.title = event.title
        self.primaryLabel.text = event.title
    }
    
    
    @IBAction func requestRideButtonPressed(_ sender: Any) {
        self.requestRideButton.setTitleColor(.red, for: .normal)
        self.requestRideButton.setTitle("Need to implement", for: .normal)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.requestRideButton.setTitleColor(nil, for: .normal)
            self.requestRideButton.setTitle("Request a Ride", for: .normal)
        }
    }
}
