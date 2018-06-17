//
//  SearchAddBarNode.swift
//  CountOn
//
//  Created by 4faramita on 2018/6/17.
//  Copyright © 2018年 4faramita. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class SearchAddBarNode: ASImageNode {
    
    let addButton = ASButtonNode()
    let searchField = ASTextNode()
    
    override init() {
        super.init()
        
        self.automaticallyManagesSubnodes = true
        
        self.image = UIImage(named: "bar")
        
        let buttonLabel = NSAttributedString(
            string: "Add",
            attributes: [
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14),
                NSAttributedStringKey.foregroundColor: UIColor(hexString: "4A90E2", transparency: 1.0)!,
            ]
        )
        addButton.setAttributedTitle(buttonLabel, for: UIControlState.normal)
        addButton.backgroundColor = UIColor(hexString: "4A90E2", transparency: 0.06)!
        
        searchField.attributedText = NSAttributedString(
            string: "Type to search",
            attributes: [
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14),
                NSAttributedStringKey.foregroundColor: UIColor(hexString: "273D52", transparency: 0.3)!,
            ]
        )
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let addButtonRatio = ASRatioLayoutSpec(ratio: 5 / 7, child: addButton)
        
        let searchBarInset = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 43, bottom: 0, right: 0), child: searchField)
        
        let foregroundStack = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 0,
            justifyContent: .spaceBetween,
            alignItems: .start,
            children: [ searchBarInset, addButtonRatio ]
        )
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 0), child: foregroundStack)
    }
}
