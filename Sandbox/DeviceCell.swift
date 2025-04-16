//
//  DeviceCell.swift
//  Sandbox
//
//  Created by Akos Polster on 16/04/2025.
//

import UIKit

class DeviceCell: UITableViewCell {
    func update(device: JieliDevice) {
        textLabel?.text = device.name
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        self.textLabel?.numberOfLines = 0
        self.detailTextLabel?.numberOfLines = 0
        accessoryType = .disclosureIndicator
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
