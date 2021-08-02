//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
import MetaWear
import MetaWearCpp

public class MWDetailBatteryVM: DetailBatteryVM {

    public var batteryLevel = ""

    public var delegate: DetailBatteryVMDelegate? = nil
    private weak var parent: DeviceDetailsCoordinator? = nil
    private weak var device: MetaWear? = nil

}

extension MWDetailBatteryVM: DetailConfiguring {

    public func configure(parent: DeviceDetailsCoordinator, device: MetaWear) {
        self.parent = parent
        self.device = device
    }
}


extension MWDetailBatteryVM {

    public func start() {
        updateState()
    }

    private func updateState() {
        guard let device = device else { return }

        mbl_mw_settings_get_battery_state_data_signal(device.board).read().continueOnSuccessWith(.mainThread) {
            let battery: MblMwBatteryState = $0.valueAs()
            batteryLevel = String(battery.charge)
        }

        delegate?.refreshView()
    }
}
