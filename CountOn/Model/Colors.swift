//
//  Colors.swift
//  CountOn
//
//  Created by 4faramita on 2018/6/19.
//  Copyright © 2018年 4faramita. All rights reserved.
//

import UIKit

struct Colors {
    static let countColor: [CountType: [ColorType: UIColor]] = [
        .increase: [
            .foreground: UIColor(hexString: "50E3C2", transparency: 1.0)!,
            .background: UIColor(hexString: "50E3C2", transparency: 0.06)!
        ],
        .decrease: [
            .foreground: UIColor(hexString: "F5A623", transparency: 1.0)!,
            .background: UIColor(hexString: "F5A623", transparency: 0.06)!
        ],
        .twoWays: [
            .foreground: UIColor(hexString: "9013FE", transparency: 1.0)!,
            .background: UIColor(hexString: "9013FE", transparency: 0.06)!
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
