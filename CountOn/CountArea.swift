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
//                NSAttributedStringKey.foregroundColor: countColor[self.type]![.foreground]!
                NSAttributedStringKey.foregroundColor: UIColor.darkGray
]
        )
    }
    
    override func didLoad() {
        super.didLoad()
        
//        self.backgroundColor = countColor[self.type]![.background]!
        self.backgroundColor = UIColor.lightGray
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


let countColor: [CountType: [ColorType: UIColor]] = [
    .increase: [
        .foreground: UIColor(red: 80, green: 227, blue: 194, alpha: 1),
        .background: UIColor(red: 80, green: 227, blue: 194, alpha: 0.06)
    ],
    .decrease: [
        .foreground: UIColor(red: 245, green: 165, blue: 35, alpha: 1),
        .background: UIColor(red: 245, green: 165, blue: 35, alpha: 0.06)
    ],
    .twoWays: [
        .foreground: UIColor(red: 144, green: 19, blue: 254, alpha: 1),
        .background: UIColor(red: 144, green: 19, blue: 254, alpha: 0.06)
    ]
]

