//
//  ChartPointsTrackerLayer.swift
//  SwiftCharts
//
//  Created by ischuetz on 29/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

open class ChartPointsTrackerLayer<T: ChartPoint>: ChartPointsLayer<T> {
   
    fileprivate var view: TrackerView?
    fileprivate let locChangedFunc: ((CGPoint) -> ())

    fileprivate let lineColor: UIColor
    fileprivate let lineWidth: CGFloat
    
    fileprivate lazy private(set) var currentPositionLineOverlay: UIView = {
        let currentPositionLineOverlay = UIView()
        currentPositionLineOverlay.backgroundColor = self.lineColor
        return currentPositionLineOverlay
    }()
    
    
    public init(xAxis: ChartAxis, yAxis: ChartAxis, chartPoints: [T], locChangedFunc: @escaping (CGPoint) -> (), lineColor: UIColor = UIColor.black, lineWidth: CGFloat = 1) {
        self.locChangedFunc = locChangedFunc
        self.lineColor = lineColor
        self.lineWidth = lineWidth
        super.init(xAxis: xAxis, yAxis: yAxis, chartPoints: chartPoints)
    }
    
    open override func display(chart: Chart) {
        let view = TrackerView(frame: chart.bounds, updateFunc: {[weak self] location in
            self?.locChangedFunc(location)
            self?.currentPositionLineOverlay.center.x = location.x
        })
        view.isUserInteractionEnabled = true
        chart.addSubview(view)
        self.view = view
        
        view.addSubview(currentPositionLineOverlay)
        
        currentPositionLineOverlay.frame = CGRect(x: chart.containerFrame.origin.x + 200 - lineWidth / 2, y: modelLocToScreenLoc(y: yAxis.last), width: lineWidth, height: modelLocToScreenLoc(y: yAxis.first))
    }
}


private class TrackerView: UIView {
    
    let updateFunc: ((CGPoint) -> ())?
    
    init(frame: CGRect, updateFunc: @escaping (CGPoint) -> ()) {
        self.updateFunc = updateFunc
        
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)
        
        self.updateFunc?(location)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)
        
        self.updateFunc?(location)
    }
}
