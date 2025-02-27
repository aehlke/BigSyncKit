//
//  QSObjectIdKeyObject.swift
//  SyncKitRealmSwiftExampleTests
//
//  Created by Manuel Entrena on 02/05/2021.
//  Copyright © 2021 Manuel Entrena. All rights reserved.
//

import RealmSwift
import BigSyncKit

class QSObjectIdKeyObject: Object, PrimaryKey, SyncedDeletable {
    @objc dynamic var name: String? = ""
    @objc dynamic var identifier: ObjectId = ObjectId.generate()
    
    @objc dynamic var isDeleted = false
    
    override class func primaryKey() -> String {
        
        return "identifier"
    }
}

class QSCompany_ObjId: Object, PrimaryKey, SyncedDeletable {
    @objc dynamic var name: String? = ""
    @objc dynamic var identifier: ObjectId = ObjectId.generate()
    let sortIndex = RealmOptional<Int>()
    
    let employees = LinkingObjects(fromType: QSEmployee_ObjId.self, property: "company")
    
    @objc dynamic var isDeleted = false
    
    override class func primaryKey() -> String {
        
        return "identifier"
    }
}

class QSEmployee_ObjId: Object, PrimaryKey, ParentKey, SyncedDeletable {
    @objc dynamic var name: String? = ""
    let sortIndex = RealmOptional<Int>()
    @objc dynamic var identifier: ObjectId = ObjectId.generate()
    @objc dynamic var photo: Data? = nil
    
    @objc dynamic var company: QSCompany_ObjId?
    
    @objc dynamic var isDeleted = false
    
    override class func primaryKey() -> String {
        return "identifier"
    }
    
    static func parentKey() -> String {
        return "company"
    }
}
