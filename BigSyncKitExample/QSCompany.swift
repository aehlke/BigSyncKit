//
//  QSCompany.swift
//  SyncKitRealmSwiftExample
//
//  Created by Manuel Entrena on 31/08/2017.
//  Copyright © 2017 Manuel Entrena. All rights reserved.
//

import RealmSwift
import BigSyncKit

class QSCompany: Object, PrimaryKey, SyncedDeletable {
    @objc dynamic var name: String? = ""
    @objc dynamic var identifier = ""
    let sortIndex = RealmOptional<Int>()
    
    let employees = LinkingObjects(fromType: QSEmployee.self, property: "company")
    
    @objc dynamic var isDeleted = false
    
    override class func primaryKey() -> String {
        
        return "identifier"
    }
}

