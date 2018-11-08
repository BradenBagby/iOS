//
//  PaceRidesConstants.swift
//  PaceRides
//
//  Created by Grant Broadwater on 9/30/18.
//  Copyright © 2018 PaceRides. All rights reserved.
//

import Foundation

let APPLICATION_TITLE = "Pace Rides"

extension UIColor {
    open class var forrestGreen: UIColor {
        get {
            return UIColor.init(red: 2.0 / 255.0, green: 136.0 / 255.0, blue: 77.0 / 255.0, alpha: 1.0)
        }
    }
    
    open class var coral: UIColor {
        get {
            return UIColor.init(red: 252.0/255.0, green: 105.0/255.0, blue: 64.0/255.0, alpha: 1.0)
        }
    }
    
    open class var tiffanyBlue: UIColor {
        get {
            return UIColor.init(red: 118.0/255.0, green: 199.0/255.0, blue: 191.0/255.0, alpha: 1.0)
        }
    }
}


extension UIImage {
    
    static var welcomeImage: UIImage? {
        return UIImage(named: "welcome")
    }
    
    static var notificationImage: UIImage? {
        return UIImage(named: "notification")
    }
    
    static var mapImage: UIImage? {
        return UIImage(named: "map")
    }
    
    static var facebookIconImage: UIImage? {
        return UIImage(named: "facebookIcon")
    }
}
