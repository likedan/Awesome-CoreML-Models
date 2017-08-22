//
//  ChartAxisValuesGeneratorNice.swift
//  SwiftCharts
//
//  Created by ischuetz on 04/08/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import UIKit

open class ChartAxisValuesGeneratorNice: ChartAxisGeneratorMultiplier {
    
    open override var first: Double? {
        return Double(minValue)
    }
    
    open override var last: Double?  {
        return Double(maxValue)
    }
    
    fileprivate var minValue: Double
    fileprivate var maxValue: Double
    fileprivate let minSpace: CGFloat
    fileprivate let preferredDividers: Int
    
    fileprivate let maxTextSize: CGFloat
    
    public init(minValue: Double, maxValue: Double, preferredDividers: Int, minSpace: CGFloat, maxTextSize: CGFloat, multiplierUpdateMode: ChartAxisGeneratorMultiplierUpdateMode = .halve) {
        
        self.minValue = minValue
        self.maxValue = maxValue
        
        self.preferredDividers = preferredDividers
        self.minSpace = minSpace
        
        self.maxTextSize = maxTextSize
        
        super.init(Double.greatestFiniteMagnitude, multiplierUpdateMode: multiplierUpdateMode)
    }
    
    func niceRangeAndMultiplier(_ dividers: Int) -> (minValue: Double, maxValue: Double, multiplier: Double) {
        let niceLength = ChartNiceNumberCalculator.niceNumber(maxValue - minValue, round: true)
        let niceMultiplier = ChartNiceNumberCalculator.niceNumber(niceLength / (Double(dividers) - 1), round: true)
        let niceMinValue = floor(minValue / niceMultiplier) * niceMultiplier
        let niceMaxValue = ceil(maxValue / niceMultiplier) * niceMultiplier
        return (niceMinValue, niceMaxValue, niceMultiplier)
    }
    
    open override func axisInitialized(_ axis: ChartAxis) {
        
        var dividers = preferredDividers
        var cont = true
        
        while dividers > 1 && cont {
            
            let nice = niceRangeAndMultiplier(dividers)
            
            if requiredLengthForDividers(dividers) < axis.screenLength {
                
                minValue = nice.minValue
                maxValue = nice.maxValue
                multiplier = nice.multiplier
                
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
