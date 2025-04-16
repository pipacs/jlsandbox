//
// Created by Akos Polster on 02/04/2025
// Copyright (C) 2025 Bragi Gmbh. All rights reserved.
//

import Foundation
import CoreBluetooth

import JLLogHelper
import JL_BLEKit
//import JL_OTALib

/// Manages Jieli devices using JL_BLEKit
class JieliManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    static var shared = JieliManager()
    var device: JieliDevice?
    var jlManager: JL_ManagerM { jlAssist.mCmdManager }
    var jlTWSManager: JL_TwsManager { jlAssist.mCmdManager.mTwsManager }
    var jlOTAManager: JL_OTAManager { jlAssist.mCmdManager.mOTAManager }

    override init() {
        JLLogManager.setLog(true, isMore: false, level: .COMPLETE)
        JLLogManager.saveLog(asFile: true)
        JLLogManager.log(withTimestamp: true)
        JLLogManager.clearLog()

        self.jlAssist = JL_Assist()

        super.init()

        self.jlAssist.mNeedPaired = true
        let pairKeyData: Data? = nil
        self.jlAssist.mPairKey = pairKeyData
        self.jlAssist.mService = rcspService
        self.jlAssist.mRcsp_R = rcspReadCharacteristic
        self.jlAssist.mRcsp_W = rcspWriteCharacteristic
        self.jlAssist.mLogData = true
        self.jlAssist.mLimitMtu = 128
    }

    // MARK: - Discovery

    func startDiscovery(callback: @escaping (JieliDevice) -> Void) {
        Logger.log()
        self.discoveryCallback = callback
        startScanning()
    }

    func stopDiscovery() {
        Logger.log()
        self.discoveryCallback = nil
        stopScanning()
    }

    // MARK: - Connectivity

    var isConnected = false

    func connect(device: JieliDevice, callback: @escaping (Result<Void, any Error>) -> Void) {
        Logger.log()
        device.peripheral.delegate = self
        self.connectionCallback = callback
        self.device = device
        self.centralManager.connect(device.peripheral)
    }

    func disconnect(callback: @escaping (Result<Void, any Error>) -> Void) {
        Logger.log()
        guard let peripheral = device?.peripheral else {
            Logger.log("Not connected")
            doDisconnect()
            callback(.success(()))
            return
        }
        centralManager.cancelPeripheralConnection(peripheral)
        doDisconnect()
        callback(.success(()))
    }

    func startObservingConnection(callback: @escaping (Bool) -> Void) {
        Logger.log()
        self.connectionObserver = callback
    }

    func stopObservingConnection() {
        Logger.log()
        self.connectionObserver = nil
    }

    // MARK: - FOTA

    func startFOTA(otaData: Data, callback: @escaping (Result<Float, Error>) -> Void) {
        Logger.log()
        self.didCancelFOTA = false

        JieliManager.shared.jlOTAManager.cmdOTAData(otaData) { [weak self] otaResult, progress in
            guard self?.didCancelFOTA != true else { return }
            Logger.log("\(otaResult), progress: \(progress)")
            switch otaResult {
            case .success:
                callback(.success(100))
            case .fail, .failSameSN, .dataIsNull, .commandFail, .seekFail, .infoFail, .lowPower,
                    .enterFail, .failedConnectMore, .failVerification,
                    .failCompletely, .failKey, .failErrorFile, .failUboot, .failLenght,
                    .failFlash, .failCmdTimeout, .failSameVersion, .failTWSDisconnect,
                    .failNotInBin:
                callback(.failure(Self.makeError(code: otaResult.rawValue)))
            case .upgrading, .reconnect, .reboot, .prepared, .statusIsUpdating,
                    .reconnectWithMacAddr, .disconnect, .unknown:
                callback(.success(progress))
            case .preparing:
                callback(.success(0))
            case .cancel:
                break
            @unknown default:
                break
            }
        }
    }

    func cancelFOTA(callback: @escaping (Result<Void, any Error>) -> Void) {
        Logger.log()
        didCancelFOTA = true
        JieliManager.shared.jlManager.mOTAManager.cmdOTACancelResult()
        callback(.success(()))
    }

    // MARK: - CBCentralManagerDelegate

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        Logger.log()
        self.jlAssist.assistUpdate(central.state)
        if central.state == .poweredOn && self.discoveryCallback != nil {
            startScanning()
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard
            let manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data,
            manufacturerData.count >= 2,
            manufacturerData[0] == 0xd6, manufacturerData[1] == 0x05
        else {
            return
        }
        var name: String? = peripheral.name
        if name == nil, let nameData = advertisementData[CBAdvertisementDataLocalNameKey] as? Data {
            name = String(data: nameData, encoding: .utf8)
        }
        if name == nil {
            name = peripheral.identifier.uuidString
        }
        let device = JieliDevice(name: name!, peripheral: peripheral)
        discoveryCallback?(device)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        Logger.log()
        self.jlAssist.mLimitMtu = peripheral.maximumWriteValueLength(for: .withResponse)
        peripheral.discoverServices(nil)
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: (any Error)?) {
        if let error { Logger.logError("\(error)") }
        let connectionError: Error = error ?? NSError(domain: "com.pipacs.Sandbox", code: -1)
        connectionCallback?(.failure(connectionError))
        doDisconnect()
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: (any Error)?) {
        if let error { Logger.logError("\(error)") }
        jlAssist.assistDisconnectPeripheral(peripheral)
        doDisconnect()
    }

    // MARK: - CBPeripheralDelegate

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?) {
        if let error = error {
            Logger.logError("\(error)")
            return
        }
        guard let services = peripheral.services else { return }
        let serviceIDs = services.map { $0.uuid.uuidString }.joined(separator: ", ")
        Logger.log(serviceIDs)
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?) {
        if let error {
            Logger.logError("\(error)")
            return
        }
        Logger.log()
        jlAssist.assistDiscoverCharacteristics(for: service, peripheral: peripheral)
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: (any Error)?) {
        if let error {
            Logger.logError("\(error)")
            return
        }
        Logger.log()
        self.jlAssist.assistUpdate(characteristic, peripheral: peripheral) { [weak self] success in
            guard success  else {
                Logger.logError("assistUpdate failed, forcing disconnection")
                self?.connectionCallback?(.failure(Self.genericError))
                self?.centralManager.cancelPeripheralConnection(peripheral)
                return
            }
            Logger.log("assistUpdate succeeded")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.updateDeviceInfo { [weak self] in
                    Logger.log("Got device info, device connected")
                    self?.isConnected = true
                    self?.connectionObserver?(true)
                    self?.connectionCallback?(.success(()))
                }
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        if let error {
            Logger.logError("\(error)")
            return
        }
        self.jlAssist.assistUpdateValue(for: characteristic)
    }

    // MARK: - Internal

    private lazy var centralManager: CBCentralManager = CBCentralManager(delegate: self, queue: .main)
    private var discoveryCallback: ((JieliDevice) -> Void)?
    private var connectionObserver: ((Bool) -> Void)?
    private var connectionCallback: ((Result<Void, any Error>) -> Void)?
    private let rcspService = "AE00"
    private let rcspWriteCharacteristic = "AE01"
    private let rcspReadCharacteristic = "AE02"
    private static let genericError = makeError(code: 42)
    private var didCancelFOTA = false
    private let jlAssist: JL_Assist

    private static func makeError(code: UInt8) -> NSError {
        NSError(domain: "com.pipacs.sandbox", code: Int(code))
    }

    private func startScanning() {
        Logger.log()
        guard centralManager.state == .poweredOn else { return }
        centralManager.scanForPeripherals(withServices: nil)
    }

    private func stopScanning() {
        Logger.log()
        centralManager.stopScan()
    }

    /// Reset internal state after disconnecting from current device
    private func doDisconnect() {
        Logger.log()
        self.device = nil
        self.isConnected = false
        self.connectionObserver?(false)
    }

    /// Update the Jieli device info
    private func updateDeviceInfo(callback: @escaping () -> Void) {
        Logger.log("Calling jlManager.cmdTargetFeatureResult")
        jlManager.cmdTargetFeatureResult { [weak self] status, _, _ in
            guard let self else { return }
            Logger.log("jlManager.cmdGetTargetFeatureResult returned status \(status)")
            let model =  self.jlManager.outputDeviceModel()
            let otaStatus = model.otaStatus
            let otaHeadsetStatus = model.otaHeadset
            Logger.log("OTA status: \(otaStatus), OTA headset status: \(otaHeadsetStatus)")
            Logger.log("Calling jlManager.cmdGetSystemInfo(.COMMON)")
            JL_Tools.mainTask { [weak self] in
                self?.jlManager.cmdGetSystemInfo(.COMMON) { status, _, _ in
                    Logger.log("jlManager.cmdGetSystemInfo(.COMMON) returned status \(status)")
                    callback()
                }
            }
        }
    }
}

extension JL_OTAResult: @retroactive CustomStringConvertible {
    public var description: String {
        switch self {
        case .cancel: return "Cancel"
        case .success: return "Success"
        case .fail: return "Fail"
        case .dataIsNull: return "Data is Null"
        case .commandFail: return "Command Fail"
        case .seekFail: return "Seek Fail"
        case .infoFail: return "Info Fail"
        case .lowPower: return "Low Power"
        case .enterFail: return "Enter Fail"
        case .upgrading: return "Upgrading"
        case .reconnect: return "Reconnect"
        case .reboot: return "Reboot"
        case .preparing: return "Preparing"
        case .prepared: return "Prepared"
        case .statusIsUpdating: return "Status Is Updating"
        case .failedConnectMore: return "Failed Connect More"
        case .failSameSN: return "Fail Same SN"
        case .failVerification: return "Fail Verification"
        case .failCompletely: return "Fail Completely"
        case .failKey: return "Fail Key"
        case .failErrorFile: return "Fail Error File"
        case .failUboot: return "Fail UBoot"
        case .failLenght: return "Fail Length"
        case .failFlash: return "Fail Flash"
        case .failCmdTimeout: return "Fail Command Timeout"
        case .failSameVersion: return "Fail Same Version"
        case .failTWSDisconnect: return "Fail TWS Not Connected"
        case .failNotInBin: return "Fail Not In Bin"
        case .reconnectWithMacAddr: return "Reconnect With Mac Address"
        case .disconnect: return "Disconnect"
        case .unknown: return "Unknown"
        @unknown default: return "Unknown"
        }
    }
}
