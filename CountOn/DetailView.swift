//
//  DetailView.swift
//  CountOn
//
//  Created by 4faramita on 2018/6/20.
//  Copyright © 2018年 4faramita. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class DetailView: ASDisplayNode {
    
    let title = ASEditableTextNode()
    let note = ASEditableTextNode()
    let historyView = ASTextNode()
    
    init(of counter: Counter) {
        self.title.attributedText = NSAttributedString(
            string: counter.title,
            attributes: [
                NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.title1),
                NSAttributedStringKey.foregroundColor: UIColor.darkGray,
                ]
        )
        self.note.attributedText = NSAttributedString(
            string: counter.note,
            attributes: [
                NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.caption1),
                NSAttributedStringKey.foregroundColor: UIColor.darkGray,
            ]
        )
    }
    
    init(with title: String) {
        self.title.attributedText = NSAttributedString(
            string: title,
            attributes: [
                NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.title1),
                NSAttributedStringKey.foregroundColor: UIColor.darkGray,
            ]
        )
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let infoStack = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 20,
            justifyContent: .start,
            alignItems: .center,
            children: [ title, note, historyView ]
        )
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 25, left: 16, bottom: 25, right: 16), child: infoStack)
    }
}
