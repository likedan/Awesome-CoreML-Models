//
//  ChartAxisValuesGeneratorYFixedNonOverlapping.swift
//  SwiftCharts
//
//  Created by ischuetz on 21/07/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import UIKit

open class ChartAxisValuesGeneratorYFixedNonOverlapping: ChartAxisValuesGeneratorFixedNonOverlapping {
    
    public init(axisValues: [ChartAxisValue], spacing: CGFloat = 4) {
        super.init(axisValues: axisValues, spacing: spacing, isX: false)
    }
}
