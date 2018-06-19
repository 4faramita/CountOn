//
//  CounterViewController.swift
//  CountOn
//
//  Created by 4faramita on 2018/4/15.
//  Copyright © 2018年 4faramita. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import RealmSwift
import RxSwift
import RxCocoa
//import RxRealm
//import GTTexture_RxExtension

final class CounterViewController:  ASViewController<ASDisplayNode>, ASTableDataSource, ASTableDelegate, ASCommonTableDataSource {
    
    let disposeBag = DisposeBag()
    
    var tableNode: ASTableNode {
        return node as! ASTableNode
    }
    
    var notificationToken: NotificationToken?
    
    init() {
        super.init(node: ASTableNode())
        tableNode.delegate = self
        tableNode.dataSource = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //    MARK: Rx
        SearchAddBarView.shared.searchField.rx
            .text
            .orEmpty
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] keyword in
                print("emit \(keyword)")
                if keyword.isEmpty {
                    CounterStore.shared.reset()
                } else {
                    CounterStore.shared.filter(with: keyword)
                }
                self?.tableNode.reloadData()
            }).disposed(by: disposeBag)
        
        
//        MARK: table
        
        tableNode.contentInset = UIEdgeInsets(top: 24, left: 0, bottom: 80, right: 0)
        tableNode.view.separatorStyle = .none
        // FIXME: Should be disabled
        tableNode.view.allowsSelection = true
        
        if CounterStore.shared.count == 0 { setupData() }
        
        // Set results notification block
        self.notificationToken = CounterStore.shared.items.observe { (changes: RealmCollectionChange) in
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                self.tableNode.reloadData()
                break
            case .update(_, let deletions, let insertions, let modifications):
                // Query results have changed, so apply them to the TableView
                self.tableNode.performBatchUpdates({
                    self.tableNode.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                    self.tableNode.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                    self.tableNode.reloadRows(at: modifications.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                }, completion:nil)
                break
            case .error(let err):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(err)")
                break
            }
        }
    }
    
    
    // MARK: ASTableNode data source and delegate.
    
    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        // Should read the row count directly from table view but
        // https://github.com/facebook/AsyncDisplayKit/issues/1159

        let counter = CounterStore.shared.item(at: indexPath.row)
        
        let node = CounterCellNode(with: counter)
        node.style.height = ASDimensionMake(UIScreen.main.bounds.size.width / 375 * 85)
        
        return node
    }
    
//    FIXME: Disable Swipe to delete.
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            CounterStore.shared.remove(at: indexPath.row)
        }
    }
    
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 1
    }
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return CounterStore.shared.count
    }
    
//    FIXME: Disabled selection
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        print(CounterStore.shared.item(at: indexPath.row).history.first!)
    }
    
    // MARK: Dummy Data
    
    func setupData() {
        DispatchQueue.global().async {
            // Get new realm and table since we are in a new thread
            autoreleasepool {
                let realm = try! Realm()
                realm.beginWrite()
                for _ in 0 ..< 10 {
                    realm.add(CounterViewController.generateCounter())
                }
                try! realm.commitWrite()
            }
        }
    }
    
    // MARK: Helpers
    
    static func generateCounter(
        _ title: String? = nil,
        at date: Date? = nil,
        from status: Int? = nil,
        of type: Int? = nil
    ) -> Counter {
        let counter = Counter()
        
        if let title = title, title.count > 0 {
            counter.title = title
        } else {
            counter.title = CounterViewController.randomString()
        }
        
        counter.status = status ?? Int(arc4random()) % 100
        counter.type = type ?? counter.status % 3
        
        let history = History(from: status ?? Int(arc4random()) % 100)
        history.date = date ?? CounterViewController.randomDate()
        counter.last = history.date
        counter.history.append(history)
        
        return counter
    }
    
    @objc func add() {
        CounterStore.shared.insert(item: CounterViewController.generateCounter())
    }
    
    class func randomString() -> String {
        return "Title \(arc4random())"
    }
    
    class func randomDate() -> Date {
        return Date(timeInterval: TimeInterval(arc4random() % 3600), since: 1.hours.earlier)
    }
}
