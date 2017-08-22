//
//  ChartPoint.swift
//  swift_charts
//
//  Created by ischuetz on 01/03/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

open class ChartPoint: Hashable, Equatable, CustomStringConvertible {
    
    open let x: ChartAxisValue
    open let y: ChartAxisValue
    
    required public init(x: ChartAxisValue, y: ChartAxisValue) {
        self.x = x
        self.y = y
    }
    
    open var description: String {
        return "\(x), \(y)"
    }
    
    open var hashValue: Int {
        return 31 &* x.hashValue &+ y.hashValue
    }
}

public func ==(lhs: ChartPoint, rhs: ChartPoint) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}
