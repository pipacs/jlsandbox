//
//  CustomCommandVC.swift
//  Sandbox
//
//  Created by Akos Polster on 06/05/2026.
//

import UIKit
import Foundation
import JL_BLEKit

class CustomCommandVC: UIViewController {
    deinit {
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Custom Commands"
        view.backgroundColor = .systemBackground
        let outputLabel = Label(text: "Commands from device:")
        view.addSubviewsForAutolayout(sendButton, clearButton, input, outputLabel, output)
        NSLayoutConstraint.activate([
            clearButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            clearButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            clearButton.widthAnchor.constraint(equalToConstant: 90),

            sendButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            sendButton.trailingAnchor.constraint(equalTo: clearButton.leadingAnchor, constant: -10),
            sendButton.widthAnchor.constraint(equalToConstant: 90),

            input.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            input.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -20),
            input.centerYAnchor.constraint(equalTo: sendButton.centerYAnchor),

            outputLabel.topAnchor.constraint(equalTo: sendButton.bottomAnchor, constant: 40),
            outputLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),

            output.topAnchor.constraint(equalTo: outputLabel.bottomAnchor, constant: 20),
            output.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            output.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            output.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        JieliManager.shared.customMessageObserver = receiveMessage
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        JieliManager.shared.customMessageObserver = nil
    }

    // MARK: - Internal

    private lazy var sendButton = BigButton(title: "Send") { [weak self] in self?.endEditing() }
    private lazy var clearButton = BigButton(title: "Clear") { [weak self] in self?.output.text = nil }
    private lazy var input: UITextField = {
        let field = UITextField()
        field.placeholder = "AB AD 1D EA"
        field.autocorrectionType = .no
        field.spellCheckingType = .no
        field.keyboardType = .decimalPad
        field.addTarget(self, action: #selector(endEditing), for: .editingDidEndOnExit)
        let digitItems: [InputAccessoryButtonItem] = ["a", "b", "c", "d", "e", "f"]
            .map { digit in InputAccessoryButtonItem(title: digit) { [weak self] in self?.insertInputText(digit) } }
        let spaceItem = InputAccessoryButtonItem(title: "space") { [weak self] in self?.insertInputText(" ") }
        field.inputAccessoryView = InputAccessoryBar(items: digitItems + [spaceItem])
        return field
    }()
    private lazy var output: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.isSelectable = true
        textView.font = UIFont.monospacedSystemFont(
            ofSize: UIFont.preferredFont(forTextStyle: .caption2).pointSize,
            weight: .regular
        )
        textView.adjustsFontForContentSizeCategory = true
        textView.backgroundColor = .secondarySystemBackground
        textView.layer.cornerRadius = 10
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        return textView
    }()
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.S"
        return formatter
    }()

    @objc private func endEditing() {
        input.resignFirstResponder()
        sendCommand(text: input.text)
    }

    private func insertInputText(_ text: String) {
        if let textRange = input.selectedTextRange {
            input.replace(textRange, withText: text)
        } else {
            input.insertText(text)
        }
    }

    private func sendCommand(text: String?) {
        guard
            let commandText = text?.replacingOccurrences(of: "[\\s]+", with: "", options: .regularExpression),
            !commandText.isEmpty else {
            return
        }
        guard let data = commandText.hexadecimal else {
            Logger.logError("Invalid hex string: \"\(commandText)\"")
            return
        }
        JieliManager.shared.jlCustomManager.cmdCustomData(data, isNeedResponse: false) { [weak self] status, _, _ in
            if status == .success {
                Logger.log("sendCustomData: success")
                self?.showOutgoingText(data.hexString)
            } else {
                Logger.logError("Failed to send custom data, status: \(status)")
            }
        }
    }

    private func receiveMessage(_ message: Data) {
        showIncomingText(message.hexString)
    }

    private func showOutgoingText(_ text: String) {
        let date = dateFormatter.string(from: Date())
        let lines = text
            .replacingOccurrences(of: "\r\n", with: "\n")
            .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        showText("\(date) 🎧⬅️ \(lines)\n")
    }

    private func showIncomingText(_ text: String) {
        let date = dateFormatter.string(from: Date())
        let lines = text
            .replacingOccurrences(of: "\r\n", with: "\n")
            .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        showText("\(date) 🎧➡️ \(lines)\n")
    }

    private func showText(_ text: String) {
        if let currentText = output.text {
            output.text = text + "\n" + currentText
        } else {
            output.text = text
        }
    }
}

/// A button item on an input accessory bar
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

/// Input accessory bar
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

extension String {
    private static let hexByteRegEx = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)

    /// Hex-encoded string as Data
    var hexadecimal: Data? {
        var data = Data(capacity: count / 2)
        let preprocessed = self.replacingOccurrences(of: "0[xX]", with: "", options: .regularExpression)
        Self.hexByteRegEx.enumerateMatches(in: preprocessed, range: NSRange(startIndex..., in: preprocessed)) { match, _, _ in
            let byteString = (preprocessed as NSString).substring(with: match!.range)
            let num = UInt8(byteString, radix: 16)!
            data.append(num)
        }
        guard !data.isEmpty else { return nil }
        return data
    }
}
