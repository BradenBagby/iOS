//
//  DriveViewController.swift
//  PaceRides
//
//  Created by Grant Broadwater on 10/9/18.
//  Copyright © 2018 PaceRides. All rights reserved.
//

import UIKit

class DriveViewController: PaceTabViewController {
    
    
    private var _userDriveFor: EventModel?
    private var _userDrive: RideModel?
    
    
    @IBOutlet weak var noDriveView: UIView!
    @IBOutlet weak var primaryLabel: UILabel!
    @IBOutlet weak var primaryButton: UIButton!
    @IBOutlet weak var destructivButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad(self.view)
        
        self.newUserData()
        UserModel.notificationCenter.addObserver(
            forName: .NewPaceUserData,
            object: nil,
            queue: OperationQueue.main,
            using: self.newUserData
        )
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        self.setRearGestureRecognizer()
    }
    
    
    func newUserData(_: Notification? = nil) {
        
        guard let paceUser = UserModel.sharedInstance() else {
            return
        }
        
        if let userDriveFor = paceUser.driveFor {
            self._userDriveFor = userDriveFor
            userDriveFor.subscribe(using: self.newEventData)
        } else {
            self._userDriveFor = nil
        }
        
        
        if let userDrive = paceUser.drive {
            self._userDrive = userDrive
            userDrive.subscribe(using: self.newRideData)
        } else {
            self._userDrive = nil
        }
        
        updateUI()
    }
    
    
    func newEventData(_: Notification? = nil) {
        updateUI()
    }
    
    
    func newRideData(_: Notification? = nil) {
        updateUI()
    }
    
    
    func updateUI() {
        
        guard let userDriveFor = self._userDriveFor else {
            self.noDriveView.isHidden = false
            return
        }
        
        self.noDriveView.isHidden = true
        
        self.primaryLabel.text = userDriveFor.title
        
        if let _ = self._userDrive {
            
            self.primaryButton.isEnabled = true
            self.primaryButton.setTitle("Get Rider's Location", for: .normal)
            self.destructivButton.setTitle("End Ride", for: .normal)
            
        } else {
            
            self.primaryButton.setTitle("Get Next Rider", for: .normal)
            if userDriveFor.rideQueue.count > 0 {
                self.primaryButton.isEnabled = true
            } else {
                self.primaryButton.isEnabled = false
            }
            
            self.destructivButton.setTitle("Stop Driving", for: .normal)
            
            
        }
        
    }
    
    
    @IBAction func primaryButtonPressed() {
        
        guard let userDriveFor = self._userDriveFor else {
            return
        }
        
        guard let paceUser = UserModel.sharedInstance(), let pubProf = paceUser.publicProfile() else {
            return
        }
        
        if let _ = self._userDrive {
            print("Get rider's location")
        } else {
            userDriveFor.getNextRiderInQueue(pubProf)
        }
    }
    
    
    @IBAction func destructiveButtonPressed() {
        
        guard let paceUser = UserModel.sharedInstance() else {
            return
        }
        
        guard let userDriveFor = self._userDriveFor else {
            return
        }
        
        if let _ = self._userDrive {
            print("End ride")
        } else {
            
            let actionSheet = UIAlertController(
                title: "Stop Driving",
                message: "Are you sure you want to stop driving for this event?",
                preferredStyle: .actionSheet
            )
            
            actionSheet.addAction(UIAlertAction(
                title: "Stop Driving",
                style: .destructive
            ) { _ in
                userDriveFor.stopDriving(paceUser: paceUser)
            })
            
            actionSheet.addAction( UIAlertAction(
                title: "Cancel",
                style: .cancel,
                handler: nil
            ))
            
            self.present(actionSheet, animated: true)
            
        }
    }
}

