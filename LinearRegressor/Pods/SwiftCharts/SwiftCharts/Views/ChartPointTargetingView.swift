//
//  ChartPointTargetingView.swift
//  swift_charts
//
//  Created by ischuetz on 15/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

open class ChartPointTargetingView: UIView {

    fileprivate let animDuration: Float
    fileprivate let animDelay: Float
    
    fileprivate let lineHorizontal: UIView
    fileprivate let lineVertical: UIView
  
    fileprivate let lineWidth = 1
    
    fileprivate let lineHorizontalTargetFrame: CGRect
    fileprivate let lineVerticalTargetFrame: CGRect
    
    public init(chartPoint: ChartPoint, screenLoc: CGPoint, animDuration: Float, animDelay: Float, layer: ChartCoordsSpaceLayer, chart: Chart) {
        self.animDuration = animDuration
        self.animDelay = animDelay
      
        let axisOriginX = layer.modelLocToScreenLoc(x: layer.xAxis.first)
        let axisOriginY = layer.modelLocToScreenLoc(y: layer.yAxis.last)
        let axisLengthX = layer.modelLocToScreenLoc(x: layer.xAxis.last) - axisOriginX
        let axisLengthY = abs(axisOriginY - layer.modelLocToScreenLoc(y: layer.yAxis.first))
        
        lineHorizontal = UIView(frame: CGRect(x: axisOriginX, y: axisOriginY, width: axisLengthX, height: CGFloat(lineWidth)))
        lineVertical = UIView(frame: CGRect(x: axisOriginX, y: axisOriginY, width: CGFloat(lineWidth), height: axisLengthY))
        
        lineHorizontal.backgroundColor = UIColor.black
        lineVertical.backgroundColor = UIColor.red
        
        let lineWidthHalf = lineWidth / 2
        var targetFrameH = lineHorizontal.frame
        targetFrameH.origin.y = screenLoc.y - CGFloat(lineWidthHalf)
        lineHorizontalTargetFrame = targetFrameH
        var targetFrameV = lineVertical.frame
        targetFrameV.origin.x = screenLoc.x - CGFloat(lineWidthHalf)
        lineVerticalTargetFrame = targetFrameV
 
        super.init(frame: chart.bounds)
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func didMoveToSuperview() {
        addSubview(lineHorizontal)
        addSubview(lineVertical)

        func targetState() {
            lineHorizontal.frame = lineHorizontalTargetFrame
            lineVertical.frame = lineVerticalTargetFrame
        }
        
        if animDuration =~ 0 {
            targetState()
        } else {
            UIView.animate(withDuration: TimeInterval(animDuration), delay: TimeInterval(animDelay), options: .curveEaseOut, animations: {
                targetState()
            }, completion: nil)
        }
    }
}
