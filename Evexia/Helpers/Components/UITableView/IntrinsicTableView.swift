//
//  IntrinsicTableView.swift
//  Evexia
//
//  Created by  Artem Klimov on 08.08.2021.
//

import UIKit

class IntrinsicTableView: UITableView {
    
    override var contentSize: CGSize {
        didSet {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        return self.contentSize
    }
}

class IntrinsicCollectionView: UICollectionView {
    
    override var contentSize: CGSize {
        didSet {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }
}
