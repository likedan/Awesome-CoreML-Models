//
//  ChartAxisYHighLayerDefault.swift
//  SwiftCharts
//
//  Created by ischuetz on 25/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

/// A ChartAxisLayer for high Y axes
class ChartAxisYHighLayerDefault: ChartAxisYLayerDefault {
    
    override var low: Bool {return false}

    /// The start point of the axis line.
    override var lineP1: CGPoint {
        return CGPoint(x: origin.x, y: axis.firstVisibleScreen)
    }

    /// The end point of the axis line.
    override var lineP2: CGPoint {
        return CGPoint(x: end.x, y: axis.lastVisibleScreen)
    }
    
    override func updateInternal() {
        guard let chart = chart else {return}
        super.updateInternal()
        if lastFrame.width != frame.width {
            
            // Move drawers by delta
            let delta = frame.width - lastFrame.width
            offset -= delta
            initDrawers()
            
            if canChangeFrameSize {
                chart.notifyAxisInnerFrameChange(yHigh: ChartAxisLayerWithFrameDelta(layer: self, delta: delta))
            }
        }
    }
    
    
    override func handleAxisInnerFrameChange(_ xLow: ChartAxisLayerWithFrameDelta?, yLow: ChartAxisLayerWithFrameDelta?, xHigh: ChartAxisLayerWithFrameDelta?, yHigh: ChartAxisLayerWithFrameDelta?) {
        super.handleAxisInnerFrameChange(xLow, yLow: yLow, xHigh: xHigh, yHigh: yHigh)
        
        // Handle resizing of other high y axes
        if let yHigh = yHigh , yHigh.layer.frame.maxX > frame.maxX {
            offset = offset - yHigh.delta
            initDrawers()
        }
    }
    
    override func initDrawers() {
        
        lineDrawer = generateLineDrawer(offset: 0)
        
        let labelsOffset = settings.labelsToAxisSpacingY + settings.axisStrokeWidth
        labelDrawers = generateLabelDrawers(offset: labelsOffset)
        let axisTitleLabelsOffset = labelsOffset + labelsMaxWidth + settings.axisTitleLabelsToLabelsSpacing
        axisTitleLabelDrawers = generateAxisTitleLabelsDrawers(offset: axisTitleLabelsOffset)
    }
    
    override func generateLineDrawer(offset: CGFloat) -> ChartLineDrawer {
        let halfStrokeWidth = settings.axisStrokeWidth / 2 // we want that the stroke begins at the beginning of the frame, not in the middle of it
        let x = origin.x + offset + halfStrokeWidth
        let p1 = CGPoint(x: x, y: axis.firstVisibleScreen)
        let p2 = CGPoint(x: x, y: axis.lastVisibleScreen)
        return ChartLineDrawer(p1: p1, p2: p2, color: settings.lineColor, strokeWidth: settings.axisStrokeWidth)
    }
    
    override func labelsX(offset: CGFloat, labelWidth: CGFloat, textAlignment: ChartLabelTextAlignment) -> CGFloat {
        var labelsX: CGFloat
        switch textAlignment {
        case .left, .default:
            labelsX = origin.x + offset
        case .right:
            labelsX = origin.x + offset + labelsMaxWidth - labelWidth
        }
        return labelsX
    }
    
    override func axisLineX(offset: CGFloat) -> CGFloat {
        return self.offset + offset + settings.axisStrokeWidth / 2
    }
}
