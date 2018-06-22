//
//  CounterCellNode.swift
//  CountOn
//
//  Created by 4faramita on 2018/4/15.
//  Copyright © 2018年 4faramita. All rights reserved.
//

import AsyncDisplayKit
import UIKit
import RealmSwift
import DateToolsSwift
import SwifterSwift
import RxSwift
import RxCocoa
import GTTexture_RxExtension
import SwiftMessages

final class CounterCellNode: ASCellNode {
    
    let disposeBag = DisposeBag()
    
    var counter: Counter {
        didSet {
            countArea = CountArea(for: types[counter.type], from: counter.status)
        }
    }
    
    var countArea = CountArea()
    let count = ASTextNode()
    
    let title = ASTextNode()
    let lastLaunch = ASTextNode()
    
    let addButton = ASButtonNode()
    let minusButton = ASButtonNode()
    
    let counterBackground = ASImageNode()

    let types: [CountType] = [.increase, .decrease, .twoWays]
    
    init(with counter: Counter) {
        
        self.counter = counter
        
        self.countArea = CountArea(for: types[counter.type], from: counter.status)
        
        super.init()
        
        automaticallyManagesSubnodes = true
        
        title.attributedText = NSAttributedString(
            string: counter.title,
            attributes: [
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 13),
                NSAttributedStringKey.foregroundColor: UIColor(hexString: "273D52", transparency: 0.9)!,
            ]
        )
        title.style.width = ASDimensionMake(128.0 * StaticValues.scale)
        title.maximumNumberOfLines = 1
        title.truncationMode = .byTruncatingTail
        
        lastLaunch.attributedText = NSAttributedString(
            string: "\(counter.history.first!.date.timeAgoSinceNow)",
            attributes: [
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 13),
                NSAttributedStringKey.foregroundColor: UIColor(hexString: "273D52", transparency: 0.5)!,
            ]
        )
        lastLaunch.style.width = ASDimensionMake(128.0 * StaticValues.scale)
        lastLaunch.maximumNumberOfLines = 1
        lastLaunch.truncationMode = .byTruncatingTail
        
        let addButtonNormalTitle = NSAttributedString(
            string: "+",
            attributes: [
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 23),
                NSAttributedStringKey.foregroundColor: UIColor.lightGray,
            ]
        )
        addButton.setAttributedTitle(addButtonNormalTitle, for: .normal)
        
        let addButtonHighlightedTitle = NSAttributedString(
            string: "+",
            attributes: [
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 23),
                NSAttributedStringKey.foregroundColor: UIColor.darkGray,
            ]
        )
        addButton.setAttributedTitle(addButtonHighlightedTitle, for: .highlighted)
        
        
        let minusButtonNormalTitle = NSAttributedString(
            string: "-",
            attributes: [
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 23),
                NSAttributedStringKey.foregroundColor: UIColor.lightGray,
            ]
        )
        minusButton.setAttributedTitle(minusButtonNormalTitle, for: UIControlState.normal)
        
        let minusButtonHighlightedTitle = NSAttributedString(
            string: "-",
            attributes: [
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 23),
                NSAttributedStringKey.foregroundColor: UIColor.darkGray,
                ]
        )
        minusButton.setAttributedTitle(minusButtonHighlightedTitle, for: .highlighted)
        
        
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
        
        let validMinuseStream = minusStream
            .filter { number in
                number == -1
            }
        
        let editStream = Observable.of(validAddStream, validMinuseStream)
            .merge()
        
        let historyResult = editStream
            .map { number in
                return History(typeOf: number)
            }
            .scan(List<History>(), accumulator: { (oldList: List<History>, newValue: History) -> List<History> in
                oldList.insert(newValue, at: 0)
                return oldList
            })
            .debounce(0.5, scheduler: MainScheduler.instance)
            .take(1)
        
        historyResult.subscribe(onNext: { [weak self] historyList in
//            FIXME: counter edit
            let realm = try! Realm()
            let counterRef = ThreadSafeReference(to: (self?.counter)!)
            guard let counter = realm.resolve(counterRef) else {
                return // entity was deleted
            }
            try! realm.write {
                counter.history.insert(contentsOf: historyList, at: 0)
                counter.status = (self?.countArea.countValue)!
                counter.last = (counter.history.first?.date)!
            }
        }).disposed(by: disposeBag)
        
        editStream.subscribe(onNext: { [weak self] number in
            self?.countArea.countValue += number
        }).disposed(by: disposeBag)
        
        addStream
            .filter { $0 != 1 }
            .throttle(0.5, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                SwiftMessages.show(view: (self?.generateWarning(forZero: false))!)
            })
            .disposed(by: disposeBag)
        
        
        minusStream
            .filter { $0 != -1 }
            .throttle(0.5, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                SwiftMessages.show(view: (self?.generateWarning(forZero: true))!)
            })
            .disposed(by: disposeBag)
        
        switch StaticValues.counterType[counter.type] {
        case .increase:
            counterBackground.image = UIImage(named: "counter_increase")
        case .decrease:
            counterBackground.image = UIImage(named: "counter_decrease")
        case .twoWays:
            counterBackground.image = UIImage(named: "counter_both")
        }
        
//        counterBackground.contentMode = .scaleAspectFit
//        counterBackground.contentMode = .scaleToFill
    }
    
    private func generateWarning(forZero: Bool) -> UIView {
        let view = MessageView.viewFromNib(layout: .cardView)
        
        // Theme message elements with the warning style.
        view.configureTheme(.warning)
        
        // Add a drop shadow.
        view.configureDropShadow()
        
        // Set message title, body, and icon. Here, we're overriding the default warning
        // image with an emoji character.
        let iconText = ["🤷‍♂️", "🤷‍♀️"].sm_random()!
        let sentence = (forZero ? "Do not want to go negative." : "Cannot go over 999.")
        view.configureContent(title: "Warning", body: sentence, iconText: iconText)
        
        // Hide when button tapped
        view.buttonTapHandler = { _ in SwiftMessages.hide() }
        view.button?.setTitle("OK", for: .normal)
        
        // Hide when message view tapped
        view.tapHandler = { _ in SwiftMessages.hide() }
        
        return view
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let infoStack = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 7,
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
        
        
        let infoInset = ASInsetLayoutSpec(
            insets: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16),
            child: infoStack
        )
        
        let counterInfoStack = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 0,
            justifyContent: .start,
            alignItems: .center,
            children: [ countArea, infoInset ]
        )
        
        let foregroundNode = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 0,
            justifyContent: .spaceBetween,
            alignItems: .center,
            children: [ counterInfoStack, buttonStack ]
        )
        
        let foregroundInsetSpec = ASInsetLayoutSpec(
            insets: UIEdgeInsets(top: 0.0, left: 0.0, bottom: 15.0, right: 0.0),
            child: foregroundNode
        )
        
        let bgSpec = ASBackgroundLayoutSpec(child: foregroundInsetSpec, background: counterBackground)
        
        return ASInsetLayoutSpec(
            insets: UIEdgeInsets(top: 0.0, left: StaticValues.scale * 20.0, bottom: 0.0, right: StaticValues.scale * 20.0),
            child: bgSpec
        )
    }
}
