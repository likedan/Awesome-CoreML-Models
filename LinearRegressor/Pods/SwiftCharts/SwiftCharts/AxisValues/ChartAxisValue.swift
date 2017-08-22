//
//  ChartAxisValue.swift
//  swift_charts
//
//  Created by ischuetz on 01/03/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

/**
 A ChartAxisValue models a value along a particular chart axis. For example, two ChartAxisValues represent the two components of a ChartPoint. It has a backing Double scalar value, which provides a canonical form for all subclasses to be laid out along an axis. It also has one or more labels that are drawn in the chart.
 This class is not meant to be instantiated directly. Use one of the existing subclasses or create a new one.
 */
open class ChartAxisValue: Equatable, Hashable, CustomStringConvertible {
    
    /// The backing value for all other types of axis values
    open let scalar: Double
    open let labelSettings: ChartLabelSettings
    open var hidden = false

    /// The labels that will be displayed in the chart
    open var labels: [ChartAxisLabel] {
        let axisLabel = ChartAxisLabel(text: description, settings: labelSettings)
        axisLabel.hidden = hidden
        return [axisLabel]
    }

    public init(scalar: Double, labelSettings: ChartLabelSettings = ChartLabelSettings()) {
        self.scalar = scalar
        self.labelSettings = labelSettings
    }
    
    open var copy: ChartAxisValue {
        return copy(scalar)
    }
    
    open func copy(_ scalar: Double) -> ChartAxisValue {
        return ChartAxisValue(scalar: scalar, labelSettings: labelSettings)
    }

    // MARK: CustomStringConvertible

    open var description: String {
        return String(scalar)
    }
    
    open var hashValue: Int {
        return scalar.hashValue
    }
}

public func ==(lhs: ChartAxisValue, rhs: ChartAxisValue) -> Bool {
    return lhs.scalar =~ rhs.scalar
}
