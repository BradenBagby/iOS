//
//  RequestRideViewController.swift
//  PaceRides
//
//  Created by Grant Broadwater on 10/29/18.
//  Copyright © 2018 PaceRides. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class RequestRideViewController: UIViewController {

    var event: EventModel!
    private var locationManager: CLLocationManager!
    private var pendingPickupLocation: CLLocation?
    private var pendingPickupLocationPin: MKPointAnnotation!
    private var userHasUpdatedLocation = false
    private var userIsEditingLocation = false
    private var locationLoaded = false
    
    @IBOutlet weak var primaryLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var editLocationButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNavigationBarColors()
        
        self.title = self.event.title
        self.primaryLabel.text = self.event.title
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        self.pendingPickupLocationPin = MKPointAnnotation()
        self.pendingPickupLocationPin.title = "Pickup Location"
        
        self.mapView.delegate = self
        self.mapView.addAnnotation(self.pendingPickupLocationPin)

        if CLLocationManager.locationServicesEnabled(),
                CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
                CLLocationManager.authorizationStatus() == .authorizedAlways {
            
            self.locationManager.startUpdatingLocation()
        } else {
            self.displayNeedLocationAlert()
        }
    }

    
    private func updateLocation(location: CLLocation) {
        self.pendingPickupLocation = location
        self.pendingPickupLocationPin.coordinate = location.coordinate
        
        if !self.locationLoaded {
            
            self.locationLoaded = true
            
            self.mapView.setRegion(
                MKCoordinateRegion(
                    center: (location.coordinate),
                    latitudinalMeters: 1000,
                    longitudinalMeters: 1000
                ),
                animated: true
            )
        }
    }
    
    
    private func displayNeedLocationAlert() {
        
        let alert = UIAlertController(
            title: "Location Services Required",
            message: "You must authorize location services in order to request a ride.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(
            title: "Okay",
            style: .cancel
        ) { _ in
            self.locationManager.requestWhenInUseAuthorization()
        })
        
        self.present(alert, animated: true)
    }
    
    
    @IBAction func cancelButtonPressed() {
        self.dismiss(animated: true)
    }
    
    
    @IBAction func editLocationButtonPressed() {
        
        self.userIsEditingLocation = !self.userIsEditingLocation
        
        if self.userIsEditingLocation {
            
            self.submitButton.isEnabled = false
            self.userHasUpdatedLocation = true
            self.editLocationButton.setTitle("Commit Location", for: .normal)
            
        } else {
            
            self.submitButton.isEnabled = true
            self.editLocationButton.setTitle("Edit Location", for: .normal)
            
        }
        
    }
    
    
    @IBAction func submitButtonPressed() {
        
        guard let paceUser = UserModel.sharedInstance(), let publicProfile = paceUser.publicProfile() else {
            return
        }
        
        guard let currentLocation = self.locationManager.location else {
            return
        }
        
        RideModel.createNewRide(rider: publicProfile, event: self.event, location: currentLocation) { error in
            
            guard error == nil else {
                print("Error")
                print(error!.localizedDescription)
                return
            }
        }
        
        self.dismiss(animated: true)
    }
}


extension RequestRideViewController: CLLocationManagerDelegate {

    
    func locationManager(_ location: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        guard status == .authorizedWhenInUse || status == .authorizedAlways else {
            self.displayNeedLocationAlert()
            return
        }
        
        self.locationManager.startUpdatingLocation()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard !userHasUpdatedLocation else { return }
        if let location = locations.last {
            self.updateLocation(location: location)
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error")
        print(error.localizedDescription)
    }
}


extension RequestRideViewController: MKMapViewDelegate {
    
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//
//        var view: MKAnnotationView!
//
//
//
//        return view
//    }
//
//    func mapView(_ mapView: MKMapView,
//                 annotationView view: MKAnnotationView,
//                 didChange newState: MKAnnotationView.DragState,
//                 fromOldState oldState: MKAnnotationView.DragState
//    ) {
//
//
//
//    }
    
}
