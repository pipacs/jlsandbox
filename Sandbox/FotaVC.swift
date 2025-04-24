//
//  FotaVC.swift
//  Sandbox
//
//  Created by Akos Polster on 24/04/2025.
//

import UIKit
import Foundation
import JL_OTALib

class FotaVC: UIViewController, UIDocumentPickerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "FOTA"
        view.backgroundColor = .systemBackground
        view.addSubviewsForAutolayout(selectFileButton, fotaLabel, fotaButton)
        NSLayoutConstraint.activate([
            selectFileButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            selectFileButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            selectFileButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            fotaLabel.topAnchor.constraint(equalTo: selectFileButton.bottomAnchor, constant: 10),
            fotaLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            fotaLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            fotaButton.topAnchor.constraint(equalTo: fotaLabel.bottomAnchor, constant: 60),
            fotaButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            fotaButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshUI()
    }

    // MARK: - UIDocumentPickerDelegate

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        do {
            fotaData = try Data(contentsOf: url)
            fotaFileName = url.lastPathComponent
        } catch {
            Logger.logError("\(error)")
            fotaData = nil
            fotaFileName = nil
        }
        refreshUI()
    }

    // MARK: - Internal

    private lazy var selectFileButton = BigButton(title: "Select FOTA Image") {
        self.present(self.filePicker, animated: true)
    }

    private let fotaLabel = Label(text: "FOTA Image:")
    private var fotaData: Data?
    private var fotaFileName: String?

    private lazy var fotaButton: BigButton = {
        let button = BigButton(title: "Update Firmware") { self.updateFirmware() }
        button.backgroundColor = .systemRed
        return button
    }()

    lazy var fotaHUD: UIAlertController = {
        let alert = UIAlertController(title: "Updating Firmware\n\n\n\n\n", message: nil, preferredStyle: .alert)
        let indicator = UIActivityIndicatorView(frame: alert.view.bounds)
        indicator.style = .large
        indicator.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        alert.view.addSubview(indicator)
        indicator.isUserInteractionEnabled = false
        indicator.startAnimating()
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in self?.cancelFOTA() })
        return alert
    }()

    private lazy var filePicker: UIDocumentPickerViewController = {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.item], asCopy: true)
        picker.delegate = self
        return picker
    }()

    private func refreshUI() {
        if let fotaFileName {
            fotaLabel.text = "FOTA Image: \(fotaFileName)"
        } else {
            fotaLabel.text = "FOTA Image:"
        }
        fotaButton.isUserInteractionEnabled = fotaData != nil
    }

    private func updateFirmware() {
        guard let fotaFileName else { return }
        let alert = UIAlertController(title: "Update Firmware?", message: "Updating with '\(fotaFileName)'", preferredStyle: .alert)
        let startFOTAAction = UIAlertAction(title: "Update", style: .destructive) { [weak self] _ in self?.startFOTA() }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(startFOTAAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }

    private func startFOTA() {
        guard let fotaData else { return }
        present(fotaHUD, animated: true)
        JieliManager.shared.startFOTA(otaData: fotaData) { [weak self] result in
            self?.displayFOTAState(result)
        }
    }

    private func cancelFOTA() {
        JieliManager.shared.cancelFOTA() { _ in
            Logger.log("Cancelled")
        }
        fotaHUD.dismiss(animated: true)
    }

    /// Display FOTA state on the FOTA progress HUD
    private func displayFOTAState(_ state: Result<Float, Error>) {
        Logger.log("\(state)")
        switch state {
        case .success(let progress):
            if progress == 0 {
                fotaHUD.message = "Starting"
            } else if progress == 101 {
                fotaHUD.dismiss(animated: true) {
                    let alert = UIAlertController(title: "Update Completed", message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Close", style: .cancel))
                    self.present(alert, animated: true)
                }
            } else {
                let progressValue = Int(progress * 100)
                fotaHUD.message = "Updating: \(progressValue)%"
            }
        case .failure(let error):
            Logger.logError("\(error)")
            fotaHUD.dismiss(animated: true) {
                let errorMessage: String
                if  let errorCode = UInt8(exactly: (error as NSError).code),
                    let otaResult = JL_OTAResult(rawValue: errorCode)
                {
                    errorMessage = "\(otaResult)"
                } else {
                    errorMessage = "\(error)"
                }
                let alert = UIAlertController(title: "Update Failed", message: errorMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Close", style: .cancel))
                self.present(alert, animated: true)
            }
        }
    }
}
