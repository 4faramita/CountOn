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
            .foreground: R.color.increasing()!,
            .background: R.color.increasing()!.withAlphaComponent(StaticValues.backgroundAlpha)
        ],
        [
            .foreground: R.color.decreasing()!,
            .background: R.color.decreasing()!.withAlphaComponent(StaticValues.backgroundAlpha)
        ],
        [
            .foreground: R.color.twoWays()!,
            .background: R.color.twoWays()!.withAlphaComponent(StaticValues.backgroundAlpha)
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
