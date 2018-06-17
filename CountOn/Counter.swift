//
//  Counter.swift
//  CountOn
//
//  Created by 4faramita on 2018/4/15.
//  Copyright © 2018年 4faramita. All rights reserved.
//

import Foundation
import RealmSwift

final class Counter: Object {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var title = ""
    @objc dynamic var note = ""
    @objc dynamic var type = 0 // { 0: increase, 1: decrease, 2: both }
    @objc dynamic var status = 0
    let history = List<History>() // insert from head
}

class History: Object {
    @objc dynamic var date = Date()
    @objc dynamic var action = 0 // {1: increase, -1: decrease, 0: init}
}
