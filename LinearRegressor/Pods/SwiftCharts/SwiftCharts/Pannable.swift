//
//  Pannable.swift
//  SwiftCharts
//
//  Created by ischuetz on 05/07/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import UIKit

public protocol Pannable {
    
    var zoomPanSettings: ChartSettingsZoomPan {get}
    
    var containerView: UIView {get}
    
    var contentView: UIView {get}
    
    var transX: CGFloat {get}
    var transY: CGFloat {get}
    
    func pan(x: CGFloat, y: CGFloat, elastic: Bool)
    
    func pan(deltaX: CGFloat, deltaY: CGFloat, elastic: Bool)
    
    func pan(deltaX: CGFloat, deltaY: CGFloat, isGesture: Bool, isDeceleration: Bool, elastic: Bool)
    
    func onPanStart(deltaX: CGFloat, deltaY: CGFloat)
    
    func onPanFinish(transX: CGFloat, transY: CGFloat, deltaX: CGFloat, deltaY: CGFloat, isGesture: Bool, isDeceleration: Bool)
}

public extension Pannable {

    func pan(x: CGFloat, y: CGFloat, elastic: Bool) {
        pan(deltaX: x - transX, deltaY: transY - y, isGesture: false, isDeceleration: false, elastic: elastic)
    }
    
    func pan(deltaX: CGFloat, deltaY: CGFloat, elastic: Bool) {
        pan(deltaX: deltaX, deltaY: deltaY, isGesture: false, isDeceleration: false, elastic: elastic)
    }
    
    func pan(deltaX: CGFloat, deltaY: CGFloat, isGesture: Bool, isDeceleration: Bool, elastic: Bool) {
        
        onPanStart(deltaX: deltaX, deltaY: deltaY)
        
        if !elastic {
            func maxTX(_ minXLimit: CGFloat) -> CGFloat {
                return minXLimit - (contentView.frame.minX - contentView.transform.tx)
            }
            func maxTY(_ minYLimit: CGFloat) -> CGFloat {
                return minYLimit - (contentView.frame.minY - contentView.transform.ty)
            }
            contentView.transform.tx = max(maxTX(containerView.frame.width - contentView.frame.width), min(maxTX(0), contentView.transform.tx + deltaX))
            contentView.transform.ty = max(maxTY(containerView.frame.height - contentView.frame.height), min(maxTY(0), contentView.transform.ty + deltaY))
            
        } else {
            contentView.transform.tx = contentView.transform.tx + deltaX
            contentView.transform.ty = contentView.transform.ty + deltaY
        }

        onPanFinish(transX: transX, transY: transY, deltaX: deltaX, deltaY: deltaY, isGesture: isGesture, isDeceleration: isDeceleration)
    }
}
