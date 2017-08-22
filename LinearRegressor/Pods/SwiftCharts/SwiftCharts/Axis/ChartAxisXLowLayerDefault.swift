//
//  ChartAxisXLowLayerDefault.swift
//  SwiftCharts
//
//  Created by ischuetz on 25/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

/// A ChartAxisLayer for low X axes
class ChartAxisXLowLayerDefault: ChartAxisXLayerDefault {

    override var low: Bool {return true}

    /// The start point of the axis line.
    override var lineP1: CGPoint {
        return CGPoint(x: axis.firstVisibleScreen, y: origin.y)
    }

    /// The end point of the axis line.
    override var lineP2: CGPoint {
        return CGPoint(x: axis.lastVisibleScreen, y: end.y)
    }
    
    override func chartViewDrawing(context: CGContext, chart: Chart) {
        super.chartViewDrawing(context: context, chart: chart)
    }

    override func updateInternal() {
        guard let chart = chart else {return}
        super.updateInternal()
        if lastFrame.height != frame.height {
            
            // Move drawers by delta
            let delta = frame.height - lastFrame.height
            offset -= delta
            initDrawers()
            
            if canChangeFrameSize {
                chart.notifyAxisInnerFrameChange(xLow: ChartAxisLayerWithFrameDelta(layer: self, delta: delta))
            }
            
        }
    }

    override func handleAxisInnerFrameChange(_ xLow: ChartAxisLayerWithFrameDelta?, yLow: ChartAxisLayerWithFrameDelta?, xHigh: ChartAxisLayerWithFrameDelta?, yHigh: ChartAxisLayerWithFrameDelta?) {
        super.handleAxisInnerFrameChange(xLow, yLow: yLow, xHigh: xHigh, yHigh: yHigh)
        
        // Handle resizing of other low x axes
        if let xLow = xLow , xLow.layer.frame.maxY > frame.maxY {
            offset = offset - xLow.delta
            initDrawers()
        }
    }
    
    override func axisLineY(offset: CGFloat) -> CGFloat {
        return self.offset + offset + settings.axisStrokeWidth / 2
    }
    
    override func initDrawers() {
        lineDrawer = generateLineDrawer(offset: 0)
        let labelsOffset = settings.axisStrokeWidth + settings.labelsToAxisSpacingX
        labelDrawers = generateLabelDrawers(offset: labelsOffset)
        let definitionLabelsOffset = labelsOffset + labelsTotalHeight + settings.axisTitleLabelsToLabelsSpacing
        axisTitleLabelDrawers = generateAxisTitleLabelsDrawers(offset: definitionLabelsOffset)
    }
}
