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
    var countValue: Int {
        didSet {
            setLabel()
        }
    }
    var countLabel = ASTextNode()
    
    private func setLabel() {
        countLabel.attributedText = NSAttributedString(
            string: "\(self.countValue)",
            attributes: [
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 23),
                NSAttributedStringKey.foregroundColor: Colors.countColor[self.type]![.foreground]!
            ]
        )
    }
    
    init(for type: CountType = .increase, from number: Int = 0) {
        self.type = type
        self.countValue = number
        
        super.init()
        
        automaticallyManagesSubnodes = true
        
        setLabel()
    }
    
    override func didLoad() {
        super.didLoad()
        
        self.backgroundColor = Colors.countColor[self.type]![.background]
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let centerSpec = ASCenterLayoutSpec(
            centeringOptions: .XY,
            sizingOptions: .minimumXY,
            child: countLabel
        )
                
        return ASRatioLayoutSpec(ratio: 7 / 6, child: centerSpec)
    }
}
