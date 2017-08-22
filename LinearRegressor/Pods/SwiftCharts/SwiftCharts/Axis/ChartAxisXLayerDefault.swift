//
//  ChartAxisXLayerDefault.swift
//  SwiftCharts
//
//  Created by ischuetz on 25/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

/// A ChartAxisLayer for X axes
class ChartAxisXLayerDefault: ChartAxisLayerDefault {

    fileprivate var minTotalCalculatedRowHeights: CGFloat?
    fileprivate var maxTotalCalculatedRowHeights: CGFloat?
    
    override var origin: CGPoint {
        return CGPoint(x: axis.firstScreen, y: offset)
    }
    
    override var end: CGPoint {
        return CGPoint(x: axis.lastScreen, y: offset)
    }
    
    override var width: CGFloat {
        return axis.screenLength
    }
    
    override var visibleFrame: CGRect {
        return CGRect(x: axis.firstVisibleScreen, y: offset, width: axis.visibleScreenLength, height: height)
    }
    
    var labelsTotalHeight: CGFloat {
        
        let currentTotalHeight = rowHeights.reduce(0) {sum, height in
            sum + height + settings.labelsSpacing
        }

        let height: CGFloat = {
            switch labelSpaceReservationMode {
            case .minPresentedSize: return minTotalCalculatedRowHeights.maxOpt(currentTotalHeight)
            case .maxPresentedSize: return maxTotalCalculatedRowHeights.maxOpt(currentTotalHeight)
            case .fixed(let value): return value
            case .current: return currentTotalHeight
            }
        }()
        
        if !rowHeights.isEmpty {
            let (min, max): (CGFloat, CGFloat) = (minTotalCalculatedRowHeights.minOpt(currentTotalHeight), maxTotalCalculatedRowHeights.maxOpt(currentTotalHeight))
            minTotalCalculatedRowHeights = min
            maxTotalCalculatedRowHeights = max
        }

        return height
    }
    
    var rowHeights: [CGFloat] {
        return calculateRowHeights()
    }
    
    override var height: CGFloat {
        return labelsTotalHeight + settings.axisStrokeWidth + settings.labelsToAxisSpacingX + settings.axisTitleLabelsToLabelsSpacing + axisTitleLabelsHeight
    }
    
    override var widthWithoutLabels: CGFloat {
        return width
    }
    
    override var heightWithoutLabels: CGFloat {
        return settings.axisStrokeWidth + settings.labelsToAxisSpacingX + settings.axisTitleLabelsToLabelsSpacing + axisTitleLabelsHeight
    }
    
    override func handleAxisInnerFrameChange(_ xLow: ChartAxisLayerWithFrameDelta?, yLow: ChartAxisLayerWithFrameDelta?, xHigh: ChartAxisLayerWithFrameDelta?, yHigh: ChartAxisLayerWithFrameDelta?) {
        super.handleAxisInnerFrameChange(xLow, yLow: yLow, xHigh: xHigh, yHigh: yHigh)
        
        if let yLow = yLow {
            axis.offsetFirstScreen(yLow.delta)
            initDrawers()
        }
        
        if let yHigh = yHigh {
            axis.offsetLastScreen(-yHigh.delta)
            initDrawers()
        }
    }
    
    func axisLineY(offset: CGFloat) -> CGFloat {
        fatalError("Override")
    }

    override func generateLineDrawer(offset: CGFloat) -> ChartLineDrawer {
        let y = axisLineY(offset: offset)
        
        // (-/+ axisStrokeWidth): Expand the line a little to the sides to form rect angle with y lines
        let p1 = CGPoint(x: axis.firstVisibleScreen - settings.axisStrokeWidth, y: y)
        let p2 = CGPoint(x: axis.lastVisibleScreen + settings.axisStrokeWidth, y: y)
        return ChartLineDrawer(p1: p1, p2: p2, color: settings.lineColor, strokeWidth: settings.axisStrokeWidth)
    }
    
    override func generateAxisTitleLabelsDrawers(offset: CGFloat) -> [ChartLabelDrawer] {
        return generateAxisTitleLabelsDrawers(axisTitleLabels, spacingLabelAxisX: settings.labelsToAxisSpacingX, spacingLabelBetweenAxis: settings.labelsSpacing, offset: offset)
    }
    
    
    fileprivate func generateAxisTitleLabelsDrawers(_ labels: [ChartAxisLabel], spacingLabelAxisX: CGFloat, spacingLabelBetweenAxis: CGFloat, offset: CGFloat) -> [ChartLabelDrawer] {
        
        let rowHeights = rowHeightsForRows(labels.map { [$0] })
        
        return labels.enumerated().map{let (index, label) = $0;
            
            let rowY = calculateRowY(rowHeights: rowHeights, rowIndex: index, spacing: spacingLabelBetweenAxis)
            
            let labelWidth = label.textSizeNonRotated.width
            let x = (axis.lastScreenInit - axis.firstScreenInit) / 2 + axis.firstScreenInit - labelWidth / 2
            let y = self.offset + offset + rowY
            
            let drawer = ChartLabelDrawer(label: label, screenLoc: CGPoint(x: x, y: y))
            drawer.hidden = label.hidden
            return drawer
        }
    }
    
    // calculate row heights (max text height) for each row
    fileprivate func calculateRowHeights() -> [CGFloat] {
  
        guard !currentAxisValues.isEmpty else {return []}

        let axisValuesWithLabels: [(axisValue: Double, labels: [ChartAxisLabel])] = currentAxisValues.map {
            ($0, labelsGenerator.generate($0, axis: axis))
        }
        
        // organize labels in rows
        let maxRowCount = axisValuesWithLabels.reduce(-1) {maxCount, tuple in
            max(maxCount, tuple.labels.count)
        }
        let rows: [[ChartAxisLabel?]] = (0..<maxRowCount).map {row in
            axisValuesWithLabels.map {tuple in
                return row < tuple.labels.count ? tuple.labels[row] : nil
            }
        }
        
        return rowHeightsForRows(rows)
    }
    
    override func generateDirectLabelDrawers(offset: CGFloat) -> [ChartAxisValueLabelDrawers] {
        
        let spacingLabelBetweenAxis = settings.labelsSpacing
        
        let rowHeights = self.rowHeights
        
        // generate label drawers for each axis value and return them bundled with the respective axis value.
        
        let scalars = valuesGenerator.generate(axis)
        
        currentAxisValues = scalars
        return scalars.flatMap {scalar in
            
            let labels = labelsGenerator.generate(scalar, axis: axis)

            let labelDrawers: [ChartLabelDrawer] = labels.enumerated().map { let (index, label) = $0;
                let rowY = calculateRowY(rowHeights: rowHeights, rowIndex: index, spacing: spacingLabelBetweenAxis)
                
                let x = axis.screenLocForScalar(scalar)
                let y = self.offset + offset + rowY
                
                let labelSize = label.textSizeNonRotated
                let labelX = x - (labelSize.width / 2)
                
                let labelDrawer = ChartLabelDrawer(label: label, screenLoc: CGPoint(x: labelX, y: y))
                labelDrawer.hidden = label.hidden
                return labelDrawer
            }
            return ChartAxisValueLabelDrawers(scalar, labelDrawers)
        }
    }
    
    // Get the y offset of row relative to the y position of the first row
    fileprivate func calculateRowY(rowHeights: [CGFloat], rowIndex: Int, spacing: CGFloat) -> CGFloat {
        return Array(0..<rowIndex).reduce(0) {y, index in
            y + rowHeights[index] + spacing
        }
    }
    
    
    // Get max text height for each row of axis values
    fileprivate func rowHeightsForRows(_ rows: [[ChartAxisLabel?]]) -> [CGFloat] {
        return rows.map { row in
            row.flatMap { $0 }.reduce(-1) { maxHeight, label in
                return max(maxHeight, label.textSize.height)
            }
        }
    }
    
    override func zoom(_ x: CGFloat, y: CGFloat, centerX: CGFloat, centerY: CGFloat) {
        axis.zoom(x, y: y, centerX: centerX, centerY: centerY, elastic: chart?.zoomPanSettings.elastic ?? false)
        initDrawers()
        chart?.view.setNeedsDisplay()
    }
    
    override func pan(_ deltaX: CGFloat, deltaY: CGFloat) {
        axis.pan(deltaX, deltaY: deltaY, elastic: chart?.zoomPanSettings.elastic ?? false)
        initDrawers()
        chart?.view.setNeedsDisplay()
    }
    
    override func zoom(_ scaleX: CGFloat, scaleY: CGFloat, centerX: CGFloat, centerY: CGFloat) {
        axis.zoom(scaleX, scaleY: scaleY, centerX: centerX, centerY: centerY, elastic: chart?.zoomPanSettings.elastic ?? false)
        initDrawers()
        chart?.view.setNeedsDisplay()
    }
}
