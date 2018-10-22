//
//  RideViewController.swift
//  PaceRides
//
//  Created by Grant Broadwater on 10/9/18.
//  Copyright © 2018 PaceRides. All rights reserved.
//

import UIKit

class RideViewController: PaceTabViewController {
    
    @IBOutlet weak var noRideView: UIView!
    @IBOutlet weak var primaryLabel: UILabel!
    
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
    
    func newUserData(_: Notification? = nil) {
        
        guard let paceUser = UserModel.sharedInstance(), let userRide = paceUser.ride else {
            self.noRideView.isHidden = false
            return
        }
        
        userRide.subscribe(using: self.newRideData)
    }
    
    
    func newRideData(_: Notification? = nil) {
        
        guard let paceUser = UserModel.sharedInstance(), let userRide = paceUser.ride else {
            self.noRideView.isHidden = false
            return
        }
        self.noRideView.isHidden = true
        
        self.primaryLabel.text = userRide.eventTitle ?? "Error"
    }
    
}

