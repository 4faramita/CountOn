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
import SwiftMessages

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
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14),
                NSAttributedStringKey.foregroundColor: R.color.title()!,
            ]
        )
        addButton.setAttributedTitle(buttonLabel, for: UIControlState.normal)
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
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14),
                NSAttributedStringKey.foregroundColor: UIColor.lightGray,
            ]
        )
        searchField.delegate = self
        searchField.clearButtonMode = UITextFieldViewMode.always
        
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
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let knowSwipeDown = UserDefaults.standard.bool(forKey: "knowSwipeDownOnSearch")
        if !knowSwipeDown {
            let view = MessageView.viewFromNib(layout: .cardView)
            view.configureTheme(.info)
            view.configureDropShadow()
            let iconText = "🙂"
            let sentence = R.string.localizable.swipeDownTheBarToDismissKeyboard()
            view.configureContent(title: R.string.localizable.tip(), body: sentence, iconText: iconText)
            view.buttonTapHandler = { _ in
                UserDefaults.standard.set(true, forKey: "knowSwipeDownOnSearch")
                SwiftMessages.hide()
            }
            view.button?.setTitle(R.string.localizable.oK(), for: .normal)
            view.tapHandler = { _ in
                UserDefaults.standard.set(true, forKey: "knowSwipeDownOnSearch")
                SwiftMessages.hide()
            }
            SwiftMessages.show(view: view)
        }
        
        return true
    }
}
