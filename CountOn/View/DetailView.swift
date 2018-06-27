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
import SwifterSwift
import DateToolsSwift
import RxSwift
import RxCocoa
import RxKeyboard
import RxGesture

class DetailView: ASDisplayNode {
    
    let disposeBag = DisposeBag()
    
    let titleTitle = ASTextNode()
    var titleField = UITextField()
    private lazy var titleNode: ASDisplayNode = {
        return ASDisplayNode(viewBlock: { [weak self] () -> UIView in
            return (self?.titleField)!
        })
    }()
    
    let noteTitle = ASTextNode()
    let noteView = ASEditableTextNode()
    
    var statusPicker = UIPickerView()
    private lazy var statusNode: ASDisplayNode = {
        return ASDisplayNode(viewBlock: { [weak self] () -> UIView in
            return (self?.statusPicker)!
        })
    }()
    
    var absoluteDate = false {
        didSet {
            if absoluteDate {
                // FIXME: The content offset for the first time is buggy
                absoluteHistoryTable?.setContentOffset(relativeHistoryTable?.contentOffset ?? .zero, animated: false)
            } else {
                relativeHistoryTable?.setContentOffset(absoluteHistoryTable?.contentOffset ?? .zero, animated: false)
            }
            setNeedsLayout()
        }
    }
    var absoluteHistoryTable: HistoryTableNode?
    var relativeHistoryTable: HistoryTableNode?
    let bottomTitle = ASTextNode()
    let statusTitle = ASTextNode()

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
    
    var typePickerView = UISegmentedControl(items: [R.string.localizable.increase(), R.string.localizable.decrease(), R.string.localizable.both()])
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
        self.status = counter.status
        
        setupFields()
    }
    
    convenience init(with title: String) {
        self.init()
        
        self.title = title
        
        setupFields()
    }
    
    override func didLoad() {
        super.didLoad()
        
        
        // MARK: Danamically change the UISegmentedControl's tint color
        
        typePickerView.rx
            .selectedSegmentIndex
            .distinctUntilChanged()
            .filter({ [0, 1, 2].contains($0) })
            .subscribe(onNext: { [weak self] index in
                self?.type = StaticValues.counterType[index]
                self?.typePickerView.tintColor = Colors.countColor[index][.foreground]
            })
            .disposed(by: disposeBag)
        
        
        // MARK: Title, note and status
        // TODO: This does not have to emit according to change
        
        titleField.rx
            .text.orEmpty
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] newTitle in
                self?.title = newTitle.trimmed
            })
            .disposed(by: disposeBag)
        
        noteView.textView.rx
            .text.orEmpty
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] newNote in
                self?.note = newNote
            })
            .disposed(by: disposeBag)
        
        
        // MARK: History table exchange
        if let relativeHistoryTable = relativeHistoryTable, let absoluteHistoryTable = absoluteHistoryTable {
            let relativeTapStream = relativeHistoryTable.view.rx
                .tapGesture(configuration: { gestureRecognizer, delegate in
                    delegate.simultaneousRecognitionPolicy = .never
                })
                .when(.recognized)
            let absoluteTapStream = absoluteHistoryTable.view.rx
                .tapGesture(configuration: { gestureRecognizer, delegate in
                    delegate.simultaneousRecognitionPolicy = .never
                })
                .when(.recognized)
            Observable.merge(relativeTapStream, absoluteTapStream)
                .subscribe(onNext: { [weak self] _ in
                    if let absoluteDate = self?.absoluteDate {
                        self?.absoluteDate = !absoluteDate
                    }
                })
                .disposed(by: disposeBag)
        }
        
        
        // MARK: click to dismiss keyboard
        
//        node.view.rx
//            .tapGesture()
//            .when(.recognized)
//            .subscribe(onNext: { [weak self] _ in
//                self?.dismissKeyboard()
//            })
//            .disposed(by: disposeBag)
        
        
        // MARK: swipe doneCancelBar down to dismiss keyboard
        
        DoneCancelBarView.shared.rx
            .swipeGesture([.down])
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.dismissKeyboard()
            })
            .disposed(by: disposeBag)
        
        RxKeyboard.instance.visibleHeight
            .drive(onNext: { keyboardVisibleHeight in
                DoneCancelBarView.shared.center = CGPoint(
                    x: StaticValues.screenWidth / 2,
                    y: StaticValues.screenHeight - 40 - keyboardVisibleHeight
                )
            })
            .disposed(by: disposeBag)
    }
    
    private func dismissKeyboard() {
        titleField.resignFirstResponder()
        noteView.resignFirstResponder()
    }
    
    
//    MARK: Setup UI
    
    private func initTitleField() {
        titleTitle.attributedText = NSAttributedString(
            string: R.string.localizable.title(),
            attributes: [
                NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.footnote),
                NSAttributedStringKey.foregroundColor: R.color.title()!,
                NSAttributedStringKey.paragraphStyle: multiLineParagraphStyle
            ]
        )
        
        titleField.enablesReturnKeyAutomatically = true
        titleField.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.title1)
        titleField.textColor = UIColor.darkGray
        titleField.placeholder = R.string.localizable.nameOfTheCounter()
    }
    
    private func setupTitleField() {
        titleField.text = title
    }
    
    private func initNoteView() {
        noteTitle.attributedText = NSAttributedString(
            string: R.string.localizable.description(),
            attributes: [
                NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.footnote),
                NSAttributedStringKey.foregroundColor: R.color.title()!,
                NSAttributedStringKey.paragraphStyle: multiLineParagraphStyle
            ]
        )
        
        noteView.attributedPlaceholderText = NSAttributedString(
            string: R.string.localizable.describeTheCounter(),
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
        self.relativeHistoryTable = HistoryTableNode(with: self.counter!.history, absoluteDate: false)
        self.absoluteHistoryTable = HistoryTableNode(with: self.counter!.history, absoluteDate: true)
    }
    
    private func setupStatusTitle() {
        statusTitle.attributedText = NSAttributedString(
            string: R.string.localizable.currentStatus() + ": \(status)",
            attributes: [
                NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.footnote),
                NSAttributedStringKey.foregroundColor: R.color.title()!,
                NSAttributedStringKey.paragraphStyle: multiLineParagraphStyle
            ]
        )
    }
    
    private func initBottom() {
        bottomTitle.attributedText = NSAttributedString(
            string: isInEditMode ? R.string.localizable.history() + ": \(counter!.history.count)" : R.string.localizable.startFrom(),
            attributes: [
                NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.footnote),
                NSAttributedStringKey.foregroundColor: R.color.title()!,
                NSAttributedStringKey.paragraphStyle: multiLineParagraphStyle
            ]
        )
        
        if isInEditMode {
            setupStatusTitle()
            setupHistoryTable()
        } else {
            initStatusNode()
        }
    }
    
    private func setupFields() {
        initTitleField()
        setupTitleField()
        initNoteView()
        setupNoteView()

        initBottom()
    }
    
    
//    MARK: Save
    
    func save(insert: (Bool) -> Void) {
        let realm = try! Realm()
        
        if isInEditMode {
            let counterRef = ThreadSafeReference(to: counter!)
            guard let counter = realm.resolve(counterRef) else {
                return // entity was deleted
            }
            if !(counter.title == title && counter.note == note && counter.type == type.rawValue) {
                insert(true)
                
                try! realm.write {
                    counter.title = title
                    counter.note = note
                    counter.type = type.rawValue
                }
            } else {
                insert(false)
            }
        } else {
            // MARK: Add new
            insert(true)
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
        titleNode.style.height = ASDimensionMake(32)
        statusNode.style.height = ASDimensionMake(statusPicker.frame.height)
        noteView.style.height = ASDimensionMake(96)
        typePicker.style.height = ASDimensionMake(typePickerView.frame.height)
        relativeHistoryTable?.style.height = ASDimensionMake(StaticValues.screenHeight - 330)
        absoluteHistoryTable?.style.height = ASDimensionMake(StaticValues.screenHeight - 330)
        
        let titleStack = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 5,
            justifyContent: .start,
            alignItems: .stretch,
            children: [ titleTitle, titleNode ]
        )
        
        let noteStack = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 5,
            justifyContent: .start,
            alignItems: .stretch,
            children: [ noteTitle, noteView ]
        )
        
        let historyTable = absoluteDate ? absoluteHistoryTable : relativeHistoryTable
        
        let bottom = isInEditMode ? historyTable! : statusNode
        
        let bottomTitleStack = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 10,
            justifyContent: .spaceBetween,
            alignItems: .start,
            children: [ bottomTitle, statusTitle ]
        )
        
        let bottomStack = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 5,
            justifyContent: .start,
            alignItems: .stretch,
            children: [ bottomTitleStack, bottom ]
        )
        
        let infoStack = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 20,
            justifyContent: .start,
            alignItems: .stretch,
            children: [ titleStack, typePicker, noteStack, bottomStack ]
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
