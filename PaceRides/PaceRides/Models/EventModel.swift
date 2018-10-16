//
//  EventReference.swift
//  PaceRides
//
//  Created by Grant Broadwater on 10/16/18.
//  Copyright © 2018 PaceRides. All rights reserved.
//

import Foundation
import Firebase


enum EventDBKeys: String {
    case events = "events"
    case title = "title"
    case reference = "reference"
}


class EventModel {
    
    static let db = Firestore.firestore()
    static let ref = EventModel.db.collection(EventDBKeys.events.rawValue)
    
    private let data: [String: Any]? = nil
    
    let uid: String
    
    var reference: DocumentReference
    
    private var _title: String?
    var title: String? {
        get {
            if let _title = self._title {
                return _title
            }
            if let data = self.data {
                return data[OrgDBKeys.title.rawValue] as? String
            }
            return nil
        }
    }
    

    private let _organization: OrganizationModel?
    var organization: OrganizationModel? {
        get {
            return self._organization
        }
    }
    
    
    init(fromReference refDoc: DocumentSnapshot, underOrganization organization: OrganizationModel? = nil) {
        
        self.uid = refDoc.documentID
        self._title = refDoc.data()?[EventDBKeys.title.rawValue] as? String
        self.reference = EventModel.ref.document(self.uid)
        self._organization = organization
    }
    
    
    init(withUID uid: String, andTitle title: String? = nil) {
        
        self.uid = uid
        self._title = title
        self.reference = EventModel.ref.document(self.uid)
        self._organization = nil
    }
    
}
