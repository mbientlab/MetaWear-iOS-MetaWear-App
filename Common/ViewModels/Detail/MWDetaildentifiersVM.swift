//
//  MWDetailHeaderVM.swift
//  MWDetailHeaderVM
//
//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
import MetaWear
import MetaWearCpp

public class MWDetailIdentifiersVM: DetailIdentifiersVM {

    public var manufacturer = ""
    public var modelNumber = ""
    public var serialNumber = ""
    public var harwareRevision = ""


    public var delegate: DetailIdentifiersVMDelegate? = nil
    private weak var parent: DeviceDetailsCoordinator? = nil
    private weak var device: MetaWear? = nil
}

extension MWDetailIdentifiersVM: DetailConfiguring {

    public func configure(parent: DeviceDetailsCoordinator, device: MetaWear) {
        self.parent = parent
        self.device = device
    }
}

extension MWDetailIdentifiersVM {

    public func start() {
        updateIdentifiers()
    }

    private func updateIdentifiers() {
        guard let device = device else { return }
        let na = "N/A"

        manufacturer = device.info?.manufacturer ?? na
        serialNumber = device.info?.serialNumber ?? na
        harwareRevision = device.info?.hardwareRevision ?? na
        modelNumber = "\(device.info?.modelNumber ?? na) (\(String(cString: mbl_mw_metawearboard_get_model_name(device.board))))"

        delegate?.refreshView()
    }
}
