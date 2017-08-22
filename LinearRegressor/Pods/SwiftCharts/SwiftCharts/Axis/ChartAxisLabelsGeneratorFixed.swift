//
//  ChartAxisLabelsGeneratorFixed.swift
//  SwiftCharts
//
//  Created by ischuetz on 27/06/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import Foundation

open class ChartAxisLabelsGeneratorFixed: ChartAxisLabelsGeneratorBase {
    
    open let dict: [Double: [ChartAxisLabel]]
    
    public convenience init(axisValues: [ChartAxisValue]) {
        var dict = [Double: [ChartAxisLabel]]()
        for axisValue in axisValues {
            if !axisValue.hidden {
                dict[axisValue.scalar] = axisValue.labels
            }
            
        }
        self.init(dict: dict)
    }
    
    public init(dict: [Double: [ChartAxisLabel]]) {
        self.dict = dict
    }
    
    open override func generate(_ scalar: Double) -> [ChartAxisLabel] {
        return dict[scalar] ?? []
    }
    
    open override func fonts(_ scalar: Double) -> [UIFont] {
        return dict[scalar].map {labels in labels.map{$0.settings.font}} ?? []
    }
}