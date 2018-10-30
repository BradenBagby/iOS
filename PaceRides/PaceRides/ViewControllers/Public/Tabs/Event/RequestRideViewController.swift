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
    private var pendingPickupLocation: CLLocationCoordinate2D?
    private var pendingPickupLocationPin: MKPointAnnotation!
    private var pendingPickupLocationPinView: MKAnnotationView!
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
        if #available(iOS 11.0, *) {
            self.pendingPickupLocationPinView = MKMarkerAnnotationView(
                annotation: self.pendingPickupLocationPin,
                reuseIdentifier: "pendingPickupLocationPinView"
            )
        } else {
            self.pendingPickupLocationPinView = MKPinAnnotationView(
                annotation: self.pendingPickupLocationPin,
                reuseIdentifier: "pendingPickupLocationPinView"
            )
        }
        self.pendingPickupLocationPinView.canShowCallout = false
        self.pendingPickupLocationPinView.isDraggable = false
        self.pendingPickupLocationPinView.isDraggable = false
        
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

    
    private func updateLocation(location: CLLocationCoordinate2D) {
        self.pendingPickupLocation = location
        self.pendingPickupLocationPin.coordinate = location
        
        if !self.locationLoaded {
            
            self.locationLoaded = true
            
            self.mapView.setRegion(
                MKCoordinateRegion(
                    center: (location),
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
            self.pendingPickupLocationPinView.isDraggable = true
            
        } else {
            
            self.submitButton.isEnabled = true
            self.editLocationButton.setTitle("Edit Location", for: .normal)
            self.pendingPickupLocationPinView.isDraggable = false
            
        }
        
    }
    
    
    @IBAction func submitButtonPressed() {
        
        guard let paceUser = UserModel.sharedInstance(), let publicProfile = paceUser.publicProfile() else {
            return
        }
        
        guard let pickupLocation = self.pendingPickupLocation else {
            return
        }
        
        RideModel.createNewRide(rider: publicProfile, event: self.event, location: pickupLocation) { error in
            
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
            self.updateLocation(location: location.coordinate)
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error")
        print(error.localizedDescription)
    }
}


extension RequestRideViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        if annotation.title == "Pickup Location" {
            return self.pendingPickupLocationPinView
        }
        
        return nil
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
    }

    func mapView(_ mapView: MKMapView,
                 annotationView view: MKAnnotationView,
                 didChange newState: MKAnnotationView.DragState,
                 fromOldState oldState: MKAnnotationView.DragState
    ) {
        
        guard view == self.pendingPickupLocationPinView,
            self.userIsEditingLocation else {
            return
        }
        
        guard newState != oldState else {
            return
        }
        
        if newState == .ending {
            if let annotation = view.annotation {
                self.updateLocation(location: annotation.coordinate)
            }
        }
        
        view.dragState = newState
    }
    
}
