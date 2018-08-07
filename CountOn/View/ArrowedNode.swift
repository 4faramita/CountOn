//
//  ArrowedNode.swift
//  CountOn
//
//  Created by 4faramita on 2018/8/6.
//  Copyright © 2018年 4faramita. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import SwifterSwift

class ArrowedNode: ASDisplayNode {
    var arrow = ASImageNode()
    let arrowPlate = ASDisplayNode()
    var tableNode = ASTableNode()
    
    override func didLoad() {
        super.didLoad()
        
        automaticallyManagesSubnodes = true
        
        // For arrow display
        backgroundColor = .clear
        arrowPlate.backgroundColor = .clear
        arrowPlate.isUserInteractionEnabled = false
        
        arrow.image = R.image.left_arrow()
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        arrowPlate.style.height = ASDimensionMake(StaticValues.screenHeight)
        arrowPlate.style.width = ASDimensionMake(StaticValues.screenWidth)
        
        let arrowRelative = ASRelativeLayoutSpec(horizontalPosition: .end,
                                                 verticalPosition: .center,
                                                 sizingOption: [],
                                                 child: arrow)
        let arrowInset = ASInsetLayoutSpec(insets: UIEdgeInsets(inset: 8), child: arrowRelative)
        let arrowPlateSpec = ASBackgroundLayoutSpec(child: arrowInset, background: arrowPlate)
        return ASBackgroundLayoutSpec(child: arrowPlateSpec, background: tableNode)
    }
    
    func rotateArrow(to orientation: Orientation) {
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            self?.arrow.alpha = 0
        }) { [weak self] (done) in
            if done {
                if orientation == .left {
                    self?.arrow.image = R.image.left_arrow()
                } else {
                    self?.arrow.image = R.image.right_arrow()
                }
                UIView.animate(withDuration: 0.25, animations: {
                    self?.arrow.alpha = 1
                })
            }
        }
    }
}

enum Orientation {
    case left
    case right
}
