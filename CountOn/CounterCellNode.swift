//
//  CounterCellNode.swift
//  CountOn
//
//  Created by 4faramita on 2018/4/15.
//  Copyright © 2018年 4faramita. All rights reserved.
//

import AsyncDisplayKit
import UIKit

final class CounterCellNode: ASCellNode {
    let title = ASTextNode()
    let lastLaunch = ASTextNode()
    let countArea: CountArea
    let count = ASTextNode()
    
    override init() {
        let types: [CountType] = [.increase, .decrease, .twoWays]
        let seed = Int(arc4random())
        countArea = CountArea(for: types[seed % 3], from: seed % 100)
        
        super.init()
        
        automaticallyManagesSubnodes = true
        
        title.attributedText = NSAttributedString(
            string: "布洛芬",
            attributes: [
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 13),
                NSAttributedStringKey.foregroundColor: UIColor(red: 39 / 255, green: 61 / 255, blue: 82 / 255, alpha: 1),
            ]
        )
        
        lastLaunch.attributedText = NSAttributedString(
            string: "上次：两天前",
            attributes: [
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 13),
                NSAttributedStringKey.foregroundColor: UIColor(red: 39 / 255, green: 61 / 255, blue: 82 / 255, alpha: 0.5),
            ]
        )
    }

    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let infoStack = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 7,
            justifyContent: .center,
            alignItems: .start,
            children: [ title, lastLaunch ]
        )
        
        let infoInset = ASInsetLayoutSpec(
            insets: UIEdgeInsets(top: 16, left: 18, bottom: 16, right: 18),
            child: infoStack
        )
        
        return ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 0,
            justifyContent: .start,
            alignItems: .center,
            children: [ countArea, infoInset ]
        )
    }
}
