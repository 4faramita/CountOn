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
        
        let detailNode = node as! DetailView
        
//        MARK: Swipe down to dismiss VC
        
//        detailNode.view.rx
//            .swipeGesture(.down)
//            .when(.recognized)
//            .subscribe(onNext: { [weak self] _ in
//                self?.dismiss(animated: true, completion: nil)
//            })
//            .disposed(by: disposeBag)

        
//        MARK: SearchAddBar hide and show
        
        DoneCancelBarView.shared.show()
        
        DoneCancelBarView.shared.cancelButton.rx
            .tap
            .subscribe(onNext: { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
                DoneCancelBarView.shared.hide()
            })
            .disposed(by: disposeBag)


//        MARK: Done and save

        DoneCancelBarView.shared.doneButton.rx
            .tap
            .subscribe(onNext: { [weak self] _ in
                detailNode.save()
                self?.dismiss(animated: true, completion: nil)
                DoneCancelBarView.shared.hide()
            })
            .disposed(by: disposeBag)
    
//        MARK: Delete
        
        DoneCancelBarView.shared.deleteButton.rx
            .tap
            .subscribe(onNext: { [weak self] _ in
                if detailNode.isInEditMode {
                    let alert = UIAlertController(title: R.string.localizable.thisCounterIsAboutToBeDeleted(), message: R.string.localizable.thisCannotBeUndoneAreYouSure(), preferredStyle: UIAlertControllerStyle.alert)
                    let cancelAction = UIAlertAction(title: R.string.localizable.cancel(), style: UIAlertActionStyle.cancel, handler: nil)
                    let yesAction = UIAlertAction(title: R.string.localizable.yes(), style: UIAlertActionStyle.destructive) { _ in
                        
                        detailNode.delete()
                        
                        self?.dismiss(animated: true, completion: nil)
//                TODO: Now I clear search field
//                      to prevent crash when deleteing from the search result.
//                      But hopefully I do not have to do that
                        SearchAddBarView.shared.searchField.clear()
//                CounterStore.shared.reset()
                        
                        DoneCancelBarView.shared.hide()
                    }
                    alert.addAction(cancelAction)
                    alert.addAction(yesAction)
                    self?.present(alert, animated: true, completion: nil)
                } else {
                    self?.dismiss(animated: true, completion: nil)
                    SearchAddBarView.shared.searchField.clear()
                    DoneCancelBarView.shared.hide()
                }
            })
            .disposed(by: disposeBag)
    }
}
