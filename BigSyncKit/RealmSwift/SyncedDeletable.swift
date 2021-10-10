//
//  SyncedDeletable.swift
//  BigSyncKit
//
//  Created by Alex Ehlke on 2021-10-10.
//

import Foundation

public protocol SyncedDeletable {
    var isDeleted: Bool { get }
}
