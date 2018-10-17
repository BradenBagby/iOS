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
    @IBOutlet weak var saveEventButton: UIButton!
    
    private var _userHasSavedEvent = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.event.subscribe(using: self.newEventData)
        UserModel.notificationCenter.addObserver(
            forName: .NewPaceUserData,
            object: nil,
            queue: OperationQueue.main,
            using: self.newEventData
        )
    }
    
    
    func newEventData(_: Notification? = nil) {
        
        guard let paceUser = UserModel.sharedInstance() else {
            updateUI()
            return
        }
        
        self._userHasSavedEvent = false
        for savedEvent in paceUser.savedEvents {
            if savedEvent.uid == self.event.uid {
                self._userHasSavedEvent = true
            }
        }
        
        self.updateUI()
    }
    
    
    func updateUI() {
        self.title = event.title
        self.primaryLabel.text = event.title
        
        self.saveEventButton.setTitle("Save Event", for: .normal)
        if self._userHasSavedEvent {
            self.saveEventButton.setTitle("✔️ Event Saved", for: .normal)
        }
    }
    
    
    @IBAction func requestRideButtonPressed(_ sender: Any) {
        self.requestRideButton.setTitleColor(.red, for: .normal)
        self.requestRideButton.setTitle("Need to implement", for: .normal)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.requestRideButton.setTitleColor(nil, for: .normal)
            self.requestRideButton.setTitle("Request a Ride", for: .normal)
        }
    }
    
    
    @IBAction func saveEventButtonPressed() {
        
        guard let paceUser = UserModel.sharedInstance() else {
            return
        }
        
        if self._userHasSavedEvent {
            paceUser.unsave(event: self.event)
        } else {
            paceUser.save(event: self.event)
        }
    }
}
