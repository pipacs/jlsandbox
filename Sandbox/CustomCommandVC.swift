//
//  CustomCommandVC.swift
//  Sandbox
//
//  Created by Akos Polster on 06/05/2026.
//

import UIKit
import Foundation
import JL_BLEKit

/// Sends/receives custom RCSP commands
class CustomCommandVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Custom RCSP Commands"
        view.backgroundColor = .systemBackground
        let backgroundTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap))
        backgroundTapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(backgroundTapGesture)
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
        JieliManager.shared.customMessageObserver = receiveMessage
    }

    // MARK: - Internal

    private lazy var sendButton = BigButton(title: "Send") { [weak self] in self?.sendCommand(text: self?.input.text) }
    private lazy var clearButton = BigButton(title: "Clear") { [weak self] in self?.output.text = nil }
    private lazy var input: UITextField = {
        let field = UITextField()
        field.placeholder = "AB AD 1D EA"
        field.autocorrectionType = .no
        field.spellCheckingType = .no
        field.keyboardType = .decimalPad
        field.addTarget(self, action: #selector(endEditing), for: .editingDidEndOnExit)
        let digitItems: [InputAccessoryButtonItem] = ["A", "B", "C", "D", "E", "F"]
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

    @objc private func handleBackgroundTap() {
        input.resignFirstResponder()
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
                self?.showText(data.hexString, direction: "🎧◀️")
            } else {
                Logger.logError("Failed to send custom data, status: \(status)")
            }
        }
    }

    private func receiveMessage(_ message: Data) {
        showText(message.hexString, direction: "🎧▶️")
    }

    private func showText(_ text: String, direction: String) {
        let lines = text
            .replacingOccurrences(of: "\r\n", with: "\n")
            .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let newText = dateFormatter.string(from: Date()) + " " + direction + " " + lines
        if let currentText = output.text {
            output.text = newText + "\n" + currentText
        } else {
            output.text = newText
        }
    }
}
