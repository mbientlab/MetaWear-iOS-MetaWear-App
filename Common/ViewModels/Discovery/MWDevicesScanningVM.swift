//
//  MWDevicesScanningVM.swift
//  MWDevicesScanningVM
//
//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
import MetaWear

fileprivate let metawearScanner = MetaWearScanner()

class MWDevicesScanningVM {

    public weak var delegate: DevicesScanningCoordinatorDelegate? = nil

    public private(set) var isScanning = false
    { didSet { DispatchQueue.main.async { self.delegate?.refreshScanningStatus() } } }

    public private(set) var useMetaBootMode = false
    { didSet { DispatchQueue.main.async { self.delegate?.refreshMetaBootStatus() } } }

    public private(set) var connectedDevices: [MetaWear] = []
    public var discoveredDevices: [ScannerModelItem] { bluetoothScanner.items }
    private lazy var bluetoothScanner: ScannerModel = makeScannerModel()
}

extension MWDevicesScanningVM: DevicesScanningVM {

    func userChangedScanningState(to newState: Bool) {
        switch newState {
            case true: startScanning()
            case false: stopScanning()
        }
    }

    func startScanning() {
        bluetoothScanner.isScanning = true
        isScanning = bluetoothScanner.isScanning
        fetchConnectedDevices()
    }

    func stopScanning() {
        bluetoothScanner.isScanning = false
        isScanning = bluetoothScanner.isScanning
    }

    func userChangedUseMetaBootMode(to useMetaBoot: Bool) {
        useMetaBootMode = useMetaBoot
        fetchConnectedDevices()
    }
}

private extension MWDevicesScanningVM {

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
            self?.delegate?.refreshConnectedDevices()
        }
    }

}


extension MWDevicesScanningVM: ScannerModelDelegate {

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
