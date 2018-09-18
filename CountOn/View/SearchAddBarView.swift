//
//  SearchAddBarView.swift
//  CountOn
//
//  Created by 4faramita on 2018/6/16.
//  Copyright © 2018年 4faramita. All rights reserved.
//

import UIKit

import SnapKit
import RealmSwift
import AsyncDisplayKit

class SearchAddBarView: UIImageView, UITextFieldDelegate {
    
    // Singleton
    static let shared = SearchAddBarView()
    
    let addButton = UIButton()
    let searchField = UITextField()
        
    convenience init() {
        self.init(image: R.image.bar())
        
        self.isUserInteractionEnabled = true
        
        let buttonLabel = NSAttributedString(
            string: R.string.localizable.add(),
            attributes: [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14),
                NSAttributedString.Key.foregroundColor: R.color.title()!,
            ]
        )
        addButton.setAttributedTitle(buttonLabel, for: UIControl.State.normal)
        addButton.backgroundColor = R.color.title()!.withAlphaComponent(StaticValues.backgroundAlpha)
        
        self.addSubview(addButton)
        addButton.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview()
            make.trailing.equalToSuperview().inset(5)
            make.height.equalTo(50)
            make.width.equalTo(70)
        }
        
        
        searchField.attributedPlaceholder = NSAttributedString(
            string: R.string.localizable.typeToSearchOrAdd(),
            attributes: [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14),
                NSAttributedString.Key.foregroundColor: UIColor.lightGray,
            ]
        )
        searchField.delegate = self
        searchField.clearButtonMode = UITextField.ViewMode.always
        
        self.addSubview(searchField)
        searchField.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().inset(43)
            make.height.equalTo(50)
            make.trailing.equalTo(addButton.snp.leading)
        }
    }
    
//    MARK: Text Field Delegation
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchField.resignFirstResponder()
        return true
    }
}
