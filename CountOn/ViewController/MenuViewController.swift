//
//  MenuViewController.swift
//  CountOn
//
//  Created by 4faramita on 2018/8/6.
//  Copyright © 2018年 4faramita. All rights reserved.
//

import UIKit

import SnapKit
import SwiftyUserDefaults
import RxSwift

final class MenuViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    
    private let iCloudSyncSwitch = UISwitch()
    private let iCloudSyncLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        title = R.string.localizable.settings()
        
        iCloudSyncSwitch.setOn(Defaults[.iCloudSync], animated: true)
        view.addSubview(iCloudSyncSwitch)
        iCloudSyncSwitch.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        view.addSubview(iCloudSyncLabel)
        iCloudSyncLabel.text = R.string.localizable.syncWithICloud()
        iCloudSyncLabel.textColor = .darkGray
        iCloudSyncLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(iCloudSyncSwitch.snp.top).offset(-10)
            make.centerX.equalToSuperview()
        }
        
        
        // MARK: Rx
        
        iCloudSyncSwitch.rx
            .value
            .subscribe(onNext: { value in
                Defaults[.iCloudSync] = value
            })
            .disposed(by: disposeBag)
    }
}
