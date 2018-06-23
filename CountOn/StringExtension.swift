//
//  StringExtension.swift
//  CountOn
//
//  Created by 4faramita on 2018/6/24.
//  Copyright © 2018年 4faramita. All rights reserved.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}
