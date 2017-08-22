//
//  ChartAxisLabelsGeneratorNumberSuffix.swift
//  SwiftCharts
//
//  Created by ischuetz on 21/07/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import Foundation

public enum ChartAxisLabelNumberSuffixUnit {
    case k, m, g, t, p, e

    static var seq: [ChartAxisLabelNumberSuffixUnit] {
        return [k, m, g, t, p, e]
    }
    
    var values: (factor: Double, text: String) {
        switch self {
        case .k: return (pow(10, 3), "K")
        case .m: return (pow(10, 6), "M")
        case .g: return (pow(10, 9), "G")
        case .t: return (pow(10, 12), "T")
        case .p: return (pow(10, 15), "P")
        case .e: return (pow(10, 18), "E")
        }
    }
    
    public var factor: Double {
        return values.factor
    }
    
    public var text: String {
        return values.text
    }
}

open class ChartAxisLabelsGeneratorNumberSuffix: ChartAxisLabelsGeneratorBase {
    
    open let labelSettings: ChartLabelSettings
    
    open let startUnit: ChartAxisLabelNumberSuffixUnit
    
    open let formatter: NumberFormatter
    
    public init(labelSettings: ChartLabelSettings, startUnit: ChartAxisLabelNumberSuffixUnit = .m, formatter: NumberFormatter = ChartAxisLabelsGeneratorNumberSuffix.defaultFormatter) {
        self.labelSettings = labelSettings
        self.startUnit = startUnit
        self.formatter = formatter
    }

    // src: http://stackoverflow.com/a/23290016/930450
    open override func generate(_ scalar: Double) -> [ChartAxisLabel] {
        let sign = scalar < 0 ? "-" : ""
        
        let absScalar = fabs(scalar)
        
        let (number, suffix): (Double, String) = {
            if (absScalar < startUnit.factor) {
                return (absScalar, "")
                
            } else {
                let exp = Int(log10(absScalar) / 3)
                let roundedScalar = round(10 * absScalar / pow(1000, Double(exp))) / 10
                return (roundedScalar, ChartAxisLabelNumberSuffixUnit.seq[exp - 1].text)
            }
        }()

        let text = "\(sign)\(formatter.string(from: NSNumber(value: number))!)\(suffix)"
        return [ChartAxisLabel(text: text, settings: labelSettings)]
    }
    
    public static var defaultFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    open override func fonts(_ scalar: Double) -> [UIFont] {
        return [labelSettings.font]
    }
}
