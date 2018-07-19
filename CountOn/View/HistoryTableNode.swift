//
//  HistoryTableNode.swift
//  CountOn
//
//  Created by 4faramita on 2018/6/23.
//  Copyright © 2018年 4faramita. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import RealmSwift

class HistoryTableNode: ASTableNode {
    
    var historyArray: [History]
    
    let absoluteDate: Bool
    
    init(with historyList: [History], absoluteDate: Bool) {
        self.absoluteDate = absoluteDate
        historyArray = historyList
        
        super.init(style: .plain)
        
        delegate = self
        dataSource = self
        
        contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
        
//        view.separatorStyle = .none
//        view.allowsSelection = true
    }
    
    override func didLoad() {
        super.didLoad()
        
        view.keyboardDismissMode = .interactive
    }
}

extension HistoryTableNode: ASTableDataSource, ASTableDelegate, ASCommonTableDataSource {
    
    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        // Should read the row count directly from table view but
        // https://github.com/facebook/AsyncDisplayKit/issues/1159
        
        let history = historyArray[indexPath.row]
        
        let node = HistoryCellNode(with: history, absoluteDate: self.absoluteDate)
        
        node.style.height = ASDimensionMake(30)
        
        node.selectionStyle = .none
        
        return node
    }
    
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 1
    }
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return historyArray.count
    }
}
