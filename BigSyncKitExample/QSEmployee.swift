//
//  QSEmployee.swift
//  SyncKitRealmSwiftExample
//
//  Created by Manuel Entrena on 31/08/2017.
//  Copyright © 2017 Manuel Entrena. All rights reserved.
//

import RealmSwift
import BigSyncKit

class QSEmployee: Object, PrimaryKey, ParentKey, SyncedDeletable {
    @objc dynamic var name: String? = ""
    let sortIndex = RealmOptional<Int>()
    @objc dynamic var identifier = ""
    @objc dynamic var photo: Data? = nil
    
    @objc dynamic var company: QSCompany?

    @objc dynamic var isDeleted = false
    
    override class func primaryKey() -> String {
        return "identifier"
    }
    
    static func parentKey() -> String {
        return "company"
    }
}
