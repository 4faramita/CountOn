//
//  UserDefaults.swift
//  CountOn
//
//  Created by 4faramita on 2018/8/5.
//  Copyright © 2018年 4faramita. All rights reserved.
//

import Foundation

import SwiftyUserDefaults

extension DefaultsKeys {
    static let knowSwipeDownSearch = DefaultsKey<Bool>("knowSwipeDownSearch")
    static let knowSwipeDownDetail = DefaultsKey<Bool>("knowSwipeDownDetail")
    static let launchedBefore = DefaultsKey<Bool>("launchedBefore")
    static let knowSideMenu = DefaultsKey<Bool>("knowSideMenu")
}
