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
    private var _userDriveDeletionObserver: NSObjectProtocol?
    
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
            
            self._userDriveDeletionObserver = RideModel.notificationCenter.addObserver(
                forName: RideModel.RideDoesNotExist,
                object: userDrive,
                queue: OperationQueue.main,
                using: self.rideDoesNotExist
            )
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
    
    
    func rideDoesNotExist(_: Notification? = nil) {
        
        let alert = UIAlertController(
            title: "Drive Ended",
            message: "This ride has been canceled or removed.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(
            title: "Okay",
            style: .cancel,
            handler: nil)
        )
        
        self.present(alert, animated: true)
        
        guard let userDriveFor = self._userDriveFor, let user = UserModel.sharedInstance(), let pubProf = user.publicProfile() else {
            return
        }
        guard let userDrive = self._userDrive else {
            return
        }
        userDriveFor.endDrive(pubProf, rideModel: userDrive)
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
            self.destructivButton.setTitle("End Drive", for: .normal)
            
        } else {
            
            if userDriveFor.rideQueue.count > 0 {
                self.primaryButton.isEnabled = true
                self.primaryButton.setTitle("Get Next Rider", for: .normal)
            } else {
                self.primaryButton.isEnabled = false
                self.primaryButton.setTitle("No One in Queue", for: .normal)
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
        
        guard let paceUser = UserModel.sharedInstance(), let pubProf = paceUser.publicProfile() else {
            return
        }
        
        guard let userDriveFor = self._userDriveFor else {
            return
        }
        
        if let userDrive = self._userDrive {
            
            let actionSheet = UIAlertController(
                title: "End Drive",
                message: "Are you sure the drive is over?",
                preferredStyle: .actionSheet
            )
            
            actionSheet.addAction(UIAlertAction(
                title: "End Drive",
                style: .destructive
            ) { _ in
                
                RideModel.notificationCenter.removeObserver(
                    self._userDriveDeletionObserver as Any,
                    name: RideModel.RideDoesNotExist,
                    object: userDrive
                )
                userDriveFor.endDrive(pubProf, rideModel: userDrive)
                
            })
            
            actionSheet.addAction(UIAlertAction(
                title: "Cancel",
                style: .cancel,
                handler: nil
            ))
            
            self.present(actionSheet, animated: true)
            
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

