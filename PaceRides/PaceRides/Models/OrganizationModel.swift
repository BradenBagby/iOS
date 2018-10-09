//
//  OrganizationModel.swift
//  PaceRides
//
//  Created by Grant Broadwater on 10/9/18.
//  Copyright © 2018 PaceRides. All rights reserved.
//

import Foundation
import Firebase

typealias OrganizationCallback = ((OrganizationModel) -> Void)

class ShallowOrganizationModel {
    
    var title: String
    private var _fullOrganizationModel: OrganizationModel? = nil
    private let reference: DocumentReference
    
    init(withTitle title: String, andReference reference: DocumentReference) {
        self.title = title
        self.reference = reference
    }
    
    func fullOrganization(completion: OrganizationCallback? = nil) {
        
        if self._fullOrganizationModel == nil {
            self._fullOrganizationModel = OrganizationModel(atReference: self.reference)
        }
        
        if let completion = completion {
            completion(self._fullOrganizationModel!)
        }
    }
    
}

class OrganizationModel {
 
    init(atReference ref: DocumentReference) {
        
    }
    
}
