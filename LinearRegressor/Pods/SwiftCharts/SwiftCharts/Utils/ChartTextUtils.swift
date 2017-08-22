//
//  ChartTextUtils.swift
//  SwiftCharts
//
//  Created by ischuetz on 13/08/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import UIKit

public struct ChartTextUtils {
    
    public static func maxTextWidth(_ minValue: Double, maxValue: Double, formatter: NumberFormatter, font: UIFont) -> CGFloat {
        
        let noDecimalsFormatter = NumberFormatter()
        noDecimalsFormatter.maximumFractionDigits = 0
        noDecimalsFormatter.roundingMode = .down
        
        let noDecimalsMin = noDecimalsFormatter.string(from: NSNumber(value: minValue))!
        let noDecimalsMax = noDecimalsFormatter.string(from: NSNumber(value: maxValue))!
        
        let minNumberNoDecimalsTextSize = noDecimalsMin.width(font)
        let maxNumberNoDecimalsTextSize = noDecimalsMax.width(font)
        
        let maxNoDecimalsLength = max(minNumberNoDecimalsTextSize, maxNumberNoDecimalsTextSize)
        
        let digitMaxWidth = "8".width(font)
        let maxDecimalsWidth = CGFloat(formatter.maximumFractionDigits) * digitMaxWidth
        
        let widthForDecimalSign = formatter.maximumFractionDigits > 0 ? formatter.decimalSeparator.width(font) : 0
        
        return maxNoDecimalsLength + maxDecimalsWidth + widthForDecimalSign
    }
    
    public static func maxTextHeight(_ minValue: Double, maxValue: Double, formatter: NumberFormatter, font: UIFont) -> CGFloat {
        return "H".height(font)
    }
}