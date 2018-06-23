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
import DateToolsSwift

class DetailView: ASDisplayNode {
    
    var titleField = UITextField()
    private lazy var titleNode: ASDisplayNode = {
        return ASDisplayNode(viewBlock: { [weak self] () -> UIView in
            return (self?.titleField)!
        })
    }()
    
    let noteView = ASEditableTextNode()
    
    var statusPicker = UIPickerView()
    private lazy var statusNode: ASDisplayNode = {
        return ASDisplayNode(viewBlock: { [weak self] () -> UIView in
            return (self?.statusPicker)!
        })
    }()
    
    var historyTable: HistoryTableNode?
    let bottomTitle = ASTextNode()

    let centerParagraphStyle = NSMutableParagraphStyle()
    let multiLineParagraphStyle = NSMutableParagraphStyle()
    let multiLineCenterParagraphStyle = NSMutableParagraphStyle()
    

    
    var isInEditMode: Bool {
        if let _ = counter {
            return true
        } else {
            return false
        }
    }
    
    var typePickerView = UISegmentedControl(items: ["Increase", "Decrease", "Both"])
    private lazy var typePicker: ASDisplayNode = {
        return ASDisplayNode(viewBlock: { [weak self] () -> UIView in
            self?.typePickerView.selectedSegmentIndex = self?.type.rawValue ?? 0
            self?.typePickerView.tintColor = Colors.countColor[((self?.type)?.rawValue)!][.foreground]
            return (self?.typePickerView)!
        })
    }()
    
    var title = ""
    var note = ""
    var type = CountType.increase
    var status = 0  // only for new
    
    var counter: Counter?
    
    override init() {
        super.init()
        
        centerParagraphStyle.alignment = .center

        multiLineParagraphStyle.lineSpacing = 3
        multiLineParagraphStyle.paragraphSpacing = 5
        
        multiLineCenterParagraphStyle.alignment = .center
        multiLineCenterParagraphStyle.lineSpacing = 3
        multiLineCenterParagraphStyle.paragraphSpacing = 5
        
        backgroundColor = .white
        automaticallyManagesSubnodes = true
    }
    
    convenience init(of counter: Counter) {
        self.init()
        
        self.counter = counter
        self.title = counter.title
        self.note = counter.note
        self.type = StaticValues.counterType[counter.type]
        
        setupFields()
    }
    
    convenience init(with title: String) {
        self.init()
        
        self.title = title
        
        setupFields()
    }
    
    
//    MARK: Setup UI
    
    private func initTitleField() {
        titleField.enablesReturnKeyAutomatically = true
        titleField.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.title1)
        titleField.textColor = UIColor.darkGray
        titleField.placeholder = "Title of the counter"
    }
    
    private func setupTitleField() {
        titleField.text = title
    }
    
    private func initNoteView() {
        noteView.attributedPlaceholderText = NSAttributedString(
            string: "Description of the counter",
            attributes: [
                NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.body),
                NSAttributedStringKey.foregroundColor: UIColor.lightGray,
                NSAttributedStringKey.paragraphStyle: multiLineParagraphStyle
                ]
        )
        noteView.scrollEnabled = true

        noteView.typingAttributes = [
            NSAttributedStringKey.font.rawValue: UIFont.preferredFont(forTextStyle: UIFontTextStyle.body),
            NSAttributedStringKey.foregroundColor.rawValue: UIColor.darkGray,
            NSAttributedStringKey.paragraphStyle.rawValue: multiLineParagraphStyle
        ]
    }
    
    private func setupNoteView() {
        noteView.attributedText = NSAttributedString(
            string: self.note,
            attributes: [
                NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.body),
                NSAttributedStringKey.foregroundColor: UIColor.darkGray,
                NSAttributedStringKey.paragraphStyle: multiLineParagraphStyle
            ]
        )
    }
    
    private func initStatusNode() {
        statusPicker.delegate = self
        statusPicker.dataSource = self
    }
    
    private func setupHistoryTable() {
        self.historyTable = HistoryTableNode(with: self.counter!.history)
    }
    
    private func initBottomTitle() {
        bottomTitle.attributedText = NSAttributedString(
            string: isInEditMode ? "History" : "Start from",
            attributes: [
                NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.footnote),
                NSAttributedStringKey.foregroundColor: UIColor.darkGray,
                NSAttributedStringKey.paragraphStyle: multiLineParagraphStyle
            ]
        )
    }
    
    private func setupFields() {
        initTitleField()
        setupTitleField()
        initNoteView()
        setupNoteView()
        if isInEditMode {
            setupHistoryTable()
        } else {
            initStatusNode()
        }
        initBottomTitle()
    }
    
    
//    MARK: Save
    
    func save() {
        let realm = try! Realm()
        
        if isInEditMode {
            let counterRef = ThreadSafeReference(to: counter!)
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
            counter.status = status
            
            let history = History(from: status)
            counter.history.insert(history, at: 0)
            counter.last = (counter.history.first?.date)!
            
            CounterStore.shared.insert(item: counter)
        }
    }
    
    func delete() {
        let realm = try! Realm()
        
        if isInEditMode {
            let counterRef = ThreadSafeReference(to: counter!)
            guard let counter = realm.resolve(counterRef) else {
                return // entity was deleted
            }
            CounterStore.shared.remove(item: counter)
        }
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        titleNode.style.height = ASDimensionMake(48)
        statusNode.style.height = ASDimensionMake(statusPicker.frame.height)
        noteView.style.height = ASDimensionMake(96)
        typePicker.style.height = ASDimensionMake(typePickerView.frame.height)
        historyTable?.style.height = ASDimensionMake(StaticValues.screenHeight - 309)
        
        let bottom = isInEditMode ? historyTable! : statusNode
        
        let bottomStack = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 10,
            justifyContent: .start,
            alignItems: .start,
            children: [ bottomTitle, bottom ]
        )
        
        let infoStack = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 20,
            justifyContent: .start,
            alignItems: .stretch,
            children: [ titleNode, typePicker, noteView, bottomStack ]
        )
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 50, left: 32, bottom: 50, right: 32), child: infoStack)
    }
}

extension DetailView: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 10
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row)"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var stringValue = ""
        for index in 0 ..< pickerView.numberOfComponents {
            let selectedRow = pickerView.selectedRow(inComponent: index)
            let title = self.pickerView(pickerView, titleForRow: selectedRow, forComponent: index)
            stringValue += title!
        }
        status = Int(stringValue.trimmed)!
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return CGFloat(50 * StaticValues.scale)
    }
}
