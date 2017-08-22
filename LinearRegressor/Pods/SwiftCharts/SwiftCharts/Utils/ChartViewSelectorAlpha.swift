//
//  ChartViewSelectorAlpha.swift
//  SwiftCharts
//
//  Created by ischuetz on 25/08/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import UIKit

open class ChartViewSelectorAlpha: ChartViewSelector {
    
    fileprivate var selectedAlpha: CGFloat
    fileprivate var deselectedAlpha: CGFloat
    
    public init(selectedAlpha: CGFloat, deselectedAlpha: CGFloat) {
        self.selectedAlpha = selectedAlpha
        self.deselectedAlpha = deselectedAlpha
    }
    
    open func displaySelected(_ view: UIView, selected: Bool) {
        view.backgroundColor = view.backgroundColor.map{$0.copy(alpha: selected ? selectedAlpha : deselectedAlpha)}
    }
}