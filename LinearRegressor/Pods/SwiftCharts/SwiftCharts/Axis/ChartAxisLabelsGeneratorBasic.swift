//
//  ChartAxisLabelsGeneratorBasic.swift
//  SwiftCharts
//
//  Created by ischuetz on 27/06/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import Foundation

/// Generates a single unformatted label for scalar
open class ChartAxisLabelsGeneratorBasic: ChartAxisLabelsGeneratorBase {

    open let labelSettings: ChartLabelSettings
    
    public init(labelSettings: ChartLabelSettings) {
        self.labelSettings = labelSettings
    }
    
    open override func generate(_ scalar: Double) -> [ChartAxisLabel] {
        return [ChartAxisLabel(text: "\(scalar)", settings: labelSettings)]
    }
    
    open override func fonts(_ scalar: Double) -> [UIFont] {
        return [labelSettings.font]
    }
}
