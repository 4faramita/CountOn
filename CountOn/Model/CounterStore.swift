//
//  CounterStore.swift
//  CountOn
//
//  Created by 4faramita on 2018/6/19.
//  Copyright © 2018年 4faramita. All rights reserved.
//

import RealmSwift

final class CounterStore {
    static let shared = CounterStore()
    
    private let realm = try! Realm()
    
    private let allItems = try! Realm().objects(Counter.self)
        .filter("isDeleted = false")
        .sorted(byKeyPath: "last", ascending: false)
    
    
    private(set) var items: Results<Counter>
    
    private init() {
        items = allItems
    }
    
    func reset() {
        items = allItems
    }
    
    func filter(with keyword: String) {
        items = allItems
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
    
    // func append(item: ToDoItem) {
    //     items.append(item)
    // }
    
    // func append(newItems: [ToDoItem]) {
    //     items.append(contentsOf: newItems)
    // }

    func remove(item: Counter) {
        try! realm.write {
            item.isDeleted = true
            // realm.delete(item)
        }
    }

    func remove(at index: Int) {
        try! realm.write {
            items[index].isDeleted = true
            // realm.delete(items[index])
        }
    }
    
    func removeAll() {
        try! realm.write {
            // while !items.isEmpty {
            //     if let item = items.first {
            //         realm.delete(item)
            //     }
            // }
            for item in items {
                item.isDeleted = true
            }
        }
    }

    // func edit(original: ToDoItem, new: ToDoItem) {
    //     guard let index = items.index(of: original) else { return }
    //     items[index] = new
    // }

    var count: Int {
        return items.count
    }

    func item(at index: Int) -> Counter {
        return items[index]
    }
}
