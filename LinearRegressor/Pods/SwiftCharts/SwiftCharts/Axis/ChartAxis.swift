//
//  ChartAxis.swift
//  SwiftCharts
//
//  Created by ischuetz on 25/06/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import UIKit

open class ChartAxis: CustomStringConvertible {
    
    /// First model value
    open internal(set) var first: Double
    
    /// Last model value
    open internal(set) var last: Double
    
    // Screen location (relative to chart view's frame) corresponding to first model value
    open internal(set) var firstScreen: CGFloat
    
    // Screen location (relative to chart view's frame) corresponding to last model value
    open internal(set) var lastScreen: CGFloat
    
    open internal(set) var firstVisibleScreen: CGFloat
    open internal(set) var lastVisibleScreen: CGFloat
    
    open let paddingFirstScreen: CGFloat
    open let paddingLastScreen: CGFloat
    
    /// Optional fixed padding value which overwrites paddingFirstScreen/paddingLastScreen when determining if model values are in bounds. This is useful e.g. when setting an initial zoom level, and scaling the padding proportionally such that it appears constant for different zoom levels. In this case it may be necessary to store the un-scaled padding in these variables to keep the bounds constant.
    open var fixedPaddingFirstScreen: CGFloat?
    open var fixedPaddingLastScreen: CGFloat?
    
    open var firstVisible: Double {
        return scalarForScreenLoc(firstVisibleScreen)
    }
    
    open var lastVisible: Double {
        return scalarForScreenLoc(lastVisibleScreen)
    }
    
    open var zoomFactor: Double {
        guard visibleLength != 0 else {return 1}
        return abs(length / visibleLength)
    }
    
    // The space between first and last model values. Can be negative (used for mirrored axes)
    open var length: Double {
        fatalError("override")
    }
    
    // The space between first and last screen locations. Can be negative (used for mirrored axes)
    open var screenLength: CGFloat {
        fatalError("override")
    }
    
    open var screenLengthInit: CGFloat {
        fatalError("override")
    }
    
    open var visibleLength: Double {
        fatalError("override")
    }
    
    open var visibleScreenLength: CGFloat {
        fatalError("override")
    }
    
    open var screenToModelRatio: CGFloat {
        return screenLength / CGFloat(length)
    }
    
    open var modelToScreenRatio: CGFloat {
        return CGFloat(length) / screenLength
    }
    
    var firstInit: Double
    var lastInit: Double
    var firstScreenInit: CGFloat
    var lastScreenInit: CGFloat
    
    public required init(first: Double, last: Double, firstScreen: CGFloat, lastScreen: CGFloat, paddingFirstScreen: CGFloat = 0, paddingLastScreen: CGFloat = 0, fixedPaddingFirstScreen: CGFloat? = nil, fixedPaddingLastScreen: CGFloat? = nil) {
        self.first = first
        self.last = last
        self.firstInit = first
        self.lastInit = last
        self.firstScreen = firstScreen
        self.lastScreen = lastScreen
        self.firstScreenInit = firstScreen
        self.lastScreenInit = lastScreen
        self.paddingFirstScreen = paddingFirstScreen
        self.paddingLastScreen = paddingLastScreen
        self.fixedPaddingFirstScreen = fixedPaddingFirstScreen
        self.fixedPaddingLastScreen = fixedPaddingLastScreen
        self.firstVisibleScreen = firstScreen
        self.lastVisibleScreen = lastScreen
        
        adjustModelBoundariesForPadding()
    }
    
    /// Calculates screen location (relative to chart view's frame) of model value. It's not required that scalar is between first and last model values.
    open func screenLocForScalar(_ scalar: Double) -> CGFloat {
        fatalError("Override")
    }
    
    /// Calculates model value corresponding to screen location (relative to chart view's frame). It's not required that screenLoc is between firstScreen and lastScreen values.
    open func scalarForScreenLoc(_ screenLoc: CGFloat) -> Double {
        fatalError("Override")
    }
    
    /// Calculates screen location (relative to axis length) of model value. It's not required that scalar is between first and last model values.
    func internalScreenLocForScalar(_ scalar: Double) -> CGFloat {
        return CGFloat(scalar - first) * screenToModelRatio
    }
    
    // TODO rename content instead of inner
    // Calculate screen location (relative to axis length, taking into account inverted y axis). It's not required that scalar is between first and last model values.
    open func innerScreenLocForScalar(_ scalar: Double) -> CGFloat {
        fatalError("Override")
    }
    
    open func innerScalarForScreenLoc(_ screenLoc: CGFloat) -> Double {
        fatalError("Override")
    }
    
    func zoom(_ x: CGFloat, y: CGFloat, centerX: CGFloat, centerY: CGFloat, elastic: Bool) {
        fatalError("Override")
    }
    
    func zoom(_ scaleX: CGFloat, scaleY: CGFloat, centerX: CGFloat, centerY: CGFloat, elastic: Bool) {
        fatalError("Override")
    }

    func pan(_ deltaX: CGFloat, deltaY: CGFloat, elastic: Bool) {
        fatalError("Override")
    }
    
    open var transform: (scale: CGFloat, translation: CGFloat) {
        return (scale: CGFloat(zoomFactor), translation: firstScreenInit - firstScreen)
    }
    
    func offsetFirstScreen(_ offset: CGFloat) {
        firstScreen += offset
        firstScreenInit += offset
        firstVisibleScreen += offset
        
        adjustModelBoundariesForPadding()
    }

    func offsetLastScreen(_ offset: CGFloat) {
        lastScreen += offset
        lastScreenInit += offset
        lastVisibleScreen += offset
        
        adjustModelBoundariesForPadding()
    }
    
    open func screenToModelLength(_ screenLength: CGFloat) -> Double {
        return scalarForScreenLoc(screenLength) - scalarForScreenLoc(0)
    }
    
    open func modelToScreenLength(_ modelLength: Double) -> CGFloat {
        return screenLocForScalar(modelLength) - screenLocForScalar(0)
    }
    
    open var firstModelValueInBounds: Double {
        fatalError("Overrode")
    }
    
    open var lastModelValueInBounds: Double {
        fatalError("Overrode")
    }
    
    open var description: String {
        return "{\(type(of: self)), first: \(first), last: \(last), firstInit: \(firstInit), lastInit: \(lastInit), zoomFactor: \(zoomFactor), firstScreen: \(firstScreen), lastScreen: \(lastScreen), firstVisible: \(firstVisible), lastVisible: \(lastVisible), firstVisibleScreen: \(firstVisibleScreen), lastVisibleScreen: \(lastVisibleScreen), paddingFirstScreen: \(paddingFirstScreen), paddingLastScreen: \(paddingLastScreen), length: \(length), screenLength: \(screenLength), firstModelValueInBounds: \(firstModelValueInBounds), lastModelValueInBounds: \(lastModelValueInBounds))}"
    }
    
    var innerRatio: Double {
        return (lastInit - firstInit) / Double(screenLengthInit - paddingFirstScreen - paddingLastScreen)
    }
    
    func toModelInner(_ screenLoc: CGFloat) -> Double {
        fatalError("Override")
    }
    
    func isInBoundaries(_ screenCenter: CGFloat, screenSize: CGSize) -> Bool {
        fatalError("Override")
    }
    
    func keepInBoundaries() {
        fatalError("Override")
    }
    
    /// NOTE: this changes the model domain, which means that after this, view based chart points should be (re)generated using the updated ratio. For rendering layers this is not an issue since they request the position from the axis on each update. View based layers / content view children only update according to the transform of the parent, which is derived directly from the gestures and doesn't take into account the axes. This means in praxis that currently it's not possible to use view based layers together with padding and inner frame with varying size. Either the inner frame size has to be fixed, by setting fixed label size for all axes, or it must not have padding, or use a rendering based layer. TODO re-regenerate views on model domain update? This can lead though to stuterring when panning between labels of different sizes. Doing this at the end of the gesture would mean that during the gesture the chart points and axes can be not aligned correctly. Don't resize inner frame during the gesture (at least for view based layers)? In this case long labels would have to be cut during the gesture, and resize the frame / re-generate the chart points when the gesture ends.
    fileprivate func adjustModelBoundariesForPadding() {
        if paddingFirstScreen != 0 || paddingLastScreen != 0 {
            first = toModelInner(firstScreenInit)
            last = toModelInner(lastScreenInit)
        }
    }
    
    open func copy(_ first: Double? = nil, last: Double? = nil, firstScreen: CGFloat? = nil, lastScreen: CGFloat? = nil, paddingFirstScreen: CGFloat? = nil, paddingLastScreen: CGFloat? = nil, fixedPaddingFirstScreen: CGFloat? = nil, fixedPaddingLastScreen: CGFloat? = nil) -> ChartAxis {
        return type(of: self).init(
            first: first ?? self.first,
            last: last ?? self.last,
            firstScreen: firstScreen ?? self.firstScreen,
            lastScreen: lastScreen ?? self.lastScreen,
            paddingFirstScreen: paddingFirstScreen ?? self.paddingFirstScreen,
            paddingLastScreen: paddingLastScreen ?? self.paddingLastScreen,
            fixedPaddingFirstScreen:  fixedPaddingFirstScreen ?? self.fixedPaddingFirstScreen,
            fixedPaddingLastScreen:  fixedPaddingLastScreen ?? self.fixedPaddingLastScreen
        )
    }
}
