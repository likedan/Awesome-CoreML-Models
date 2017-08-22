//
//  ChartPointViewBarStacked.swift
//  Examples
//
//  Created by ischuetz on 15/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public struct TappedChartPointViewBarStacked {
    public let barView: ChartPointViewBarStacked
    public let stackFrame: (index: Int, view: UIView, viewFrameRelativeToBarSuperview: CGRect)?
}


private class ChartBarStackFrameView: UIView {
    
    var isSelected: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public typealias ChartPointViewBarStackedFrame = (rect: CGRect, color: UIColor)

open class ChartPointViewBarStacked: ChartPointViewBar {
    

    fileprivate var stackViews: [(index: Int, view: ChartBarStackFrameView, targetFrame: CGRect)] = []
    
    var stackFrameSelectionViewUpdater: ChartViewSelector?
    
    var stackedTapHandler: ((TappedChartPointViewBarStacked) -> Void)? {
        didSet {
            if stackedTapHandler != nil && gestureRecognizers?.isEmpty ?? true {
                enableTap()
            }
        }
    }
    
    public required init(p1: CGPoint, p2: CGPoint, width: CGFloat, bgColor: UIColor?, stackFrames: [ChartPointViewBarStackedFrame], settings: ChartBarViewSettings, stackFrameSelectionViewUpdater: ChartViewSelector? = nil) {
        self.stackFrameSelectionViewUpdater = stackFrameSelectionViewUpdater

        super.init(p1: p1, p2: p2, width: width, bgColor: bgColor, settings: settings)
        
        for (index, stackFrame) in stackFrames.enumerated() {
            let (targetFrame, firstFrame): (CGRect, CGRect) = {
                if isHorizontal {
                    let initFrame = CGRect(x: 0, y: stackFrame.rect.origin.y, width: 0, height: stackFrame.rect.size.height)
                    return (stackFrame.rect, initFrame)
                    
                } else { // vertical
                    let initFrame = CGRect(x: stackFrame.rect.origin.x, y: self.frame.height, width: stackFrame.rect.size.width, height: 0)
                    return (stackFrame.rect, initFrame)
                }
            }()
            
            let v = ChartBarStackFrameView(frame: firstFrame)
            v.backgroundColor = stackFrame.color
            
            if settings.cornerRadius > 0 {
                let corners: UIRectCorner
                
                if (stackFrames.count == 1) {
                    corners = UIRectCorner.allCorners
                } else {
                    switch (index, isHorizontal) {
                    case (0, true):
                        corners = [.bottomLeft, .topLeft]
                    case (0, false):
                        corners = [.bottomLeft, .bottomRight]
                    case (stackFrames.count - 1, true):
                        corners = [.topRight, .bottomRight]
                    case (stackFrames.count - 1, false):
                        corners = [.topLeft, .topRight]
                    default:
                        corners = []
                    }
                }
                
                let bounds = CGRect(x: 0, y: 0, width: stackFrame.rect.width, height: stackFrame.rect.height)
                
                let path = UIBezierPath(
                    roundedRect: bounds,
                    byRoundingCorners: corners,
                    cornerRadii: CGSize(width: settings.cornerRadius, height: settings.cornerRadius)
                )
                
                if !corners.isEmpty {
                    let maskLayer = CAShapeLayer()
                    maskLayer.frame = bounds
                    maskLayer.path = path.cgPath
                    v.layer.mask = maskLayer
                }
            }
            
            stackViews.append((index, v, targetFrame))
            addSubview(v)
        }
    }
    
    override func onTap(_ sender: UITapGestureRecognizer) {
        let loc = sender.location(in: self)
        guard let tappedStackFrame = (stackViews.filter{$0.view.frame.contains(loc)}.first) else {
            stackedTapHandler?(TappedChartPointViewBarStacked(barView: self, stackFrame: nil))
            return
        }
        
        toggleSelection()
        tappedStackFrame.view.isSelected = !tappedStackFrame.view.isSelected
        
        let f = tappedStackFrame.view.frame.offsetBy(dx: frame.origin.x, dy: frame.origin.y)
        
        stackFrameSelectionViewUpdater?.displaySelected(tappedStackFrame.view, selected: tappedStackFrame.view.isSelected)
        stackedTapHandler?(TappedChartPointViewBarStacked(barView: self, stackFrame: (tappedStackFrame.index, tappedStackFrame.view, f)))
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public required init(p1: CGPoint, p2: CGPoint, width: CGFloat, bgColor: UIColor?, settings: ChartBarViewSettings) {
        super.init(p1: p1, p2: p2, width: width, bgColor: bgColor, settings: settings)
    }
    
    
    override open func didMoveToSuperview() {
        
        func targetState() {
            frame = targetFrame
            for stackFrame in stackViews {
                stackFrame.view.frame = stackFrame.targetFrame
            }
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
