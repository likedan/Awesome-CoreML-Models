//
//  ChartViewSelectorBrightness.swift
//  SwiftCharts
//
//  Created by ischuetz on 25/08/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import UIKit

open class ChartViewSelectorBrightness: ChartViewSelector {
 
    let selectedFactor: CGFloat
    
    public init(selectedFactor: CGFloat) {
        self.selectedFactor = selectedFactor
    }
    
    open func displaySelected(_ view: UIView, selected: Bool) {
        view.backgroundColor = selected ? view.backgroundColor?.adjustBrigtness(factor: selectedFactor) : view.backgroundColor?.adjustBrigtness(factor: 1 / selectedFactor)
    }
}