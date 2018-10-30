//
//  RideViewController.swift
//  PaceRides
//
//  Created by Grant Broadwater on 10/9/18.
//  Copyright © 2018 PaceRides. All rights reserved.
//

import UIKit
import MapKit

class RideViewController: PaceTabViewController {
    
    @IBOutlet weak var noRideView: UIView!
    @IBOutlet weak var primaryLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
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
        
        guard let paceUser = UserModel.sharedInstance(), let userRide = paceUser.ride else {
            self.noRideView.isHidden = false
            return
        }
        
        userRide.subscribe(using: self.newRideData)
    }
    
    
    func newRideData(_: Notification? = nil) {
        self.updateUI()
    }
    
    
    func updateUI() {
        guard let paceUser = UserModel.sharedInstance(), let userRide = paceUser.ride else {
            self.noRideView.isHidden = false
            self.mapView.removeAnnotations(self.mapView.annotations)
            return
        }
        self.noRideView.isHidden = true
        
        self.primaryLabel.text = userRide.eventTitle ?? "Error"
        
        if let status = userRide.status {
            switch status {
            case 0:
                self.statusLabel.text = "Ride in queue"
            case 1:
                self.statusLabel.text = "Driver en route"
            default:
                self.statusLabel.text = "Error"
            }
        } else {
            self.statusLabel.text = "Error"
        }
        
        if let pickupLocation = userRide.pickupLocation {
            self.mapView.isHidden = false
            
            let pin = MKPointAnnotation()
            pin.coordinate = pickupLocation.coordinate
            pin.title = "Pickup Location"
            
            self.mapView.addAnnotation(pin)
            self.mapView.setRegion(
                MKCoordinateRegion(
                    center: (pickupLocation.coordinate),
                    latitudinalMeters: 2000,
                    longitudinalMeters: 2000
                ),
                animated: true
            )
        } else {
            self.mapView.isHidden = true
        }
    }
    
    @IBAction func cancelRideRequestButtonPressed() {
        
        guard let paceUser = UserModel.sharedInstance(),
            let userRide = paceUser.ride,
            let eventUID = userRide.eventUID else {
            return
        }
        
        let actionSheet = UIAlertController(
            title: "Cancel Request",
            message: "Are you sure you want to cancel your ride request",
            preferredStyle: .actionSheet
        )
        
        actionSheet.addAction(UIAlertAction(
            title: "Cancel Request",
            style: .destructive
        ) { _ in
            
            userRide.cancelRequest(toEvent: eventUID, forRider: paceUser) { error in
                
                guard error == nil else {
                    print("Error")
                    print(error!.localizedDescription)
                    return
                }
                
                self.updateUI()
            }
        })
        
        
        actionSheet.addAction(UIAlertAction(
            title: "Keep Request",
            style: .cancel,
            handler: nil
        ))
        
        self.present(actionSheet, animated: true)
    }
}

