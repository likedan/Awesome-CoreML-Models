//
//  ChartAxisValueInt.swift
//  SwiftCharts
//
//  Created by ischuetz on 04/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

open class ChartAxisValueInt: ChartAxisValue {

    open let int: Int

    public init(_ int: Int, labelSettings: ChartLabelSettings = ChartLabelSettings()) {
        self.int = int
        super.init(scalar: Double(int), labelSettings: labelSettings)
    }
    
    override open func copy(_ scalar: Double) -> ChartAxisValueInt {
        return ChartAxisValueInt(int, labelSettings: labelSettings)
    }

    // MARK: CustomStringConvertible
    
    override open var description: String {
        return String(int)
    }
}
