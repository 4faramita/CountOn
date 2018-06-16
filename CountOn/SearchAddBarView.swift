//
//  SearchAddBarView.swift
//  CountOn
//
//  Created by 4faramita on 2018/6/16.
//  Copyright © 2018年 4faramita. All rights reserved.
//

import UIKit
//import SnapKit

class SearchAddBarView: UIImageView {
    
    let addButton = UIButton()
    let searchField = UITextField()
    
    convenience init() {
        self.init(image: UIImage(named: "bar"))
        
        
        addButton.titleLabel?.text = "Add"
        self.addSubview(addButton)
    }
}
