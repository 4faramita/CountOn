//
//  AppDelegate.swift
//  CountOn
//
//  Created by 4faramita on 2018/4/15.
//  Copyright © 2018年 4faramita. All rights reserved.
//

import UIKit
import RealmSwift
import RxSwift
import RxCocoa
import RxKeyboard
import IceCream
import Peek
import SwiftyUserDefaults

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let disposeBag = DisposeBag()
    
    var syncEngine: SyncEngine?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 1,
            
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 1) {
                    migration.enumerateObjects(ofType: History.className()) { oldObject, newObject in
                        // combine name fields into a single field
                        newObject!["id"] = UUID().uuidString
                    }
                }
        })
        
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
        
        // Now that we've told Realm how to handle the schema change, opening the file
        // will automatically perform the migration
        _ = try! Realm()

        let window = UIWindow(frame: UIScreen.main.bounds)
        
        window.peek.enabled = true
        
        window.backgroundColor = .white
        window.rootViewController = CounterViewController()
        window.makeKeyAndVisible()
        
        self.window = window
        
        let searchAddBar = SearchAddBarView.shared
        searchAddBar.center = CGPoint(x: window.frame.width / 2, y: window.frame.height - 40)
        
        let doneCancelBar = DoneCancelBarView.shared
        doneCancelBar.isUserInteractionEnabled = false
        doneCancelBar.alpha = 0
        doneCancelBar.center = CGPoint(x: StaticValues.screenWidth / 2, y: StaticValues.screenHeight - 40)
        
        // let undoBar = UndoBarView.shared
        // searchAddBar.center = CGPoint(x: window.frame.width / 2, y: window.frame.height - 40)
        
        window.addSubview(searchAddBar)
        window.addSubview(doneCancelBar)
        window.bringSubview(toFront: doneCancelBar)
        
        RxKeyboard.instance.visibleHeight
            .drive(onNext: { keyboardVisibleHeight in
                searchAddBar.center = CGPoint(x: window.frame.width / 2, y: window.frame.height - 40 - keyboardVisibleHeight)
            })
            .disposed(by: disposeBag)
        
        if Defaults[.iCloudSync] {
            syncEngine = SyncEngine(objects: [ SyncObject<Counter>(), SyncObject<History>() ])
            application.registerForRemoteNotifications()
        }
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}
