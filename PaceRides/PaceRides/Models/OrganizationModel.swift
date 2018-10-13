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
    
    case administrators = "administrators"
    case memberRequsts = "requests"
    
    case userDisplayName = "displayName"
    case userReference = "reference"
}


class OrganizationModel {
    
    static let NewData = Notification.Name("NewOrganizationData")
    static let notificationCenter = NotificationCenter.default
    private static let db = Firestore.firestore()
    private static let ref = OrganizationModel.db.collection("organizations")
    
    
    private var orgData: [String: Any]?
    private let reference: DocumentReference
    private var docListener: ListenerRegistration? = nil
    private var administratorsListener: ListenerRegistration? = nil
    private var membershipRequestsListener: ListenerRegistration? = nil
    
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
    
    private var _administrators: [UserReference]?
    var administrators: [UserReference]? {
        get {
            return _administrators
        }
    }
    
    private var _membershipRequests: [UserReference]?
    var membershipRequests: [UserReference]? {
        get {
            return _membershipRequests
        }
    }
    
    var link: String {
        get {
            return "https://pacerides.com/organization?id=\(self.uid)"
        }
    }
    
    
    init(withTitle title: String, andReference reference: DocumentReference) {
        self._title = title
        self.orgData = nil
        self.reference = reference
        self._administrators = nil
        self._membershipRequests = nil
    }
    
    
    init(withId id: String) {
        self._title = nil
        self.orgData = nil
        self.reference = OrganizationModel.db.collection(OrgDBKeys.organizations.rawValue).document(id)
        self._administrators = nil
        self._membershipRequests = nil
    }
    
    
    /// Adds using block to notification obersvers then fetches
    func subscribe(using block: @escaping (Notification) -> Void) {
        OrganizationModel.notificationCenter.addObserver(
            forName: OrganizationModel.NewData,
            object: self,
            queue: OperationQueue.main,
            using: block
        )
        fetch()
    }
    
    
    /// Begins process of pulling down all data relevant to this organization
    func fetch() {
        
        if orgData != nil {
            OrganizationModel.notificationCenter.post(
                name: OrganizationModel.NewData,
                object: self
            )
            return
        }
        
        if let listener = self.docListener {
            listener.remove()
        }
        
        docListener = self.reference.addSnapshotListener(self.snapshotListener)
        
        if let listener = self.administratorsListener {
            listener.remove()
        }
        
        administratorsListener = self.reference.collection(OrgDBKeys.administrators.rawValue)
            .addSnapshotListener(self.administratorsCollectionListener)
        
        membershipRequestsListener = self.reference.collection(OrgDBKeys.memberRequsts.rawValue)
            .addSnapshotListener(self.membershipRequestCollectionListener)
    }
    
    
    func requestMember(_ userPublicProfile: PacePublicProfile, completion: ((Error?) -> Void)? = nil) {
        
        let requestData: [String: Any] = [
            OrgDBKeys.userDisplayName.rawValue: userPublicProfile.displayName as Any,
            OrgDBKeys.userReference.rawValue: userPublicProfile.dbReference
        ]
        
        OrganizationModel.ref.document(self.uid).collection(OrgDBKeys.memberRequsts.rawValue)
            .document(userPublicProfile.uid).setData(requestData, options: SetOptions.merge(), completion: completion)
    }
    
    func cancelRequest(_ userPublicProfile: PacePublicProfile, completion: ((Error?) -> Void)? = nil) {
        OrganizationModel.ref.document(self.uid).collection(OrgDBKeys.memberRequsts.rawValue)
            .document(userPublicProfile.uid).delete(completion: completion)
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
    
    
    private func administratorsCollectionListener(querySnap: QuerySnapshot?, error: Error?) {
        
        guard error == nil else {
            print(error!.localizedDescription)
            return
        }
        
        guard let querySnap = querySnap else {
            print("No query snapshot returned")
            return
        }
        
        self._administrators = []
        for document in querySnap.documents {
            if let userRef = UserReference(fromDocument: document) {
                self._administrators!.append(userRef)
            }
        }
        
        OrganizationModel.notificationCenter.post(
            name: OrganizationModel.NewData,
            object: self
        )
    }
    
    private func membershipRequestCollectionListener(querySnap: QuerySnapshot?, error: Error?) {
        
        guard error == nil else {
            print(error!.localizedDescription)
            return
        }
        
        guard let querySnap = querySnap else {
            print("No query snapshot returned")
            return
        }
        
        self._membershipRequests = []
        for document in querySnap.documents {
            if let userRef = UserReference(fromDocument: document) {
                self._membershipRequests!.append(userRef)
            }
        }
        
        OrganizationModel.notificationCenter.post(
            name: OrganizationModel.NewData,
            object: self
        )
    }
}
