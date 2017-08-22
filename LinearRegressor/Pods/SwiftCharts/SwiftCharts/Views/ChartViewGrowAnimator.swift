//
//  ChartViewGrowAnimator.swift
//  SwiftCharts
//
//  Created by ischuetz on 02/09/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import UIKit

public struct ChartViewGrowAnimator: ChartViewAnimator {

    public let anchor: CGPoint
    
    public init(anchor: CGPoint) {
        self.anchor = anchor
    }
    
    public func prepare(_ view: UIView) {
        view.layer.anchorPoint = anchor
        let offsetX = view.frame.width * (0.5 - anchor.x)
        let offsetY = view.frame.height * (0.5 - anchor.y)
        view.frame = view.frame.offsetBy(dx: -offsetX, dy: -offsetY)
        
        initState(view)
    }
 
    public func initState(_ view: UIView) {
        view.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
    }
    
    public func targetState(_ view: UIView) {
        view.transform = CGAffineTransform(scaleX: 1, y: 1)
    }
}