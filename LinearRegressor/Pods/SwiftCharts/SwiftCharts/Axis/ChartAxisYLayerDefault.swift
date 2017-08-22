//
//  ChartAxisYLayerDefault.swift
//  SwiftCharts
//
//  Created by ischuetz on 25/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

/// A ChartAxisLayer for Y axes
class ChartAxisYLayerDefault: ChartAxisLayerDefault {
    
    fileprivate var minCalculatedLabelWidth: CGFloat?
    fileprivate var maxCalculatedLabelWidth: CGFloat?
    
    override var origin: CGPoint {
        return CGPoint(x: offset, y: axis.lastScreen)
    }
    
    override var end: CGPoint {
        return CGPoint(x: offset, y: axis.firstScreen)
    }
    
    override var height: CGFloat {
        return axis.screenLength
    }
    
    override var visibleFrame: CGRect {
        return CGRect(x: offset, y: axis.lastVisibleScreen, width: width, height: axis.visibleScreenLength)
    }
    
    var labelsMaxWidth: CGFloat {
        
        let currentWidth: CGFloat = {
            if self.labelDrawers.isEmpty {
                return self.maxLabelWidth(self.currentAxisValues)
            } else {
                return self.labelDrawers.reduce(0) {maxWidth, labelDrawer in
                    return max(maxWidth, labelDrawer.drawers.reduce(0) {maxWidth, drawer in
                        max(maxWidth, drawer.size.width)
                    })
                }
            }
        }()
        
        
        let width: CGFloat = {
            switch labelSpaceReservationMode {
            case .minPresentedSize: return minCalculatedLabelWidth.maxOpt(currentWidth)
            case .maxPresentedSize: return maxCalculatedLabelWidth.maxOpt(currentWidth)
            case .fixed(let value): return value
            case .current: return currentWidth
            }
        }()
        
        if !currentAxisValues.isEmpty {
            let (min, max): (CGFloat, CGFloat) = (minCalculatedLabelWidth.minOpt(currentWidth), maxCalculatedLabelWidth.maxOpt(currentWidth))
            minCalculatedLabelWidth = min
            maxCalculatedLabelWidth = max
        }
        
        return width
    }
    
    override var width: CGFloat {
        return labelsMaxWidth + settings.axisStrokeWidth + settings.labelsToAxisSpacingY + settings.axisTitleLabelsToLabelsSpacing + axisTitleLabelsWidth
    }
    
    override var widthWithoutLabels: CGFloat {
        return settings.axisStrokeWidth + settings.labelsToAxisSpacingY + settings.axisTitleLabelsToLabelsSpacing + axisTitleLabelsWidth
    }
    
    override var heightWithoutLabels: CGFloat {
        return height
    }
    
    override func handleAxisInnerFrameChange(_ xLow: ChartAxisLayerWithFrameDelta?, yLow: ChartAxisLayerWithFrameDelta?, xHigh: ChartAxisLayerWithFrameDelta?, yHigh: ChartAxisLayerWithFrameDelta?) {
        super.handleAxisInnerFrameChange(xLow, yLow: yLow, xHigh: xHigh, yHigh: yHigh)
        
        if let xLow = xLow {
            axis.offsetFirstScreen(-xLow.delta)
            initDrawers()
        }
        
        if let xHigh = xHigh {
            axis.offsetLastScreen(xHigh.delta)
            initDrawers()
        }
        
    }
    
    override func generateAxisTitleLabelsDrawers(offset: CGFloat) -> [ChartLabelDrawer] {
        
        if let firstTitleLabel = axisTitleLabels.first {
            
            if axisTitleLabels.count > 1 {
                print("WARNING: No support for multiple definition labels on vertical axis. Using only first one.")
            }
            let axisLabel = firstTitleLabel
            let labelSize = axisLabel.textSizeNonRotated
            let axisLabelDrawer = ChartLabelDrawer(label: axisLabel, screenLoc: CGPoint(
                x: self.offset + offset,
                y: axis.lastScreenInit + ((axis.firstScreenInit - axis.lastScreenInit) / 2) - (labelSize.height / 2)))
            
            return [axisLabelDrawer]
            
        } else { // definitionLabels is empty
            return []
        }
    }
    
    override func generateDirectLabelDrawers(offset: CGFloat) -> [ChartAxisValueLabelDrawers] {
        
        var drawers: [ChartAxisValueLabelDrawers] = []
        
        let scalars = valuesGenerator.generate(axis)
        currentAxisValues = scalars
        for scalar in scalars {
            let labels = labelsGenerator.generate(scalar, axis: axis)
            let y = axis.screenLocForScalar(scalar)
            if let axisLabel = labels.first { // for now y axis supports only one label x value
                let labelSize = axisLabel.textSizeNonRotated
                let labelY = y - (labelSize.height / 2)
                let labelX = labelsX(offset: offset, labelWidth: labelSize.width, textAlignment: axisLabel.settings.textAlignment)
                let labelDrawer = ChartLabelDrawer(label: axisLabel, screenLoc: CGPoint(x: labelX, y: labelY))

                let labelDrawers = ChartAxisValueLabelDrawers(scalar, [labelDrawer])
                drawers.append(labelDrawers)
            }
        }
        return drawers
    }
    
    func labelsX(offset: CGFloat, labelWidth: CGFloat, textAlignment: ChartLabelTextAlignment) -> CGFloat {
        fatalError("override")
    }
    
    fileprivate func maxLabelWidth(_ axisLabels: [ChartAxisLabel]) -> CGFloat {
        return axisLabels.reduce(CGFloat(0)) {maxWidth, label in
            return max(maxWidth, label.textSizeNonRotated.width)
        }
    }
    fileprivate func maxLabelWidth(_ axisValues: [Double]) -> CGFloat {
        return axisValues.reduce(CGFloat(0)) {maxWidth, value in
            let labels = labelsGenerator.generate(value, axis: axis)
            return max(maxWidth, maxLabelWidth(labels))
        }
    }
    
    override func zoom(_ x: CGFloat, y: CGFloat, centerX: CGFloat, centerY: CGFloat) {
        axis.zoom(x, y: y, centerX: centerX, centerY: centerY, elastic: chart?.zoomPanSettings.elastic ?? false)
        update()
        chart?.view.setNeedsDisplay()
    }
    
    override func pan(_ deltaX: CGFloat, deltaY: CGFloat) {
        axis.pan(deltaX, deltaY: deltaY, elastic: chart?.zoomPanSettings.elastic ?? false)
        update()
        chart?.view.setNeedsDisplay()
    }
    
    override func zoom(_ scaleX: CGFloat, scaleY: CGFloat, centerX: CGFloat, centerY: CGFloat) {
        axis.zoom(scaleX, scaleY: scaleY, centerX: centerX, centerY: centerY, elastic: chart?.zoomPanSettings.elastic ?? false)
        update()
        chart?.view.setNeedsDisplay()
    }

    func axisLineX(offset: CGFloat) -> CGFloat {
        fatalError("Override")
    }
    
    override func generateLineDrawer(offset: CGFloat) -> ChartLineDrawer {
        let x = axisLineX(offset: offset)
        let p1 = CGPoint(x: x, y: axis.firstVisibleScreen)
        let p2 = CGPoint(x: x, y: axis.lastVisibleScreen)
        return ChartLineDrawer(p1: p1, p2: p2, color: settings.lineColor, strokeWidth: settings.axisStrokeWidth)
    }
}
