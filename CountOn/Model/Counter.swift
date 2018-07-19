//
//  Counter.swift
//  CountOn
//
//  Created by 4faramita on 2018/4/15.
//  Copyright © 2018年 4faramita. All rights reserved.
//

import Foundation
import RealmSwift
import IceCream

final class Counter: Object {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var title = ""
    @objc dynamic var note = ""
    @objc dynamic var type = 0 // { 0: increase, 1: decrease, 2: both }
    @objc dynamic var status = 0
    @objc dynamic var isDeleted = false
    let history = LinkingObjects(fromType: History.self, property: "owner").sorted(byKeyPath: "date", ascending: false)
    
    @objc dynamic var last = Date()  // for sorting
    
    override class func primaryKey() -> String? {
        return "id"
    }
}

extension Counter: CKRecordConvertible { }

extension Counter: CKRecordRecoverable { }
