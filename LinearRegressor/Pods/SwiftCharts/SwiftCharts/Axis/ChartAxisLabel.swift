//
//  ChartAxisLabel.swift
//  swift_charts
//
//  Created by ischuetz on 01/03/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

/// A model of an axis label
open class ChartAxisLabel {

    /// Displayed text. Can be truncated.
    open let text: String
    
    open let settings: ChartLabelSettings

    open fileprivate(set) var originalText: String
    
    var hidden: Bool = false

    open lazy private(set) var textSizeNonRotated: CGSize = {
        return self.text.size(self.settings.font)
    }()
    
    /// The size of the bounding rectangle for the axis label, taking into account the font and rotation it will be drawn with
    open lazy private(set) var textSize: CGSize = {
        let size = self.textSizeNonRotated
        if self.settings.rotation =~ 0 {
            return size
        } else {
            return CGRect(x: 0, y: 0, width: size.width, height: size.height).boundingRectAfterRotating(radians: self.settings.rotation * CGFloat.pi / 180.0).size
        }
    }()
    
    public init(text: String, settings: ChartLabelSettings) {
        self.text = text
        self.settings = settings
        self.originalText = text
    }
    
    func copy(_ text: String? = nil, settings: ChartLabelSettings? = nil, originalText: String? = nil, hidden: Bool? = nil) -> ChartAxisLabel {
        let label = ChartAxisLabel(
            text: text ?? self.text,
            settings: settings ?? self.settings
        )
        label.originalText = originalText ?? self.originalText
        label.hidden = hidden ?? self.hidden
        return label
    }
}

extension ChartAxisLabel: CustomDebugStringConvertible {
    public var debugDescription: String {
        return [
            "text": text,
            "settings": settings
        ]
            .debugDescription
    }
}
