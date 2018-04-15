//
//  CountArea.swift
//  CountOn
//
//  Created by 4faramita on 2018/4/15.
//  Copyright © 2018年 4faramita. All rights reserved.
//

import AsyncDisplayKit
import UIKit

final class CountArea: ASDisplayNode {
    
    let type: CountType
    var count = ASTextNode()
    
    init(for type: CountType = .increase, from number: Int = 0) {
        self.type = type
        
        super.init()
        
        automaticallyManagesSubnodes = true
        
        count.attributedText = NSAttributedString(
            string: "\(number)",
            attributes: [
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 23),
                NSAttributedStringKey.foregroundColor: countColor[self.type]![.foreground]!()
            ]
        )
    }
    
    override func didLoad() {
        super.didLoad()
        
        self.backgroundColor = countColor[self.type]![.background]!()
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let centerSpec = ASCenterLayoutSpec(
            centeringOptions: .XY,
            sizingOptions: .minimumXY,
            child: count
        )
        
        return ASRatioLayoutSpec(ratio: 0.85, child: centerSpec)
    }
}

enum CountType {
    case increase
    case decrease
    case twoWays
}

enum ColorType {
    case foreground
    case background
}


let countColor: [CountType: [ColorType: () -> UIColor]] = [
    .increase: [
        .foreground: { return UIColor(red: 80 / 255, green: 227 / 255, blue: 194 / 255, alpha: 1) },
        .background: { return UIColor(red: 80 / 255, green: 227 / 255, blue: 194 / 255, alpha: 0.06) }
    ],
    .decrease: [
        .foreground: { return UIColor(red: 245 / 255, green: 166 / 255, blue: 35 / 255, alpha: 1) },
        .background: { return UIColor(red: 245 / 255, green: 166 / 255, blue: 35 / 255, alpha: 0.06) }
    ],
    .twoWays: [
        .foreground: { return UIColor(red: 144 / 255, green: 19 / 255, blue: 254 / 255, alpha: 1) },
        .background: { return UIColor(red: 144 / 255, green: 19 / 255, blue: 254 / 255, alpha: 0.06) }
    ]
]

