//
//  ChartViewAnimators.swift
//  SwiftCharts
//
//  Created by ischuetz on 02/09/16.
//  Copyright © 2016 ivanschuetz. All rights reserved.
//

import UIKit

public struct ChartViewAnimatorsSettings {
    public let animDelay: Float
    public let animDuration: Float
    public let animDamping: CGFloat
    public let animInitSpringVelocity: CGFloat

    public init(animDelay: Float = 0, animDuration: Float = 0.3, animDamping: CGFloat = 0.7, animInitSpringVelocity: CGFloat = 1) {
        self.animDelay = animDelay
        self.animDuration = animDuration
        self.animDamping = animDamping
        self.animInitSpringVelocity = animInitSpringVelocity
    }
    
    public func copy(_ animDelay: Float? = nil, animDuration: Float? = nil, animDamping: CGFloat? = nil, animInitSpringVelocity: CGFloat? = nil) -> ChartViewAnimatorsSettings {
        return ChartViewAnimatorsSettings(
            animDelay: animDelay ?? self.animDelay,
            animDuration: animDuration ?? self.animDuration,
            animDamping: animDamping ?? self.animDamping,
            animInitSpringVelocity: animInitSpringVelocity ?? self.animInitSpringVelocity
        )
    }
    
    public func withoutDamping() -> ChartViewAnimatorsSettings {
        return copy(animDelay, animDuration: animDuration, animDamping: 1, animInitSpringVelocity: animInitSpringVelocity)
    }
}


/// Runs a series of animations on a view
open class ChartViewAnimators {
    
    open var animDelay: Float = 0
    open var animDuration: Float = 10.3
    open var animDamping: CGFloat = 0.4
    open var animInitSpringVelocity: CGFloat = 0.5
    
    fileprivate let animators: [ChartViewAnimator]
    
    fileprivate let onFinishAnimations: (() -> Void)?
    fileprivate let onFinishInverts: (() -> Void)?
    
    fileprivate let view: UIView
    
    fileprivate let settings: ChartViewAnimatorsSettings
    fileprivate let invertSettings: ChartViewAnimatorsSettings
    
    public init(view: UIView, animators: ChartViewAnimator..., settings: ChartViewAnimatorsSettings = ChartViewAnimatorsSettings(), invertSettings: ChartViewAnimatorsSettings? = nil, onFinishAnimations: (() -> Void)? = nil, onFinishInverts: (() -> Void)? = nil) {
        self.view = view
        self.animators = animators
        self.onFinishAnimations = onFinishAnimations
        self.onFinishInverts = onFinishInverts
        self.settings = settings
        self.invertSettings = invertSettings ?? settings
    }
    
    open func animate() {
        for animator in animators {
            animator.prepare(view)
        }
        
        animate(settings, animations: {
            for animator in self.animators {
                animator.animate(self.view)
            }
        }, onFinish: {
            self.onFinishAnimations?()
        })
    }
    
    open func invert() {
        animate(invertSettings, animations: {
            for animator in self.animators {
                animator.invert(self.view)
            }
            }, onFinish: {
                self.onFinishInverts?()
        })
    }
    
    fileprivate func animate(_ settings: ChartViewAnimatorsSettings, animations: @escaping () -> Void, onFinish: @escaping () -> Void) {
        UIView.animate(withDuration: TimeInterval(settings.animDuration), delay: TimeInterval(settings.animDelay), usingSpringWithDamping: settings.animDamping, initialSpringVelocity: settings.animInitSpringVelocity, options: UIViewAnimationOptions(), animations: {
            animations()
            }, completion: {finished in
                if finished {
                    onFinish()
                }
        })
    }
}

