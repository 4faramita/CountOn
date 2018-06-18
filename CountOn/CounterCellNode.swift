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
        
        lastLaunch.attributedText = NSAttributedString(
            string: "上次：\(counter.history.first!.date.timeAgoSinceNow)",
            attributes: [
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 13),
                NSAttributedStringKey.foregroundColor: UIColor(hexString: "273D52", transparency: 0.5)!,
            ]
        )
        
        let addButtonNormalTitle = NSAttributedString(
            string: "+",
            attributes: [
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 23),
                NSAttributedStringKey.foregroundColor: UIColor.lightGray,
            ]
        )
        addButton.setAttributedTitle(addButtonNormalTitle, for: UIControlState.normal)
        
        addButton.rx
            .tap
            .subscribe(onNext: { [weak self] _ in
                let realm = try! Realm()
                let counterRef = ThreadSafeReference(to: (self?.counter)!)
                guard let counter = realm.resolve(counterRef) else {
                    return // person was deleted
                }
                try! realm.write {
                    counter.history.insert(History(typeOf: 1), at: 0)
                    counter.status += 1
                    counter.last = Date()
                }
            })
            .disposed(by: disposeBag)
        
        let minusButtonNormalTitle = NSAttributedString(
            string: "-",
            attributes: [
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 23),
                NSAttributedStringKey.foregroundColor: UIColor.lightGray,
            ]
        )
        minusButton.setAttributedTitle(minusButtonNormalTitle, for: UIControlState.normal)
        
        minusButton.rx
            .tap
            .subscribe(onNext: { [weak self] _ in
                let realm = try! Realm()
                let counterRef = ThreadSafeReference(to: (self?.counter)!)
                guard let counter = realm.resolve(counterRef) else {
                    return // person was deleted
                }
                try! realm.write {
                    counter.history.insert(History(typeOf: -1), at: 0)
                    counter.status -= 1
                    counter.last = Date()
                }
            })
            .disposed(by: disposeBag)
        
//        let addButtonClickTitle = NSAttributedString(
//            string: "+",
//            attributes: [
//                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 23),
//                NSAttributedStringKey.foregroundColor: UIColor.darkGray,
//            ]
//        )
//        addButton.setAttributedTitle(addButtonClickTitle, for: UIControlState.selected)
        
        counterBackground.image = UIImage(named: "CounterBG")
//        counterBackground.contentMode = .scaleAspectFit
//        counterBackground.contentMode = .scaleToFill
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let infoStack = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 7,
            justifyContent: .center,
            alignItems: .start,
            children: [ title, lastLaunch ]
        )
        
        
//        let addButtonCenter = ASCenterLayoutSpec(
//            centeringOptions: .XY,
//            sizingOptions: .minimumXY,
//            child: addButton
//        )
        
        let addButtonSpec = ASRatioLayoutSpec(ratio: 70 / 54, child: addButton)
        
//        let minusButtonCenter = ASCenterLayoutSpec(
//            centeringOptions: .XY,
//            sizingOptions: .minimumXY,
//            child: minusButton
//        )
        
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
