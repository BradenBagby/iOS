//
//  OrganizationModel.swift
//  PaceRides
//
//  Created by Grant Broadwater on 10/9/18.
//  Copyright © 2018 PaceRides. All rights reserved.
//

import Foundation
import Firebase


extension NSNotification.Name {
    public static let NewOrganizationData = Notification.Name("NewOrganizationData")
}


enum OrgDBKeys: String {
    case organization = "organization"
}


class OrganizationModel {
    
    static let notificationCenter = NotificationCenter.default
    private static let db = Firestore.firestore()
    
    
    private var orgData: [String: Any]?
    private let reference: DocumentReference
    private var listener: ListenerRegistration?
    
    var title: String?
    
    var uid: String {
        get {
            return self.reference.documentID
        }
    }
    
    init(withTitle title: String, andReference reference: DocumentReference) {
        self.title = title
        self.orgData = nil
        self.reference = reference
        self.listener = nil
    }
    
    init(withId id: String) {
        self.title = nil
        self.orgData = nil
        self.reference = OrganizationModel.db.collection(OrgDBKeys.organization.rawValue).document(id)
        self.listener = nil
    }
    
    
    func fetch() {
        
        if orgData != nil {
            OrganizationModel.notificationCenter.post(
                name: .NewOrganizationData,
                object: self
            )
            return
        }
        
        if let listener = self.listener {
            listener.remove()
        }
        
        listener = OrganizationModel.db.collection(OrgDBKeys.organization.rawValue)
            .document(self.reference.documentID).addSnapshotListener(self.snapshotListener)
    }
    
    private func snapshotListener(document: DocumentSnapshot?, error: Error?) {
        
    }
}
