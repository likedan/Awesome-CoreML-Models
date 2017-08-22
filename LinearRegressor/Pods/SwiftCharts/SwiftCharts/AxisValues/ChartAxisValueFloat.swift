//
//  ChartAxisValueFloat.swift
//  swift_charts
//
//  Created by ischuetz on 15/03/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

@available(*, deprecated: 0.2.5, message: "use ChartAxisValueDouble instead")
open class ChartAxisValueFloat: ChartAxisValue {
    
    open let formatter: NumberFormatter

    open var float: CGFloat {
        return CGFloat(scalar)
    }

    public init(_ float: CGFloat, formatter: NumberFormatter = ChartAxisValueFloat.defaultFormatter, labelSettings: ChartLabelSettings = ChartLabelSettings()) {
        self.formatter = formatter
        super.init(scalar: Double(float), labelSettings: labelSettings)
    }
   
    override open func copy(_ scalar: Double) -> ChartAxisValueFloat {
        return ChartAxisValueFloat(CGFloat(scalar), formatter: formatter, labelSettings: labelSettings)
    }
    
    public static var defaultFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    // MARK: CustomStringConvertible

    override open var description: String {
        return formatter.string(from: NSNumber(value: Float(float)))!
    }
}
