//
//  ArrowASTableNode.swift
//  CountOn
//
//  Created by 4faramita on 2018/8/6.
//  Copyright © 2018年 4faramita. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class ArrowASTableNode: ASTableNode {
    let arrow = ASImageNode()
    
    override func didLoad() {
        super.didLoad()
        
        addSubnode(arrow)
        arrow.image = R.image.left_arrow()
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASStackLayoutSpec(
            direction: .vertical,
            spacing: 0,
            justifyContent: .center,
            alignItems: .end,
            children: [ arrow ]
        )
    }
}
