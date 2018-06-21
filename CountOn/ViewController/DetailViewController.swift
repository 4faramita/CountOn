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
        
        
//        MARK: Title and note
        
        detailNode.titleField.textView.rx
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
