//
//  Colors.swift
//  CountOn
//
//  Created by 4faramita on 2018/6/19.
//  Copyright © 2018年 4faramita. All rights reserved.
//

import UIKit

struct Colors {
    static let countColor: [[ColorType: UIColor]] = [
        [
            .foreground: UIColor(named: "increasing")!,
            .background: UIColor(named: "increasing")!.withAlphaComponent(StaticValues.backgroundAlpha)
        ],
        [
            .foreground: UIColor(named: "decreasing")!,
            .background: UIColor(named: "decreasing")!.withAlphaComponent(StaticValues.backgroundAlpha)
        ],
        [
            .foreground: UIColor(named: "twoWays")!,
            .background: UIColor(named: "twoWays")!.withAlphaComponent(StaticValues.backgroundAlpha)
        ]
    ]
}

enum CountType: Int {
    case increase = 0
    case decrease = 1
    case twoWays = 2
}

enum ColorType {
    case foreground
    case background
}
