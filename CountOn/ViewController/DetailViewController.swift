//
//  DetailViewController.swift
//  CountOn
//
//  Created by 4faramita on 2018/6/20.
//  Copyright © 2018年 4faramita. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import RxSwift
import RxCocoa
import RxKeyboard
import RxGesture
import SwifterSwift

class DetailViewController: ASViewController<ASDisplayNode> {

    let doneCancelBar = DoneCancelBarView()
    
    let disposeBag = DisposeBag()
    
    var detailNode = DetailView()

    
    init(of counter: Counter) {
        super.init(node: DetailView(of: counter))
        
        self.title = counter.title
    }
    
    init(with title: String) {
        super.init(node: DetailView(with: title))
        
        self.title = title
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    private func dismissKeyboard() {
        detailNode.titleField.resignFirstResponder()
        detailNode.noteView.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailNode = node as! DetailView
        
        
//        MARK: Danamically change the UISegmentedControl's tint color
        
        detailNode.typePickerView.rx
            .selectedSegmentIndex
            .distinctUntilChanged()
            .filter({ [0, 1, 2].contains($0) })
            .subscribe(onNext: { [weak self] index in
                self?.detailNode.type = StaticValues.counterType[index]
                self?.detailNode.typePickerView.tintColor = Colors.countColor[index][.foreground]
            })
            .disposed(by: disposeBag)
        
        
//        MARK: Swipe down to dismiss VC
        
//        detailNode.view.rx
//            .swipeGesture(.down)
//            .when(.recognized)
//            .subscribe(onNext: { [weak self] _ in
//                self?.dismiss(animated: true, completion: nil)
//            })
//            .disposed(by: disposeBag)
        
        node.view.addSubview(doneCancelBar)
        doneCancelBar.center = CGPoint(x: StaticValues.screenWidth / 2, y: StaticValues.screenHeight - 40)
        
        
//        MARK: Title, note and status
//        TODO: This does not have to emit according to change
        
        detailNode.titleField.rx
            .text.orEmpty
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] newTitle in
                self?.detailNode.title = newTitle.trimmed
            })
            .disposed(by: disposeBag)
        
        detailNode.noteView.textView.rx
            .text.orEmpty
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] newNote in
                self?.detailNode.note = newNote
            })
            .disposed(by: disposeBag)
        
        
//        MARK: SearchAddBar hide and show
        
        SearchAddBarView.shared.hide()
        
        doneCancelBar.cancelButton.rx
            .tap
            .subscribe(onNext: { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
                SearchAddBarView.shared.show()
            })
            .disposed(by: disposeBag)


//        MARK: Done and save

        doneCancelBar.doneButton.rx
            .tap
            .subscribe(onNext: { [weak self] _ in
                self?.detailNode.save()
                self?.dismiss(animated: true, completion: nil)
                SearchAddBarView.shared.show()
            })
            .disposed(by: disposeBag)
    
//        MARK: Delete
        
        doneCancelBar.deleteButton.rx
            .tap
            .subscribe(onNext: { [weak self] _ in
                let alert = UIAlertController(title: "This counter is about to be deleted.", message: "This cannot be undone. Are you sure?", preferredStyle: UIAlertControllerStyle.alert)
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
                let yesAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.destructive) { _ in
                    self?.detailNode.delete()
                    self?.dismiss(animated: true, completion: nil)
//                TODO: Now I clear search field
//                      to prevent crash when deleteing from the search result.
//                      But hopefully I do not have to do that
                    SearchAddBarView.shared.searchField.clear()
//                CounterStore.shared.reset()
                    
                    SearchAddBarView.shared.show()
                }
                alert.addAction(cancelAction)
                alert.addAction(yesAction)
                self?.present(alert, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)


//        MARK: click to dismiss keyboard

//        node.view.rx
//            .tapGesture()
//            .when(.recognized)
//            .subscribe(onNext: { [weak self] _ in
//                self?.dismissKeyboard()
//            })
//            .disposed(by: disposeBag)


//        MARK: swipe doneCancelBar down to dismiss keyboard
        
        doneCancelBar.rx
            .swipeGesture([.down])
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                print("swiped")
                self?.dismissKeyboard()
            })
            .disposed(by: disposeBag)

        RxKeyboard.instance.visibleHeight
            .drive(onNext: { [weak self] keyboardVisibleHeight in
                self?.doneCancelBar.center = CGPoint(
                    x: StaticValues.screenWidth / 2,
                    y: StaticValues.screenHeight - 40 - keyboardVisibleHeight
                )
            })
            .disposed(by: disposeBag)
    }
}
