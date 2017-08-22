//
//  ChartAxisYLowLayerDefault.swift
//  SwiftCharts
//
//  Created by ischuetz on 25/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

/// A ChartAxisLayer for low Y axes
class ChartAxisYLowLayerDefault: ChartAxisYLayerDefault {
    
    override var low: Bool {return true}

    /// The start point of the axis line.
    override var lineP1: CGPoint {
        return CGPoint(x: origin.x + lineOffset, y: axis.firstVisibleScreen)
    }

    /// The end point of the axis line.
    override var lineP2: CGPoint {
        return CGPoint(x: end.x + lineOffset, y: axis.lastVisibleScreen)
    }

    /// The offset of the axis labels from the edge of the axis bounds
    ///
    /// Imagine the following image rotated 90 degrees counter-clockwise.
    ///
    /// ````
    /// ─ ─ ─ ─  ▲
    ///  Title   │
    ///          │
    ///          ▼
    ///  Label
    /// ````
    fileprivate var labelsOffset: CGFloat {
        return axisTitleLabelsWidth + settings.axisTitleLabelsToLabelsSpacing
    }

    /// The offset of the axis line from the edge of the axis bounds.
    ///
    /// Imagine the following image rotated 90 degrees counter-clockwise.
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
        return labelsOffset + labelsMaxWidth + settings.labelsToAxisSpacingY + settings.axisStrokeWidth
    }
    
    override func handleAxisInnerFrameChange(_ xLow: ChartAxisLayerWithFrameDelta?, yLow: ChartAxisLayerWithFrameDelta?, xHigh: ChartAxisLayerWithFrameDelta?, yHigh: ChartAxisLayerWithFrameDelta?) {
        super.handleAxisInnerFrameChange(xLow, yLow: yLow, xHigh: xHigh, yHigh: yHigh)
        
        // Handle resizing of other low y axes
        if let yLow = yLow , yLow.layer.frame.origin.x < origin.x {
            offset = offset + yLow.delta
            initDrawers()
        }
    }
    
    override func updateInternal() {
        guard let chart = chart else {return}
        super.updateInternal()
        if lastFrame.width != frame.width, canChangeFrameSize {
            chart.notifyAxisInnerFrameChange(yLow: ChartAxisLayerWithFrameDelta(layer: self, delta: frame.width - lastFrame.width))
        }
    }
    
    override func initDrawers() {
        axisTitleLabelDrawers = generateAxisTitleLabelsDrawers(offset: 0)
        labelDrawers = generateLabelDrawers(offset: labelsOffset)
        lineDrawer = generateLineDrawer(offset: lineOffset)
    }
    
    override func generateLineDrawer(offset: CGFloat) -> ChartLineDrawer {
        let halfStrokeWidth = settings.axisStrokeWidth / 2 // we want that the stroke ends at the end of the frame, not be in the middle of it
        let p1 = CGPoint(x: origin.x + offset - halfStrokeWidth, y: axis.firstVisibleScreen)
        let p2 = CGPoint(x: end.x + offset - halfStrokeWidth, y: axis.lastVisibleScreen)
        return ChartLineDrawer(p1: p1, p2: p2, color: settings.lineColor, strokeWidth: settings.axisStrokeWidth)
    }

    override func labelsX(offset: CGFloat, labelWidth: CGFloat, textAlignment: ChartLabelTextAlignment) -> CGFloat {
        let labelsXRight = origin.x + offset
        var labelsX: CGFloat
        switch textAlignment {
        case .right, .default:
            labelsX = labelsXRight + labelsMaxWidth - labelWidth
        case .left:
            labelsX = labelsXRight
        }
        return labelsX
    }
    
    override func axisLineX(offset: CGFloat) -> CGFloat {
        return self.offset + offset - settings.axisStrokeWidth / 2
    }
}
