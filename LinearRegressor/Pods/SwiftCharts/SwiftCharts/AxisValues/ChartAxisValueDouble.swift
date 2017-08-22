//
//  ChartAxisValueDouble.swift
//  SwiftCharts
//
//  Created by ischuetz on 30/08/15.
//  Copyright © 2015 ivanschuetz. All rights reserved.
//

import UIKit

open class ChartAxisValueDouble: ChartAxisValue {
    
    open let formatter: NumberFormatter

    public convenience init(_ int: Int, formatter: NumberFormatter = ChartAxisValueDouble.defaultFormatter, labelSettings: ChartLabelSettings = ChartLabelSettings()) {
        self.init(Double(int), formatter: formatter, labelSettings: labelSettings)
    }
    
    public init(_ double: Double, formatter: NumberFormatter = ChartAxisValueDouble.defaultFormatter, labelSettings: ChartLabelSettings = ChartLabelSettings()) {
        self.formatter = formatter
        super.init(scalar: double, labelSettings: labelSettings)
    }
    
    override open func copy(_ scalar: Double) -> ChartAxisValueDouble {
        return ChartAxisValueDouble(scalar, formatter: formatter, labelSettings: labelSettings)
    }
    
    public static var defaultFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    // MARK: CustomStringConvertible

    override open var description: String {
        return formatter.string(from: NSNumber(value: scalar))!
    }
}
