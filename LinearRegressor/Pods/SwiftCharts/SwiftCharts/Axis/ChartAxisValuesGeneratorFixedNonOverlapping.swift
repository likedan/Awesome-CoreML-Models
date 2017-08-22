//
//  ChartAxisValuesGeneratorFixedNonOverlapping.swift
//  SwiftCharts
//
//  Created by ischuetz / Iain Bryson on 19/07/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import UIKit

open class ChartAxisValuesGeneratorFixedNonOverlapping: ChartAxisValuesGeneratorFixed {
    
    open let axisValues: [ChartAxisValue]
    
    open let maxLabelSize: CGSize
    open let totalLabelSize: CGSize
    open let spacing: CGFloat
    
    fileprivate var isX: Bool
    
    init(axisValues: [ChartAxisValue], spacing: CGFloat, isX: Bool) {
        self.axisValues = axisValues
        self.spacing = spacing
        self.isX = isX
        
        (totalLabelSize, maxLabelSize) = axisValues.calculateLabelsDimensions()
        
        super.init(values: axisValues.map{$0.scalar})
    }
        
    open override func generate(_ axis: ChartAxis) -> [Double] {
        updateAxisValues(axis)
        return super.generate(axis)
    }
    
    fileprivate func updateAxisValues(_ axis: ChartAxis) {
        values = selectNonOverlappingAxisLabels(axisValues, screenLength: axis.screenLength).map{$0.scalar}
    }
    
    fileprivate func selectNonOverlappingAxisLabels(_ axisValues: [ChartAxisValue], screenLength: CGFloat) -> [ChartAxisValue] {
        
        // Select only the x-axis labels which would prevent any overlap
        let spacePerTick = screenLength / CGFloat(axisValues.count)
        
        var filteredAxisValues: [ChartAxisValue] = []
        
        var coord: CGFloat = 0, currentLabelEnd: CGFloat = 0
        axisValues.forEach({axisValue in
            coord += spacePerTick
            if (currentLabelEnd <= coord) {
                filteredAxisValues.append(axisValue)
                currentLabelEnd = coord + (isX ? maxLabelSize.width : maxLabelSize.height) + spacing
            }
        })
        
        // Always show the last label
        if let filteredLast = filteredAxisValues.last, let axisLabelLast = axisValues.last , filteredLast != axisLabelLast {
            filteredAxisValues[filteredAxisValues.count - 1] = axisLabelLast
        }
        
        return filteredAxisValues
    }
}