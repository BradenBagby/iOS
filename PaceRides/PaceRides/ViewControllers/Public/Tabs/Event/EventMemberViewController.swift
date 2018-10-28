//
//  EventMemberViewController.swift
//  PaceRides
//
//  Created by Grant Broadwater on 10/28/18.
//  Copyright © 2018 PaceRides. All rights reserved.
//

import UIKit

class EventMemberViewController: UIViewController {

    var event: EventModel!
    @IBOutlet weak var btnCopyLink: UIButton!
    @IBOutlet weak var btnDrive: UIButton!
    
    private var _userIsDrivingForEvent = true
    private var _userIsDrivingForThisEvent = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.newUserData()
        UserModel.notificationCenter.addObserver(
            forName: .NewPaceUserData,
            object: nil,
            queue: OperationQueue.main,
            using: self.newUserData
        )
    }
    
    
    func newUserData(_: Notification? = nil) {
     
        guard let paceUser = UserModel.sharedInstance() else {
            self._userIsDrivingForEvent = true
            self._userIsDrivingForThisEvent = false
            self.updateUI()
            return
        }
        
        if let userDriveFor = paceUser.driveFor {
            self._userIsDrivingForEvent = true
            self._userIsDrivingForThisEvent = userDriveFor.uid == self.event.uid
        } else {
            self._userIsDrivingForEvent = false
        }
        
        self.updateUI()
    }
    
    func updateUI() {
        
        if _userIsDrivingForEvent {
            if _userIsDrivingForThisEvent {
                self.btnDrive.isEnabled = true
                self.btnDrive.setTitle("Stop Driving", for: .normal)
                self.btnDrive.setTitleColor(.red, for: .normal)
            } else {
                self.btnDrive.isEnabled = false
                self.btnDrive.setTitle("Drive", for: .normal)
                self.btnDrive.setTitleColor(nil, for: .normal)
            }
        } else {
            self.btnDrive.isEnabled = true
            self.btnDrive.setTitle("Drive", for: .normal)
            self.btnDrive.setTitleColor(nil, for: .normal)
        }
        
    }
    
    @IBAction func copyLinkButtonPressed() {
        UIPasteboard.general.string = self.event.link
        self.btnCopyLink.setTitle("✔️ Link Copied!", for: .normal)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.btnCopyLink.setTitle("Copy Link", for: .normal)
        }
    }
    
    @IBAction func driveButtonPressed() {
        
        guard let paceUser = UserModel.sharedInstance(), let pubProf = paceUser.publicProfile() else {
            return
        }
        
        if let userDriveFor = paceUser.driveFor {
            if userDriveFor.uid == self.event.uid {
                userDriveFor.stopDriving(paceUser: paceUser)
            }
        } else {
            self.event.addDriver(paceUser: pubProf)
        }
    }
}
