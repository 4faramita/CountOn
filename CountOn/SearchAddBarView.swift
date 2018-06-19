//
//  SearchAddBarView.swift
//  CountOn
//
//  Created by 4faramita on 2018/6/16.
//  Copyright © 2018年 4faramita. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxGesture
import RealmSwift

class SearchAddBarView: UIImageView, UITextFieldDelegate {
    
    // Singleton
    static let shared = SearchAddBarView()
    
    let addButton = UIButton()
    let searchField = UITextField()
    
    let disposeBag = DisposeBag()
    
    convenience init() {
        self.init(image: UIImage(named: "bar"))
        
        self.isUserInteractionEnabled = true
        
        let buttonLabel = NSAttributedString(
            string: "Add",
            attributes: [
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14),
                NSAttributedStringKey.foregroundColor: UIColor(hexString: "4A90E2", transparency: 1.0)!,
            ]
        )
        addButton.setAttributedTitle(buttonLabel, for: UIControlState.normal)
        addButton.backgroundColor = UIColor(hexString: "4A90E2", transparency: 0.06)!
        
        self.addSubview(addButton)
        addButton.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview()
            make.trailing.equalToSuperview().inset(5)
            make.height.equalTo(50)
            make.width.equalTo(70)
        }
        
        addButton.rx
            .tap
            .subscribe(onNext: { [weak self] _ in
                let title = self?.searchField.text
//                TODO: Maybe find a way to automatically clear this and emit a event
//                self?.searchField.clear()
//                CounterStore.shared.reset()
                
                let newCounter = CounterViewController.generateCounter(
                    title,
                    at: Date()
                )
                
                CounterStore.shared.insert(item: newCounter)
            })
            .disposed(by: disposeBag)
        
        searchField.attributedPlaceholder = NSAttributedString(
            string: "Type to search or add",
            attributes: [
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14),
                NSAttributedStringKey.foregroundColor: UIColor(hexString: "273D52", transparency: 0.3)!,
            ]
        )
        searchField.delegate = self
        searchField.clearButtonMode = UITextFieldViewMode.whileEditing
        
        self.addSubview(searchField)
        searchField.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().inset(43)
            make.height.equalTo(50)
            make.trailing.equalTo(addButton.snp.leading)
        }
        
//        Pull down to dismiss keyboard
        self.rx
            .swipeGesture([.down])
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.searchField.resignFirstResponder()
            }).disposed(by: disposeBag)
    }
    
//    MARK: Text Field Delegation
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchField.resignFirstResponder()
        return true
    }
}
