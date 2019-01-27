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
import DateToolsSwift
import RxSwift
import RxCocoa
import RxKeyboard
import RxGesture

final class DetailNode: ASDisplayNode {
    
    private let disposeBag = DisposeBag()
    
    private let titleTitle = ASTextNode()
    var titleField = UITextField()
    private lazy var titleNode: ASDisplayNode = {
        return ASDisplayNode(viewBlock: { [weak self] () -> UIView in
            return (self?.titleField)!
        })
    }()
    
    private let noteTitle = ASTextNode()
    let noteView = ASEditableTextNode()
    
    private var statusPicker = UIPickerView()
    private lazy var statusNode: ASDisplayNode = {
        return ASDisplayNode(viewBlock: { [weak self] () -> UIView in
            return (self?.statusPicker)!
        })
    }()
    
    private var absoluteDate = false {
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
    private var absoluteHistoryTable: HistoryTableNode?
    private var relativeHistoryTable: HistoryTableNode?
    private let bottomTitle = ASTextNode()
    private let statusTitle = ASTextNode()
    private let resetButton = ASButtonNode()

    private let centerParagraphStyle = NSMutableParagraphStyle()
    private let multiLineParagraphStyle = NSMutableParagraphStyle()
    private let multiLineCenterParagraphStyle = NSMutableParagraphStyle()
    
    private var isInEditMode: Bool
    
    var isFromTable: Bool {
        if let _ = counter {
            return true
        } else {
            return false
        }
    }
    
    private var typePickerView = UISegmentedControl(items: [R.string.localizable.increase(), R.string.localizable.decrease(), R.string.localizable.both()])
    private lazy var typePicker: ASDisplayNode = {
        return ASDisplayNode(viewBlock: { [weak self] () -> UIView in
            self?.typePickerView.selectedSegmentIndex = self?.type.rawValue ?? 0
            self?.typePickerView.tintColor = Colors.countColor[((self?.type)?.rawValue)!][.foreground]
            return (self?.typePickerView)!
        })
    }()
    
    private var title = ""
    private var note = ""
    private var type = CountType.increase
    private var status = 0
    
    private var counter: Counter?
    
    override init() {
        isInEditMode = true
        
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
        isInEditMode = false
        
        self.title = title
        
        setupFields()
    }
    
    override func didLoad() {
        super.didLoad()
        
        
        // MARK: Danamically change the UISegmentedControl's tint color
        
        typePickerView.rx
            .selectedSegmentIndex
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
            .subscribe(onNext: { [weak self] newTitle in
                self?.title = newTitle.trimmed
            })
            .disposed(by: disposeBag)
        
        noteView.textView.rx
            .text.orEmpty
            .subscribe(onNext: { [weak self] newNote in
                self?.note = newNote
            })
            .disposed(by: disposeBag)
        
        resetButton.rx
            .tap
            .subscribe(onNext: { [weak self] in
                self?.isInEditMode = false
                self?.initBottom()
                self?.setNeedsLayout()
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
    }
    
    override func layout() {
        super.layout()
        
        resetButton.cornerRadius = resetButton.frame.height / 2
    }
    
    
    // MARK: Setup UI
    
    private func initTitleField() {
        titleTitle.attributedText = NSAttributedString(
            string: R.string.localizable.title(),
            attributes: [
                NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.footnote),
                NSAttributedString.Key.foregroundColor: R.color.title()!,
            ]
        )
        
        titleField.enablesReturnKeyAutomatically = true
        titleField.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.title1)
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
                NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.footnote),
                NSAttributedString.Key.foregroundColor: R.color.title()!,
            ]
        )
        
        noteView.attributedPlaceholderText = NSAttributedString(
            string: R.string.localizable.describeTheCounter(),
            attributes: [
                NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body),
                NSAttributedString.Key.foregroundColor: UIColor.lightGray,
                NSAttributedString.Key.paragraphStyle: multiLineParagraphStyle
                ]
        )
        noteView.scrollEnabled = true

        noteView.typingAttributes = [
            NSAttributedString.Key.font.rawValue: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body),
            NSAttributedString.Key.foregroundColor.rawValue: UIColor.darkGray,
            NSAttributedString.Key.paragraphStyle.rawValue: multiLineParagraphStyle
        ]
    }
    
    private func setupNoteView() {
        noteView.attributedText = NSAttributedString(
            string: self.note,
            attributes: [
                NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body),
                NSAttributedString.Key.foregroundColor: UIColor.darkGray,
                NSAttributedString.Key.paragraphStyle: multiLineParagraphStyle
            ]
        )
    }
    
    private func initStatusNode() {
        statusPicker.delegate = self
        statusPicker.dataSource = self
        statusPicker.selectRow(status % 10, inComponent: 2, animated: true)
        statusPicker.selectRow((status / 10) % 10, inComponent: 1, animated: true)
        statusPicker.selectRow((status / 100) % 10, inComponent: 0, animated: true)
    }
    
    private func setupHistoryTable() {
        let realm = try! Realm()
        let histories = realm.objects(History.self).filter { (history) -> Bool in
            return history.owner?.id == self.counter!.id
            }
            .sorted { (lhs, rhs) -> Bool in
                lhs.date > rhs.date
            }
        self.relativeHistoryTable = HistoryTableNode(with: histories, absoluteDate: false)
        self.absoluteHistoryTable = HistoryTableNode(with: histories, absoluteDate: true)
    }
    
    private func setupStatusTitle() {
        statusTitle.attributedText = NSAttributedString(
            string: R.string.localizable.currentStatus() + ": \(status)",
            attributes: [
                NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.footnote),
                NSAttributedString.Key.foregroundColor: R.color.title()!,
            ]
        )
    }
    
    private func setupResetButton() {
        let resetTitle = NSAttributedString(
            string: R.string.localizable.reset(),
            attributes: [
                NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.footnote),
                NSAttributedString.Key.foregroundColor: R.color.delete()!,
            ]
        )
        resetButton.setAttributedTitle(resetTitle, for: UIControl.State.normal)
        resetButton.borderWidth = 1 / UIScreen.main.nativeScale
        resetButton.borderColor = R.color.delete()!.cgColor
        resetButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    }
    
    private func initBottom() {
        bottomTitle.attributedText = NSAttributedString(
            string: isInEditMode ? R.string.localizable.history() + ": \(counter!.historyLink.count)" : R.string.localizable.setTheCounterTo(),
            attributes: [
                NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.footnote),
                NSAttributedString.Key.foregroundColor: R.color.title()!,
            ]
        )
        
        if isInEditMode {
            setupStatusTitle()
            setupResetButton()
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
    
    
    // MARK: Save
    
    func save(insert: (Bool) -> Void) {
        let realm = try! Realm()
        
        if let counter = counter {
            let counterRef = ThreadSafeReference(to: counter)
            guard let counter = realm.resolve(counterRef) else {
                return // entity was deleted
            }
            if !(counter.title == title && counter.note == note && counter.type == type.rawValue && counter.status == status) {
                insert(true)
                
                try! realm.write {
                    counter.title = title
                    counter.note = note
                    counter.type = type.rawValue
                    
                    if counter.status != status {
                        // Reset
                        counter.status = status
                        
                        let history = History(from: status)
                        history.owner = counter
                        realm.add(history)
                        counter.last = history.date
                    }
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
            history.owner = counter
            counter.last = history.date
            
            try! realm.write {
                realm.add(history)
            }
            
            CounterStore.shared.insert(item: counter)
        }
    }
    
    func delete() {
        let realm = try! Realm()
        
        if let counter = counter {
            let counterRef = ThreadSafeReference(to: counter)
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
        let bottomTitles = isInEditMode ? [ bottomTitle, statusTitle, resetButton ] : [ bottomTitle ]
        
        let bottomTitleStack = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 10,
            justifyContent: .spaceBetween,
            alignItems: .start,
            children: bottomTitles
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

extension DetailNode: UIPickerViewDataSource, UIPickerViewDelegate {
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
