//
//  Label.swift
//  Sandbox
//
//  Created by Akos Polster on 24/04/2025.
//

import UIKit

/// Multi-line label with text and font configurable in initializer
class Label: UILabel {
    init(text: String? = nil, font: UIFont = UIFont.preferredFont(forTextStyle: .body)) {
        super.init(frame: .zero)
        self.numberOfLines = 0
        self.text = text
        self.font = font
        self.sizeToFit()
        self.setContentHuggingPriority(.required, for: .horizontal)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
