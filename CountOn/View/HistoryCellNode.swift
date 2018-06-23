//
//  HistoryCellNode.swift
//  CountOn
//
//  Created by 4faramita on 2018/6/23.
//  Copyright © 2018年 4faramita. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class HistoryCellNode: ASCellNode {
    let type = ASTextNode()
    let date = ASTextNode()
    
    init(with history: History) {
        super.init()
        
        automaticallyManagesSubnodes = true
        
        let typeString: String
        switch history.action {
        case 1:
            typeString = "Increased by 1"
        case -1:
            typeString = "Decreased by 1"
        case 0:
            typeString = "Initialized at \(history.status)"
        default:
            fatalError()
        }
        
        let dateString = history.date.timeAgoSinceNow
        
        type.attributedText = NSAttributedString(
            string: typeString,
            attributes: [
                NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.caption1),
                NSAttributedStringKey.foregroundColor: UIColor.lightGray,
                ]
        )
        
        date.attributedText = NSAttributedString(
            string: dateString,
            attributes: [
                NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.caption2),
                NSAttributedStringKey.foregroundColor: UIColor.lightGray,
                ]
        )
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let infoStack = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 0,
            justifyContent: .spaceBetween,
            alignItems: .center,
            children: [ type, date ]
        )
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16), child: infoStack)
    }
}
