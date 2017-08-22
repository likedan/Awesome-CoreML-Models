//
//  ChartAxisLabelGeneratorDate.swift
//  SwiftCharts
//
//  Created by ischuetz on 05/08/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import UIKit

open class ChartAxisLabelsGeneratorDate: ChartAxisLabelsGeneratorBase {
    
    open let labelSettings: ChartLabelSettings
    
    open let formatter: DateFormatter
    
    public init(labelSettings: ChartLabelSettings, formatter: DateFormatter = ChartAxisLabelsGeneratorDate.defaultFormatter) {
        self.labelSettings = labelSettings
        self.formatter = formatter
    }
    
    open override func generate(_ scalar: Double) -> [ChartAxisLabel] {
        let text = formatter.string(from: Date(timeIntervalSince1970: scalar))
        return [ChartAxisLabel(text: text, settings: labelSettings)]
    }
    
    public static var defaultFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()
    
    open override func fonts(_ scalar: Double) -> [UIFont] {
        return [labelSettings.font]
    }
}
