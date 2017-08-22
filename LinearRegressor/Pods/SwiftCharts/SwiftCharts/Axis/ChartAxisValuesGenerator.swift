//
//  ChartAxisValuesGenerator.swift
//  SwiftCharts
//
//  Created by ischuetz on 27/06/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import Foundation

/// Generates axis values to be displayed
public protocol ChartAxisValuesGenerator {
    
    var first: Double? {get}

    var last: Double? {get}
    
    func axisInitialized(_ axis: ChartAxis)
    
    func generate(_ axis: ChartAxis) -> [Double]
}
