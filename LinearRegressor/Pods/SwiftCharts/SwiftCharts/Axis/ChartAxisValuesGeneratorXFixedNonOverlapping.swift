//
//  ChartAxisValuesGeneratorXFixedNonOverlapping.swift
//  SwiftCharts
//
//  Created by ischuetz / Iain Bryson on 19/07/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import UIKit

open class ChartAxisValuesGeneratorXFixedNonOverlapping: ChartAxisValuesGeneratorFixedNonOverlapping {
    
    public init(axisValues: [ChartAxisValue], spacing: CGFloat = 4) {
        super.init(axisValues: axisValues, spacing: spacing, isX: true)
    }
}