//
//  DeviceVC.swift
//  Sandbox
//
//  Created by Akos Polster on 16/04/2025.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import JLLogHelper

class DeviceVC: UIViewController {
    let device: JieliDevice
    let funcTableView = UITableView()
    let itemsArray: BehaviorRelay<[String]> = BehaviorRelay(value: [
        "GET EQ Info",
        "SET EQ",
        "GET ANC",
        "SET ANC",
        "GET Battery Level",
        "RENAME",
        "FOTA",
    ])
    let disposeBag = DisposeBag()
    lazy var fotaVC = FotaVC()

    init(device: JieliDevice) {
        self.device = device
        super.init(nibName: nil, bundle: nil)
        view.addSubview(funcTableView)
        funcTableView.rowHeight = 40
        funcTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        itemsArray.bind(to: funcTableView.rx.items(cellIdentifier: "cell", cellType: UITableViewCell.self)) { _, item, cell in
            cell.textLabel?.text = item
        }.disposed(by: disposeBag)

        funcTableView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        
        funcTableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                self.didSelectAction(indexPath.row)
            })
            .disposed(by: disposeBag)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = device.name
        view.backgroundColor = .systemBackground
    }
    
    private func didSelectAction(_ index: Int) {
        switch index {
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
        self.funcTableView.reloadData()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if parent == nil {
            JieliManager.shared.disconnect { _ in
                Logger.log("Disconnected")
            }
        }
    }

}
