//
//  DriveViewController.swift
//  PaceRides
//
//  Created by Grant Broadwater on 10/9/18.
//  Copyright © 2018 PaceRides. All rights reserved.
//

import UIKit

class DriveViewController: PaceTabViewController {
    
    
    private var _userDrivingForEvent = false
    private var _userDriveEventTitle: String?
    
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
            self._userDrivingForEvent = true
            userDriveFor.subscribe(using: self.newEventData)
        } else {
            self._userDrivingForEvent = false
            self._userDriveEventTitle = nil
        }
        
        updateUI()
    }
    
    
    func newEventData(_: Notification? = nil) {
     
        self._userDrivingForEvent = false
        self._userDriveEventTitle = nil
        
        guard let paceUser = UserModel.sharedInstance() else {
            updateUI()
            return
        }
        
        guard let userDriveFor = paceUser.driveFor else {
            updateUI()
            return
        }
        
        self._userDrivingForEvent = true
        self._userDriveEventTitle = userDriveFor.title
        
        updateUI()
    }
    
    
    func updateUI() {
        
        self.noDriveView.isHidden = self._userDrivingForEvent
        
        if self._userDrivingForEvent {
            self.primaryLabel.text = self._userDriveEventTitle
        }
        
    }
    
    
    @IBAction func primaryButtonPressed() {
        print("Primary button pressed")
    }
    
    
    @IBAction func destructiveButtonPressed() {
        print("Destructive button presssed")
    }
}

