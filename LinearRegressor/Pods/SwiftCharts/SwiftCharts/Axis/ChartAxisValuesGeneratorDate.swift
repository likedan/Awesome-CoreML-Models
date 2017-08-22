//
//  ChartAxisValuesGeneratorDate.swift
//  SwiftCharts
//
//  Created by ischuetz on 05/08/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import UIKit

open class ChartAxisValuesGeneratorDate: ChartAxisGeneratorMultiplier {
    
    let unit: Calendar.Component

    fileprivate let minSpace: CGFloat
    fileprivate let preferredDividers: Int
    fileprivate let maxTextSize: CGFloat
    
    public init(unit: Calendar.Component, preferredDividers: Int, minSpace: CGFloat, maxTextSize: CGFloat, multiplierUpdateMode: ChartAxisGeneratorMultiplierUpdateMode = .halve) {
        self.unit = unit
        self.preferredDividers = preferredDividers
        self.minSpace = minSpace
        self.maxTextSize = maxTextSize
        super.init(0, multiplierUpdateMode: multiplierUpdateMode)
    }
    
    override func calculateModelStart(_ axis: ChartAxis, multiplier: Double) -> Double {
        guard !multiplier.isNaN && !multiplier.isZero else {return Double.nan}
        
        let firstVisibleDate = Date(timeIntervalSince1970: axis.firstVisible)
        let firstInitDate = Date(timeIntervalSince1970: axis.firstInit)
        
        return firstInitDate.addComponent(Int((Double(firstVisibleDate.timeInterval(firstInitDate, unit: unit)) / multiplier)) * Int(multiplier), unit: unit).timeIntervalSince1970
    }
    
    override func incrementScalar(_ scalar: Double, multiplier: Double) -> Double {
        let scalarDate = Date(timeIntervalSince1970: scalar)
        return scalarDate.addComponent(Int(multiplier), unit: unit).timeIntervalSince1970
    }
    
    open override func axisInitialized(_ axis: ChartAxis) {
        
        var dividers = preferredDividers
        var cont = true
        
        while dividers > 1 && cont {
            if requiredLengthForDividers(dividers) < axis.screenLength {
                
                let firstDate = Date(timeIntervalSince1970: axis.first)
                let lastDate = Date(timeIntervalSince1970: axis.last)
                let lengthInUnits = lastDate.timeInterval(firstDate, unit: unit)
                
                multiplier = Double(lengthInUnits) / Double(dividers)
                cont = false
                
            } else {
                dividers -= 1
            }
        }
    }
    
    fileprivate func requiredLengthForDividers(_ dividers: Int) -> CGFloat {
        return minSpace + ((maxTextSize + minSpace) * CGFloat(dividers))
    }
}
