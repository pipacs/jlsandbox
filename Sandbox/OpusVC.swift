//
//  OpusVC.swift
//  Sandbox
//
//  Created by Akos Polster on 02/02/2026.
//

import UIKit
import Foundation
import JL_BLEKit
import JLAudioUnitKit

class OpusVC: UIViewController, JLDevAudioManagerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "GET Opus Data"
        view.backgroundColor = .systemBackground
        let streamLabel = Label(text: "Incoming Opus data:")
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

    // MARK: - JLDevAudioManagerDelegate methods

    public func devAudioManager(_ manager: JLDevAudioManager, audio data: Data) {
        let dataText = data.hexString
        Logger.log("Received " + dataText)
        streamData.text = dataText
    }

    public func devAudioManager(_ manager: JLDevAudioManager, startByDeviceWithParam param: JLRecordParams) {
        Logger.log("Starting with parameters \(param)")
    }

    public func devAudioManager(_ manager: JLDevAudioManager, stopByDeviceWithParam param: JLSpeechRecognition) {
        Logger.log("Stopping with parameters \(param)")
    }

    public func devAudioManager(_ manager: JLDevAudioManager, status: JL_SpeakType) {
        Logger.log("Status \(status)")
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

    private lazy var audioManager: JLDevAudioManager = {
        JLDevAudioManager.share(self, withManager: JieliManager.shared.jlManager)
    }()


    private func startStream() {
        Logger.log()
        startButton.isUserInteractionEnabled = false
        stopButton.isUserInteractionEnabled = true
        streamData.text = "(none)"

        let params = JLRecordParams()
        params.mDataType = .OPUS
        params.mSampleRate = .rate16K
        params.mVadWay = .normal
        audioManager.cmdStartRecord(JieliManager.shared.jlManager, params: params) { status, _, _ in
            Logger.log("Recorder callback: Status \(status)")
        }
    }

    private func stopStream() {
        Logger.log()
        startButton.isUserInteractionEnabled = true
        stopButton.isUserInteractionEnabled = false
        audioManager.cmdStopRecord(JieliManager.shared.jlManager, reason: .normal) { status, _, _ in
            Logger.log("Recording stopped, status \(status)")
        }
    }
}
