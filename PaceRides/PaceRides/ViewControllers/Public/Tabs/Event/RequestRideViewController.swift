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

class RequestRideViewController: UIViewController, CLLocationManagerDelegate {

    var event: EventModel!
    private var locationManager: CLLocationManager!
    
    @IBOutlet weak var primaryLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNavigationBarColors()
        
        self.title = self.event.title
        self.primaryLabel.text = self.event.title
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        self.mapView.delegate = self

        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                locationManager.requestWhenInUseAuthorization()
            case .authorizedAlways, .authorizedWhenInUse:
                self.locationManager.startUpdatingLocation()
            }
        } else {
            print("Location services are not enabled")
        }
    }
    
    func locationManager(_ location: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        guard status == .authorizedWhenInUse || status == .authorizedAlways else {
            self.displayNeedLocationAlert()
            return
        }
        
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            self.setMap(location: location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error")
        print(error.localizedDescription)
    }
    
    
    private func setMap(location: CLLocation) {
        self.mapView.showsUserLocation = true
        self.mapView.setRegion(
            MKCoordinateRegion(
                center: (location.coordinate),
                latitudinalMeters: 1000,
                longitudinalMeters: 1000
            ),
            animated: true
        )
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

extension RequestRideViewController: MKMapViewDelegate {
    
}
