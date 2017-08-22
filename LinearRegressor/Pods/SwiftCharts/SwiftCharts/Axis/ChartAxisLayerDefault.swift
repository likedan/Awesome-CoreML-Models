//
//  ChartAxisLayerDefault.swift
//  SwiftCharts
//
//  Created by ischuetz on 25/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

/**
 This class allows customizing the layout of an axis layer and its contents. An example of how some of these settings affect the layout of a Y axis is shown below.

 ````
                   ┌───────────────────────────────────────────────────────────────────┐
                   │                             screenTop                             │
                   │   ┌───────────────────────────────────────────────────────────┐   │
                   │   │ ───────────────────────────────────────────────────────── │   │     labelsToAxisSpacingX
                   │   │                                                       ◀───┼───┼──── similar for labelsToAxisSpacingY
                   │   │  Label 1     Label 2     Label 3     Label 4     Label 5  │   │
                   │   │                                                       ◀───┼───┼──── labelsSpacing (only supported for X axes)
 screenLeading ────┼─▶ │  Label A     Label B     Label C     Label D     Label E  │   │
                   │   │                                                           │   │
                   │   │                              ◀────────────────────────────┼───┼──── axisTitleLabelsToLabelsSpacing
                   │   │                                                           │   │
                   │   │                           Title                           │ ◀─┼──── screenTrailing
                   │   └───────────────────────────────────────────────────────────┘   │
                   │                           screenBottom                            │
                   └───────────────────────────────────────────────────────────────────┘
 ````
 */
open class ChartAxisSettings {
    var screenLeading: CGFloat = 0
    var screenTrailing: CGFloat = 0
    var screenTop: CGFloat = 0
    var screenBottom: CGFloat = 0
    var labelsSpacing: CGFloat = 5
    var labelsToAxisSpacingX: CGFloat = 5
    var labelsToAxisSpacingY: CGFloat = 5
    var axisTitleLabelsToLabelsSpacing: CGFloat = 5
    var lineColor:UIColor = UIColor.black
    var axisStrokeWidth: CGFloat = 2.0
    var isAxisLineVisible: Bool = true
    
    convenience init(_ chartSettings: ChartSettings) {
        self.init()
        self.labelsSpacing = chartSettings.labelsSpacing
        self.labelsToAxisSpacingX = chartSettings.labelsToAxisSpacingX
        self.labelsToAxisSpacingY = chartSettings.labelsToAxisSpacingY
        self.axisTitleLabelsToLabelsSpacing = chartSettings.axisTitleLabelsToLabelsSpacing
        self.screenLeading = chartSettings.leading
        self.screenTop = chartSettings.top
        self.screenTrailing = chartSettings.trailing
        self.screenBottom = chartSettings.bottom
        self.axisStrokeWidth = chartSettings.axisStrokeWidth
    }
}

public typealias ChartAxisValueLabelDrawers = (scalar: Double, drawers: [ChartLabelDrawer])

/// Helper class to notify other layers about frame changes which affect content available space
public final class ChartAxisLayerWithFrameDelta {
    let layer: ChartAxisLayer
    let delta: CGFloat
    init(layer: ChartAxisLayer, delta: CGFloat) {
        self.layer = layer
        self.delta = delta
    }
}

extension Optional where Wrapped: ChartAxisLayerWithFrameDelta {
    var deltaDefault0: CGFloat {
        return self?.delta ?? 0
    }
}

public enum AxisLabelsSpaceReservationMode {
    case minPresentedSize /// Doesn't reserve less space than the min presented label width/height so far
    case maxPresentedSize /// Doesn't reserve less space than the max presented label width/height so far
    case fixed(CGFloat) /// Fixed value, ignores labels width/height
    case current /// Reserves space for currently visible labels
}

public typealias ChartAxisValueLabelDrawersWithAxisLayer = (valueLabelDrawers: ChartAxisValueLabelDrawers, layer: ChartAxisLayer)
public struct ChartAxisLayerTapSettings {
    public let expandArea: CGSize
    let handler: ((ChartAxisValueLabelDrawersWithAxisLayer) -> Void)?
    
    public init(expandArea: CGSize = CGSize(width: 10, height: 10), handler: ((ChartAxisValueLabelDrawersWithAxisLayer) -> Void)? = nil) {
        self.expandArea = expandArea
        self.handler = handler
    }
}


/// A default implementation of ChartAxisLayer, which delegates drawing of the axis line and labels to the appropriate Drawers
open class ChartAxisLayerDefault: ChartAxisLayer {
    
    open var axis: ChartAxis
    
    var origin: CGPoint {
        fatalError("Override")
    }
    
    var end: CGPoint {
        fatalError("Override")
    }
    
    open var frame: CGRect {
        return CGRect(x: origin.x, y: origin.y, width: width, height: height)
    }
    
    open var frameWithoutLabels: CGRect {
        return CGRect(x: origin.x, y: origin.y, width: widthWithoutLabels, height: heightWithoutLabels)
    }
    
    open var visibleFrame: CGRect {
        fatalError("Override")
    }
    
    /// Constant dimension between origin and end
    var offset: CGFloat
    
    open var currentAxisValues: [Double] = []
    
    open let valuesGenerator: ChartAxisValuesGenerator
    open var labelsGenerator: ChartAxisLabelsGenerator
    
    let axisTitleLabels: [ChartAxisLabel]
    let settings: ChartAxisSettings
    
    // exposed for subclasses
    var lineDrawer: ChartLineDrawer?
    var labelDrawers: [ChartAxisValueLabelDrawers] = []
    var axisTitleLabelDrawers: [ChartLabelDrawer] = []
    
    let labelsConflictSolver: ChartAxisLabelsConflictSolver?
    
    open weak var chart: Chart?
    
    let labelSpaceReservationMode: AxisLabelsSpaceReservationMode

    let clipContents: Bool
    
    open var tapSettings: ChartAxisLayerTapSettings?
    
    public var canChangeFrameSize: Bool = true
    
    var widthWithoutLabels: CGFloat {
        return width
    }
    
    var heightWithoutLabels: CGFloat {
        return settings.axisStrokeWidth + settings.labelsToAxisSpacingX + settings.axisTitleLabelsToLabelsSpacing + axisTitleLabelsHeight
    }
    
    open var axisValuesScreenLocs: [CGFloat] {
        return self.currentAxisValues.map{axis.screenLocForScalar($0)}
    }
    
    open var axisValuesWithFrames: [(axisValue: Double, frames: [CGRect])] {
        return labelDrawers.map {let (axisValue, drawers) = $0; return
            (axisValue: axisValue, frames: drawers.map{$0.frame})
        }
    }
    
    var visibleAxisValuesScreenLocs: [CGFloat] {
        return currentAxisValues.reduce(Array<CGFloat>()) {u, scalar in
            return u + [axis.screenLocForScalar(scalar)]
        }
    }
    
    // smallest screen space between axis values
    open var minAxisScreenSpace: CGFloat {
        return axisValuesScreenLocs.reduce((CGFloat.greatestFiniteMagnitude, -CGFloat.greatestFiniteMagnitude)) {tuple, screenLoc in
            let minSpace = tuple.0
            let previousScreenLoc = tuple.1
            return (min(minSpace, abs(screenLoc - previousScreenLoc)), screenLoc)
        }.0
    }
    
    lazy private(set) var axisTitleLabelsHeight: CGFloat = {
        return self.axisTitleLabels.reduce(0) { sum, label in
            sum + label.textSize.height
        }
    }()

    lazy private(set) var axisTitleLabelsWidth: CGFloat = {
        return self.axisTitleLabels.reduce(0) { sum, label in
            sum + label.textSize.width
        }
    }()
    
    open func keepInBoundaries() {
        axis.keepInBoundaries()
        initDrawers()
        chart?.view.setNeedsDisplay()
    }
    
    var width: CGFloat {
        fatalError("override")
    }
    
    open var lineP1: CGPoint {
        fatalError("override")
    }
    
    open var lineP2: CGPoint {
        fatalError("override")
    }
    
    var height: CGFloat {
        fatalError("override")
    }
    
    open var low: Bool {
        fatalError("override")
    }

    /// Frame of layer after last update. This is used to detect deltas with the frame resulting from an update. Note that the layer's frame can be altered by only updating the model data (this depends on how the concrete axis layer calculates the frame), which is why this frame is not always identical to the layer's frame directly before calling udpate.
    var lastFrame: CGRect = CGRect.zero
    
    // NOTE: Assumes axis values sorted by scalar (can be increasing or decreasing)
    public required init(axis: ChartAxis, offset: CGFloat, valuesGenerator: ChartAxisValuesGenerator, labelsGenerator: ChartAxisLabelsGenerator, axisTitleLabels: [ChartAxisLabel], settings: ChartAxisSettings, labelsConflictSolver: ChartAxisLabelsConflictSolver? = nil, labelSpaceReservationMode: AxisLabelsSpaceReservationMode, clipContents: Bool)  {
        self.axis = axis
        self.offset = offset
        self.valuesGenerator = valuesGenerator
        self.labelsGenerator = labelsGenerator
        self.axisTitleLabels = axisTitleLabels
        self.settings = settings
        self.labelsConflictSolver = labelsConflictSolver
        self.labelSpaceReservationMode = labelSpaceReservationMode
        self.clipContents = clipContents
        self.lastFrame = frame
        
        self.currentAxisValues = valuesGenerator.generate(axis)
    }
    
    open func update() {
        prepareUpdate()
        updateInternal()
        postUpdate()
    }
    
    fileprivate func clearDrawers() {
        lineDrawer = nil
        labelDrawers = []
        axisTitleLabelDrawers = []
    }
    
    func prepareUpdate() {
        clearDrawers()
    }
    
    func updateInternal() {
        initDrawers()
    }
    
    func postUpdate() {
        lastFrame = frame
    }
    
    open func handleAxisInnerFrameChange(_ xLow: ChartAxisLayerWithFrameDelta?, yLow: ChartAxisLayerWithFrameDelta?, xHigh: ChartAxisLayerWithFrameDelta?, yHigh: ChartAxisLayerWithFrameDelta?) {
    }
    
    open func chartInitialized(chart: Chart) {
        self.chart = chart
        
        update()
    }

    /**
     Draws the axis' line, labels and axis title label

     - parameter context: The context to draw the axis contents in
     - parameter chart:   The chart that this axis belongs to
     */
    open func chartViewDrawing(context: CGContext, chart: Chart) {
        func draw() {
            if settings.isAxisLineVisible {
                if let lineDrawer = lineDrawer {
                    context.setLineWidth(CGFloat(settings.axisStrokeWidth))
                    lineDrawer.triggerDraw(context: context, chart: chart)
                }
            }
            
            for (_, labelDrawers) in labelDrawers {
                for labelDrawer in labelDrawers {
                    labelDrawer.triggerDraw(context: context, chart: chart)
                }
            }
            for axisTitleLabelDrawer in axisTitleLabelDrawers {
                axisTitleLabelDrawer.triggerDraw(context: context, chart: chart)
            }
        }
        
        if clipContents {
            context.saveGState()
            context.addRect(visibleFrame)
            context.clip()
            draw()
            context.restoreGState()
        } else {
            draw()
        }
    }
    
    open func chartContentViewDrawing(context: CGContext, chart: Chart) {}
    
    open func chartDrawersContentViewDrawing(context: CGContext, chart: Chart, view: UIView) {}
    
    open func handleGlobalTap(_ location: CGPoint) {}
    
    func initDrawers() {
        fatalError("override")
    }
    
    func generateLineDrawer(offset: CGFloat) -> ChartLineDrawer {
        fatalError("override")
    }
    
    func generateAxisTitleLabelsDrawers(offset: CGFloat) -> [ChartLabelDrawer] {
        fatalError("override")
    }
    
    /// Generates label drawers to be displayed on the screen. Calls generateDirectLabelDrawers to generate labels and passes result to an optional conflict solver, which maps the labels array to a new one such that the conflicts are solved. If there's no conflict solver returns the drawers unmodified.
    func generateLabelDrawers(offset: CGFloat) -> [ChartAxisValueLabelDrawers] {
        let directLabelDrawers = generateDirectLabelDrawers(offset: offset)
        return labelsConflictSolver.map{$0.solveConflicts(directLabelDrawers)} ?? directLabelDrawers
    }
    
    /// Generates label drawers which correspond directly to axis values. No conflict solving.
    func generateDirectLabelDrawers(offset: CGFloat) -> [ChartAxisValueLabelDrawers] {
        fatalError("override")
    }
    
    open func zoom(_ x: CGFloat, y: CGFloat, centerX: CGFloat, centerY: CGFloat) {
        fatalError("override")
    }
    
    open func zoom(_ scaleX: CGFloat, scaleY: CGFloat, centerX: CGFloat, centerY: CGFloat) {
        fatalError("override")
    }
    
    open func pan(_ deltaX: CGFloat, deltaY: CGFloat) {
        fatalError("override")
    }
    
    open func handlePanStart(_ location: CGPoint) {}
    
    open func handlePanStart() {}
    
    open func handlePanFinish() {}
    
    open func handleZoomFinish() {}
    
    open func handlePanEnd() {}
    
    open func handleZoomEnd() {}
    
    open func copy(_ axis: ChartAxis? = nil, offset: CGFloat? = nil, valuesGenerator: ChartAxisValuesGenerator? = nil, labelsGenerator: ChartAxisLabelsGenerator? = nil, axisTitleLabels: [ChartAxisLabel]? = nil, settings: ChartAxisSettings? = nil, labelsConflictSolver: ChartAxisLabelsConflictSolver? = nil, labelSpaceReservationMode: AxisLabelsSpaceReservationMode? = nil, clipContents: Bool? = nil) -> ChartAxisLayerDefault {
        return type(of: self).init(
            axis: axis ?? self.axis,
            offset: offset ?? self.offset,
            valuesGenerator: valuesGenerator ?? self.valuesGenerator,
            labelsGenerator: labelsGenerator ?? self.labelsGenerator,
            axisTitleLabels: axisTitleLabels ?? self.axisTitleLabels,
            settings: settings ?? self.settings,
            labelsConflictSolver: labelsConflictSolver ?? self.labelsConflictSolver,
            labelSpaceReservationMode: labelSpaceReservationMode ?? self.labelSpaceReservationMode,
            clipContents: clipContents ?? self.clipContents
        )
    }
    
    open func handleGlobalTap(_ location: CGPoint) -> Any? {
        guard let tapSettings = tapSettings else {return nil}
        
        if visibleFrame.contains(location) {
            if let tappedLabelDrawers = (labelDrawers.filter{$0.drawers.contains{drawer in drawer.frame.insetBy(dx: -tapSettings.expandArea.width, dy: -tapSettings.expandArea.height).contains(location)}}).first {
                tapSettings.handler?((valueLabelDrawers: tappedLabelDrawers, layer: self))
                return tappedLabelDrawers
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    open func processZoom(deltaX: CGFloat, deltaY: CGFloat, anchorX: CGFloat, anchorY: CGFloat) -> Bool {
        return false
    }
    
    open func processPan(location: CGPoint, deltaX: CGFloat, deltaY: CGFloat, isGesture: Bool, isDeceleration: Bool) -> Bool {
        return false
    }
}
