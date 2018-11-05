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
    
    case reference = "reference"
    
    case administrators = "administrators"
    case members = "members"
    case memberRequsts = "requests"
    
    case userDisplayName = "displayName"
    
    case events = "events"
}

enum PaceOrganizationErrors: Error {
    case AdminSelfRemoveError
}

extension PaceOrganizationErrors: CustomNSError {
    
    public static var errorDomain: String {
        return "PaceOrganizationErrors"
    }
    
    public var errorCode: Int {
        switch self {
        case .AdminSelfRemoveError:
            return 16001
        }
    }
    
    public var errorUserInfo: [String: Any] {
        switch self {
        case .AdminSelfRemoveError:
            return [:]
        }
    }
    
}


class OrganizationModel {
    
    static let NewData = Notification.Name("NewOrganizationData")
    static let NewMemberData = Notification.Name("NewOrganizationMemberData")
    static let notificationCenter = NotificationCenter.default
    private static let db = Firestore.firestore()
    private static let ref = OrganizationModel.db.collection("organizations")
    
    
    private var orgData: [String: Any]?
    let reference: DocumentReference
    private var docListener: ListenerRegistration? = nil
    private var administratorsListener: ListenerRegistration? = nil
    private var memberListener: ListenerRegistration? = nil
    private var membersListener: ListenerRegistration? = nil
    private var membershipRequestsListener: ListenerRegistration? = nil
    private var eventsListener: ListenerRegistration? = nil
    
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
    
    private var _administrators = [UserReference]()
    var administrators: [UserReference] {
        get {
            return _administrators
        }
    }
    
    private var _members = [UserReference]()
    var members: [UserReference] {
        return _members
    }
    
    private var _membershipRequests = [UserReference]()
    var membershipRequests: [UserReference] {
        get {
            return _membershipRequests
        }
    }
    
    private var _events = [EventModel]()
    var events: [EventModel] {
        get {
            return self._events
        }
    }
    
    var link: String {
        get {
            return "https://pacerides.com/organization?id=\(self.uid)"
        }
    }
    
    
    init(withTitle title: String?, andReference reference: DocumentReference) {
        self._title = title
        self.orgData = nil
        self.reference = reference
    }
    
    
    init(withId id: String) {
        self._title = nil
        self.orgData = nil
        self.reference = OrganizationModel.db.collection(OrgDBKeys.organizations.rawValue).document(id)
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
        
        guard self.docListener == nil else {
            OrganizationModel.notificationCenter.post(
                name: OrganizationModel.NewMemberData,
                object: self
            )
            OrganizationModel.notificationCenter.post(
                name: OrganizationModel.NewData,
                object: self
            )
            return
        }
        
        docListener = self.reference.addSnapshotListener(self.snapshotListener)
        administratorsListener = self.reference.collection(OrgDBKeys.administrators.rawValue)
            .addSnapshotListener(self.administratorsCollectionListener)
        membersListener = self.reference.collection(OrgDBKeys.members.rawValue)
            .addSnapshotListener(self.membersCollectionListener)
        membershipRequestsListener = self.reference.collection(OrgDBKeys.memberRequsts.rawValue)
            .addSnapshotListener(self.membershipRequestCollectionListener)
        eventsListener = self.reference.collection(OrgDBKeys.events.rawValue)
            .addSnapshotListener(self.eventsCollectionListener)
    }
    
    
    func requestMember(_ userPublicProfile: PacePublicProfile, completion: ((Error?) -> Void)? = nil) {
        
        let requestData: [String: Any] = [
            OrgDBKeys.userDisplayName.rawValue: userPublicProfile.displayName as Any,
            OrgDBKeys.reference.rawValue: userPublicProfile.dbReference
        ]
        
        OrganizationModel.ref.document(self.uid).collection(OrgDBKeys.memberRequsts.rawValue)
            .document(userPublicProfile.uid).setData(requestData, merge: true, completion: completion)
    }
    
    
    func cancelMembershipRequest(_ userPublicProfile: PacePublicProfile, completion: ((Error?) -> Void)? = nil) {
        self.reference.collection(OrgDBKeys.memberRequsts.rawValue).document(userPublicProfile.uid)
            .delete(completion: completion)
    }
    
    
    func rejectMembershipRequest(_ user: UserReference, completion: ((Error?) -> Void)? = nil) {
        self.reference.collection(OrgDBKeys.memberRequsts.rawValue).document(user.uid)
            .delete(completion: completion)
    }
    
    
    func acceptMembershipRequest(_ user: UserReference, completion: ((Error?) -> Void)? = nil) {
        let batch = OrganizationModel.db.batch()
        
        let reqRef = self.reference.collection(OrgDBKeys.memberRequsts.rawValue).document(user.uid)
        batch.deleteDocument(reqRef)
        
        let memData: [String: Any] = [
            OrgDBKeys.userDisplayName.rawValue: user.displayName as Any,
            OrgDBKeys.reference.rawValue: user.reference
        ]
        let memRef = self.reference.collection(OrgDBKeys.members.rawValue).document(user.uid)
        batch.setData(memData, forDocument: memRef)
        
        let userOrgData: [String: Any] = [
            UserDBKeys.title.rawValue: self.title as Any,
            UserDBKeys.reference.rawValue: self.reference
        ]
        let userOrgRef = user.reference.collection(UserDBKeys.organizations.rawValue).document(self.uid)
        batch.setData(userOrgData, forDocument: userOrgRef)
        
        batch.commit(completion: completion)
    }
    
    
    func removeMember(uid userUID: String, completion: ((Error?) -> Void)? = nil) {
        self.reference.collection(OrgDBKeys.members.rawValue).document(userUID)
            .delete(completion: completion)
    }
    
    
    func makeAdministrator(_ user: UserReference, completion: ((Error?) -> Void)? = nil) {
        let batch = OrganizationModel.db.batch()
        
        let memRef = self.reference.collection(OrgDBKeys.members.rawValue).document(user.uid)
        batch.deleteDocument(memRef)
        
        let adminData: [String: Any] = [
            OrgDBKeys.userDisplayName.rawValue: user.displayName as Any,
            OrgDBKeys.reference.rawValue: user.reference
        ]
        let adminRef = self.reference.collection(OrgDBKeys.administrators.rawValue).document(user.uid)
        batch.setData(adminData, forDocument: adminRef)
        
        batch.commit(completion: completion)
    }
    
    func removeAdministrator(_ user: UserReference, completion: ((Error?) -> Void)? = nil) {
        
        guard let paceUser = UserModel.sharedInstance() else {
            return
        }
        
        guard paceUser.uid != user.uid else {
            if let completion = completion {
                completion(PaceOrganizationErrors.AdminSelfRemoveError)
            }
            return
        }
        
        let batch = OrganizationModel.db.batch()
        
        let adminRef = self.reference.collection(OrgDBKeys.administrators.rawValue).document(user.uid)
        batch.deleteDocument(adminRef)
        
        let memberData: [String: Any] = [
            OrgDBKeys.userDisplayName.rawValue: user.displayName as Any,
            OrgDBKeys.reference.rawValue: user.reference
        ]
        let memberRef = self.reference.collection(OrgDBKeys.members.rawValue).document(user.uid)
        batch.setData(memberData, forDocument: memberRef)
        
        batch.commit(completion: completion)
    }
    
    func createEvent(withTitle title: String, completion: ((Error?) -> Void)? = nil) {
        
        guard !title.isEmpty else {
            if let completion = completion {
                completion(NSError(domain: "PaceEventError", code: 11111, userInfo: nil))
            }
            return
        }
        
        let batch = OrganizationModel.db.batch()
        
        let eventRef = EventModel.ref.document()
        let eventOrgData: [String: Any] = [
            EventDBKeys.title.rawValue: self.title as Any,
            EventDBKeys.reference.rawValue: self.reference
        ]
        let eventData: [String: Any] = [
            EventDBKeys.title.rawValue: title,
            EventDBKeys.organization.rawValue: eventOrgData
        ]
        batch.setData(eventData, forDocument: eventRef)
        
        let orgEventRef = self.reference.collection(OrgDBKeys.events.rawValue).document(eventRef.documentID)
        let orgEventData: [String: Any] = [
            OrgDBKeys.title.rawValue: title,
            OrgDBKeys.reference.rawValue: eventRef
        ]
        batch.setData(orgEventData, forDocument: orgEventRef)
        
        batch.commit(completion: completion)
    }
    
    
    func hasEventPrivileges() -> Bool {
        if let subscription = self.subscription, subscription == 1 {
            return true
        }
        return false
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
        
        if let newTitle = docData[OrgDBKeys.title.rawValue] as? String {
            self._title = newTitle
        }
        
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
        
        self._administrators.removeAll()
        for document in querySnap.documents {
            if let userRef = UserReference(fromDocument: document) {
                self._administrators.append(userRef)
            }
        }
        
        OrganizationModel.notificationCenter.post(
            name: OrganizationModel.NewData,
            object: self
        )
    }
    
    private func membersCollectionListener(querySnap: QuerySnapshot?, error: Error?) {
        
        guard error == nil else {
            print(error!.localizedDescription)
            return
        }
        
        guard let querySnap = querySnap else {
            print("No query snapshot returned")
            return
        }
        
        self._members.removeAll()
        for document in querySnap.documents {
            if let userRef = UserReference(fromDocument: document) {
                self._members.append(userRef)
            }
        }
        
        OrganizationModel.notificationCenter.post(
            name: OrganizationModel.NewMemberData,
            object: self
        )
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
        
        self._membershipRequests.removeAll()
        for document in querySnap.documents {
            if let userRef = UserReference(fromDocument: document) {
                self._membershipRequests.append(userRef)
            }
        }
        
        OrganizationModel.notificationCenter.post(
            name: OrganizationModel.NewData,
            object: self
        )
    }
    
    
    private func eventsCollectionListener(querySnap: QuerySnapshot?, error: Error?) {
        
        guard error == nil else {
            print(error!.localizedDescription)
            return
        }
        
        guard let querySnap = querySnap else {
            print("No query snapshot returned")
            return
        }
        
        self._events.removeAll()
        for document in querySnap.documents {
            self._events.append(EventModel(fromReference: document, underOrganization: self))
        }
        
        OrganizationModel.notificationCenter.post(
            name: OrganizationModel.NewData,
            object: self
        )
    }
}
