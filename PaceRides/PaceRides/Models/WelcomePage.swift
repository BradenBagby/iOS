//
//  WelcomePageModel.swift
//  PaceRides
//
//  Created by Grant Broadwater on 11/6/18.
//  Copyright © 2018 PaceRides. All rights reserved.
//

import UIKit

class WelcomePage {
    
    static let welcome = WelcomePage(
        withTitle: "Welcome",
        message: "Pace Rides needs a couple of things before we get started.\n\n\n>>> Swipe to Continue >>>",
        reuseIdentifier: WelcomeCollectionViewCell.reuseIdentifier,
        cellType: WelcomeCollectionViewCell.self,
        andImage: .welcomeImage
    )
    
    static let notification = WelcomePage(
        withTitle: "Push Notifications",
        message: "We'll let you know when your ride gets there.",
        reuseIdentifier: WelcomeCollectionViewCell.reuseIdentifier,
        cellType: WelcomeCollectionViewCell.self,
        andImage: .notificationImage
    )
    
    static let location = WelcomePage(
        withTitle: "Location Services",
        message: "The drivers need to know where to pick you up.",
        reuseIdentifier: WelcomeCollectionViewCell.reuseIdentifier,
        cellType: WelcomeCollectionViewCell.self,
        andImage: .mapImage
    )
    
    static let facebookLogin = WelcomePage(
        withTitle: "Who Are You?",
        message: "We only ever look at your public profile.",
        reuseIdentifier: FacebookLoginCollectionViewCell.reuseIdentifier,
        cellType: FacebookLoginCollectionViewCell.self,
        andImage: .facebookIconImage
    )
    
    
    let title: String
    let message: String
    let reuseIdentifier: String
    let cellType: UICollectionViewCell.Type
    let image: UIImage?
    
    init(
        withTitle title: String,
        message: String,
        reuseIdentifier: String,
        cellType: UICollectionViewCell.Type,
        andImage image: UIImage?
    ) {
        self.title = title
        self.message = message
        self.reuseIdentifier = reuseIdentifier
        self.cellType = cellType
        self.image = image
    }
}
