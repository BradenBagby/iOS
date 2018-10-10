//
//  OrganizationModel.swift
//  PaceRides
//
//  Created by Grant Broadwater on 10/9/18.
//  Copyright © 2018 PaceRides. All rights reserved.
//

import Foundation
import Firebase


enum OrgDBKeys: String {
    case organizations = "organizations"
    case title = "title"
    case subscription = "subscription"
}


class OrganizationModel {
    
    static let NewData = Notification.Name("NewOrganizationData")
    static let notificationCenter = NotificationCenter.default
    private static let db = Firestore.firestore()
    
    
    private var orgData: [String: Any]?
    private let reference: DocumentReference
    private var listener: ListenerRegistration?
    
    private var _title: String?
    var title: String? {
        get {
            if let _title = self._title {
                return _title
            }
            if let data = self.orgData {
                return data[OrgDBKeys.title.rawValue] as? String
            }
            return nil
        }
    }
    
    var subscription: Int? {
        get {
            if let data = self.orgData {
                return data[OrgDBKeys.subscription.rawValue] as? Int
            }
            return nil
        }
    }
    
    var uid: String {
        get {
            return self.reference.documentID
        }
    }
    
    init(withTitle title: String, andReference reference: DocumentReference) {
        self._title = title
        self.orgData = nil
        self.reference = reference
        self.listener = nil
    }
    
    init(withId id: String) {
        self._title = nil
        self.orgData = nil
        self.reference = OrganizationModel.db.collection(OrgDBKeys.organizations.rawValue).document(id)
        self.listener = nil
    }
    
    func subscribe(using block: @escaping (Notification) -> Void) {
        OrganizationModel.notificationCenter.addObserver(
            forName: OrganizationModel.NewData,
            object: self,
            queue: OperationQueue.main,
            using: block
        )
        fetch()
    }
    
    func fetch() {
        
        if orgData != nil {
            OrganizationModel.notificationCenter.post(
                name: OrganizationModel.NewData,
                object: self
            )
            return
        }
        
        if let listener = self.listener {
            listener.remove()
        }
        
        listener = OrganizationModel.db.collection(OrgDBKeys.organizations.rawValue)
            .document(self.reference.documentID).addSnapshotListener(self.snapshotListener)
    }
    
    private func snapshotListener(document: DocumentSnapshot?, error: Error?) {
        
        guard error == nil else {
            print(error!.localizedDescription)
            return
        }
        
        guard let document = document else {
            print("No organization document for uid: \(self.uid)")
            return
        }
        
        guard let docData = document.data() else {
            print("No data in document for uid: \(self.uid)")
            return
        }
        
        self.orgData = docData
        
        OrganizationModel.notificationCenter.post(
            name: OrganizationModel.NewData,
            object: self
        )
    }
}
