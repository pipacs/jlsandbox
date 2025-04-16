//
//  ViewController.swift
//  Sandbox
//
//  Created by Akos Polster on 16/04/2025.
//

import UIKit
import Foundation

class DeviceListVC: UITableViewController {
    var deviceMap: [UUID: JieliDevice] = [:]
    var devices: [JieliDevice] = []

    init() {
        super.init(style: .insetGrouped)
        tableView.register(DeviceCell.self, forCellReuseIdentifier: "cell")
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Jieli Sandbox"
    }

    override func viewDidAppear(_ animated: Bool) {
        JieliManager.shared.startDiscovery { device in
            self.deviceMap[device.peripheral.identifier] = device
            self.devices = self.deviceMap.values.sorted { $0.name < $1.name }
            self.tableView.reloadData()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        JieliManager.shared.stopDiscovery()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let device = devices[indexPath.row]
        let deviceVC = DeviceVC(device: device)
        self.navigationController?.pushViewController(deviceVC, animated: true)
        JieliManager.shared.connect(device: device) { result in
            Logger.log("\(result)")
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        (cell as? DeviceCell)?.update(device: devices[indexPath.row])
        return cell
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        devices.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "Jieli Devices"
    }
}
