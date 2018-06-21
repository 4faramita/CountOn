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
import SwifterSwift
//import GTTexture_RxExtension

class DetailView: ASDisplayNode {
    
    let counterType: [CountType] = [.increase, .decrease, .twoWays]
    
    let titleField = ASEditableTextNode()
    let noteView = ASEditableTextNode()
    let typePicker = UISegmentedControl()
    
    let historyView = ASTextNode()
    
    var title = ""
    var note = ""
    var type = CountType.increase
    
    var history = List<History>()
    
    var counter: Counter?
    
    override init() {
        super.init()
        
        backgroundColor = .white
        automaticallyManagesSubnodes = true
    }
    
    convenience init(of counter: Counter) {
        self.init()
        
        self.counter = counter
        self.title = counter.title
        self.note = counter.note
        self.type = counterType[counter.type]
        self.history = counter.history
        
        setupFields()
    }
    
    convenience init(with title: String) {
        self.init()
        
        self.title = title
        
        setupFields()
    }
    
    
//    MARK: Setup UI
    
    private func initTitleField() {
        titleField.attributedPlaceholderText = NSAttributedString(
            string: "Title of the counter",
            attributes: [
                NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.title1),
                NSAttributedStringKey.foregroundColor: UIColor.lightGray,
                ]
        )
        titleField.maximumLinesToDisplay = 1
        titleField.scrollEnabled = false
        titleField.typingAttributes = [
            NSAttributedStringKey.font.rawValue: UIFont.preferredFont(forTextStyle: UIFontTextStyle.title1),
            NSAttributedStringKey.foregroundColor.rawValue: UIColor.darkGray,
        ]
    }
    
    private func setupTitleField() {
        titleField.attributedText = NSAttributedString(
            string: title,
            attributes: [
                NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.title1),
                NSAttributedStringKey.foregroundColor: UIColor.darkGray,
                ]
        )
    }
    
    private func initNoteView() {
        noteView.attributedPlaceholderText = NSAttributedString(
            string: "Description of the counter",
            attributes: [
                NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.body),
                NSAttributedStringKey.foregroundColor: UIColor.lightGray,
                ]
        )
        noteView.scrollEnabled = true
        noteView.style.height = ASDimensionMake(128.0)

        noteView.typingAttributes = [
            NSAttributedStringKey.font.rawValue: UIFont.preferredFont(forTextStyle: UIFontTextStyle.body),
            NSAttributedStringKey.foregroundColor.rawValue: UIColor.darkGray,
        ]
    }
    
    private func setupNoteView() {
        noteView.attributedText = NSAttributedString(
            string: self.note,
            attributes: [
                NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.body),
                NSAttributedStringKey.foregroundColor: UIColor.darkGray,
                ]
        )
    }
    
    private func setupFields() {
        initTitleField()
        setupTitleField()
        initNoteView()
        setupNoteView()
    }
    
    
//    MARK: Save
    
    func save() {
        let realm = try! Realm()
        
        if let counter = self.counter {
            let counterRef = ThreadSafeReference(to: counter)
            guard let counter = realm.resolve(counterRef) else {
                return // entity was deleted
            }
            try! realm.write {
                counter.title = title
                counter.note = note
                counter.type = type.rawValue
            }
        } else {
            let counter = Counter()
            counter.title = title
            counter.note = note
            counter.type = type.rawValue
            
            let history = History(from: 0)
            counter.history.insert(history, at: 0)
            counter.last = (counter.history.first?.date)!
            
            CounterStore.shared.insert(item: counter)
        }
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let infoStack = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 20,
            justifyContent: .start,
            alignItems: .stretch,
            children: [ titleField, noteView, historyView ]
        )
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 50, left: 32, bottom: 50, right: 32), child: infoStack)
    }
}
