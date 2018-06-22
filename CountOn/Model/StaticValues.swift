//
//  StaticValues.swift
//  CountOn
//
//  Created by 4faramita on 2018/6/17.
//  Copyright © 2018年 4faramita. All rights reserved.
//

import UIKit

struct StaticValues {
    static let screenWidth = UIScreen.main.bounds.size.width
    static let screenHeight = UIScreen.main.bounds.size.height
    static let scale = screenWidth / 375
    static let counterType: [CountType] = [.increase, .decrease, .twoWays]
}
