//
//  History.swift
//  CountOn
//
//  Created by 4faramita on 2018/7/19.
//  Copyright © 2018年 4faramita. All rights reserved.
//

import Foundation
import RealmSwift
import IceCream

final class History: Object {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var isDeleted = false
    
    @objc dynamic var owner: Counter? // to-one relationships must be optional
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
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
        // self.status = status + action
    }
}

extension History: CKRecordConvertible { }

extension History: CKRecordRecoverable { }
