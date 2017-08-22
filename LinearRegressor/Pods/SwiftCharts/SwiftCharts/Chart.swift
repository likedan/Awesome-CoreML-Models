//
//  Chart.swift
//  SwiftCharts
//
//  Created by ischuetz on 25/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

/// ChartSettings allows configuration of the visual layout of a chart
public struct ChartSettings {

    /// Empty space in points added to the leading edge of the chart
    public var leading: CGFloat = 0

    /// Empty space in points added to the top edge of the chart
    public var top: CGFloat = 0

    /// Empty space in points added to the trailing edge of the chart
    public var trailing: CGFloat = 0

    /// Empty space in points added to the bottom edge of the chart
    public var bottom: CGFloat = 0

    /// The spacing in points between axis labels when using multiple labels for each axis value. This is currently only supported with an X axis.
    public var labelsSpacing: CGFloat = 5

    /// The spacing in points between X axis labels and the X axis line
    public var labelsToAxisSpacingX: CGFloat = 5

    /// The spacing in points between Y axis labels and the Y axis line
    public var labelsToAxisSpacingY: CGFloat = 5

    public var spacingBetweenAxesX: CGFloat = 15

    public var spacingBetweenAxesY: CGFloat = 15

    /// The spacing in points between axis title labels and axis labels
    public var axisTitleLabelsToLabelsSpacing: CGFloat = 5

    /// The stroke width in points of the axis lines
    public var axisStrokeWidth: CGFloat = 1.0
    
    public var zoomPan = ChartSettingsZoomPan()
    
    public var clipInnerFrame = true
    
    /// Define a custom clipping rect for chart layers that use containerViewUnclipped to display chart points.
    // TODO (review): this probably should be moved to ChartPointsViewsLayer
    public var customClipRect: CGRect? = nil
    
    public init() {}
}

public struct ChartSettingsZoomPan {
    public var panEnabled = false
    
    public var zoomEnabled = false

    public var minZoomX: CGFloat?
    
    public var minZoomY: CGFloat?
    
    public var maxZoomX: CGFloat?
    
    public var maxZoomY: CGFloat?
    
    public var gestureMode: ChartZoomPanGestureMode = .max
    
    public var elastic: Bool = false
}

public enum ChartZoomPanGestureMode {
    case onlyX // Only X axis is zoomed/panned
    case onlyY // Only Y axis is zoomed/panned
    case max // Only axis corresponding to dimension with max zoom/pan delta is zoomed/panned
    case both // Both axes are zoomed/panned
}

public protocol ChartDelegate {
    
    func onZoom(scaleX: CGFloat, scaleY: CGFloat, deltaX: CGFloat, deltaY: CGFloat, centerX: CGFloat, centerY: CGFloat, isGesture: Bool)
    
    func onPan(transX: CGFloat, transY: CGFloat, deltaX: CGFloat, deltaY: CGFloat, isGesture: Bool, isDeceleration: Bool)
    
    func onTap(_ models: [TappedChartPointLayerModels<ChartPoint>])
}

/// A Chart object is the highest level access to your chart. It has the view where all of the chart layers are drawn, which you can provide (useful if you want to position it as part of a storyboard or XIB), or it can be created for you.
open class Chart: Pannable, Zoomable {

    /// The view that the chart is drawn in
    open let view: ChartView

    open let containerView: UIView
    open let contentView: UIView
    open let drawersContentView: UIView
    open let containerViewUnclipped: UIView

    /// The layers of the chart that are drawn in the view
    fileprivate let layers: [ChartLayer]

    open var delegate: ChartDelegate?

    open var transX: CGFloat {
        return contentFrame.minX
    }
    
    open var transY: CGFloat {
        return contentFrame.minY
    }

    open var scaleX: CGFloat {
        return contentFrame.width / containerFrame.width
    }
    
    open var scaleY: CGFloat {
        return contentFrame.height / containerFrame.height
    }
 
    open var maxScaleX: CGFloat? {
        return settings.zoomPan.maxZoomX
    }
    
    open var minScaleX: CGFloat? {
        return settings.zoomPan.minZoomX
    }
    
    open var maxScaleY: CGFloat? {
        return settings.zoomPan.maxZoomY
    }
    
    open var minScaleY: CGFloat? {
        return settings.zoomPan.minZoomY
    }
    
    /// Max possible total pan distance with current transformation
    open var currentMaxPan: CGFloat {
        return contentView.frame.height - containerView.frame.height
    }
    
    fileprivate var settings: ChartSettings
    
    open var zoomPanSettings: ChartSettingsZoomPan {
        set {
            settings.zoomPan = newValue
            configZoomPan(newValue)
        } get {
            return settings.zoomPan
        }
    }
    
    /**
     Create a new Chart with a frame and layers. A new ChartBaseView will be created for you.

     - parameter innerFrame: Frame comprised by axes, where the chart displays content
     - parameter settings: Chart settings
     - parameter frame:  The frame used for the ChartBaseView
     - parameter layers: The layers that are drawn in the chart

     - returns: The new Chart
     */
    convenience public init(frame: CGRect, innerFrame: CGRect? = nil, settings: ChartSettings, layers: [ChartLayer]) {
        self.init(view: ChartBaseView(frame: frame), innerFrame: innerFrame, settings: settings, layers: layers)
    }

    /**
     Create a new Chart with a view and layers.

     
     - parameter innerFrame: Frame comprised by axes, where the chart displays content
     - parameter settings: Chart settings
     - parameter view:   The view that the chart will be drawn in
     - parameter layers: The layers that are drawn in the chart

     - returns: The new Chart
     */
    public init(view: ChartView, innerFrame: CGRect? = nil, settings: ChartSettings, layers: [ChartLayer]) {
        
        self.layers = layers
        
        self.view = view

        self.settings = settings
        
        let containerView = UIView(frame: innerFrame ?? view.bounds)
        
        let drawersContentView = ChartContentView(frame: containerView.bounds)
        drawersContentView.backgroundColor = UIColor.clear
        containerView.addSubview(drawersContentView)
        
        let contentView = ChartContentView(frame: containerView.bounds)
        contentView.backgroundColor = UIColor.clear
        containerView.addSubview(contentView)
        
        // TODO It may be better to move this view to ChartPointsViewsLayer (together with customClipRect setting) and create it on demand.
        containerViewUnclipped = UIView(frame: containerView.bounds)
        view.addSubview(containerViewUnclipped)
        let shape = CAShapeLayer()
        shape.path = UIBezierPath(rect: settings.customClipRect ?? CGRect.zero).cgPath
        containerViewUnclipped.layer.mask = shape

        containerView.clipsToBounds = settings.clipInnerFrame
        view.addSubview(containerView)

        self.contentView = contentView
        self.drawersContentView = drawersContentView
        self.containerView = containerView
        contentView.chart = self
        drawersContentView.chart = self
        
        self.view.chart = self
        
        for layer in self.layers {
            layer.chartInitialized(chart: self)
        }
        
        self.view.setNeedsDisplay()
        
        #if !os(tvOS)
        view.initRecognizers(settings)
        #endif
        
        configZoomPan(settings.zoomPan)
    }
    
    fileprivate func configZoomPan(_ settings: ChartSettingsZoomPan) {
        if settings.minZoomX != nil || settings.minZoomY != nil {
            zoom(scaleX: settings.minZoomX ?? 1, scaleY: settings.minZoomY ?? 1, anchorX: 0, anchorY: 0)
        }
    }
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /**
     Adds a subview to the chart's content view

     - parameter view: The subview to add to the chart's content view
     */
    open func addSubview(_ view: UIView) {
        contentView.addSubview(view)
    }

    open func addSubviewNoTransform(_ view: UIView) {
        containerView.addSubview(view)
    }
    
    open func addSubviewNoTransformUnclipped(_ view: UIView) {
        containerViewUnclipped.addSubview(view)
    }
    
    /// The frame of the chart's view
    open var frame: CGRect {
        return view.frame
    }

    var containerFrame: CGRect {
        return containerView.frame
    }
    
    // Implementation details free variable name & backwards compatibility
    open var innerFrame: CGRect {
        return containerFrame
    }
    
    open var contentFrame: CGRect {
        return contentView.frame
    }
    
    /// The bounds of the chart's view
    open var bounds: CGRect {
        return view.bounds
    }

    /**
     Removes the chart's view from its superview
     */
    open func clearView() {
        view.removeFromSuperview()
    }

    open func update() {
        for layer in layers {
            layer.update()
        }
        self.view.setNeedsDisplay()
    }
 
    func notifyAxisInnerFrameChange(xLow: ChartAxisLayerWithFrameDelta? = nil, yLow: ChartAxisLayerWithFrameDelta? = nil, xHigh: ChartAxisLayerWithFrameDelta? = nil, yHigh: ChartAxisLayerWithFrameDelta? = nil) {
        for layer in layers {
            layer.handleAxisInnerFrameChange(xLow, yLow: yLow, xHigh: xHigh, yHigh: yHigh)
        }
        
        handleAxisInnerFrameChange(xLow, yLow: yLow, xHigh: xHigh, yHigh: yHigh)
    }
    
    fileprivate func handleAxisInnerFrameChange(_ xLow: ChartAxisLayerWithFrameDelta?, yLow: ChartAxisLayerWithFrameDelta?, xHigh: ChartAxisLayerWithFrameDelta?, yHigh: ChartAxisLayerWithFrameDelta?) {
        let previousContentFrame = contentView.frame
        
        // Resize container view
        containerView.frame = containerView.frame.insetBy(dx: yLow.deltaDefault0, dy: xHigh.deltaDefault0, dw: yHigh.deltaDefault0, dh: xLow.deltaDefault0)
        containerViewUnclipped.frame = containerView.frame
        
        // Change dimensions of content view by total delta of container view
        contentView.frame = CGRect(x: contentView.frame.origin.x, y: contentView.frame.origin.y, width: contentView.frame.width - (yLow.deltaDefault0 + yHigh.deltaDefault0), height: contentView.frame.height - (xLow.deltaDefault0 + xHigh.deltaDefault0))

        // Scale contents of content view
        let widthChangeFactor = contentView.frame.width / previousContentFrame.width
        let heightChangeFactor = contentView.frame.height / previousContentFrame.height
        let frameBeforeScale = contentView.frame
        contentView.transform = CGAffineTransform(scaleX: contentView.transform.a * widthChangeFactor, y: contentView.transform.d * heightChangeFactor)
        contentView.frame = frameBeforeScale
    }
    
    open func onZoomStart(deltaX: CGFloat, deltaY: CGFloat, centerX: CGFloat, centerY: CGFloat) {
        for layer in layers {
            layer.zoom(deltaX, y: deltaY, centerX: centerX, centerY: centerY)
        }
    }
    
    open func onZoomStart(scaleX: CGFloat, scaleY: CGFloat, centerX: CGFloat, centerY: CGFloat) {
        for layer in layers {
            layer.zoom(scaleX, scaleY: scaleY, centerX: centerX, centerY: centerY)
        }
    }
    
    open func onZoomFinish(scaleX: CGFloat, scaleY: CGFloat, deltaX: CGFloat, deltaY: CGFloat, centerX: CGFloat, centerY: CGFloat, isGesture: Bool) {
        for layer in layers {
            layer.handleZoomFinish()
        }
        delegate?.onZoom(scaleX: scaleX, scaleY: scaleY, deltaX: deltaX, deltaY: deltaY, centerX: centerX, centerY: centerY, isGesture: isGesture)
    }
    
    open func onPanStart(deltaX: CGFloat, deltaY: CGFloat) {
        for layer in layers {
            layer.pan(deltaX, deltaY: deltaY)
        }
    }
    
    open func onPanStart(location: CGPoint) {
        for layer in layers {
            layer.handlePanStart(location)
        }
    }

    open func onPanEnd() {
        for layer in layers {
            layer.handlePanEnd()
        }
    }

    open func onZoomEnd() {
        for layer in layers {
            layer.handleZoomEnd()
        }
    }
    
    open func onPanFinish(transX: CGFloat, transY: CGFloat, deltaX: CGFloat, deltaY: CGFloat, isGesture: Bool, isDeceleration: Bool) {
        for layer in layers {
            layer.handlePanFinish()
        }
        delegate?.onPan(transX: transX, transY: transY, deltaX: deltaX, deltaY: deltaY, isGesture: isGesture, isDeceleration: isDeceleration)
    }

    func onTap(_ location: CGPoint) {
        var models = [TappedChartPointLayerModels<ChartPoint>]()
        for layer in layers {
            if let chartPointsLayer = layer as? ChartPointsLayer {
                if let tappedModels = chartPointsLayer.handleGlobalTap(location) as? TappedChartPointLayerModels<ChartPoint> {
                    models.append(tappedModels)
                }
            } else {
                layer.handleGlobalTap(location)
            }
        }
        delegate?.onTap(models)
    }
    
    open func resetPanZoom() {
        zoom(scaleX: minScaleX ?? 1, scaleY: minScaleY ?? 1, anchorX: 0, anchorY: 0)
        
        // TODO exact numbers. 
        // Chart needs unified functionality to get/set current transform matrix independently of implementation details like contentView or axes transform, which are separate.
        // Currently the axes and the content view basically manage the transform separately
        // For more details, see http://stackoverflow.com/questions/41337146/apply-transform-matrix-to-core-graphics-drawing-and-subview
        pan(deltaX: 10000, deltaY: 10000, isGesture: false, isDeceleration: false, elastic: false)
        
        keepInBoundaries()
        for layer in layers {
            layer.keepInBoundaries()
        }
    }

    /**
     Draws the chart's layers in the chart view

     - parameter rect: The rect that needs to be drawn
     */
    fileprivate func drawRect(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {return}
        for layer in self.layers {
            layer.chartViewDrawing(context: context, chart: self)
        }
    }
    
    fileprivate func drawContentViewRect(_ rect: CGRect, sender: ChartContentView) {
        guard let context = UIGraphicsGetCurrentContext() else {return}
        if sender == drawersContentView {
            for layer in layers {
                layer.chartDrawersContentViewDrawing(context: context, chart: self, view: sender)
            }
        } else if sender == contentView {
            for layer in layers {
                layer.chartContentViewDrawing(context: context, chart: self)
            }
            drawersContentView.setNeedsDisplay()
        }
    }
    
    func allowPan(location: CGPoint, deltaX: CGFloat, deltaY: CGFloat, isGesture: Bool, isDeceleration: Bool) -> Bool {
        var someLayerProcessedPan = false
        for layer in layers {
            if layer.processPan(location: location, deltaX: deltaX, deltaY: deltaY, isGesture: isGesture, isDeceleration: isDeceleration) {
                someLayerProcessedPan = true
            }
        }
        return !someLayerProcessedPan
    }
    
    func allowZoom(deltaX: CGFloat, deltaY: CGFloat, anchorX: CGFloat, anchorY: CGFloat) -> Bool {
        var someLayerProcessedZoom = false
        for layer in layers {
            if layer.processZoom(deltaX: deltaX, deltaY: deltaY, anchorX: anchorX, anchorY: anchorY) {
                someLayerProcessedZoom = true
            }
        }
        return !someLayerProcessedZoom
    }
}


open class ChartContentView: UIView {
    
    weak var chart: Chart?
    
    override open func draw(_ rect: CGRect) {
        self.chart?.drawContentViewRect(rect, sender: self)
    }
}

/// A UIView subclass for drawing charts
open class ChartBaseView: ChartView {
    
    override open func draw(_ rect: CGRect) {
        self.chart?.drawRect(rect)
    }
}

open class ChartView: UIView, UIGestureRecognizerDelegate {
    
    /// The chart that will be drawn in this view
    weak var chart: Chart?
    
    fileprivate var lastPanTranslation: CGPoint?
    fileprivate var isPanningX: Bool? // true: x, false: y
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    /**
     Initialization code shared between all initializers
     */
    func sharedInit() {
        backgroundColor = UIColor.clear
    }
    
    
    #if !os(tvOS)
    
    // MARK: Interactivity
    
    fileprivate var pinchRecognizer: UIPinchGestureRecognizer?
    fileprivate var panRecognizer: UIPanGestureRecognizer?
    fileprivate var tapRecognizer: UITapGestureRecognizer?
    
    func initRecognizers(_ settings: ChartSettings) {
        if settings.zoomPan.zoomEnabled {
            let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(ChartView.onPinch(_:)))
            pinchRecognizer.delegate = self
            addGestureRecognizer(pinchRecognizer)
            self.pinchRecognizer = pinchRecognizer
        }
    
        if settings.zoomPan.panEnabled {
            let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ChartView.onPan(_:)))
            panRecognizer.delegate = self
            addGestureRecognizer(panRecognizer)
            self.panRecognizer = panRecognizer
        }
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ChartView.onTap(_:)))
        tapRecognizer.delegate = self
        tapRecognizer.cancelsTouchesInView = false
        addGestureRecognizer(tapRecognizer)
        self.tapRecognizer = tapRecognizer
    }

    fileprivate var zoomCenter: CGPoint?
    
    @objc func onPinch(_ sender: UIPinchGestureRecognizer) {
        
        guard let chartSettings = chart?.settings, chartSettings.zoomPan.zoomEnabled else {return}

        switch sender.state {
        case .began:
            zoomCenter = nil
            fallthrough
            
        case .changed:
            guard sender.numberOfTouches > 1 else {return}
            
            let center = zoomCenter ?? {
                let center = sender.location(in: self)
                zoomCenter = center
                return center
            }()
            
            let x = abs(sender.location(in: self).x - sender.location(ofTouch: 1, in: self).x)
            let y = abs(sender.location(in: self).y - sender.location(ofTouch: 1, in: self).y)
            
            let (deltaX, deltaY): (CGFloat, CGFloat) = {
                switch chartSettings.zoomPan.gestureMode {
                case .onlyX: return (sender.scale, 1)
                case .onlyY: return (1, sender.scale)
                case .max: return x > y ? (sender.scale, 1) : (1, sender.scale)
                case .both:
                    // calculate scale x and scale y
                    let (absMax, absMin) = x > y ? (abs(x), abs(y)) : (abs(y), abs(x))
                    let minScale = (absMin * (sender.scale - 1) / absMax) + 1
                    return x > y ? (sender.scale, minScale) : (minScale, sender.scale)
                }
            }()
            chart?.zoom(deltaX: deltaX, deltaY: deltaY, centerX: center.x, centerY: center.y, isGesture: true)
            
        case .ended:
            guard let center = zoomCenter, let chart = chart else {print("No center or chart"); return}
            
            let adjustBoundsVelocity: CGFloat = 0.2
            
            let minScaleX = chart.settings.zoomPan.minZoomX ?? 1
            let minScaleY = chart.settings.zoomPan.minZoomY ?? 1
            
            func outOfBoundsOffsets(_ limit: Bool) -> (x: CGFloat, y: CGFloat) {
                let scaleX = chart.scaleX
                var x: CGFloat?
                if scaleX < minScaleX {
                    x = limit ? min(1 + adjustBoundsVelocity, minScaleX / scaleX) : minScaleX / scaleX
                }
                if x == minScaleX {
                    x = nil
                }
                
                let scaleY = chart.scaleY
                var y: CGFloat?
                if scaleY < minScaleY {
                    y = limit ? min(1 + adjustBoundsVelocity, minScaleY / scaleY) : minScaleY / scaleY
                }
                if y == minScaleY {
                    y = nil
                }
                
                return (x ?? 1, y ?? 1)
            }
            
            
            func adjustBoundsRec(_ counter: Int) {
                // FIXME
                if counter > 400 {
                    let (xOffset, yOffset) = outOfBoundsOffsets(false)
                    chart.zoom(deltaX: xOffset, deltaY: yOffset, centerX: center.x, centerY: center.y, isGesture: true)
                    return
                }
                
                DispatchQueue.main.async {
                    
                    let (xOffset, yOffset) = outOfBoundsOffsets(true)
                    
                    if xOffset != 1 || yOffset != 1 {
                        chart.zoom(deltaX: xOffset, deltaY: yOffset, centerX: center.x, centerY: center.y, isGesture: true)
                        adjustBoundsRec(counter + 1)
                    }
                }
            }
            
            @discardableResult
            func adjustBounds() -> Bool {
                let (xOffset, yOffset) = outOfBoundsOffsets(true)
                
                guard (xOffset != 1 || yOffset != 1) else {
                    if chart.scaleX =~ minScaleX || chart.scaleY =~ minScaleY {
                        chart.pan(deltaX: chart.scaleX =~ minScaleY ? -chart.contentView.frame.minX : 0, deltaY: chart.scaleY =~ minScaleY ? -chart.contentView.frame.minY : 0, isGesture: false, isDeceleration: false, elastic: chart.zoomPanSettings.elastic)
                    }
                    return false
                }
                
                adjustBoundsRec(0)
                
                return true
            }
            
            if chart.zoomPanSettings.elastic {
                adjustBounds()
            }
            
            chart.onZoomEnd()
            
        case .cancelled:
            chart?.onZoomEnd()
        case .failed:
            fallthrough
        case .possible: break
        }
        
        sender.scale = 1.0
    }
    
    @objc func onPan(_ sender: UIPanGestureRecognizer) {
        
        guard let chartSettings = chart?.settings , chartSettings.zoomPan.panEnabled else {return}
        
        func finalPanDelta(deltaX: CGFloat, deltaY: CGFloat) -> (deltaX: CGFloat, deltaY: CGFloat) {
            switch chartSettings.zoomPan.gestureMode {
            case .onlyX: return (deltaX, 0)
            case .onlyY: return (0, deltaY)
            case .max:
                if isPanningX == nil {
                    isPanningX = abs(deltaX) > abs(deltaY)
                }
                return isPanningX! ? (deltaX, 0) : (0, deltaY)
            case .both: return (deltaX, deltaY)
            }
        }
        
        switch sender.state {
            
        case .began:
            lastPanTranslation = nil
            isPanningX = nil
            
            chart?.onPanStart(location: sender.location(in: self))
            
        case .changed:
            
            let trans = sender.translation(in: self)
            
            let location = sender.location(in: self)
            
            var deltaX = lastPanTranslation.map{trans.x - $0.x} ?? trans.x
            let deltaY = lastPanTranslation.map{trans.y - $0.y} ?? trans.y

            var (finalDeltaX, finalDeltaY) = finalPanDelta(deltaX: deltaX, deltaY: deltaY)
            
            lastPanTranslation = trans
            
            if (chart?.allowPan(location: location, deltaX: finalDeltaX, deltaY: finalDeltaY, isGesture: true, isDeceleration: false)) ?? false {
                chart?.pan(deltaX: finalDeltaX, deltaY: finalDeltaY, isGesture: true, isDeceleration: false, elastic: chart?.zoomPanSettings.elastic ?? false)
            }

        case .ended:
            
            guard let view = sender.view, let chart = chart else {print("No view or chart"); return}
            
            
            let velocityX = sender.velocity(in: sender.view).x
            let velocityY = sender.velocity(in: sender.view).y
            
            let (finalDeltaX, finalDeltaY) = finalPanDelta(deltaX: velocityX, deltaY: velocityY)

            let location = sender.location(in: self)
            
            func next(_ velocityX: CGFloat, velocityY: CGFloat) {
                DispatchQueue.main.async {
                    
                    chart.pan(deltaX: velocityX, deltaY: velocityY, isGesture: true, isDeceleration: true, elastic: chart.zoomPanSettings.elastic)
                    
                    if abs(velocityX) > 0.1 || abs(velocityY) > 0.1 {
                        let friction: CGFloat = 0.9

                        next(velocityX * friction, velocityY: velocityY * friction)
                        
                    } else {
                        if chart.zoomPanSettings.elastic {
                            adjustBounds()
                        }
                    }
                }
            }
            
            
            let adjustBoundsVelocity: CGFloat = 20
            
            func outOfBoundsOffsets(_ limit: Bool) -> (x: CGFloat, y: CGFloat) {
                var x: CGFloat?
                if chart.contentView.frame.minX > 0 {
                    x = limit ? max(-adjustBoundsVelocity, -chart.contentView.frame.minX) : -chart.contentView.frame.minX
                } else {
                    let offset = chart.contentView.frame.maxX - chart.containerView.frame.width
                    if offset < 0 {
                        x = limit ? min(adjustBoundsVelocity, -offset) : -offset
                    }
                }
                
                var y: CGFloat?
                if chart.contentView.frame.minY > 0 {
                    y = limit ? max(-adjustBoundsVelocity, -chart.contentView.frame.minY) : -chart.contentView.frame.minY
                } else {
                    let offset = chart.contentView.frame.maxY - chart.containerView.frame.height
                    if offset < 0 {
                        y = limit ? min(adjustBoundsVelocity, -offset) : -offset
                    }
                }
                
                // Drop possile values < epsilon, this causes endless loop since adding them to the view translation apparently is a no-op
                let roundDecimals: CGFloat = 1000000000
                x = x.map{($0 * roundDecimals) / roundDecimals}.flatMap{$0 =~ 0 ? 0 : x}
                y = y.map{($0 * roundDecimals) / roundDecimals}.flatMap{$0 =~ 0 ? 0 : y}
                
                return (x ?? 0, y ?? 0)
            }
            
            func adjustBoundsRec(_ counter: Int) {
                
                // FIXME
                if counter > 400 {
                    let (xOffset, yOffset) = outOfBoundsOffsets(false)
                    chart.pan(deltaX: xOffset, deltaY: yOffset, isGesture: true, isDeceleration: false, elastic: chart.zoomPanSettings.elastic)
                    return
                }
                
                DispatchQueue.main.async {
                    let (xOffset, yOffset) = outOfBoundsOffsets(true)
                    
                    if xOffset != 0 || yOffset != 0 {
                        chart.pan(deltaX: xOffset, deltaY: yOffset, isGesture: true, isDeceleration: false, elastic: chart.zoomPanSettings.elastic)
                        adjustBoundsRec(counter + 1)
                    }
                }
            }
            
            @discardableResult
            func adjustBounds() -> Bool {
                let (xOffset, yOffset) = outOfBoundsOffsets(true)
                
                guard (xOffset != 0 || yOffset != 0) else {return false}
                adjustBoundsRec(0)
                
                return true
            }
            
            let initFriction: CGFloat = 50
            
            if (chart.allowPan(location: location, deltaX: finalDeltaX, deltaY: finalDeltaY, isGesture: true, isDeceleration: false)) {
                if (chart.zoomPanSettings.elastic && !adjustBounds()) || !chart.zoomPanSettings.elastic {
                    next(finalDeltaX / initFriction, velocityY: finalDeltaY / initFriction)
                }
            }
            
            chart.onPanEnd()
            
        case .cancelled: break;
        case .failed: break;
        case .possible:
//            sender.state = UIGestureRecognizerState.Changed
            break;
        }
    }
    
    @objc func onTap(_ sender: UITapGestureRecognizer) {
        chart?.onTap(sender.location(in: self))
    }
    #endif

}
