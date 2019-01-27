//
//  CounterCellNode.swift
//  CountOn
//
//  Created by 4faramita on 2018/4/15.
//  Copyright © 2018年 4faramita. All rights reserved.
//

import UIKit

import AsyncDisplayKit
import RealmSwift
import DateToolsSwift
import RxSwift
import RxCocoa
import GTTexture_RxExtension
import Whisper

final class CounterCellNode: ASCellNode {
    
    private let disposeBag = DisposeBag()
    
    private var counter: Counter {
        didSet {
            countArea = CountAreaNode(for: types[counter.type], from: counter.status)
        }
    }
    
    private var countArea = CountAreaNode()
    private let count = ASTextNode()
    
    private let title = ASTextNode()
    private let lastLaunch = ASTextNode()
    
    private let addButton = ASButtonNode()
    private let minusButton = ASButtonNode()
    
    private let counterBackground = ASImageNode()
    
//    let notification = UINotificationFeedbackGenerator()
    private let selection = UISelectionFeedbackGenerator()


    private let types: [CountType] = [.increase, .decrease, .twoWays]
    
    init(with counter: Counter) {
        
        self.counter = counter
        
        self.countArea = CountAreaNode(for: types[counter.type], from: counter.status)
        
        super.init()
        
        automaticallyManagesSubnodes = true
        
        title.attributedText = NSAttributedString(
            string: counter.title,
            attributes: [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13),
//                NSAttributedString.Key.foregroundColor: UIColor(hexString: "273D52", transparency: 0.9)!,
                NSAttributedString.Key.foregroundColor: UIColor.darkGray,
            ]
        )

        title.maximumNumberOfLines = 1
        title.truncationMode = .byTruncatingTail
        
        lastLaunch.attributedText = NSAttributedString(
            string: "\(counter.last.timeAgoSinceNow)",
            attributes: [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13),
//                NSAttributedString.Key.foregroundColor: UIColor(hexString: "273D52", transparency: 0.5)!,
                NSAttributedString.Key.foregroundColor: UIColor.lightGray,
            ]
        )

        lastLaunch.maximumNumberOfLines = 1
        lastLaunch.truncationMode = .byTruncatingTail
        
        let addButtonNormalTitle = NSAttributedString(
            string: "+",
            attributes: [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 23),
                NSAttributedString.Key.foregroundColor: UIColor.lightGray,
            ]
        )
        addButton.setAttributedTitle(addButtonNormalTitle, for: .normal)
        
        let addButtonHighlightedTitle = NSAttributedString(
            string: "+",
            attributes: [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 23),
                NSAttributedString.Key.foregroundColor: UIColor.darkGray,
            ]
        )
        addButton.setAttributedTitle(addButtonHighlightedTitle, for: .highlighted)
        
        
        let minusButtonNormalTitle = NSAttributedString(
            string: "-",
            attributes: [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 23),
                NSAttributedString.Key.foregroundColor: UIColor.lightGray,
            ]
        )
        minusButton.setAttributedTitle(minusButtonNormalTitle, for: UIControl.State.normal)
        
        let minusButtonHighlightedTitle = NSAttributedString(
            string: "-",
            attributes: [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 23),
                NSAttributedString.Key.foregroundColor: UIColor.darkGray,
                ]
        )
        minusButton.setAttributedTitle(minusButtonHighlightedTitle, for: .highlighted)
        
        
        switch StaticValues.counterType[counter.type] {
        case .increase:
            counterBackground.image = R.image.counter_increase()
        case .decrease:
            counterBackground.image = R.image.counter_decrease()
        case .twoWays:
            counterBackground.image = R.image.counter_both()
        }
        
        if StaticValues.scale < 1 {
            counterBackground.contentMode = .scaleAspectFit
        }
        // counterBackground.contentMode = .scaleToFill
    }
    
    override func didLoad() {
        super.didLoad()
        
        let addStream = addButton.rx
            .tap
            .map { [weak self] _ -> Int in
                if let countValue = self?.countArea.countValue, countValue < 999 {
                    return 1
                }
                return 2
        }
        
        let validAddStream = addStream
            .filter { number in
                number == 1
        }
        
        let minusStream = minusButton.rx
            .tap
            .map { [weak self] _ -> Int in
                if let countValue = self?.countArea.countValue, countValue > 0 {
                    return -1
                }
                return -2
        }
        
        let validMinusStream = minusStream
            .filter { number in
                number == -1
        }
        
        let editStream = Observable.of(validAddStream, validMinusStream)
            .merge()
        
        let historyResult = editStream
            .map { [weak self] number in
                let history = History(typeOf: number)
                history.owner = self?.counter
                return history
            }
            .scan(List<History>(), accumulator: { (oldList: List<History>, newValue: History) -> List<History> in
                oldList.insert(newValue, at: 0)
                return oldList
            })
            .debounce(0.5, scheduler: MainScheduler.instance)
            .take(1)
        
        historyResult.subscribe(onNext: { [weak self] historyList in
            // FIXME: counter edit
            let realm = try! Realm()
            let counterRef = ThreadSafeReference(to: (self?.counter)!)
            guard let counter = realm.resolve(counterRef) else {
                return // entity was deleted
            }
            try! realm.write {
                realm.add(historyList)
                counter.status = (self?.countArea.countValue)!
                counter.last = (historyList.first?.date)!
            }
        }).disposed(by: disposeBag)
        
        editStream.subscribe(onNext: { [weak self] number in
            self?.countArea.countValue += number
//            self?.notification.notificationOccurred(.error)
            self?.selection.selectionChanged()
        }).disposed(by: disposeBag)
        
        addStream
            .filter { $0 != 1 }
            .throttle(0.5, scheduler: MainScheduler.instance)
            .subscribe(onNext: { _ in
                Whisper.show(
                    whistle: Murmur(title: R.string.localizable.cannotGoOver999(), backgroundColor: .orange),
                    action: .show(1))
            })
            .disposed(by: disposeBag)
        
        
        minusStream
            .filter { $0 != -1 }
            .throttle(0.5, scheduler: MainScheduler.instance)
            .subscribe(onNext: { _ in
                Whisper.show(
                    whistle: Murmur(title: R.string.localizable.doNotWantToGoNegative(), backgroundColor: .orange),
                    action: .show(1))
            })
            .disposed(by: disposeBag)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let isSE = (StaticValues.scale < 1)
        let scale: CGFloat = 6.0 / 7.0
        
        let infoWidth = isSE ? 83 : (128.0 * StaticValues.scale)
        title.style.width = ASDimensionMake(infoWidth)
        lastLaunch.style.width = ASDimensionMake(infoWidth)

        
        let spacing: CGFloat = isSE ? (7 * scale) : 7
        let infoStack = ASStackLayoutSpec(
            direction: .vertical,
            spacing: spacing,
            justifyContent: .center,
            alignItems: .start,
            children: [ title, lastLaunch ]
        )
        
        let addButtonSpec = ASRatioLayoutSpec(ratio: 70 / 54, child: addButton)

        let minusButtonSpec = ASRatioLayoutSpec(ratio: 70 / 54, child: minusButton)
        
        let buttons: [ASLayoutSpec]
        switch countArea.type {
        case .increase:
            buttons = [addButtonSpec]
        case .decrease:
            buttons = [minusButtonSpec]
        case .twoWays:
            buttons = [minusButtonSpec, addButtonSpec]
        }
        
        let buttonStack = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 0,
            justifyContent: .start,
            alignItems: .center,
            children: buttons
        )
        
        let infoInset: CGFloat = isSE ? (16 * scale) : 16
        let infoInsetSpac = ASInsetLayoutSpec(
            insets: UIEdgeInsets(top: infoInset, left: infoInset, bottom: infoInset, right: infoInset),
            child: infoStack
        )
        
        let counterInfoStack = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 0,
            justifyContent: .start,
            alignItems: .center,
            children: [ countArea, infoInsetSpac ]
        )
        
        let foregroundNode = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 0,
            justifyContent: .spaceBetween,
            alignItems: .center,
            children: [ counterInfoStack, buttonStack ]
        )
        
        let bottomInset: CGFloat = isSE ? 10 : 15
        let foregroundInsetSpec = ASInsetLayoutSpec(
            insets: UIEdgeInsets(top: 0.0, left: 0.0, bottom: bottomInset, right: 0.0),
            child: foregroundNode
        )
        
        let bgSpec = ASBackgroundLayoutSpec(child: foregroundInsetSpec, background: counterBackground)
        
        let sideInset: CGFloat = isSE ? 30.0 : (20.0 * StaticValues.scale)
        return ASInsetLayoutSpec(
            insets: UIEdgeInsets(top: 0.0, left: sideInset, bottom: 0.0, right: sideInset),
            child: bgSpec
        )
    }
}
