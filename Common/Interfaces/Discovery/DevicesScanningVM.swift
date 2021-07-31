//
//  DevicesScanningVM.swift
//  DevicesScanningVM
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

    func startScanning()
    func stopScanning()
    func userChangedScanningState(to newState: Bool)
    func userChangedUseMetaBootMode(to useMetaBoot: Bool)
}

protocol DevicesScanningCoordinatorDelegate: AnyObject {

    func refreshScanningStatus()
    func refreshConnectedDevices()
    func refreshMetaBootStatus()

    func didAddDiscoveredDevice(at index: Int)
}
