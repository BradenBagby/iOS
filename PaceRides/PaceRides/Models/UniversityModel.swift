//
//  UniversityModel.swift
//  PaceRides
//
//  Created by Grant Broadwater on 10/8/18.
//  Copyright © 2018 PaceRides. All rights reserved.
//

import Foundation
import Firebase

typealias UniversityCompletionHandler = ((UniversityModel?, Error?) -> Void)

enum UniversityDBKeys: String {
    case schoolEmails = "school-emails"
    case name = "name"
    case shorthand = "shorthand"
    case primaryColor = "primaryColor"
    case accentColor = "accentColor"
    case textColor = "textColor"
    case unselectedColor = "unselectedColor"
}


class UniversityModel {
    
    private static let db = Firestore.firestore()
    
    static func getUniversity(withEmailDomain emailDomain: String, completion: UniversityCompletionHandler? = nil) {
        
        db.collection(UniversityDBKeys.schoolEmails.rawValue).document(emailDomain).getDocument() { document, error in
            
            guard error == nil else {
                if let completion = completion {
                    completion(nil, error)
                }
                return
            }
            
            guard let document = document else {
                if let completion = completion {
                    completion(nil, nil)
                }
                return
            }
            
            if let completion = completion {
                completion(UniversityModel(fromDocument: document), nil)
            }
        }
    }
    
    private let documentData: [String: Any]
    
    var name: String? {
        get {
            return self.documentData[UniversityDBKeys.name.rawValue] as? String
        }
    }
    
    var shorthand: String? {
        get {
             return self.documentData[UniversityDBKeys.shorthand.rawValue] as? String
        }
    }
    
    var primaryColor: UIColor? {
        get {
            if let primaryColorData = self.documentData[UniversityDBKeys.primaryColor.rawValue] as? [String:Any],
                    let r = primaryColorData["red"] as? Double,
                    let g = primaryColorData["green"] as? Double,
                    let b = primaryColorData["blue"] as? Double {
                
                return UIColor(
                    red: CGFloat(r / 255.0),
                    green: CGFloat(g / 255.0),
                    blue: CGFloat(b / 255.0),
                    alpha: 1.0
                )
            }
            return nil
        }
    }
    
    var accentColor: UIColor? {
        get {
            if let accentColorData = self.documentData[UniversityDBKeys.accentColor.rawValue] as? [String:Any],
                let r = accentColorData["red"] as? Double,
                let g = accentColorData["green"] as? Double,
                let b = accentColorData["blue"] as? Double {
                
                return UIColor(
                    red: CGFloat(r / 255.0),
                    green: CGFloat(g / 255.0),
                    blue: CGFloat(b / 255.0),
                    alpha: 1.0
                )
            }
            return nil
        }
    }
    
    var textColor: UIColor? {
        get {
            if let textColorData = self.documentData[UniversityDBKeys.textColor.rawValue] as? [String:Any],
                let r = textColorData["red"] as? Double,
                let g = textColorData["green"] as? Double,
                let b = textColorData["blue"] as? Double {
                
                return UIColor(
                    red: CGFloat(r / 255.0),
                    green: CGFloat(g / 255.0),
                    blue: CGFloat(b / 255.0),
                    alpha: 1.0
                )
            }
            return nil
        }
    }
    
    var unselectedColor: UIColor? {
        get {
            if let unselectedColor = self.documentData[UniversityDBKeys.unselectedColor.rawValue] as? [String:Any],
                let r = unselectedColor["red"] as? Double,
                let g = unselectedColor["green"] as? Double,
                let b = unselectedColor["blue"] as? Double {
                
                return UIColor(
                    red: CGFloat(r / 255.0),
                    green: CGFloat(g / 255.0),
                    blue: CGFloat(b / 255.0),
                    alpha: 1.0
                )
            }
            return nil
        }
    }
    
    
    private init?(fromDocument document: DocumentSnapshot) {
        if let data = document.data() {
            self.documentData = data
        } else {
            return nil
        }
    }
}
