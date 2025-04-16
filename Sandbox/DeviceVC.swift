//
//  DeviceVC.swift
//  Sandbox
//
//  Created by Akos Polster on 16/04/2025.
//

import UIKit
import JL_OTALib

class DeviceVC: UIViewController {
    let device: JieliDevice

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

    init(device: JieliDevice) {
        self.device = device
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = device.name
        view.backgroundColor = .systemBackground

        let reloadButton = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.down"), style: .plain, target: self, action: #selector(updateFirmware))
        navigationItem.rightBarButtonItem = reloadButton
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if parent == nil {
            JieliManager.shared.disconnect { _ in
                Logger.log("Disconnected")
            }
        }
    }

    @objc func updateFirmware() {
        let alert = UIAlertController(title: "Update Firmware?", message: "Updating with generic firmware 'update.ufw'", preferredStyle: .alert)
        let startFOTAAction = UIAlertAction(title: "Update", style: .destructive) { [weak self] _ in self?.startFOTA() }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(startFOTAAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }

    func startFOTA() {
        guard
            let file = Bundle.main.url(forResource: "update.ufw", withExtension: nil),
            let data = try? Data(contentsOf: file)
        else {
            return
        }
        present(fotaHUD, animated: true)
        JieliManager.shared.startFOTA(otaData: data) { [weak self] result in
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
            } else if progress == 100 {
                fotaHUD.message = "Completed"
                fotaHUD.dismiss(animated: true)
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
