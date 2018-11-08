//
//  WelcomeViewController.swift
//  PaceRides
//
//  Created by Grant Broadwater on 11/6/18.
//  Copyright © 2018 PaceRides. All rights reserved.
//

import UIKit
import UserNotifications

let allowPushNotificationsButtonLabel = "Allow Push Notifications"
let allowLocationServicesButtonLabel = "Allow Location Services"
let openSettingsButtonLabel = "Open Settings"
let completeButtonLabel = "Complete!"

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    var notificationCell: WelcomeCollectionViewCellInterface? = nil
    var locationCell: WelcomeCollectionViewCellInterface? = nil
    let welcomePages = [
        WelcomePage.welcome,
        WelcomePage.notification,
        WelcomePage.location,
        WelcomePage.facebookLogin
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pageControl.numberOfPages = self.welcomePages.count
        self.pageControl.currentPage = 0
        
        self.appDelegate().notificationCenter.addObserver(
            forName: self.appDelegate().NotificationsAuthorizationMayHaveChanged,
            object: self.appDelegate(),
            queue: OperationQueue.main,
            using: self.notificationsAuthorized
        )
        self.appDelegate().notificationCenter.addObserver(
            forName: self.appDelegate().LocationServicesAuthorizationMayHaveChanged,
            object: self.appDelegate(),
            queue: OperationQueue.main,
            using: self.locationServicesAuthorizationMayHaveChanged
        )
    }
}


extension WelcomeViewController: UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(
            width: self.view.frame.width,
            height: self.view.frame.height - (self.pageControl.frame.height + 36)
        )
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let pageNumber = Int(targetContentOffset.pointee.x / self.view.frame.width)
        self.pageControl.currentPage = pageNumber
    }
}


extension WelcomeViewController: UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return welcomePages.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: self.welcomePages[indexPath.item].reuseIdentifier,
            for: indexPath
        ) as! WelcomeCollectionViewCellInterface
        
        cell.page = self.welcomePages[indexPath.item]
        cell.delegate = self
        
        return cell
    }
}


extension WelcomeViewController: UICollectionViewDelegate {
    
}


extension WelcomeViewController: WelcomeCollectionViewCellInterfaceDelegate {
    
    func getButtonText(cell: WelcomeCollectionViewCellInterface) -> String? {
        
        guard let cellPage = cell.page else {
            return nil
        }
        
        if cellPage.title == WelcomePage.notification.title {
            self.notificationCell = cell
            return nil
        }
        
        if cellPage.title == WelcomePage.location.title {
            self.locationCell = cell
            
            if let locAuthStatus = self.appDelegate().getLocationAuthroizationStatus() {
                switch locAuthStatus {
                case .denied, .restricted:
                    return openSettingsButtonLabel
                case .notDetermined:
                    return allowLocationServicesButtonLabel
                case .authorizedAlways, .authorizedWhenInUse:
                    return completeButtonLabel
                }
            }
        }
        
        return nil
    }
    
    
    func getButtonText(cell: WelcomeCollectionViewCellInterface, completion: @escaping ((String?) -> Void)) {
        
        guard let cellPage = cell.page else {
            return
        }
        
        if cellPage.title == WelcomePage.notification.title {
            
            self.appDelegate().getNotificationAuthorization() { notificationSettings in
                
                switch notificationSettings.authorizationStatus {
                    
                case .notDetermined:
                    completion(allowPushNotificationsButtonLabel)
                    return
                case .denied:
                    completion(openSettingsButtonLabel)
                    return
                case .authorized:
                    completion(completeButtonLabel)
                    return
                case .provisional:
                    completion(openSettingsButtonLabel)
                    return
                }
                
            }
            
        }
        
        if cellPage.title == WelcomePage.location.title {
            if let locAuthStatus = self.appDelegate().getLocationAuthroizationStatus() {
                switch locAuthStatus {
                case .denied, .restricted:
                    completion(openSettingsButtonLabel)
                    return
                case .notDetermined:
                    completion(allowLocationServicesButtonLabel)
                    return
                case .authorizedAlways, .authorizedWhenInUse:
                    completion(completeButtonLabel)
                    return
                }
            }
        }
        
        completion(nil)
    }
    
    
    func getButtonColor(cell: WelcomeCollectionViewCellInterface) -> UIColor? {
        
        guard let cellPage = cell.page else {
            return nil
        }
        
        if cellPage.title == WelcomePage.location.title, let locAuthStatus = self.appDelegate().getLocationAuthroizationStatus() {
            switch locAuthStatus {
            case .denied, .restricted, .notDetermined:
                return .tiffanyBlue
            case .authorizedAlways, .authorizedWhenInUse:
                return .forrestGreen
            }
        }
        
        return nil
    }
    
    
    func getButtonColor(cell: WelcomeCollectionViewCellInterface, completion: @escaping ((UIColor?) -> Void)) {
        
        guard let cellPage = cell.page else {
            return
        }
        
        if cellPage.title == WelcomePage.notification.title {
            
            self.appDelegate().getNotificationAuthorization() { notificationSettings in
                
                switch notificationSettings.authorizationStatus {
                    
                case .notDetermined:
                    completion(.tiffanyBlue)
                    return
                case .denied:
                    completion(.tiffanyBlue)
                    return
                case .authorized:
                    completion(.forrestGreen)
                    return
                case .provisional:
                    completion(.tiffanyBlue)
                    return
                }
                
            }
        }
        
        if cellPage.title == WelcomePage.location.title, let locAuthStatus = self.appDelegate().getLocationAuthroizationStatus() {
            switch locAuthStatus {
            case .denied, .restricted, .notDetermined:
                completion(.tiffanyBlue)
            case .authorizedAlways, .authorizedWhenInUse:
                completion(.forrestGreen)
            }
        }
        
        completion(.tiffanyBlue)
    }
    
    
    func handleButtonPress(cell: WelcomeCollectionViewCellInterface) {
        
        guard let cellPage = cell.page else {
            return
        }
        
        if cellPage.title == WelcomePage.notification.title {
            
            self.appDelegate().getNotificationAuthorization() { notificationSettings in
                
                switch notificationSettings.authorizationStatus {
                    
                case .notDetermined:
                    self.appDelegate().requestNotificationAuthorization() {
                        cell.reloadDelegateData()
                    }
                    return
                case .denied:
                    self.appDelegate().openApplicationSettings()
                    return
                case .authorized:
                    return
                case .provisional:
                    self.appDelegate().openApplicationSettings()
                    return
                }
                
            }
            
        }
        
        if cellPage.title == WelcomePage.location.title {
            if cellPage.title == WelcomePage.location.title, let locAuthStatus = self.appDelegate().getLocationAuthroizationStatus() {
                switch locAuthStatus {
                case .denied, .restricted:
                    self.appDelegate().openApplicationSettings()
                    return
                case .notDetermined:
                    self.appDelegate().requestLocationServices()
                    return
                case .authorizedAlways, .authorizedWhenInUse:
                    return
                }
            }
        }
        
    }
    
    func notificationsAuthorized(_: Notification? = nil) {
        
        guard let notificationCell = self.notificationCell else {
            return
        }
        
        notificationCell.reloadDelegateData()
    }
    
    func locationServicesAuthorizationMayHaveChanged(_: Notification? = nil) {
        
        guard let locationCell = self.locationCell else {
            return
        }
        
        locationCell.reloadDelegateData()
    }
}
