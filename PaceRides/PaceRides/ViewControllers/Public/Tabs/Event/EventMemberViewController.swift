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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func copyLinkButtonPressed() {
        UIPasteboard.general.string = self.event.link
        self.btnCopyLink.setTitle("✔️ Link Copied!", for: .normal)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.btnCopyLink.setTitle("Copy Link", for: .normal)
        }
    }
    
    @IBAction func driveButtonPressed() {
        
        guard let paceUser = UserModel.sharedInstance() else {
            return
        }
        
        print("\(paceUser.uid) drive for \(self.event.title ?? "Error")")
    }
}
