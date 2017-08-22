//
//  ChartPointViewBar.swift
//  Examples
//
//  Created by ischuetz on 14/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public struct ChartBarViewSettings {
    
    let animDuration: Float
    let animDelay: Float
    
    let selectionViewUpdater: ChartViewSelector?
    
    let cornerRadius: CGFloat
    
    let delayInit: Bool
    
    public init(animDuration: Float = 0.5, animDelay: Float = 0, cornerRadius: CGFloat = 0, selectionViewUpdater: ChartViewSelector? = nil, delayInit: Bool = false) {
        self.animDuration = animDuration
        self.animDelay = animDelay
        self.cornerRadius = cornerRadius
        self.selectionViewUpdater = selectionViewUpdater
        self.delayInit = delayInit
    }
    
    public func copy(animDuration: Float? = nil, animDelay: Float? = nil, cornerRadius: CGFloat? = nil, selectionViewUpdater: ChartViewSelector? = nil) -> ChartBarViewSettings {
        return ChartBarViewSettings(
            animDuration: animDuration ?? self.animDuration,
            animDelay: animDelay ?? self.animDelay,
            cornerRadius: cornerRadius ?? self.cornerRadius,
            selectionViewUpdater: selectionViewUpdater ?? self.selectionViewUpdater
        )
    }
}

open class ChartPointViewBar: UIView {
    
    let targetFrame: CGRect

    var isSelected: Bool = false
    
    var tapHandler: ((ChartPointViewBar) -> Void)? {
        didSet {
            if tapHandler != nil && gestureRecognizers?.isEmpty ?? true {
                enableTap()
            }
        }
    }
    
    open let isHorizontal: Bool
    
    open let settings: ChartBarViewSettings
    
    public required init(p1: CGPoint, p2: CGPoint, width: CGFloat, bgColor: UIColor?, settings: ChartBarViewSettings) {
        
        let targetFrame = ChartPointViewBar.frame(p1, p2: p2, width: width)
        let firstFrame: CGRect = {
            if p1.y - p2.y =~ 0 { // horizontal
                return CGRect(x: targetFrame.origin.x, y: targetFrame.origin.y, width: 0, height: targetFrame.size.height)
            } else { // vertical
                return CGRect(x: targetFrame.origin.x, y: targetFrame.origin.y, width: targetFrame.size.width, height: 0)
            }
        }()
        
        self.targetFrame =  targetFrame
        self.settings = settings
        
        isHorizontal = p1.y == p2.y
        
        super.init(frame: firstFrame)
        
        backgroundColor = bgColor
        
        if settings.cornerRadius > 0 {
            layer.cornerRadius = settings.cornerRadius
        }
    }
    
    static func frame(_ p1: CGPoint, p2: CGPoint, width: CGFloat) -> CGRect {
        if p1.y - p2.y =~ 0 { // horizontal
            return CGRect(x: p1.x, y: p1.y - width / 2, width: p2.x - p1.x, height: width)
            
        } else { // vertical
            return CGRect(x: p1.x - width / 2, y: p1.y, width: width, height: p2.y - p1.y)
        }
    }
    
    func updateFrame(_ p1: CGPoint, p2: CGPoint) {
        frame = ChartPointViewBar.frame(p1, p2: p2, width: isHorizontal ? frame.height : frame.width)
    }
    
    func enableTap() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTap))
        addGestureRecognizer(tapRecognizer)
    }
    
    @objc func onTap(_ sender: UITapGestureRecognizer) {
        toggleSelection()
        tapHandler?(self)
    }
    
    func toggleSelection() {
        isSelected = !isSelected
        settings.selectionViewUpdater?.displaySelected(self, selected: isSelected)
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func didMoveToSuperview() {
        
        func targetState() {
            frame = targetFrame
            layoutIfNeeded()
        }
        
        if settings.animDuration =~ 0 {
            targetState()
        } else {
            UIView.animate(withDuration: CFTimeInterval(settings.animDuration), delay: CFTimeInterval(settings.animDelay), options: .curveEaseOut, animations: {
                targetState()
            }, completion: nil)
        }
    }
}
