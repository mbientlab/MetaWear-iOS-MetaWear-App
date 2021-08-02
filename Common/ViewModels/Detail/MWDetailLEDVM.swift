//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
import MetaWear
import MetaWearCpp

public class MWDetailLEDVM: DetailLEDVM {

    // No state in iOS implementation

    public var delegate: DetailLEDVMDelegate? = nil
    private weak var parent: DeviceDetailsCoordinator? = nil
    private weak var device: MetaWear? = nil

}

extension MWDetailLEDVM: DetailConfiguring {

    public func configure(parent: DeviceDetailsCoordinator, device: MetaWear) {
        self.parent = parent
        self.device = device
    }
}

extension MWDetailLEDVM {

    public func start() {
        // Nothing
    }

}

// MARK: - Intents

extension MWDetailLEDVM {

    public func turnOffLEDs() {
        guard let device = device else { return }
        mbl_mw_led_stop_and_clear(device.board)
    }

    public func turnOnRed() {
        setLedColor(MBL_MW_LED_COLOR_RED)
    }

    public func turnOnGreen() {
        setLedColor(MBL_MW_LED_COLOR_GREEN)
    }

    public func turnOnBlue() {
        setLedColor(MBL_MW_LED_COLOR_BLUE)
    }

    public func flashRed() {
        guard let device = device else { return }
        device.flashLED(color: .red, intensity: 1.0)
    }

    public func flashGreen() {
        guard let device = device else { return }
        device.flashLED(color: .green, intensity: 1.0)
    }

    public func flashBlue() {
        guard let device = device else { return }
        device.flashLED(color: .blue, intensity: 1.0)
    }

    private func setLedColor(_ color: MblMwLedColor) {
        guard let device = device else { return }
        var pattern = MblMwLedPattern(high_intensity: 31,
                                      low_intensity: 31,
                                      rise_time_ms: 0,
                                      high_time_ms: 2000,
                                      fall_time_ms: 0,
                                      pulse_duration_ms: 2000,
                                      delay_time_ms: 0,
                                      repeat_count: 0xFF)
        mbl_mw_led_stop_and_clear(device.board)
        mbl_mw_led_write_pattern(device.board, &pattern, color)
        mbl_mw_led_play(device.board)
    }
}
