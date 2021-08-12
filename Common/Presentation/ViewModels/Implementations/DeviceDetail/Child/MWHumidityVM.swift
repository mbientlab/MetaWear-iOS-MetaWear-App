//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
import MetaWear
import MetaWearCpp
import Combine

public class MWHumidityVM: HumidityVM {

    public private(set) var humidity = Float(0)
    public private(set) var humidityReadout = " "

    public private(set) var isStreaming = false
    public private(set) var isOversampling = true

    public private(set) var oversamplingSelected: HumidityOversampling = .x1
    public let oversamplingOptions = HumidityOversampling.allCases


    // Identity
    public weak var delegate: HumidityVMDelegate? = nil
    private var parent: DeviceDetailsCoordinator? = nil
    private var device: MetaWear? = nil
}

extension MWHumidityVM: DetailConfiguring {

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

public extension MWHumidityVM {

    func userSetHumidityOversampling(_ newValue: HumidityOversampling) {
        oversamplingSelected = newValue
        delegate?.refreshView()
    }

    func userRequestedStreamingStart() {
        guard let device = device else { return }
        isStreaming = true
        isOversampling = false
        delegate?.refreshView()

        mbl_mw_humidity_bme280_set_oversampling(device.board, oversamplingSelected.cppEnumValue)

        let signal = mbl_mw_humidity_bme280_get_percentage_data_signal(device.board)!
        mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, obj) in

            let humidity: Float = obj!.pointee.valueAs()
            let _self: MWHumidityVM = bridge(ptr: context!)
            DispatchQueue.main.async {
                _self.updateHumidity(humidity)
            }
        }

        // Reads every 700 ms
        device.timerCreate(period: 700).continueOnSuccessWith { [weak self] timer in
            guard let self = self else { return }

            let cleanup = {
                mbl_mw_timer_remove(timer)
                mbl_mw_datasignal_unsubscribe(signal)
            }
            self.parent?.storeStream(timer, cleanup: cleanup)

            mbl_mw_event_record_commands(timer)
            mbl_mw_datasignal_read(signal)

            timer.eventEndRecord().continueOnSuccessWith {
                mbl_mw_timer_start(timer)
            }
        }
    }

    private func updateHumidity(_ value: Float) {
        humidity = value
        humidityReadout = String(format: "%.2f", value)
    }

    func userRequestedStreamingStop() {
        guard let board = device?.board else { return }
        isStreaming = false
        isOversampling = true
        delegate?.refreshView()

        let signal = mbl_mw_humidity_bme280_get_percentage_data_signal(board)!
        parent?.removeStream(signal)
    }
}
