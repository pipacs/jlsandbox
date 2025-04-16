//
//  DeviceVC.swift
//  Sandbox
//
//  Created by Akos Polster on 16/04/2025.
//

import UIKit

class DeviceVC: UIViewController {
    let device: JieliDevice

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

        let reloadButton = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.down"), style: .plain, target: self, action: #selector(doFOTA))
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

    @objc func doFOTA() {

    }
}
