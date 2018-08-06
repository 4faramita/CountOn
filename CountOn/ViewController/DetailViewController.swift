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
import EasyTipView
import SwiftyUserDefaults

class DetailViewController: ASViewController<ASDisplayNode> {
    
    let disposeBag = DisposeBag()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tipView = EasyTipView(text: R.string.localizable.swipeDownTheBarToDismissKeyboard())
        
        // MARK: click to dismiss keyboard
        // FIXME
        //
        // node.view.rx
        //     .tapGesture()
        //     .when(.recognized)
        //     .subscribe(onNext: { [weak self] _ in
        //         self?.dismissKeyboard()
        //     })
        //     .disposed(by: disposeBag)
        
        
        // MARK: swipe doneCancelBar down to dismiss keyboard
        
        DoneCancelBarView.shared.rx
            .swipeGesture([.down])
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                tipView.dismiss()
                Defaults[.knowSwipeDownDetail] = true
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
        
        let detailNode = node as! DetailView
        
        detailNode.noteView.textView.rx
            .didBeginEditing
            .delay(1, scheduler: MainScheduler.instance)
            .subscribe(onNext: {
                if !Defaults[.knowSwipeDownDetail] {
                    tipView.show(forView: DoneCancelBarView.shared)
                }
            })
            .disposed(by: disposeBag)
        
        detailNode.titleField.rx
            .controlEvent(UIControlEvents.editingDidBegin)
            .delay(1, scheduler: MainScheduler.instance)
            .subscribe(onNext: {
                if !Defaults[.knowSwipeDownDetail] {
                    tipView.show(forView: DoneCancelBarView.shared)
                }
            })
            .disposed(by: disposeBag)
        
        
        // MARK: Swipe down to dismiss VC
        
         detailNode.view.rx
            .swipeGesture(.down) { gestureRecognizer, delegate in
                    delegate.simultaneousRecognitionPolicy = .never
            }
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
                DoneCancelBarView.shared.hide()
            })
            .disposed(by: disposeBag)
        
        
        // MARK: SearchAddBar hide and show
        
        DoneCancelBarView.shared.show()
        
        DoneCancelBarView.shared.cancelButton.rx
            .tap
            .subscribe(onNext: { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
                DoneCancelBarView.shared.hide()
            })
            .disposed(by: disposeBag)


        // MARK: Done and save

        DoneCancelBarView.shared.doneButton.rx
            .tap
            .subscribe(onNext: { [weak self] _ in
                let keyword = SearchAddBarView.shared.searchField.text ?? ""
                
                detailNode.save { changed in
                    if changed  {
                        SearchAddBarView.shared.searchField.clear()
                        CounterStore.shared.reset()
                        (self?.presentingViewController as! CounterViewController).tableNode.reloadData()
                    } else {
                        SearchAddBarView.shared.searchField.text = keyword
                    }
                }
                
                
                DoneCancelBarView.shared.hide()
                
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    
        // MARK: Delete
        
        DoneCancelBarView.shared.deleteButton.rx
            .tap
            .subscribe(onNext: { [weak self] _ in
                // let title = SearchAddBarView.shared.searchField.text ?? ""
                SearchAddBarView.shared.searchField.clear()
                
                if detailNode.isFromTable {
                    let alert = UIAlertController(title: R.string.localizable.thisCounterIsAboutToBeDeleted(), message: R.string.localizable.thisCannotBeUndoneAreYouSure(), preferredStyle: UIAlertControllerStyle.alert)
                    let cancelAction = UIAlertAction(title: R.string.localizable.cancel(), style: UIAlertActionStyle.cancel, handler: nil)
                    let yesAction = UIAlertAction(title: R.string.localizable.yes(), style: UIAlertActionStyle.destructive) { _ in
                        
                        detailNode.delete()
                        // FIXME: Resume after deletion
                        // SearchAddBarView.shared.searchField.text = title
                        
                        DoneCancelBarView.shared.hide()
                        self?.dismiss(animated: true, completion: nil)
                    }
                    alert.addAction(cancelAction)
                    alert.addAction(yesAction)
                    self?.present(alert, animated: true, completion: nil)
                } else {
                    DoneCancelBarView.shared.hide()
                    self?.dismiss(animated: true, completion: nil)
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func dismissKeyboard() {
        let detailNode = node as! DetailView
        
        detailNode.titleField.resignFirstResponder()
        detailNode.noteView.resignFirstResponder()
    }
}

extension DetailViewController: EasyTipViewDelegate {
    func easyTipViewDidDismiss(_ tipView: EasyTipView) {
        Defaults[.knowSwipeDownDetail] = true
    }
}
