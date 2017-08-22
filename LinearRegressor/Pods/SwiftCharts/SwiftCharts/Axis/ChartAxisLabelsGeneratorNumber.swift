//
//  ChartAxisLabelsGeneratorNumber.swift
//  SwiftCharts
//
//  Created by ischuetz on 27/06/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import Foundation

/// Generates a single formatted number for scalar
open class ChartAxisLabelsGeneratorNumber: ChartAxisLabelsGeneratorBase {
    
    open let labelSettings: ChartLabelSettings
    
    open let formatter: NumberFormatter
    
    public init(labelSettings: ChartLabelSettings, formatter: NumberFormatter = ChartAxisLabelsGeneratorNumber.defaultFormatter) {
        self.labelSettings = labelSettings
        self.formatter = formatter
    }
    
    open override func generate(_ scalar: Double) -> [ChartAxisLabel] {
        let text = formatter.string(from: NSNumber(value: scalar))!
        return [ChartAxisLabel(text: text, settings: labelSettings)]
    }
    
    public static var defaultFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    open override func fonts(_ scalar: Double) -> [UIFont] {
        return [labelSettings.font]
    }
}
