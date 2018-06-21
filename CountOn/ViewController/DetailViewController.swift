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

class DetailViewController: ASViewController<ASDisplayNode> {

    let doneCancelBar = DoneCancelBarView()
    
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
        
        node.view.addSubview(doneCancelBar)
        doneCancelBar.center = CGPoint(x: StaticValues.screenWidth / 2, y: StaticValues.screenHeight - 40)
        SearchAddBarView.shared.hide()
        
        RxKeyboard.instance.visibleHeight
            .drive(onNext: { [weak self] keyboardVisibleHeight in
                self?.doneCancelBar.center = CGPoint(x: StaticValues.screenWidth / 2, y: StaticValues.screenHeight - 40 - keyboardVisibleHeight)
            })
            .disposed(by: disposeBag)
        
        doneCancelBar.cancelButton.rx
            .tap
            .subscribe(onNext: {
                self.dismiss(animated: true, completion: nil)
                SearchAddBarView.shared.show()
            })
            .disposed(by: disposeBag)
    }

//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        print(">>> will appear")
//    }
}
