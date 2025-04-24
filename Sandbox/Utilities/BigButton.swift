//
//  BigButton.swift
//  Sandbox
//
//  Created by Akos Polster on 24/04/2025.
//

import UIKit

/// Big blue button
class BigButton: UIButton {
    /// Initialize with a title and an action, called on .touchUpInside
    init(title: String, action: @escaping () -> Void) {
        self.action = action
        super.init(frame: .zero)
        backgroundColor = .systemBlue
        setTitle(title, for: .normal)
        setTitleColor(.white, for: .normal)
        setTitleColor(.lightText, for: .disabled)
        layer.cornerRadius = 6
        contentEdgeInsets = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        tintColor = .white
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isEnabled: Bool {
        didSet {
            alpha = isEnabled ? 1.0 : 0.5
        }
    }

    override var isUserInteractionEnabled: Bool {
        didSet {
            alpha = isUserInteractionEnabled ? 1.0 : 0.5
        }
    }

    // MARK: - Internal

    private let action: () -> Void
    @objc private func handleTap() {
        action()
    }
}
