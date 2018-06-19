//
//  CounterStore.swift
//  CountOn
//
//  Created by 4faramita on 2018/6/19.
//  Copyright © 2018年 4faramita. All rights reserved.
//

import RealmSwift

class CounterStore {
    static let shared = CounterStore()
    
//    var id = UUID().uuidString
    
    let realm = try! Realm()
    private(set) var items = try! Realm().objects(Counter.self)
        .sorted(byKeyPath: "last", ascending: false)
//    {
//        didSet {
//            self.id = UUID().uuidString
//        }
//    }
    
    private init() {}
    
    func reset() {
        items = try! Realm().objects(Counter.self)
            .sorted(byKeyPath: "last", ascending: false)
    }
    
    func filter(with keyword: String) {
        items = try! Realm().objects(Counter.self)
            .sorted(byKeyPath: "last", ascending: false)
            .filter("title CONTAINS[cd] '\(keyword)'")
    }
    
    func insert(item: Counter) {
        try! realm.write {
            realm.add(item)
        }
    }
    
    func insert(newItems: [Counter]) {
        try! realm.write {
            realm.add(newItems)
        }
    }
    
//    func append(item: ToDoItem) {
//        items.append(item)
//    }

//    func append(newItems: [ToDoItem]) {
//        items.append(contentsOf: newItems)
//    }

    func remove(item: Counter) {
        try! realm.write {
            realm.delete(item)
        }
    }

    func remove(at index: Int) {
        try! realm.write {
            realm.delete(items[index])
        }
    }

//    func edit(original: ToDoItem, new: ToDoItem) {
//        guard let index = items.index(of: original) else { return }
//        items[index] = new
//    }

    var count: Int {
        return items.count
    }

    func item(at index: Int) -> Counter {
        return items[index]
    }
}
