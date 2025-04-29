//
//  DeviceVC.swift
//  Sandbox
//
//  Created by Akos Polster on 16/04/2025.
//

import UIKit
import JLLogHelper

class DeviceVC: UITableViewController {
    let device: JieliDevice
    let itemsArray = [
        "GET EQ Info",
        "SET EQ",
        "GET ANC",
        "SET ANC",
        "GET Battery Level",
        "RENAME",
        "FOTA",
    ]
    lazy var fotaVC = FotaVC()

    init(device: JieliDevice) {
        self.device = device
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = device.name
        view.backgroundColor = .systemBackground
        tableView.rowHeight = 40
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if parent == nil {
            JieliManager.shared.disconnect { _ in
                Logger.log("Disconnected")
            }
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            ControlViewModel.getEQ { eq in
                eq?.logProperties()
            }
        case 1:
            let eq = JieliManager.shared.jlManager.mSystemEQ
            var eqArray = eq.eqArray as? [Int]
            eqArray?[0] = 10
            eq.cmdSetSystemEQ(.CUSTOM, params: eqArray!)
        case 2:
            let mode = JieliManager.shared.jlManager.getDeviceModel()
            let current = mode.mAncModeCurrent
            current.logProperties()
        case 3:
            let mode = JieliManager.shared.jlManager.getDeviceModel()
            let current = mode.mAncModeCurrent
            current.mAncMode = .transparent
            JieliManager.shared.jlManager.mTwsManager.cmdSetANC(current)
        case 4:
            let twsMgr = JieliManager.shared.jlManager.mTwsManager
            twsMgr.cmdHeadsetGetAdvFlag(.getElectricity) { dict in
                let dict = dict as? [String: Any]
                JLLogManager.logLevel(.INFO, content: "dict: \(dict ?? [:])")
            }
        case 5:
            let twsMgr = JieliManager.shared.jlManager.mTwsManager
            let name = "Jieli"
            twsMgr.cmdHeadsetEdrName(name.data(using: .utf8) ?? Data())
            twsMgr.cmdHeadsetGetAdvFlag(.edrName)
        case 6:
            navigationController?.pushViewController(fotaVC, animated: true)
        default:
            break
        }
        tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        itemsArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = itemsArray[indexPath.row]
        return cell
    }
}
