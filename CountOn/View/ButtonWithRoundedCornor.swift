//
//  ButtonWithRoundedCornor.swift
//  CountOn
//
//  Created by 4faramita on 2018/6/28.
//  Copyright © 2018年 4faramita. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class ButtonWithRoundedCornor: ASButtonNode {

    override func layout() {
        super.layout()
        
//        let path = UIBezierPath(roundedRect: frame, cornerRadius: frame.height / 2)
//        path.lineWidth = 1 / UIScreen.main.nativeScale
//        R.color.delete()!.setStroke()
//        path.stroke()
        
//        let maskLayer = CAShapeLayer()
//        maskLayer.frame = frame
//        maskLayer.path = path.cgPath
//        layer.mask = maskLayer
        
        print(">>> \(frame.height)")
        borderWidth = 1 / UIScreen.main.nativeScale
        borderColor = R.color.delete()!.cgColor
        contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        cornerRadius = frame.height / 2
//        clipsToBounds = true
        print(contentEdgeInsets)
    }
}
