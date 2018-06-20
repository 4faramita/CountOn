//
//  DoneCancelBarView.swift
//  CountOn
//
//  Created by 4faramita on 2018/6/20.
//  Copyright © 2018年 4faramita. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxGesture
import RealmSwift

class DoneCancelBarView: UIImageView {
    let disposeBag = DisposeBag()
    
        let doneButton = UIButton()
        let cancelButton = UIButton()
    
    convenience init() {
        self.init(image: UIImage(named: "clear_bar"))
        
        self.isUserInteractionEnabled = true
        
//        MARK: Done button
        
        let doneLabel = NSAttributedString(
            string: "Done",
            attributes: [
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18),
                NSAttributedStringKey.foregroundColor: UIColor(hexString: "417505", transparency: 1.0)!,
                ]
        )
        doneButton.setAttributedTitle(doneLabel, for: UIControlState.normal)
        doneButton.backgroundColor = UIColor(hexString: "B8E986", transparency: 0.2)!
        
        self.addSubview(doneButton)
        
        doneButton.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview()
            make.trailing.equalToSuperview().inset(5)
            make.height.equalTo(50)
            make.width.equalToSuperview().multipliedBy(0.5)
        }
        
//        MARK: Cancel button
        
        let cancelLabel = NSAttributedString(
            string: "Cancel",
            attributes: [
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18),
                NSAttributedStringKey.foregroundColor: UIColor(hexString: "4A4A4A", transparency: 1.0)!,
            ]
        )
        cancelButton.setAttributedTitle(cancelLabel, for: UIControlState.normal)
        cancelButton.backgroundColor = UIColor(hexString: "9B9B9B", transparency: 0.2)!
        self.addSubview(cancelButton)
        
        cancelButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().inset(5)
            make.height.equalTo(50)
            make.trailing.equalTo(doneButton.snp.leading)
        }
    }
}
