//
//  DevicesTableScanningController.swift
//  DevicesTableScanningController
//
//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
import MetaWear

fileprivate let metawearScanner = MetaWearScanner()

class DevicesTableScanningVM {

    public weak var delegate: DevicesScanningCoordinatorDelegate? = nil

    public private(set) var isScanning = false
    { didSet { DispatchQueue.main.async { self.delegate?.updateScanningStatus() } } }

    public private(set) var useMetaBootMode = false
    { didSet { DispatchQueue.main.async { self.delegate?.updateMetaBootStatus() } } }

    public private(set) var connectedDevices: [MetaWear] = []
    public var discoveredDevices: [ScannerModelItem] { bluetoothScanner.items }
    private lazy var bluetoothScanner: ScannerModel = makeScannerModel()
}

extension DevicesTableScanningVM: DevicesScanningVM {

    func setScanningState(to newState: Bool) {
        switch newState {
            case true: startScanning()
            case false: stopScanning()
        }
    }

    func startScanning() {
        bluetoothScanner.isScanning = true
        fetchConnectedDevices()
    }

    func stopScanning() {
        bluetoothScanner.isScanning = false
    }

    func setUseMetaBoot(to useMetaBoot: Bool) {
        useMetaBootMode = useMetaBoot
        fetchConnectedDevices()
    }
}

private extension DevicesTableScanningVM {

    func makeScannerModel() -> ScannerModel {
        ScannerModel(delegate: self, scanner: metawearScanner, adTimeout: 5) { [weak self] device -> Bool in
            self?.useMetaBootMode == true ? device.isMetaBoot : !device.isMetaBoot
        }
    }

    func fetchConnectedDevices() {
        connectedDevices = metawearScanner.deviceMap
            .filter { $0.key.state == .connected }
            .map(\.value)

        DispatchQueue.main.async { [weak self] in
            self?.delegate?.reloadConnectedDevices()
        }
    }

}


extension DevicesTableScanningVM: ScannerModelDelegate {

    func scannerModel(_ scannerModel: ScannerModel, didAddItemAt idx: Int) {
        delegate?.didAddDiscoveredDevice(at: idx)
    }

    func scannerModel(_ scannerModel: ScannerModel, confirmBlinkingItem item: ScannerModelItem, callback: @escaping (Bool) -> Void) {
        // Do nothing
    }

    func scannerModel(_ scannerModel: ScannerModel, errorDidOccur error: Error) {
        // Do nothing
    }

}
