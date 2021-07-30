//
//  DeviceScanningController.swift
//  DeviceScanningController
//
//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
import MetaWear

protocol DevicesScanningVM: AnyObject {

    var delegate: DevicesScanningCoordinatorDelegate? { get set }

    var connectedDevices: [MetaWear] { get }
    var discoveredDevices: [ScannerModelItem] { get }
    var isScanning: Bool { get }
    var useMetaBootMode: Bool { get }

    func setScanningState(to newState: Bool)
    func startScanning()
    func stopScanning()
    func setUseMetaBoot(to useMetaBoot: Bool)
}

protocol DevicesScanningCoordinatorDelegate: AnyObject {

    func updateScanningStatus()
    func reloadConnectedDevices()
    func updateMetaBootStatus()
    func didAddDiscoveredDevice(at index: Int)
}
