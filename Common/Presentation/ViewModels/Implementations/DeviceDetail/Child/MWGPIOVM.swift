//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
import MetaWear
import MetaWearCpp
import Combine

public class MWGPIOVM: GPIOVM {

    public private(set) var digitalValue = ""
    public private(set) var analogAbsoluteValue = ""
    public private(set) var analogRatioValue = ""

    public private(set) var pinChangeCount = 0
    public var pinChangeCountString: String { String(pinChangeCount) }

    public private(set) var mode: GPIOMode = .digital
    public private(set) var modes = GPIOMode.allCases

    public private(set) var isChangingPins = false
    public private(set) var pinSelected = GPIOPin.zero
    public private(set) var pins = GPIOPin.allCases

    public private(set) var pullMode = GPIOPullMode.pullNone
    public let pullModeOptions = GPIOPullMode.allCases
    public private(set) var changeType = GPIOChangeType.rising

    // Identity
    public weak var delegate: GPIOVMDelegate? = nil
    private var parent: DeviceDetailsCoordinator? = nil
    private var device: MetaWear? = nil

}

extension MWGPIOVM: DetailConfiguring {

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

public extension MWGPIOVM {

    func userDidSelectMode(_ mode: GPIOMode) {
        self.mode = mode
        delegate?.refreshView()
    }

    func userDidSelectPin(_ pin: GPIOPin) {
        pinSelected = pin
        delegate?.refreshView()
    }

    func userDidPressPull(_ pull: GPIOPullMode) {
        guard let board = device?.board else { return }
        changeType = .init(previous: pullMode, next: pull)
        pullMode = pull
        mbl_mw_gpio_set_pull_mode(board, pinSelected.pinValue, pullMode.cppEnumValue)
        delegate?.refreshView()
        delegate?.indicateCommandWasSentToBoard()
    }

    func userPressedSetPin() {
        guard let board = device?.board else { return }
        mbl_mw_gpio_set_digital_output(board, pinSelected.pinValue)
        delegate?.refreshView()
        delegate?.indicateCommandWasSentToBoard()
    }

    func userPressedClearPin() {
        guard let board = device?.board else { return }
        mbl_mw_gpio_clear_digital_output(board, pinSelected.pinValue)
        delegate?.refreshView()
        delegate?.indicateCommandWasSentToBoard()
    }

}

public extension MWGPIOVM {

    func userRequestedPinChangeStart() {
        guard let board = device?.board else { return }
        guard !isChangingPins else { return }
        isChangingPins = true
        delegate?.refreshView()
        delegate?.indicateCommandWasSentToBoard()

        let pin = pinSelected.pinValue
        mbl_mw_gpio_set_pin_change_type(board, pin, changeType.cppEnumValue)

        let signal = mbl_mw_gpio_get_pin_monitor_data_signal(board, pin)!
        mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, obj) in
            let response: UInt32 = obj!.pointee.valueAs()
            NSLog("PIN CHANGE RESPONSE: \(response)")

            let _self: MWGPIOVM = bridge(ptr: context!)
            DispatchQueue.main.async {
                _self.pinChangeCount += 1
                _self.delegate?.refreshView()
            }
        }
        mbl_mw_gpio_start_pin_monitoring(board, pin)

        let cleanup = {
            mbl_mw_gpio_stop_pin_monitoring(board, pin)
            mbl_mw_datasignal_unsubscribe(signal)
        }
        self.parent?.signals.storeStream(signal, cleanup: cleanup)
    }

    func userRequestedPinChangeStop() {
        guard let board = device?.board else { return }
        guard isChangingPins else { return }
        isChangingPins = false
        pinChangeCount = 0
        delegate?.refreshView()

        let pin = pinSelected.pinValue
        let signal = mbl_mw_gpio_get_pin_monitor_data_signal(board, pin)!
        parent?.signals.removeStream(signal)
        delegate?.indicateCommandWasSentToBoard()
    }

    func userRequestedDigitalReadout() {
        guard let board = device?.board else { return }
        delegate?.indicateCommandWasSentToBoard()
        let pin = pinSelected.pinValue
        let signal = mbl_mw_gpio_get_digital_input_data_signal(board, pin)!

        signal.read().continueOnSuccessWith { [weak self] data in
            let value: UInt32 = data.valueAs()
            DispatchQueue.main.async { [weak self] in
                self?.setDigitalValue(value)
            }
        }
    }

    func userRequestedAnalogAbsoluteReadout() {
        guard let board = device?.board else { return }
        delegate?.indicateCommandWasSentToBoard()
        let pin = pinSelected.pinValue
        let signal = mbl_mw_gpio_get_analog_input_data_signal(board, pin, MBL_MW_GPIO_ANALOG_READ_MODE_ABS_REF)!

        signal.read().continueOnSuccessWith { [weak self] data in
            let value: UInt32 = data.valueAs() // Units in mili volts
            DispatchQueue.main.async { [weak self] in
                self?.setAnalogAbsolute(value: value)
            }
        }

        delegate?.indicateCommandWasSentToBoard()
    }

    func userRequestedAnalogRatioReadout() {
        guard let board = device?.board else { return }
        delegate?.indicateCommandWasSentToBoard()
        let pin = pinSelected.pinValue
        let signal = mbl_mw_gpio_get_analog_input_data_signal(board, pin, MBL_MW_GPIO_ANALOG_READ_MODE_ADC)!

        signal.read().continueOnSuccessWith { [weak self] data in
            let value: UInt32 = data.valueAs() // Units in 10-bit ratio
            DispatchQueue.main.async { [weak self] in
                self?.setAnalogRatio(value: value)
            }
        }
    }
}

// MARK: - Helpers

private extension MWGPIOVM {

    private func setDigitalValue(_ value: UInt32) {
        digitalValue = value == 0 ? "0" : "1"
        delegate?.refreshView()
    }

    private func setAnalogAbsolute(value: UInt32) {
        analogAbsoluteValue = String(format: "%.3fV", Double(value) / 1000.0)
        delegate?.refreshView()
    }

    private func setAnalogRatio(value: UInt32) {
        analogRatioValue = String(format: "%.3f", Double(value) / 0x3ff)
        delegate?.refreshView()
    }
}
