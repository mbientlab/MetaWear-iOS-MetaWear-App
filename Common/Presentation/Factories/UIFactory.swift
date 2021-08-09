//
//  UIFactory.swift
//  UIFactory
//
//  Created by Ryan Ferrell on 8/6/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI
import MetaWear

public enum UIEnvironment {
    /// Base for macOS 11 and iOS 14
    case swiftUIMinimumV2
}

/// Suclass for your environment
open class UIFactory {

    public init(environment: UIEnvironment) {
        self.environment = environment
    }

    public var environment: UIEnvironment

    public func makeMetaWearScanningSVC() -> MetaWearScanningSVC {
        .init()
    }

    public func makeScannedDeviceCellSVC(device: MetaWear?, parent: DevicesScanningVM?) -> MWScannedDeviceCellVM {
        let vm = MWScannedDeviceCellVM()
        vm.parent = parent
        return vm
    }

    public func makeScannedDeviceCellSVC(scannerItem: ScannerModelItem?, parent: DevicesScanningVM?) -> MWScannedDeviceCellVM {
        let vm = MWScannedDeviceCellVM()
        vm.parent = parent
        return vm
    }

    public func makeDetailScreenVC(device: MetaWear?) -> DeviceDetailsCoordinator {
        switch environment {
            case .swiftUIMinimumV2:
                return MWDeviceDetailScreenSVC(device: device, vms: _makeDetailVMContainer())
        }
    }
    // Helper

    private func _makeDetailVMContainer() -> DetailVMContainer {
        switch environment {
            case .swiftUIMinimumV2: return DetailVMContainerForSwiftUIStandard()
        }
    }
}
