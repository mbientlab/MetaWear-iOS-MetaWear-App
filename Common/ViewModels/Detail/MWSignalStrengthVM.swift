//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
import MetaWear
import MetaWearCpp

public class MWDetailSignalStrengthVM: DetailSignalStrengthVM {

    public var rssiLevel = ""
    public var transmissionPowerLevels = [4, 0, -4, -8, -12, -16, -20, -30]
    public var chosenPowerLevelIndex = 0

    public var delegate: DetailSignalStrengthVMDelegate? = nil
    private weak var parent: DeviceDetailsCoordinator? = nil
    private weak var device: MetaWear? = nil

}

extension MWDetailSignalStrengthVM: DetailConfiguring {

    public func configure(parent: DeviceDetailsCoordinator, device: MetaWear) {
        self.parent = parent
        self.device = device
    }
}


extension MWDetailSignalStrengthVM {

    public func start() {
        updateState()
    }

    private func updateState() {
        guard let device = device else { return }
        rssiLevel = String(device.rssi)
        delegate?.refreshView()
    }
}


// MARK: - Intents

extension MWDetailSignalStrengthVM {

    public func userRequestsRSSI() {
        guard let device = device else { return }

        device.readRSSI().continueOnSuccessWith(.mainThread) { rssi in
            self.rssiLevel = String(rssi)
            self.delegate?.refreshView()
        }
    }

    #warning("Original implementation did not set txPowerLevel at load")
    public func userChangedTransmissionPower(toIndex: Int) {
        guard transmissionPowerLevels.indices.contains(toIndex),
              let device = device
        else { return }

        chosenPowerLevelIndex = toIndex
        let newPower = transmissionPowerLevels[toIndex]
        let txpower = Int8(newPower)
        mbl_mw_settings_set_tx_power(device.board, txpower)

        userRequestsRSSI()
    }
}
