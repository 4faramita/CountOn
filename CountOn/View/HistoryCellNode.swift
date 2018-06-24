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
    
    let absoluteDateString: String
    let relativeDateString: String
    
    init(with history: History, absoluteDate: Bool = false) {
        absoluteDateString = history.date.dateTimeString()
        relativeDateString = history.date.timeAgoSinceNow
        
        super.init()
        
        automaticallyManagesSubnodes = true
        
        let typeString: String
        switch history.action {
        case 1:
            typeString = "+"
            backgroundColor = R.color.increasing()!.withAlphaComponent(StaticValues.backgroundAlpha)
        case -1:
            typeString = "-"
            backgroundColor = R.color.decreasing()!.withAlphaComponent(StaticValues.backgroundAlpha)
        case 0:
            typeString = "→ \(history.status)"
        default:
            fatalError()
        }
        
        type.attributedText = NSAttributedString(
            string: typeString,
            attributes: [
                NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.caption1),
                NSAttributedStringKey.foregroundColor: UIColor.lightGray,
                ]
        )
        
        setDateString(to: absoluteDate ? absoluteDateString : relativeDateString)
    }
    
    private func setDateString(to value: String) {
        date.attributedText = NSAttributedString(
            string: value,
            attributes: [
                NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.caption2),
                NSAttributedStringKey.foregroundColor: UIColor.lightGray,
                ]
        )
    }
    
//    func changeDateStyle() {
//        if type.attributedText?.string == relativeDateString {
//            setDateString(to: absoluteDateString)
//        } else {
//            setDateString(to: relativeDateString)
//        }
//    }
    
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
