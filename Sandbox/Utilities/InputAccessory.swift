//
//  InputAccessory.swift
//  Sandbox
//
//  Created by Akos Polster on 07/05/2026.
//

import UIKit

class InputAccessoryButtonItem: NSObject {
    let button: UIButton
    private var buttonAction: (() -> Void)?

    init(title: String, action: @escaping () -> Void) {
        self.buttonAction = action
        let textColor = UIColor { $0.userInterfaceStyle == .dark ? .white : .black }
        let btn = UIButton(type: .custom)
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(textColor, for: .normal)
        btn.sizeToFit()
        self.button = btn
        super.init()
        btn.addTarget(self, action: #selector(handleAction), for: .touchUpInside)
    }

    @objc private func handleAction() {
        buttonAction?()
    }
}

class InputAccessoryBar: UIView {
    private var items: [InputAccessoryButtonItem] = []

    init(items: [InputAccessoryButtonItem]) {
        self.items = items
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        autoresizingMask = .flexibleWidth
        backgroundColor = UIColor {
            $0.userInterfaceStyle == .dark ?
                UIColor(red: 43.0/255.0, green: 43.0/255.0, blue: 43.0/255.0, alpha: 1) :
                UIColor(red: 222.0/255.0, green: 224.0/255.0, blue: 228.0/255.0, alpha: 1)
        }
        let stack = UIStackView(arrangedSubviews: items.map(\.button))
        stack.distribution = .equalSpacing
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

