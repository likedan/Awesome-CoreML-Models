//
//  ChartCoordsSpaceLayer.swift
//  SwiftCharts
//
//  Created by ischuetz on 25/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

open class ChartCoordsSpaceLayer: ChartLayerBase {
    
    open let xAxis: ChartAxis
    open let yAxis: ChartAxis
    
    public init(xAxis: ChartAxis, yAxis: ChartAxis) {
        self.xAxis = xAxis
        self.yAxis = yAxis
    }
    
    open func modelLocToScreenLoc(x: Double, y: Double) -> CGPoint {
        return CGPoint(x: modelLocToScreenLoc(x: x), y: modelLocToScreenLoc(y: y))
    }
    
    open func modelLocToScreenLoc(x: Double) -> CGFloat {
        return xAxis.innerScreenLocForScalar(x) / (chart?.contentView.transform.a ?? 1)
    }
    
    open func modelLocToScreenLoc(y: Double) -> CGFloat {
        return yAxis.innerScreenLocForScalar(y) / (chart?.contentView.transform.d ?? 1)
    }

    open func modelLocToContainerScreenLoc(x: Double, y: Double) -> CGPoint {
        return CGPoint(x: modelLocToContainerScreenLoc(x: x), y: modelLocToContainerScreenLoc(y: y))
    }
    
    open func modelLocToContainerScreenLoc(x: Double) -> CGFloat {
        return xAxis.screenLocForScalar(x) - (chart?.containerFrame.origin.x ?? 0)
    }
    
    open func modelLocToContainerScreenLoc(y: Double) -> CGFloat {
        return yAxis.screenLocForScalar(y) - (chart?.containerFrame.origin.y ?? 0)
    }

    open func modelLocToGlobalScreenLoc(x: Double, y: Double) -> CGPoint {
        return CGPoint(x: modelLocToGlobalScreenLoc(x: x), y: modelLocToGlobalScreenLoc(y: y))
    }
    
    open func modelLocToGlobalScreenLoc(x: Double) -> CGFloat {
        return xAxis.screenLocForScalar(x)
    }
    
    open func modelLocToGlobalScreenLoc(y: Double) -> CGFloat {
        return yAxis.screenLocForScalar(y)
    }
    
    open func scalarForScreenLoc(x: CGFloat) -> Double {
        return xAxis.innerScalarForScreenLoc(x * (chart?.contentView.transform.a ?? 1))
    }
    
    open func scalarForScreenLoc(y: CGFloat) -> Double {
        return yAxis.innerScalarForScreenLoc(y * (chart?.contentView.transform.d ?? 1))
    }
    
    open func globalToDrawersContainerCoordinates(_ point: CGPoint) -> CGPoint? {
        return globalToContainerCoordinates(point)
    }
    
    open func globalToContainerCoordinates(_ point: CGPoint) -> CGPoint? {
        guard let chart = chart else {return nil}
        return point.substract(chart.containerView.frame.origin)
    }
    
    open func globalToContentCoordinates(_ point: CGPoint) -> CGPoint? {
        guard let chart = chart else {return nil}
        guard let containerCoords = globalToContainerCoordinates(point) else {return nil}
        return CGPoint(
            x: (containerCoords.x - chart.contentView.frame.origin.x) / chart.contentView.transform.a,
            y: (containerCoords.y - chart.contentView.frame.origin.y) / chart.contentView.transform.d
        )
    }
    
    open func containerToGlobalCoordinates(_ point: CGPoint) -> CGPoint? {
        guard let chart = chart else {return nil}
        return point.add(chart.containerView.frame.origin)
    }

    open func contentToContainerCoordinates(_ point: CGPoint) -> CGPoint? {
        guard let chart = chart else {return nil}
        let containerX = (point.x * chart.contentView.transform.a) + chart.contentView.frame.minX
        let containerY = (point.y * chart.contentView.transform.d) + chart.contentView.frame.minY
        return CGPoint(x: containerX, y: containerY)
    }
    
    open func contentToGlobalCoordinates(_ point: CGPoint) -> CGPoint? {
        return contentToContainerCoordinates(point).flatMap{containerToGlobalCoordinates($0)}
    }
    
    // TODO review method, variable names
    open func contentToGlobalScreenLoc(_ chartPoint: ChartPoint) -> CGPoint? {
        let containerScreenLoc = CGPoint(x: modelLocToScreenLoc(x: chartPoint.x.scalar), y: modelLocToScreenLoc(y: chartPoint.y.scalar))
        return containerToGlobalCoordinates(containerScreenLoc)
    }
    
    open func containerToGlobalScreenLoc(_ chartPoint: ChartPoint) -> CGPoint? {
        let containerScreenLoc = CGPoint(x: modelLocToContainerScreenLoc(x: chartPoint.x.scalar), y: modelLocToContainerScreenLoc(y: chartPoint.y.scalar))
        return containerToGlobalCoordinates(containerScreenLoc)
    }
}
