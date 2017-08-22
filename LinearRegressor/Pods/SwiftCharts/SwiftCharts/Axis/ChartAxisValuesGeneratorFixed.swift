//
//  ChartAxisValuesGeneratorFixed.swift
//  SwiftCharts
//
//  Created by ischuetz on 27/06/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import Foundation

/// Generates a fixed axis values array
open class ChartAxisValuesGeneratorFixed: ChartAxisValuesGenerator {
    
    open var first: Double? {
        return values.first
    }
    
    open var last: Double? {
        return values.last
    }
    
    open internal(set) var values: [Double]
    
    public convenience init(values: [ChartAxisValue]) {
        self.init(values: values.map{$0.scalar})
    }

    public init(values: [Double]) {
        self.values = values
    }

    open func axisInitialized(_ axis: ChartAxis) {}
    
    open func generate(_ axis: ChartAxis) -> [Double] {
        let (first, last) = axis.firstVisible > axis.lastVisible ? (axis.lastModelValueInBounds, axis.firstVisible) : (axis.firstVisible, axis.lastVisible)
        return values.filter{$0 >= first && $0 <= last}
    }
}
