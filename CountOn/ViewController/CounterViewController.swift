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
import EasyTipView
import SwiftyUserDefaults
import SideMenu

final class CounterViewController:  ASViewController<ASDisplayNode> {
    
    let disposeBag = DisposeBag()
    
    var arrowedNode: ArrowedNode {
        return node as! ArrowedNode
    }
    
    var tableNode: ASTableNode {
        return arrowedNode.tableNode
    }
    
    var notificationToken: NotificationToken?
    
    let dismissKeyboardTipView = EasyTipView(text: R.string.localizable.swipeDownTheBarToDismissKeyboard())
    
    init() {        
        super.init(node: ArrowedNode())
        
        tableNode.delegate = self
        tableNode.dataSource = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // MARK: Side menu
        let menuViewConreoller = MenuViewController()
        let menuRightNavigationController = UISideMenuNavigationController(rootViewController: menuViewConreoller)
        SideMenuManager.default.menuRightNavigationController = menuRightNavigationController
        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: tableNode.view)
        SideMenuManager.default.menuPresentMode = .viewSlideInOut
        SideMenuManager.default.menuFadeStatusBar = false
        
        // MARK: Tip
        var downPointingTipPreferences = EasyTipView.Preferences()
        downPointingTipPreferences.drawing.font = UIFont(name: "Futura-Medium", size: 13)!
        downPointingTipPreferences.drawing.foregroundColor = UIColor.white
        downPointingTipPreferences.drawing.backgroundColor = UIColor(hue:0.46, saturation:0.99, brightness:0.6, alpha:1)
        downPointingTipPreferences.drawing.arrowPosition = EasyTipView.ArrowPosition.bottom
        EasyTipView.globalPreferences = downPointingTipPreferences
        
        // FIXME: Arrow tip
        //
        // var rightPointingTipPreferences = EasyTipView.Preferences()
        // rightPointingTipPreferences.drawing.font = UIFont(name: "Futura-Medium", size: 13)!
        // rightPointingTipPreferences.drawing.foregroundColor = UIColor.white
        // rightPointingTipPreferences.drawing.backgroundColor = UIColor(hue:0.46, saturation:0.99, brightness:0.6, alpha:1)
        // rightPointingTipPreferences.drawing.arrowPosition = EasyTipView.ArrowPosition.right
        //
        // var sideMenuTipView = EasyTipView(text: "Slide to right to open menu", preferences: rightPointingTipPreferences)
        //
        // if !Defaults[.knowSideMenu] {
        //     print(">>> doesn't know side menu")
        //
        //     sideMenuTipView.show(forView: arrowedNode.arrow.view)
        // }
        
        // MARK: Rx
        
        SearchAddBarView.shared.searchField.rx
            .controlEvent(UIControlEvents.editingDidBegin)
            .delay(1, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                if !Defaults[.knowSwipeDownSearch] {
                    self?.dismissKeyboardTipView.show(forView: SearchAddBarView.shared)
                }
            })
            .disposed(by: disposeBag)
        
        SearchAddBarView.shared.searchField.rx
            .text
            .orEmpty
            .subscribe(onNext: { [weak self] keyword in
                if keyword.isEmpty {
                    CounterStore.shared.reset()
                } else {
                    CounterStore.shared.filter(with: keyword)
                }
                self?.tableNode.reloadData()
            })
            .disposed(by: disposeBag)
        
        SearchAddBarView.shared.addButton.rx
            .tap
            .subscribe(onNext: { [weak self] _ in
                let title = SearchAddBarView.shared.searchField.text ?? ""
                let detailVC = DetailViewController(with: title)
                DispatchQueue.main.async {
                    self?.present(detailVC, animated: true)
                }
            })
            .disposed(by: disposeBag)
        
        SearchAddBarView.shared.rx
            .swipeGesture([.down])
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                Defaults[.knowSwipeDownSearch] = true
                self?.dismissKeyboardTipView.dismiss()
                SearchAddBarView.shared.searchField.resignFirstResponder()
            })
            .disposed(by: disposeBag)

        
        // MARK: table
        
        tableNode.contentInset = UIEdgeInsets(top: 24, left: 0, bottom: 80, right: 0)
        tableNode.view.separatorStyle = .none
        tableNode.view.allowsSelection = true
        
        tableNode.view.keyboardDismissMode = .interactive
        
        
        // MARK: First launch
        // FIXME
         if !Defaults[.launchedBefore] {
            setupData()
            Defaults[.launchedBefore] = true
         }
        
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
    
    // MARK: Dummy Data
    
    func setupData() {
        DispatchQueue.global().async {
            // Get new realm and table since we are in a new thread
            autoreleasepool {
                let first = CounterViewController.generateCounter(R.string.localizable.clickHereToStart(), at: Date(), from: 42)
                let second = CounterViewController.generateCounter(R.string.localizable.takeAIbuprofenPill(), from: 0, of: 0)
                let third = CounterViewController.generateCounter(R.string.localizable.run5km100Times(), from: 100, of: 1)
                let fourth = CounterViewController.generateCounter(R.string.localizable.slapBetBank(), from: 5, of: 2)
                
                let realm = try! Realm()
                try! realm.write {
                    first.note = R.string.localizable.helloThisIsACounterItCanRepresentsTheHistoryOfAnActivityOrTheNumberOfAItemBasicallyAnythingYouWantClickDoneToCheckOtherCounters()
                    second.note = R.string.localizable.thisCounterOnlyGoesUpMaybeForAActivityYouRegularlyDo() + R.string.localizable.youCanChangeTheDetailOfACounterButYouCannotChangeTheHistory()
                    third.note = R.string.localizable.thisCounterOnlyGoesDownMaybeForAGoalYouHopeToAchieve() + R.string.localizable.youCanTapOnTheHistoryListToChangeBetweenRelativeAndAbsoluteTime()
                    fourth.note = R.string.localizable.thisCounterCanGoUpAndDownMaybeForKeepingTrackOfACertainKindOfItem() + R.string.localizable.atAnyTimeYouCanSwipeDownOnTheBottomBarToDismissTheKeyboard()
                    
                    realm.add([first, second, third, fourth])
                }
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
        history.owner = counter
        let realm = try! Realm()
        try! realm.write {
            counter.last = history.date
            realm.add(history)
        }
        
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

extension CounterViewController: ASTableDataSource, ASTableDelegate, ASCommonTableDataSource {
    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        // Should read the row count directly from table view but
        // https://github.com/facebook/AsyncDisplayKit/issues/1159
        
        let counter = CounterStore.shared.item(at: indexPath.row)

        let node = CounterCellNode(with: counter)
        node.style.height = ASDimensionMake(UIScreen.main.bounds.size.width / 375 * 85)
        
        node.selectionStyle = .none
        
        return node
    }
    
    // Disabled Swipe to delete.
    // func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    //     if editingStyle == .delete {
    //         CounterStore.shared.remove(at: indexPath.row)
    //     }
    // }
    
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 1
    }
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return CounterStore.shared.count
    }
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        let detailVC = DetailViewController(of: CounterStore.shared.item(at: indexPath.row))
        
        DispatchQueue.main.async { [weak self] in
            self?.present(detailVC, animated: true, completion: {
                self?.tableNode.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            })
        }
    }
}

extension CounterViewController: EasyTipViewDelegate {
    func easyTipViewDidDismiss(_ tipView: EasyTipView) {
        if tipView == self.dismissKeyboardTipView {
            Defaults[.knowSwipeDownSearch] = true
        }
    }
}

extension CounterViewController: UISideMenuNavigationControllerDelegate {
    func sideMenuWillAppear(menu: UISideMenuNavigationController, animated: Bool) {
        UIApplication.shared.windows.first?.bringSubview(toFront: SearchAddBarView.shared)
        UIApplication.shared.windows.first?.bringSubview(toFront: DoneCancelBarView.shared)
    }
    
     func sideMenuDidAppear(menu: UISideMenuNavigationController, animated: Bool) {
        self.arrowedNode.rotateArrow(to: .right)
        
        Defaults[.knowSideMenu] = true
    }
    
    // func sideMenuWillDisappear(menu: UISideMenuNavigationController, animated: Bool) {
    //     print("SideMenu Disappearing! (animated: \(animated))")
    // }
    
    func sideMenuDidDisappear(menu: UISideMenuNavigationController, animated: Bool) {
        StaticValues.mainWindow?.bringSubview(toFront: SearchAddBarView.shared)
        StaticValues.mainWindow?.bringSubview(toFront: DoneCancelBarView.shared)

        self.arrowedNode.rotateArrow(to: .left)
    }
}




