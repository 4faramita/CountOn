//
//  UndoBarView.swift
//  CountOn
//
//  Created by 4faramita on 2018/7/18.
//  Copyright © 2018年 4faramita. All rights reserved.
//

import UIKit
import SnapKit

class UndoBarView: UIImageView {
    static let shared = UndoBarView()
    
    let undoButton = UIButton()
    
    convenience init() {
        self.init(image: R.image.undo_bar())
        
        self.isUserInteractionEnabled = true
        
        addSubview(undoButton)
        
        let undoLabel = NSAttributedString(
            string: "Undo",
            attributes: [
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18),
                NSAttributedStringKey.foregroundColor: R.color.undo()!.darken(),
                ]
        )
        undoButton.setAttributedTitle(undoLabel, for: UIControlState.normal)
        
        undoButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.height.equalTo(50)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
    }
    
    func show() {
        UIView.animate(withDuration: 0.25, animations: {
            UndoBarView.shared.alpha = 1
        }) { (done) in
            if done {
                DoneCancelBarView.shared.isUserInteractionEnabled = true
            }
        }
    }
    
    func hide() {
        UIView.animate(withDuration: 0.25, animations: {
            UndoBarView.shared.alpha = 0
        }) { (done) in
            if done {
                DoneCancelBarView.shared.isUserInteractionEnabled = false
            }
        }
    }
}
