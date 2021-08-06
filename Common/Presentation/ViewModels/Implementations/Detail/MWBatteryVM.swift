//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
import MetaWear
import MetaWearCpp
import Combine

public class MWDetailBatteryVM: DetailBatteryVM {

    public var batteryLevel = " "
    public var batteryLevelPercentage = 0

    public var delegate: DetailBatteryVMDelegate? = nil
    private weak var parent: DeviceDetailsCoordinator? = nil
    private weak var device: MetaWear? = nil
    var lastAutoReconnect = Date()
    var reconnection: AnyCancellable? = nil
}

extension MWDetailBatteryVM: DetailConfiguring {

    public func configure(parent: DeviceDetailsCoordinator, device: MetaWear) {
        self.parent = parent
        self.device = device
    }
}


extension MWDetailBatteryVM {

    public func start() {
        userRequestedBatteryLevel()
    }
}

// MARK: - Intents

extension MWDetailBatteryVM {

    public func userRequestedBatteryLevel() {
        guard let device = device else { return }

        mbl_mw_settings_get_battery_state_data_signal(device.board).read().continueWith(.mainThread) {
            if let error = $0.error {
                self.parent?.alerts.presentAlert(
                    title: "Battery Error",
                    message: error.localizedDescription)
            } else {
                let battery: MblMwBatteryState = $0.result!.valueAs()
                self.batteryLevel = String(battery.charge)
                self.batteryLevelPercentage = Int(battery.charge)
            }

            self.delegate?.refreshView()
        }
    }
}
