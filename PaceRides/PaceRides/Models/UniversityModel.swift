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
    
    private init?(fromDocument document: DocumentSnapshot) {
        if let data = document.data() {
            self.documentData = data
        } else {
            return nil
        }
    }
}
