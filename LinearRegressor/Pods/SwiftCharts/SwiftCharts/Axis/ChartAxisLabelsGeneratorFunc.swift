//
//  ChartAxisLabelsGeneratorFunc.swift
//  SwiftCharts
//
//  Created by ischuetz on 28/06/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import Foundation

/// Label generator that delegates to a closure, for greater flexibility
open class ChartAxisLabelsGeneratorFunc: ChartAxisLabelsGeneratorBase {

    let f: (Double) -> [ChartAxisLabel]

    /// Convenience initializer for function which maps scalar to a single label
    public convenience init(f: @escaping (Double) -> ChartAxisLabel) {
        self.init(f: {scalar in
            return [f(scalar)]
        })
    }
    
    public init(f: @escaping (Double) -> [ChartAxisLabel]) {
        self.f = f
    }
    
    open override func generate(_ scalar: Double) -> [ChartAxisLabel] {
        return f(scalar)
    }
    
    open override func fonts(_ scalar: Double) -> [UIFont] {
        return f(scalar).map{$0.settings.font}
    }
}
