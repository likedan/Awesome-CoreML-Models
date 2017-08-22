//
//  ChartNiceNumberCalculator.swift
//  SwiftCharts
//
//  Created by ischuetz on 08/08/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import Foundation

class ChartNiceNumberCalculator {
    
    // src: http://stackoverflow.com/a/4948320/930450
    static func niceNumber(_ value: Double, round: Bool) -> Double {
        
        let exponent = floor(log10(value))
        
        let fraction = value / pow(10, exponent)
        
        var niceFraction = 1.0
        
        if round {
            if fraction < 1.5 {
                niceFraction = 1
            } else if fraction < 3 {
                niceFraction = 2
            } else if fraction < 7 {
                niceFraction = 5
            } else {
                niceFraction = 10
            }
            
        } else {
            if fraction <= 1 {
                niceFraction = 1
            } else if fraction <= 2 {
                niceFraction = 2
            } else if niceFraction <= 5 {
                niceFraction = 5
            } else {
                niceFraction = 10
            }
        }
        
        return niceFraction * pow(10, exponent)
    }
}
