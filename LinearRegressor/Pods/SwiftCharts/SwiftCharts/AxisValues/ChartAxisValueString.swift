//
//  ChartAxisValueString.swift
//  SwiftCharts
//
//  Created by ischuetz on 29/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

open class ChartAxisValueString: ChartAxisValue {
   
    open let string: String
    
    public init(_ string: String = "", order: Int, labelSettings: ChartLabelSettings = ChartLabelSettings()) {
        self.string = string
        super.init(scalar: Double(order), labelSettings: labelSettings)
    }
    
    // MARK: CustomStringConvertible

    override open var description: String {
        return string
    }
}
