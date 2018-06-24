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
    
    static let shared = DoneCancelBarView()
    
    let disposeBag = DisposeBag()
    
    let cancelButton = UIButton()
    let doneButton = UIButton()
    let deleteButton = UIButton()
    
    
    convenience init() {
        self.init(image: R.image.clear_bar())
        
        self.isUserInteractionEnabled = true
        
        addSubview(cancelButton)
        addSubview(doneButton)
        addSubview(deleteButton)
        
//        MARK: Cancel button
        
        let cancelLabel = NSAttributedString(
            string: R.string.localizable.cancel(),
            attributes: [
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18),
                NSAttributedStringKey.foregroundColor: R.color.cancel()!,
                ]
        )
        cancelButton.setAttributedTitle(cancelLabel, for: UIControlState.normal)
//        cancelButton.backgroundColor = UIColor(hexString: "9B9B9B", transparency: 0.2)!
        
        cancelButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().inset(5)
            make.height.equalTo(50)
            make.trailing.equalTo(doneButton.snp.leading)
        }
        
        
//        MARK: Done button
        
        let doneLabel = NSAttributedString(
            string: R.string.localizable.done(),
            attributes: [
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18),
                NSAttributedStringKey.foregroundColor: R.color.done()!,
            ]
        )
        doneButton.setAttributedTitle(doneLabel, for: UIControlState.normal)
//        doneButton.backgroundColor = UIColor(hexString: "B8E986", transparency: 0.2)!
        
        
        
        doneButton.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview()
            
            make.height.equalTo(50)
            make.width.equalTo(cancelButton)
        }
        
        
//        MARK: Delete button
        
        let deleteLabel = NSAttributedString(
            string: R.string.localizable.delete(),
            attributes: [
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18),
                NSAttributedStringKey.foregroundColor: R.color.delete()!,
            ]
        )
        deleteButton.setAttributedTitle(deleteLabel, for: UIControlState.normal)
//        deleteButton.backgroundColor = UIColor(hexString: "D0021B", transparency: 0.2)!
        
        
        deleteButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.equalTo(doneButton.snp.trailing)
            make.height.equalTo(50)
            make.trailing.equalToSuperview().inset(5)
            make.width.equalTo(cancelButton)
        }
    }
    
    func show() {
        UIView.animate(withDuration: 0.25, animations: {
            DoneCancelBarView.shared.alpha = 1
        }) { (done) in
            if done {
                DoneCancelBarView.shared.isUserInteractionEnabled = true
            }
        }
    }
    
    func hide() {
        UIView.animate(withDuration: 0.25, animations: {
            DoneCancelBarView.shared.alpha = 0
        }) { (done) in
            if done {
                DoneCancelBarView.shared.isUserInteractionEnabled = false
            }
        }
    }
}
