//
//  HandlingLabel.swift
//  Examples
//
//  Created by ischuetz on 18/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

// Convenience view to handle events without subclassing
open class HandlingLabel: UILabel {
        
    open var movedToSuperViewHandler: (() -> ())?
    open var touchHandler: (() -> ())?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    fileprivate func sharedInit() {
        isUserInteractionEnabled = true
    }
    
    override open func didMoveToSuperview() {
        movedToSuperViewHandler?()
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchHandler?()
    }
}
