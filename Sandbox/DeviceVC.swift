//
//  DeviceVC.swift
//  Sandbox
//
//  Created by Akos Polster on 16/04/2025.
//

import UIKit
import JL_OTALib
import SnapKit
import RxSwift
import RxCocoa

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
    
    let funcTableView = UITableView()
    let itemsArray: BehaviorRelay<[String]> = BehaviorRelay(value: [
        "GET EQ Info",
        "SET EQ",
        "GET ANC",
        "SET ANC",
        "GET Battery Level",
        "RENAME"
    ])
    let disposeBag = DisposeBag()

    
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
        let reloadButton = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.down"), style: .plain, target: self, action: #selector(updateFirmware))
        navigationItem.rightBarButtonItem = reloadButton
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
