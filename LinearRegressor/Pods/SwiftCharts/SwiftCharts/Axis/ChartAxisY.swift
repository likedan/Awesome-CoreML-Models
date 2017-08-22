//
//  ChartAxisY.swift
//  SwiftCharts
//
//  Created by ischuetz on 26/06/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import UIKit

open class ChartAxisY: ChartAxis {
    
    open override var length: Double {
        return last - first
    }
    
    open override var screenLength: CGFloat {
        return firstScreen - lastScreen
    }

    open override var screenLengthInit: CGFloat {
        return firstScreenInit - lastScreenInit
    }
    
    open override var visibleLength: Double {
        return lastVisible - firstVisible
    }
    
    open override var visibleScreenLength: CGFloat {
        return firstVisibleScreen - lastVisibleScreen
    }
    
    open override func screenLocForScalar(_ scalar: Double) -> CGFloat {
        return firstScreen - internalScreenLocForScalar(scalar)
    }
    
    open override func innerScreenLocForScalar(_ scalar: Double) -> CGFloat {
        return screenLength - internalScreenLocForScalar(scalar)
    }
    
    open override func scalarForScreenLoc(_ screenLoc: CGFloat) -> Double {
        return Double(-(screenLoc - firstScreen) * modelToScreenRatio) + first
    }
    
    open override func innerScalarForScreenLoc(_ screenLoc: CGFloat) -> Double {
        return length + Double(-screenLoc * modelToScreenRatio) + first
    }
    
    open override func screenToModelLength(_ screenLength: CGFloat) -> Double {
        return super.screenToModelLength(screenLength) * -1
    }
    
    open override func modelToScreenLength(_ modelLength: Double) -> CGFloat {
        return super.modelToScreenLength(modelLength) * -1
    }
    
    open override var firstModelValueInBounds: Double {
        return firstVisible + screenToModelLength(fixedPaddingFirstScreen ?? paddingFirstScreen)
    }
    
    open override var lastModelValueInBounds: Double {
        return lastVisible - screenToModelLength(fixedPaddingLastScreen ?? paddingLastScreen)
    }
    
    override func zoom(_ x: CGFloat, y: CGFloat, centerX: CGFloat, centerY: CGFloat, elastic: Bool) {
        
        // Zoom around center of gesture. Uses center as anchor point dividing the line in 2 segments which are scaled proportionally.
        let segment1 = firstScreen - centerY
        let segment2 = centerY - lastScreen
        let deltaSegment1 = (segment1 * y) - segment1
        let deltaSegment2 = (segment2 * y) - segment2
        let newOriginY = firstScreen + deltaSegment1
        let newEndY = lastScreen - deltaSegment2
        
        if elastic {
            firstScreen = newOriginY
            lastScreen = newEndY
        } else {
            keepInBoundaries(newOriginY, newEndX: newEndY)
        }
    }
    
    override func keepInBoundaries() {
        keepInBoundaries(firstScreen, newEndX: lastScreen)
    }
    
    fileprivate func keepInBoundaries(_ newOriginX: CGFloat, newEndX: CGFloat) {
        var newOriginY = newOriginX
        var newEndY = newEndX
        
        if newEndY > lastScreenInit {
            let delta = newEndY - lastScreenInit
            newEndY = lastScreenInit
            newOriginY = newOriginY - delta
        }
        
        if newOriginY < firstScreenInit {
            let delta = firstScreenInit - newOriginY
            newOriginY = firstScreenInit
            newEndY = newEndY + delta
        }
        
        if newOriginY - newEndY > firstScreenInit - lastScreenInit { // new length > original length
            firstScreen = newOriginY
            lastScreen = newEndY
            
            // if new origin is above origin, move it back
            let offsetOriginY = firstScreenInit - firstScreen
            if offsetOriginY > 0 {
                firstScreen = firstScreen + offsetOriginY
                lastScreen = lastScreen + offsetOriginY
            }
            
        } else { // possible correction
            firstScreen = firstScreenInit
            lastScreen = lastScreenInit
        }
    }
    
    override func pan(_ deltaX: CGFloat, deltaY: CGFloat, elastic: Bool) {
        
        let length = screenLength
        
        let (newOriginY, newEndY): (CGFloat, CGFloat) = {
            
            if deltaY < 0 { // scrolls up
                let tryY = firstScreen + deltaY
                let originY = elastic ? tryY : max(firstScreenInit, tryY)
                let endY = originY - length
                return (originY, endY)
                
            } else if deltaY > 0 { // scrolls down
                let tryY = lastScreen + deltaY
                let endY = elastic ? tryY : min(lastScreenInit, tryY)
                let originY = endY + length
                return (originY, endY)
                
            } else {
                return (firstScreen, lastScreen)
            }
        }()
        
        firstScreen = newOriginY
        lastScreen = newEndY
    }
    
    override func toModelInner(_ screenLoc: CGFloat) -> Double {
        let modelInner = Double(screenLoc - lastScreenInit - paddingLastScreen) * innerRatio + firstInit
        return lastInit - modelInner + firstInit // invert
    }
    
    override func zoom(_ scaleX: CGFloat, scaleY: CGFloat, centerX: CGFloat, centerY: CGFloat, elastic: Bool) {
        zoom(scaleX, y: scaleY / CGFloat(zoomFactor), centerX: centerX, centerY: centerY, elastic: elastic)
    }
    
    override func isInBoundaries(_ screenCenter: CGFloat, screenSize: CGSize) -> Bool {
        return screenCenter - screenSize.height / 2 >= lastVisibleScreen && screenCenter + screenSize.height / 2 <= firstVisibleScreen
    }
}