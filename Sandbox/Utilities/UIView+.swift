//
//  UIView+.swift
//  Sandbox
//
//  Created by Akos Polster on 24/04/2025.
//

import UIKit

/// Entity that can provide top, bottom, leading and trailing anchors
public protocol AnchorProvider {
    var topAnchor: NSLayoutYAxisAnchor { get }
    var bottomAnchor: NSLayoutYAxisAnchor { get }
    var leadingAnchor: NSLayoutXAxisAnchor { get }
    var trailingAnchor: NSLayoutXAxisAnchor { get }
}

extension UIView: AnchorProvider { }
extension UILayoutGuide: AnchorProvider { }

extension UIView {
    /// Prepare subviews for autolayout and add them to self
    public func addSubviewsForAutolayout(_ subviews: [UIView]) {
        for view in subviews {
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
        }
    }

    /// Prepare subviews for autolayout and add them to self
    public func addSubviewsForAutolayout(_ subviews: UIView...) {
        addSubviewsForAutolayout(subviews)
    }

    /// Anchor the view's edges to the other view's corresponding edges
    public func anchorEdges(to view: AnchorProvider, insets: UIEdgeInsets = .zero) {
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: view.topAnchor, constant: insets.top),
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -insets.bottom),
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: insets.left),
            trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -insets.right)
        ])
    }

    /// Create a flexible horizontal spacer
    static func makeSpacer() -> UIView {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.setContentHuggingPriority(.fittingSizeLevel, for: .horizontal)
        view.setContentCompressionResistancePriority(.fittingSizeLevel, for: .horizontal)
        return view
    }
}
