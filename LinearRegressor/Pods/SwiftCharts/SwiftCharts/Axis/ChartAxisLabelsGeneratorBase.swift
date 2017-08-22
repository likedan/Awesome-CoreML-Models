//
//  ChartAxisLabelsGeneratorBase.swift
//  SwiftCharts
//
//  Created by ischuetz on 17/08/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import Foundation

/// Needed for common stored properties which are not possible in the extension (without workarounds)
open class ChartAxisLabelsGeneratorBase: ChartAxisLabelsGenerator {

    open var onlyShowCompleteLabels: Bool = false
    
    open var maxStringPTWidth: CGFloat? = nil
    
    var cache = [Double: [ChartAxisLabel]]()
    
    open func generate(_ scalar: Double) -> [ChartAxisLabel] {
        fatalError("Override")
    }
    
    open func fonts(_ scalar: Double) -> [UIFont] {
        fatalError("Override")
    }
    
    open func cache(_ scalar: Double, labels: [ChartAxisLabel]) {
        cache[scalar] = labels
    }
    
    open func cachedLabels(_ scalar: Double) -> [ChartAxisLabel]? {
        return cache[scalar]
    }
}