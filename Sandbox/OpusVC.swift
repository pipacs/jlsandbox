//
//  OpusVC.swift
//  Sandbox
//
//  Created by Akos Polster on 02/02/2026.
//

import UIKit
import Foundation

class OpusVC: UIViewController, UIDocumentPickerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "GET Opus Data"
        view.backgroundColor = .systemBackground
        let streamLabel = Label(text: "Opus data:")
        view.addSubviewsForAutolayout(streamLabel, streamData, startButton, stopButton)
        NSLayoutConstraint.activate([
            startButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            startButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            startButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            stopButton.topAnchor.constraint(equalTo: startButton.bottomAnchor, constant: 20),
            stopButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stopButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            streamLabel.topAnchor.constraint(equalTo: stopButton.bottomAnchor, constant: 20),
            streamLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            streamLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            streamData.topAnchor.constraint(equalTo: streamLabel.bottomAnchor, constant: 20),
            streamData.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            streamData.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }

    // MARK: - Internal

    private lazy var startButton = BigButton(title: "Start Opus Stream") { [weak self] in
        self?.startStream()
    }

    private lazy var stopButton: BigButton = {
        let button = BigButton(title: "Stop Opus Stream") { [weak self] in
            self?.stopStream()
        }
        button.isUserInteractionEnabled = false
        return button
    }()

    private lazy var streamData = Label()

    private func startStream() {
        Logger.log()
        startButton.isUserInteractionEnabled = false
        stopButton.isUserInteractionEnabled = true
        streamData.text = "(none)"
    }

    private func stopStream() {
        Logger.log()
        startButton.isUserInteractionEnabled = true
        stopButton.isUserInteractionEnabled = false
    }
}
