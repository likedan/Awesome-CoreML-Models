//
//  ChartPointBubble.swift
//  Examples
//
//  Created by ischuetz on 17/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

open class ChartPointBubble: ChartPoint {
    open let diameterScalar: Double
    open let bgColor: UIColor
    open let borderColor: UIColor
    
    public init(x: ChartAxisValue, y: ChartAxisValue, diameterScalar: Double, bgColor: UIColor, borderColor: UIColor = UIColor.black) {
        self.diameterScalar = diameterScalar
        self.bgColor = bgColor
        self.borderColor = borderColor
        super.init(x: x, y: y)
    }

    required public init(x: ChartAxisValue, y: ChartAxisValue) {
        fatalError("init(x:y:) has not been implemented")
    }
}