//
//  OrganizationModel.swift
//  PaceRides
//
//  Created by Grant Broadwater on 10/9/18.
//  Copyright © 2018 PaceRides. All rights reserved.
//

import Foundation
import Firebase


class OrganizationModel {
    
    var title: String
    private var orgData: [String: Any]?
    private let reference: DocumentReference
    
    init(withTitle title: String, andReference reference: DocumentReference) {
        self.title = title
        self.reference = reference
    }
}
