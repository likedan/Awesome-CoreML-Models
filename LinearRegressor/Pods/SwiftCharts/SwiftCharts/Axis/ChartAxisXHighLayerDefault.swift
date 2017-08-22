//
//  ChartAxisXHighLayerDefault.swift
//  SwiftCharts
//
//  Created by ischuetz on 25/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

/// A ChartAxisLayer for high X axes
class ChartAxisXHighLayerDefault: ChartAxisXLayerDefault {
    
    override var low: Bool {return false}

    /// The start point of the axis line.
    override var lineP1: CGPoint {
        return CGPoint(x: origin.x, y: origin.y + lineOffset)
    }

    /// The end point of the axis line
    override var lineP2: CGPoint {
        return CGPoint(x: end.x, y: end.y + lineOffset)
    }

    /// The offset of the axis labels from the edge of the axis bounds
    ///
    /// ````
    /// ─ ─ ─ ─  ▲
    ///  Title   │
    ///          │
    ///          ▼
    ///  Label
    /// ````
    fileprivate var labelsOffset: CGFloat {
        return axisTitleLabelsHeight + settings.axisTitleLabelsToLabelsSpacing
    }

    /// The offset of the axis line from the edge of the axis bounds
    ///
    /// ````
    /// ─ ─ ─ ─  ▲
    ///  Title   │
    ///          │
    ///          │
    ///  Label   │
    ///          │
    ///          │
    /// ───────  ▼
    /// ````
    fileprivate var lineOffset: CGFloat {
        return labelsOffset + settings.labelsToAxisSpacingX + labelsTotalHeight
    }
    
    override func chartViewDrawing(context: CGContext, chart: Chart) {
        super.chartViewDrawing(context: context, chart: chart)
    }
    
    override func updateInternal() {
        guard let chart = chart else {return}
        
        super.updateInternal()

        if lastFrame.height != frame.height, canChangeFrameSize {
            chart.notifyAxisInnerFrameChange(xHigh: ChartAxisLayerWithFrameDelta(layer: self, delta: frame.height - lastFrame.height))
        }
    }

    override func handleAxisInnerFrameChange(_ xLow: ChartAxisLayerWithFrameDelta?, yLow: ChartAxisLayerWithFrameDelta?, xHigh: ChartAxisLayerWithFrameDelta?, yHigh: ChartAxisLayerWithFrameDelta?) {
        super.handleAxisInnerFrameChange(xLow, yLow: yLow, xHigh: xHigh, yHigh: yHigh)
        
        // handle resizing of other high x axes
        if let xHigh = xHigh, xHigh.layer.frame.minY < frame.minY {
            offset = offset + xHigh.delta
            
            initDrawers()
        }
    }
    
    override func axisLineY(offset: CGFloat) -> CGFloat {
        return lineP1.y + settings.axisStrokeWidth / 2
    }

    override func initDrawers() {
        axisTitleLabelDrawers = generateAxisTitleLabelsDrawers(offset: 0)
        labelDrawers = generateLabelDrawers(offset: labelsOffset)
        lineDrawer = generateLineDrawer(offset: lineOffset)
    }
}
