//
//  ChartAxisX.swift
//  SwiftCharts
//
//  Created by ischuetz on 26/06/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import UIKit

open class ChartAxisX: ChartAxis {
    
    open override var length: Double {
        return last - first
    }
    
    open override var screenLength: CGFloat {
        return lastScreen - firstScreen
    }

    open override var screenLengthInit: CGFloat {
        return lastScreenInit - firstScreenInit
    }
    
    open override var visibleLength: Double {
        return lastVisible - firstVisible
    }
    
    open override var visibleScreenLength: CGFloat {
        return lastVisibleScreen - firstVisibleScreen
    }
    
    open override func screenLocForScalar(_ scalar: Double) -> CGFloat {
        return firstScreen + internalScreenLocForScalar(scalar)
    }
    
    open override func innerScreenLocForScalar(_ scalar: Double) -> CGFloat {
        return internalScreenLocForScalar(scalar)
    }
    
    open override func scalarForScreenLoc(_ screenLoc: CGFloat) -> Double {
        return Double((screenLoc - firstScreen) * modelToScreenRatio) + first
    }
    
    open override func innerScalarForScreenLoc(_ screenLoc: CGFloat) -> Double {
        return Double(screenLoc * modelToScreenRatio) + first
    }
    
    open override var firstModelValueInBounds: Double {
        return firstVisible + screenToModelLength(fixedPaddingFirstScreen ?? paddingFirstScreen)
    }
    
    open override var lastModelValueInBounds: Double {
        return lastVisible - screenToModelLength(fixedPaddingLastScreen ?? paddingLastScreen)
    }

    override func zoom(_ x: CGFloat, y: CGFloat, centerX: CGFloat, centerY: CGFloat, elastic: Bool) {
        
        // Zoom around center of gesture. Uses center as anchor point dividing the line in 2 segments which are scaled proportionally.
        let segment1 = centerX - firstScreen
        let segment2 = lastScreen - centerX
        let deltaSegment1 = (segment1 * x) - segment1
        let deltaSegment2 = (segment2 * x) - segment2
        let newOriginX = firstScreen - deltaSegment1
        let newEndX = lastScreen + deltaSegment2
        
        if elastic {
            firstScreen = newOriginX
            lastScreen = newEndX
        } else {
            keepInBoundaries(newOriginX, newEndX: newEndX)
        }
    }
    
    fileprivate func keepInBoundaries(_ newOriginX: CGFloat, newEndX: CGFloat) {
        
        var newOriginX = newOriginX
        var newEndX = newEndX
        
        if newEndX < lastScreenInit {
            let delta = lastScreenInit - newEndX
            newEndX = lastScreenInit
            newOriginX = newOriginX + delta
        }
        
        if newOriginX > firstScreenInit {
            let delta = newOriginX - firstScreenInit
            newOriginX = firstScreenInit
            newEndX = newEndX - delta
        }
        
        if newEndX - newOriginX > lastScreenInit - firstScreenInit { // new length > original length
            firstScreen = newOriginX
            lastScreen = newEndX
            
            // if p1 is to the right of origin, move it back
            let offsetOriginX = firstScreen - firstScreenInit
            if offsetOriginX > 0 {
                firstScreen = firstScreen - offsetOriginX
                lastScreen = lastScreen - offsetOriginX
            }
            
        } else { // possible correction
            firstScreen = firstScreenInit
            lastScreen = lastScreenInit
        }
    }
    
    override func keepInBoundaries() {
        keepInBoundaries(firstScreen, newEndX: lastScreen)
    }
    
    override func pan(_ deltaX: CGFloat, deltaY: CGFloat, elastic: Bool) {
        
        let length = screenLength
        
        let (newOriginX, newEndX): (CGFloat, CGFloat) = {
            
            if deltaX < 0 { // scrolls left
                let tryX = lastScreen + deltaX
                let endX = elastic ? tryX : max(lastScreenInit, tryX)
                let originX = endX - length
                return (originX, endX)
                
            } else if deltaX > 0 {  // scrolls right
                let tryX = firstScreen + deltaX
                let originX = elastic ? tryX : min(tryX, firstScreenInit)
                let endX = originX + length
                return (originX, endX)
                
            } else {
                return (firstScreen, lastScreen)
            }
        }()
        
        firstScreen = newOriginX
        lastScreen = newEndX
    }
    
    override func zoom(_ scaleX: CGFloat, scaleY: CGFloat, centerX: CGFloat, centerY: CGFloat, elastic: Bool) {
        zoom(scaleX / CGFloat(zoomFactor), y: scaleY, centerX: centerX, centerY: centerY, elastic: elastic)
    }
 
    override func toModelInner(_ screenLoc: CGFloat) -> Double {
        return Double(screenLoc - firstScreenInit - paddingFirstScreen) * innerRatio + firstInit
    }
    
    override func isInBoundaries(_ screenCenter: CGFloat, screenSize: CGSize) -> Bool {
        return screenCenter - screenSize.width / 2 >= firstVisibleScreen && screenCenter + screenSize.width / 2 <= lastVisibleScreen
    }
    
}
