//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
import MetaWear
import MetaWearCpp

public class MWBatteryVM: BatteryVM {

    public private(set) var batteryLevel = " "
    public private(set) var batteryLevelPercentage = 0

    // Identity
    public weak var delegate: BatteryVMDelegate? = nil
    private weak var parent: DeviceDetailsCoordinator? = nil
    private weak var device: MetaWear? = nil
}

extension MWBatteryVM: DetailConfiguring {

    public func configure(parent: DeviceDetailsCoordinator, device: MetaWear) {
        self.parent = parent
        self.device = device
    }

    public func start() {
        userRequestedBatteryLevel()
    }
}

// MARK: - Intents

extension MWBatteryVM {

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
                self.delegate?.refreshView()
            }
        }
    }
}
