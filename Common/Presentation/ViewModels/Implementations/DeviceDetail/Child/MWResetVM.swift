//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
import MetaWear
import MetaWearCpp

public class MWResetVM: ResetVM {

    // No state

    // Identity
    public weak var delegate: ResetVMDelegate? = nil
    private weak var parent: DeviceDetailsCoordinator? = nil
    private weak var device: MetaWear? = nil

}

extension MWResetVM: DetailConfiguring {

    public func configure(parent: DeviceDetailsCoordinator, device: MetaWear) {
        self.parent = parent
        self.device = device
    }

    public func start() {
        // No state to show
    }
}

// MARK: - Intents

public extension MWResetVM {

    func userRequestedSleep() {
        guard let device = device else { return }

        // Sleep causes a disconnection
        parent?.userIntentDidCauseDeviceDisconnect()
        // Set it to sleep after the next reset
        mbl_mw_debug_enable_power_save(device.board)
        // Preform the soft reset
        mbl_mw_debug_reset(device.board)
    }

    func userRequestedFactoryReset() {
        guard let device = device else { return }
        // Resetting causes a disconnection
        parent?.userIntentDidCauseDeviceDisconnect()
        device.clearAndReset()
    }

    func userRequestedSoftReset() {
        guard let device = device else { return }
        // Resetting causes a disconnection
        parent?.userIntentDidCauseDeviceDisconnect()
        // Preform the soft reset
        mbl_mw_debug_reset(device.board)
    }

}
