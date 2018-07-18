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
    var history = List<History>() // insert from head
    
    @objc dynamic var last = Date()  // for sorting
    
    override class func primaryKey() -> String? {
        return "id"
    }
}

class History: Object {
    @objc dynamic var date = Date()
    @objc dynamic var action = 0 // {1: increase, -1: decrease, 0: init}
    @objc dynamic var status = -1
    
    convenience init(from status: Int) {
        self.init()
        
        self.status = status
    }
    
    convenience init(typeOf action: Int) {
        self.init()
        
        self.action = action
//        self.status = status + action
    }
}

extension Counter: CKRecordConvertible {
    // Yep, leave it blank!
}

extension Counter: CKRecordRecoverable {
    // Leave it blank, too.
}
