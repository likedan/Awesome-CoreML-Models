//
//  ChartPointsScatterLayer.swift
//  Examples
//
//  Created by ischuetz on 17/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

open class ChartPointsScatterLayer<T: ChartPoint>: ChartPointsLayer<T> {

    open let itemSize: CGSize
    open let itemFillColor: UIColor
    
    fileprivate let optimized: Bool
    
    required public init(xAxis: ChartAxis, yAxis: ChartAxis, chartPoints: [T], displayDelay: Float = 0, itemSize: CGSize, itemFillColor: UIColor, optimized: Bool, tapSettings: ChartPointsTapSettings<T>?) {
        self.itemSize = itemSize
        self.itemFillColor = itemFillColor
        self.optimized = optimized
        super.init(xAxis: xAxis, yAxis: yAxis, chartPoints: chartPoints, displayDelay: displayDelay, tapSettings: tapSettings)
    }
    
    override open func chartContentViewDrawing(context: CGContext, chart: Chart) {
    }
    
    override open func chartDrawersContentViewDrawing(context: CGContext, chart: Chart, view: UIView) {
        if !optimized {
            for chartPointModel in chartPointsModels {
                drawChartPointModel(context, chartPointModel: chartPointModel, view: view)
            }
        } else { // Generate CGLayer with shape only once and draw it at different positions.
            let contentScale = view.contentScaleFactor * 2
            guard let layer = generateCGLayer(context, view: view, contentScale: contentScale) else {print("Couldn't generate layer"); return}
            
            let w = itemSize.width
            let h = itemSize.height
            
            for chartPointModel in chartPointsModels {
                let screenLoc = modelLocToScreenLoc(x: chartPointModel.chartPoint.x.scalar, y: chartPointModel.chartPoint.y.scalar)
                context.saveGState()
                context.translateBy(x: screenLoc.x, y: screenLoc.y)
                context.draw(layer, in: CGRect(x: -w / 2, y: -h / 2, width: w, height: h))
                context.restoreGState()
            }
        }
    }
    
    override func toLocalCoordinates(_ globalPoint: CGPoint) -> CGPoint? {
        return globalToDrawersContainerCoordinates(globalPoint)
    }
    
    open override func modelLocToScreenLoc(x: Double) -> CGFloat {
        return xAxis.screenLocForScalar(x) - (chart?.containerFrame.origin.x ?? 0)
    }
    
    open override func modelLocToScreenLoc(y: Double) -> CGFloat {
        return yAxis.screenLocForScalar(y) - (chart?.containerFrame.origin.y ?? 0)
    }
    
    open override func zoom(_ scaleX: CGFloat, scaleY: CGFloat, centerX: CGFloat, centerY: CGFloat) {
        chart?.drawersContentView.setNeedsDisplay()
    }
    
    open override func zoom(_ x: CGFloat, y: CGFloat, centerX: CGFloat, centerY: CGFloat) {
        chart?.drawersContentView.setNeedsDisplay()
    }
    
    open override func pan(_ deltaX: CGFloat, deltaY: CGFloat) {
        chart?.drawersContentView.setNeedsDisplay()
    }
    
    open func drawChartPointModel(_ context: CGContext, chartPointModel: ChartPointLayerModel<T>, view: UIView) {
        fatalError("override")
    }
    
    open func updatePointLayer(_ chartPointModel: ChartPointLayerModel<T>) {
        fatalError("override")
    }
    
    func generateCGLayer(_ context: CGContext, view: UIView, contentScale: CGFloat) -> CGLayer? {
        let scaledBounds = CGRect(x: 0, y: 0, width: itemSize.width * contentScale, height: itemSize.height * contentScale)
        let layer = CGLayer(context, size: scaledBounds.size, auxiliaryInfo: nil)
        let myLayerContext1 = layer?.context
        myLayerContext1?.scaleBy(x: contentScale, y: contentScale)
        return layer
    }
    
}

open class ChartPointsScatterTrianglesLayer<T: ChartPoint>: ChartPointsScatterLayer<T> {
    
    fileprivate let trianglePointsCG: [CGPoint]
    
    required public init(xAxis: ChartAxis, yAxis: ChartAxis, chartPoints: [T], displayDelay: Float = 0, itemSize: CGSize, itemFillColor: UIColor, optimized: Bool = true, tapSettings: ChartPointsTapSettings<T>? = nil) {
        trianglePointsCG = [CGPoint(x: 0, y: itemSize.height), CGPoint(x: itemSize.width / 2, y: 0), CGPoint(x: itemSize.width, y: itemSize.height), CGPoint(x: 0, y: itemSize.height)]
        super.init(xAxis: xAxis, yAxis: yAxis, chartPoints: chartPoints, displayDelay: displayDelay, itemSize: itemSize, itemFillColor: itemFillColor, optimized: optimized, tapSettings: tapSettings)
    }
    
    override func generateCGLayer(_ context: CGContext, view: UIView, contentScale: CGFloat) -> CGLayer? {
        guard let layer = super.generateCGLayer(context, view: view, contentScale: contentScale), let layerContext = layer.context else {print("Couldn't get context"); return nil}
        
        layerContext.setFillColor(itemFillColor.cgColor)
        layerContext.addLines(between: trianglePointsCG)
        layerContext.fillPath()
        
        return layer
    }
    
    override open func drawChartPointModel(_ context: CGContext, chartPointModel: ChartPointLayerModel<T>, view: UIView) {
        
        let w = itemSize.width
        let h = itemSize.height
        
        let screenLoc = modelLocToScreenLoc(x: chartPointModel.chartPoint.x.scalar, y: chartPointModel.chartPoint.y.scalar)
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x: screenLoc.x, y: screenLoc.y - h / 2))
        path.addLine(to: CGPoint(x: screenLoc.x + w / 2, y: screenLoc.y + h / 2))
        path.addLine(to: CGPoint(x: screenLoc.x - w / 2, y: screenLoc.y + h / 2))
        path.closeSubpath()
        
        context.setFillColor(itemFillColor.cgColor)
        context.addPath(path)
        context.fillPath()
    }
}

open class ChartPointsScatterSquaresLayer<T: ChartPoint>: ChartPointsScatterLayer<T> {
    
    fileprivate let squarePointsCG: [CGPoint]
    
    required public init(xAxis: ChartAxis, yAxis: ChartAxis, chartPoints: [T], displayDelay: Float = 0, itemSize: CGSize, itemFillColor: UIColor, optimized: Bool = true, tapSettings: ChartPointsTapSettings<T>? = nil) {
        squarePointsCG = [CGPoint(x: 0, y: 0), CGPoint(x: itemSize.width, y: 0), CGPoint(x: itemSize.width, y: itemSize.height), CGPoint(x: 0, y: itemSize.height), CGPoint(x: 0, y: 0)]
        super.init(xAxis: xAxis, yAxis: yAxis, chartPoints: chartPoints, displayDelay: displayDelay, itemSize: itemSize, itemFillColor: itemFillColor, optimized: optimized, tapSettings: tapSettings)
    }
    
    override open func drawChartPointModel(_ context: CGContext, chartPointModel: ChartPointLayerModel<T>, view: UIView) {
        
        let w = itemSize.width
        let h = itemSize.height

        let screenLoc = modelLocToScreenLoc(x: chartPointModel.chartPoint.x.scalar, y: chartPointModel.chartPoint.y.scalar)
        
        context.setFillColor(itemFillColor.cgColor)
        context.fill(CGRect(x: screenLoc.x - w / 2, y: screenLoc.y - h / 2, width: w, height: h))
    }
    
    override func generateCGLayer(_ context: CGContext, view: UIView, contentScale: CGFloat) -> CGLayer? {
        guard let layer = super.generateCGLayer(context, view: view, contentScale: contentScale), let layerContext = layer.context else {print("Couldn't get context"); return nil}
        
        layerContext.setFillColor(itemFillColor.cgColor)
        layerContext.fill(CGRect(x: 0, y: 0, width: itemSize.width, height: itemSize.height))
        layerContext.fillPath()
        
        return layer
    }
}

open class ChartPointsScatterCirclesLayer<T: ChartPoint>: ChartPointsScatterLayer<T> {
    
    required public init(xAxis: ChartAxis, yAxis: ChartAxis, chartPoints: [T], displayDelay: Float = 0, itemSize: CGSize, itemFillColor: UIColor, optimized: Bool = true, tapSettings: ChartPointsTapSettings<T>? = nil) {
        super.init(xAxis: xAxis, yAxis: yAxis, chartPoints: chartPoints, displayDelay: displayDelay, itemSize: itemSize, itemFillColor: itemFillColor, optimized: optimized, tapSettings: tapSettings)
    }
    
    override open func drawChartPointModel(_ context: CGContext, chartPointModel: ChartPointLayerModel<T>, view: UIView) {
        let w = itemSize.width
        let h = itemSize.height
        
        let screenLoc = modelLocToScreenLoc(x: chartPointModel.chartPoint.x.scalar, y: chartPointModel.chartPoint.y.scalar)
        
        context.setFillColor(itemFillColor.cgColor)
        context.fillEllipse(in: CGRect(x: screenLoc.x - w / 2, y: screenLoc.y - h / 2, width: w, height: h))
    }
    
    override func generateCGLayer(_ context: CGContext, view: UIView, contentScale: CGFloat) -> CGLayer? {
        guard let layer = super.generateCGLayer(context, view: view, contentScale: contentScale), let layerContext = layer.context else {print("Couldn't get context"); return nil}
        
        layerContext.setFillColor(itemFillColor.cgColor)
        layerContext.fillEllipse(in: CGRect(x: 0, y: 0, width: itemSize.width, height: itemSize.height))
        layerContext.fillPath()
        
        return layer
    }
}

open class ChartPointsScatterCrossesLayer<T: ChartPoint>: ChartPointsScatterLayer<T> {
    
    open let strokeWidth: CGFloat
    
    fileprivate let line1PointsCG: [CGPoint]
    fileprivate let line2PointsCG: [CGPoint]
    
    required public init(xAxis: ChartAxis, yAxis: ChartAxis, chartPoints: [T], displayDelay: Float = 0, itemSize: CGSize, itemFillColor: UIColor, strokeWidth: CGFloat = 2, optimized: Bool = true, tapSettings: ChartPointsTapSettings<T>? = nil) {
        self.strokeWidth = strokeWidth
        line1PointsCG = [CGPoint(x: 0, y: 0), CGPoint(x: itemSize.width, y: itemSize.height)]
        line2PointsCG = [CGPoint(x: itemSize.width, y: 0), CGPoint(x: 0, y: itemSize.height)]
        super.init(xAxis: xAxis, yAxis: yAxis, chartPoints: chartPoints, displayDelay: displayDelay, itemSize: itemSize, itemFillColor: itemFillColor, optimized: optimized, tapSettings: tapSettings)
    }

    required public init(xAxis: ChartAxis, yAxis: ChartAxis, chartPoints: [T], displayDelay: Float, itemSize: CGSize, itemFillColor: UIColor, optimized: Bool, tapSettings: ChartPointsTapSettings<T>?) {
        fatalError("init(xAxis:yAxis:chartPoints:displayDelay:itemSize:itemFillColor:optimized:tapSettings:) has not been implemented")
    }
    
    override open func drawChartPointModel(_ context: CGContext, chartPointModel: ChartPointLayerModel<T>, view: UIView) {
        let w = itemSize.width
        let h = itemSize.height

        let screenLoc = modelLocToScreenLoc(x: chartPointModel.chartPoint.x.scalar, y: chartPointModel.chartPoint.y.scalar)
        
        func drawLine(_ p1X: CGFloat, p1Y: CGFloat, p2X: CGFloat, p2Y: CGFloat) {
            context.setStrokeColor(itemFillColor.cgColor)
            context.setLineWidth(strokeWidth)
            context.move(to: CGPoint(x: p1X, y: p1Y))
            context.addLine(to: CGPoint(x: p2X, y: p2Y))
            context.strokePath()
        }
        
        drawLine(screenLoc.x - w / 2, p1Y: screenLoc.y - h / 2, p2X: screenLoc.x + w / 2, p2Y: screenLoc.y + h / 2)
        drawLine(screenLoc.x + w / 2, p1Y: screenLoc.y - h / 2, p2X: screenLoc.x - w / 2, p2Y: screenLoc.y + h / 2)
    }
    
    override func generateCGLayer(_ context: CGContext, view: UIView, contentScale: CGFloat) -> CGLayer? {
        guard let layer = super.generateCGLayer(context, view: view, contentScale: contentScale), let layerContext = layer.context else {print("Couldn't get context"); return nil}

        context.setStrokeColor(itemFillColor.cgColor)
        context.setLineWidth(strokeWidth)
        
        layerContext.addLines(between: line1PointsCG)
        layerContext.addLines(between: line2PointsCG)
        
        layerContext.strokePath()
        
        return layer
    }
}
