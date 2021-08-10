//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
import MetaWear
import MetaWearCpp

public class MWHapticVM: HapticVM {

    // UI State
    public private(set) var canSendCommand = true

    // Settings
    public private(set) var hapticPulseWidth: Double = 500
    public private(set) var dutyCycle: Int = 248
    public var hapticPulseWidthString: String { String(format: "%1.f", hapticPulseWidth) }
    public var hapticDutyCycleString: String { String(dutyCycle) }

    /// Count of "buzz presses" to trigger optional animations
    public private(set) var buzzCount = 0
    /// Count of "haptic presses" to trigger optional animations
    public private(set) var hapticCount = 0

    // Identity
    public var delegate: HapticVMDelegate? = nil
    private var parent: DeviceDetailsCoordinator? = nil
    private var device: MetaWear? = nil
}

extension MWHapticVM: DetailConfiguring {

    public func configure(parent: DeviceDetailsCoordinator, device: MetaWear) {
        self.parent = parent
        self.device = device
    }

    public func start() {
        guard device?.board != nil else { return }
        delegate?.refreshView()
    }
}

// MARK: - Intents

public extension MWHapticVM {

    func userSetPulseWidth(ms: Double) {
        let legal = max(0, min(ms, 10_000))
        hapticPulseWidth = legal
        delegate?.refreshView()
    }

    func userSetDutyCycle(cycle: Int) {
        let legal = max(0, min(cycle, 248))
        dutyCycle = legal
        delegate?.refreshView()
    }

    func userRequestedStartHapticDriver() {
        guard let board = device?.board else { return }

        let _dutyCycle = UInt8(dutyCycle)
        let _pulseWidth = UInt16(hapticPulseWidth)

        canSendCommand = false
        hapticCount += 1
        delegate?.refreshView()

        mbl_mw_haptic_start_motor(board, (Float(_dutyCycle) / 248.0) * 100.0, _pulseWidth)

        let delay = Double(_pulseWidth) / 1000.0
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.canSendCommand = true
            self?.delegate?.refreshView()
        }
    }

    func userRequestedStartBuzzerDriver() {
        guard let board = device?.board else { return }

        let _pulseWidth = UInt16(hapticPulseWidth)

        canSendCommand = false
        buzzCount += 1
        delegate?.refreshView()

        mbl_mw_haptic_start_buzzer(board, _pulseWidth)

        let delay = Double(_pulseWidth) / 1000.0
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.canSendCommand = true
            self?.delegate?.refreshView()
        }

        delegate?.refreshView()
    }

}
