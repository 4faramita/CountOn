//
//  DetailView.swift
//  CountOn
//
//  Created by 4faramita on 2018/6/20.
//  Copyright © 2018年 4faramita. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import RealmSwift
import RxSwift
import RxCocoa

class DetailView: ASScrollNode {
    
    let titleLabel = ASEditableTextNode()
    let noteView = ASEditableTextNode()
    let historyView = ASTextNode()
    
    var title = "" {
        didSet {
            self.titleLabel.attributedText = NSAttributedString(
                string: self.title,
                attributes: [
                    NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.title1),
                    NSAttributedStringKey.foregroundColor: UIColor.darkGray,
                ]
            )
        }
    }
    
    var note = "" {
        didSet {
            self.noteView.attributedText = NSAttributedString(
                string: self.note,
                attributes: [
                    NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.caption1),
                    NSAttributedStringKey.foregroundColor: UIColor.darkGray,
                ]
            )
        }
    }
    
    var history = List<History>()
    
    var counter: Counter? {
        didSet {
            if let counter = self.counter {
               title = counter.title
               note = counter.note
               history = counter.history
            }
        }
    }
    
    override init() {
        super.init()
        
        backgroundColor = .white
        automaticallyManagesSubnodes = true
        view.keyboardDismissMode = .interactive
        
//        view.contentInset = UIEdgeInsets(top: 24, left: 0, bottom: 80, right: 0)
    }
    
    convenience init(of counter: Counter) {
        self.init()
        
        self.counter = counter
    }
    
    convenience init(with title: String) {
        self.init()

        self.title = title
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let infoStack = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 20,
            justifyContent: .start,
            alignItems: .center,
            children: [ titleLabel, noteView, historyView ]
        )
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 25, left: 16, bottom: 25, right: 16), child: infoStack)
    }
}
