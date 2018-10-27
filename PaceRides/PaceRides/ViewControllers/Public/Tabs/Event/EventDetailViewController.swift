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
    private var _userRide: RideModel?
    private var _userRideIsForThisEvent = false
    private var _userRideIsThisEvent = false
    private var _userIsAdmin = false
    private var _userIsMember = false
    
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
        
        if let org = self.event.organization {
            org.subscribe(using: self.newOrganizationData)
        }
        
        self._userHasSavedEvent = false
        for savedEvent in paceUser.savedEvents {
            if savedEvent.uid == self.event.uid {
                self._userHasSavedEvent = true
            }
        }
        
        if let ride = paceUser.ride {
            self._userRide = ride
            ride.subscribe(using: self.newRideData)
        } else {
            self._userRide = nil
        }
        
        self.updateUI()
    }
    
    
    func newOrganizationData(_: Notification? = nil) {
        
        guard let org = self.event.organization else {
            return
        }
        
        guard let paceUser = UserModel.sharedInstance() else {
            return
        }
        
        self._userIsAdmin = false
        self._userIsMember = false
        for admin in org.administrators {
            if paceUser.uid == admin.uid {
                self._userIsAdmin = true
                break
            }
        }
        
        if !_userIsAdmin {
            for member in org.members {
                if paceUser.uid == member.uid {
                    self._userIsMember = true
                    break
                }
            }
        }
        
        self.updateUI()
    }
    
    
    func newRideData(_: Notification? = nil) {
        
        self._userRideIsForThisEvent = false
        
        guard let userRide = self._userRide else {
            return
        }
        
        if userRide.eventUID == self.event.uid {
            self._userRideIsForThisEvent = true
        }
        
        updateUI()
    }
    
    
    func updateUI() {
        
        self.title = event.title
        self.primaryLabel.text = event.title
        
        self.saveEventButton.setTitle("Save Event", for: .normal)
        if self._userHasSavedEvent {
            self.saveEventButton.setTitle("✔️ Event Saved", for: .normal)
        }
        
        self.requestRideButton.isEnabled = true
        self.requestRideButton.setTitle("Request a Ride", for: .normal)
        self.requestRideButton.setTitleColor(nil, for: .normal)
        if self._userRide != nil {
            if self._userRideIsForThisEvent {
                self.requestRideButton.setTitle("Cancel Ride Request", for: .normal)
                self.requestRideButton.setTitleColor(.red, for: .normal)
            } else {
                self.requestRideButton.isEnabled = false
            }
        }
        
        if self._userIsAdmin {
            print("User is admin")
        } else if self._userIsMember {
            print("User is member")
        }
        
    }
    
    
    @IBAction func requestRideButtonPressed(_ sender: Any) {
        
        guard let paceUser = UserModel.sharedInstance(), let publicProfile = paceUser.publicProfile() else {
            return
        }
        
        if self._userRide == nil {
            
            RideModel.createNewRide(rider: publicProfile, event: self.event) { error in
                
                guard error == nil else {
                    print("Error")
                    self.requestRideButton.setTitle("Error", for: .normal)
                    print(error!.localizedDescription)
                    return
                }
            }
            return
            
        } else if self._userRideIsForThisEvent {
            
            let actionSheet = UIAlertController(
                title: "Cancel Request",
                message: "Are you sure you want to cancel your ride request",
                preferredStyle: .actionSheet
            )
            
            actionSheet.addAction(UIAlertAction(
                title: "Cancel Request",
                style: .destructive
            ) { _ in
                
                self._userRide!.cancelRequest(toEvent: self.event.uid, forRider: paceUser) { error in
                    
                    guard error == nil else {
                        print("Error")
                        self.requestRideButton.setTitle("Error", for: .normal)
                        print(error!.localizedDescription)
                        return
                    }
                    
                    self._userRide = nil
                    self._userRideIsForThisEvent = false
                    self.updateUI()
                }
            })
            
            
            actionSheet.addAction(UIAlertAction(
                title: "Keep Request",
                style: .cancel,
                handler: nil
            ))
            
            self.present(actionSheet, animated: true)
            
        } else {
            
            print("Cannot request ride when already in ride.")
            
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
