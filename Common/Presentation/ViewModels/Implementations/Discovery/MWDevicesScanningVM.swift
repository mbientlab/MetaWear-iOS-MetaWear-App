//
//  MWDevicesScanningVM.swift
//  MWDevicesScanningVM
//
//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
import MetaWear
import MetaWearCpp

fileprivate let metawearScanner = MetaWearScanner.sharedRestore

public class MWDevicesScanningVM {

    public weak var delegate: DevicesScanningCoordinatorDelegate? = nil

    public private(set) var isScanning = false
    { didSet { DispatchQueue.main.async { self.delegate?.refreshScanningStatus() } } }

    public private(set) var useMetaBootMode = false
    { didSet { DispatchQueue.main.async { self.delegate?.refreshMetaBootStatus() } } }

    public private(set) var connectedDevices: [MetaWear] = []
    public var discoveredDevices: [ScannerModelItem] { bluetoothScanner.items }
    private lazy var bluetoothScanner: ScannerModel = makeScannerModel()

    public private(set) var scanCount = 0
}

extension MWDevicesScanningVM: DevicesScanningVM {

    public func userChangedScanningState(to newState: Bool) {
        switch newState {
            case true: startScanning()
            case false: stopScanning()
        }
    }

    public func startScanning() {
        bluetoothScanner.isScanning = true
        bluetoothScanner.delegate = self
        isScanning = bluetoothScanner.isScanning
        connectedDevices = []
        delegate?.refreshScanningStatus()
        fetchConnectedDevices()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.fetchConnectedDevices()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            self.fetchConnectedDevices()
        }
    }

    public func stopScanning() {
        bluetoothScanner.isScanning = false
        isScanning = bluetoothScanner.isScanning
    }

    public func userChangedUseMetaBootMode(to useMetaBoot: Bool) {
        useMetaBootMode = useMetaBoot
        fetchConnectedDevices()
    }

    public func connectTo(_ item: ScannerModelItem) {
        item.toggleConnect()
    }

    public func disconnect(_ item: ScannerModelItem) {
        item.toggleConnect()
    }

    public func childDeviceDidConnect() {
        fetchConnectedDevices()
    }
}

private extension MWDevicesScanningVM {

    func makeScannerModel() -> ScannerModel {
        ScannerModel(delegate: self, scanner: metawearScanner, adTimeout: 5) { [weak self] discoveredDevice -> Bool in
            // Callback that filters discovered devices
            // Side effect: track scan counts to show activity
            DispatchQueue.main.async { [weak self] in
                self?.scanCount += 1
            }
            // Respect MetaBoot preference
            return discoveredDevice.isMetaBoot == self?.useMetaBootMode
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

    /// ScannerModel only adds devices (appends), not removes them
    public func scannerModel(_ scannerModel: ScannerModel, didAddItemAt idx: Int) {
        delegate?.didAddDiscoveredDevice(at: idx)
    }

    ///  Called when an item receives a user toggleConnect() intent and a confirmation the correct device was connected is needed
    public func scannerModel(_ scannerModel: ScannerModel, confirmBlinkingItem item: ScannerModelItem, callback: @escaping (Bool) -> Void) {
        // Do nothing
    }

    ///  Called when an item receives a user toggleConnect() intent and a connection problem occurs
    public func scannerModel(_ scannerModel: ScannerModel, errorDidOccur error: Error) {
        NSLog(error.localizedDescription)
    }

}
