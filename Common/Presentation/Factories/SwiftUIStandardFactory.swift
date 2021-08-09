//
//  SwiftUIStandardFactory.swift
//  SwiftUIStandardFactory
//
//  Created by Ryan Ferrell on 8/6/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI
import MetaWear

// MARK: - App UI Factory

public class DevelopmentUIFactory: UIFactory {

    public override init(environment: UIEnvironment) {
        super.init(environment: environment)
    }

    public override func makeScannedDeviceCellSVC(device: MetaWear?, parent: DevicesScanningVM?) -> MWScannedDeviceCellVM {
        MWScannedDeviceCellSVC(device: device, parent: parent)
    }

    public override func makeScannedDeviceCellSVC(scannerItem: ScannerModelItem?, parent: DevicesScanningVM?) -> MWScannedDeviceCellVM {
        MWScannedDeviceCellSVC(scannerItem: scannerItem, parent: parent)
    }


    public override func makeDetailScreenVC(device: MetaWear?) -> DeviceDetailsCoordinator {
        MWDeviceDetailScreenSVC(device: device, vms: makeDetailVMContainer())
    }

    // Helper

    private func makeDetailVMContainer() -> DetailVMContainer {
        switch environment {
            case .swiftUIMinimumV2: return DetailVMContainerForSwiftUIStandard()
        }
    }
}

// MARK: - VMs

public class DetailVMContainerForSwiftUIStandard: DetailVMContainer {
    public init() {}

    public lazy private(set) var header: DetailHeaderVM               = MWDetailHeaderSVC()
    public lazy private(set) var identifiers: DetailIdentifiersVM     = MWDetailIdentifiersSVC()
    public lazy private(set) var battery: DetailBatteryVM             = MWDetailBatterySVC()
    public lazy private(set) var signal: DetailSignalStrengthVM       = MWSignalSVC()
    public lazy private(set) var firmware: DetailFirmwareVM           = MWFirmwareSVC()
    public lazy private(set) var led: DetailLEDVM                     = MWLEDSVC()
    public lazy private(set) var mechanical: DetailMechanicalSwitchVM = MWMechanicalSwitchSVC()
    public lazy private(set) var temperature: DetailTemperatureVM     = MWTemperatureSVC()
    public lazy private(set) var reset: DetailResetVM                 = MWResetSVC()
    public lazy private(set) var accelerometer: DetailAccelerometerVM = MWAccelerometerSVC()

    public var configurables: [DetailConfiguring] { [
        header,
        identifiers,
        battery,
        signal,
        firmware,
        led,
        mechanical,
        temperature,
        reset,
        accelerometer
    ] }
}
