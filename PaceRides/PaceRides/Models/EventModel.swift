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
    
    static let NewData = Notification.Name("NewEventData")
    static let notificationCenter = NotificationCenter.default
    static let db = Firestore.firestore()
    static let ref = EventModel.db.collection(EventDBKeys.events.rawValue)
    
    private var data: [String: Any]? = nil
    
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
    
    
    private var docListener: ListenerRegistration? = nil
    
    
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
    
    /// Adds using block to notification obersvers then fetches
    func subscribe(using block: @escaping (Notification) -> Void) {
        EventModel.notificationCenter.addObserver(
            forName: EventModel.NewData,
            object: self,
            queue: OperationQueue.main,
            using: block
        )
        fetch()
    }
    
    
    /// Begins process of pulling down all data relevant to this organization
    func fetch() {
        
        guard self.docListener == nil else {
            EventModel.notificationCenter.post(
                name: EventModel.NewData,
                object: self
            )
            return
        }
        
        docListener = self.reference.addSnapshotListener(self.snapshotListener)
        
    }
    
    func snapshotListener(document: DocumentSnapshot?, error: Error?) {
        
        guard error == nil else {
            print(error!.localizedDescription)
            return
        }
        
        guard let document = document else {
            print("No event document for uid: \(self.uid)")
            return
        }
        
        guard let docData = document.data() else {
            print("No data in document for event uid: \(self.uid)")
            return
        }
        
        self.data = docData
        
        if let newTitle = docData[OrgDBKeys.title.rawValue] as? String {
            self._title = newTitle
        }
        
        EventModel.notificationCenter.post(
            name: EventModel.NewData,
            object: self
        )
    }
}
