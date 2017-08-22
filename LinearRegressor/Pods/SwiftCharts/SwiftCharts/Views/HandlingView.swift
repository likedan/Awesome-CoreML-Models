//
//  ChartItemView.swift
//  swift_charts
//
//  Created by ischuetz on 15/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

// Convenience view to handle events without subclassing
open class HandlingView: UIView {
    
    open var movedToSuperViewHandler: (() -> ())?
    open var touchHandler: (() -> ())?

    override open func didMoveToSuperview() {
        movedToSuperViewHandler?()
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchHandler?()
    }
}
