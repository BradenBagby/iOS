//
//  UserReference.swift
//  PaceRides
//
//  Created by Grant Broadwater on 10/10/18.
//  Copyright © 2018 PaceRides. All rights reserved.
//

import Foundation
import Firebase

enum UserRefDBKeys: String {
    case displayName = "displayName"
    case reference = "reference"
}

class UserReference {
    
    private let data: [String: Any]
    
    let uid: String
    
    var displayName: String? {
        return self.data[UserRefDBKeys.displayName.rawValue] as? String
    }
    
    init?(fromDocument document: DocumentSnapshot) {
        
        guard let data = document.data() else {
            return nil
        }
        
        self.uid = document.documentID
        self.data = data
    }
    
}
