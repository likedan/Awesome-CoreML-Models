//
//  ChartAxisValuesGeneratorXDividers.swift
//  SwiftCharts
//
//  Created by ischuetz on 26/07/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import Foundation

open class ChartAxisValuesGeneratorXDividers: ChartAxisGeneratorMultiplier {
    
    open override var first: Double? {
        return Double(minValue)
    }
    
    open override var last: Double?  {
        return Double(maxValue)
    }
    
    fileprivate var minValue: Double
    fileprivate var maxValue: Double
    fileprivate let minSpace: CGFloat
    fileprivate let nice: Bool
    fileprivate let preferredDividers: Int
    
    fileprivate let maxTextSize: CGFloat
    
    public init(minValue: Double, maxValue: Double, preferredDividers: Int, nice: Bool, formatter: NumberFormatter, font: UIFont, minSpace: CGFloat = 10, multiplierUpdateMode: ChartAxisGeneratorMultiplierUpdateMode = .halve) {
        
        self.minValue = minValue
        self.maxValue = maxValue
        
        self.nice = nice
        self.preferredDividers = preferredDividers
        self.minSpace = minSpace
        
        self.maxTextSize = ChartAxisValuesGeneratorXDividers.largestSize(minValue, maxValue: maxValue, formatter: formatter, font: font)
        
        super.init(Double.greatestFiniteMagnitude, multiplierUpdateMode: multiplierUpdateMode)
    }
    
    fileprivate static func largestSize(_ minValue: Double, maxValue: Double, formatter: NumberFormatter, font: UIFont) -> CGFloat {
        
        let minNumberTextSize = formatter.string(from: NSNumber(value: minValue))!.width(font)
        let maxNumberTextSize = formatter.string(from: NSNumber(value: maxValue))!.width(font)
        
        let minDigits = formatter.minimumFractionDigits
        let maxDigits = formatter.maximumFractionDigits
        
        let remainingWidth: CGFloat = {
            if minDigits < maxDigits {
                return (minDigits..<maxDigits).reduce(0) {total, _ in total + "0".width(font)}
            } else {
                return 0
            }
        }()

        return max(minNumberTextSize, maxNumberTextSize) + remainingWidth
    }
    
    open func calculateFittingRangeAndFactor(_ axis: ChartAxis) -> (min: Double, max: Double, factor: Double)? {
        
        if nice {
            let niceMinMax = nice(minValue: Double(minValue), maxValue: Double(maxValue))
            minValue = niceMinMax.minValue
            maxValue = niceMinMax.maxValue
        }
        
        let growDelta = floor(pow(10, round(log10(Double(min(abs(minValue), abs(maxValue)))))))
        
        let length = maxValue - minValue
        let maxDelta = length / 6 // try to expand range to the left/right of initial range
        
        var fittingFactorsPerDelta = [(min: Double, max: Double, factor: Double)]()
        var currentDelta: Double = 0
        var counter = 0 // just in case
        while(currentDelta < maxDelta && counter < 100) {
            let min = minValue - currentDelta
            let max = maxValue + currentDelta
            if let fittingFactor = findFittingFactor(axis, modelLength: Int(max - min)) {
                fittingFactorsPerDelta.append((min, max, Double(fittingFactor)))
            }

            currentDelta += growDelta // grow left and right
            counter += 1
        }
        
        var maxFittingFactorOpt: (min: Double, max: Double, factor: Double)?
        for f in fittingFactorsPerDelta {
            
            if let maxFittingFactor = maxFittingFactorOpt {
                if f.factor > maxFittingFactor.factor {
                    maxFittingFactorOpt = f
                }
            } else {
                maxFittingFactorOpt = f
            }
        }
        
        return maxFittingFactorOpt
    }
    
    // inspired by d3 nice
    fileprivate func nice(minValue: Double, maxValue: Double) -> (minValue: Double, maxValue: Double) {
        let span = pow(10, round(log(maxValue - minValue)/log(10)) - 1)
        return(minValue: (floor(minValue / span) * span), maxValue: (ceil(maxValue / span) * span))
    }
    
    fileprivate func findFittingFactor(_ axis: ChartAxis, modelLength: Int) -> Int? {
        
        let factors = modelLength.primeFactors
        
        var lastFitting: Int?
        
        // look for max factor which fits
        for factor in factors {
            if minSpace + ((maxTextSize + minSpace) * CGFloat(factor)) < axis.screenLength {
                lastFitting = factor
            } else { // when labels don't fit, return the previous fitting
                return lastFitting
            }
        }
        return lastFitting
    }
    
    open override func axisInitialized(_ axis: ChartAxis) {
        
        func defaultInit() {
            let maxDividers = Int((axis.screenLength + minSpace) / (maxTextSize + minSpace))
            let dividers = min(preferredDividers, maxDividers)
            multiplier = axis.length / Double(dividers)
        }
        
        if nice {
            if let rangeAndMultiplier = calculateFittingRangeAndFactor(axis) {
                minValue = rangeAndMultiplier.min
                maxValue = rangeAndMultiplier.max
                multiplier = Double(maxValue - minValue) / Double(rangeAndMultiplier.factor)
                
            } else {
                defaultInit()
            }
        } else {
            defaultInit()
        }
    }
}
