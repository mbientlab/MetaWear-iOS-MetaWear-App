//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
import MetaWear
import MetaWearCpp

public class MWBarometerVM: BarometerVM {

    // Button state
    public private(set) var isStreaming = false

    // Sensor settings
    public private(set) var standbyTimeSelected: BarometerStandbyTime = .ms1000
    public private(set) var iirFilterSelected: BarometerIIRFilter = .avg16
    public private(set) var oversamplingSelected: BarometerOversampling = .standard

    // Sensor settings options available
    public private(set) lazy var standbyTimeOptions: [BarometerStandbyTime] = getStandbyOptions()
    public private(set) var iirTimeOptions: [BarometerIIRFilter] = BarometerIIRFilter.allCases
    public private(set) var oversamplingOptions: [BarometerOversampling] = BarometerOversampling.allCases

    // Data state
    public private(set) var altitude = Float(0)
    public private(set) var altitudeString = ""
    public let altitudeUnitLabel = "m"

    // Identity
    public var delegate: MWBarometerVMDelegate? = nil
    private var parent: DeviceDetailsCoordinator? = nil
    private var device: MetaWear? = nil
    private lazy var model: BarometerModel? = .init(board: device?.board)
}

extension MWBarometerVM: DetailConfiguring {

    public func configure(parent: DeviceDetailsCoordinator, device: MetaWear) {
        self.parent = parent
        self.device = device
    }

    public func start() {
        guard device?.board != nil else { return }
        isStreaming = false
        delegate?.refreshView()
    }
}

// MARK: - Intents for Configuration

public extension MWBarometerVM {

    func userSetStandbyTime(_ newValue: BarometerStandbyTime) {
        standbyTimeSelected = newValue
        delegate?.refreshView()
    }

    func userSetIIRFilter(_ newValue: BarometerIIRFilter) {
        iirFilterSelected = newValue
        delegate?.refreshView()
    }

    func userSetOversampling(_ newValue: BarometerOversampling) {
        oversamplingSelected = newValue
        delegate?.refreshView()
    }
}

// MARK: - Intents for Sensor Streaming

public extension MWBarometerVM {

    func userRequestedStreamStart() {
        isStreaming = true
        delegate?.refreshView()

        guard let board = device?.board else { return }

        mbl_mw_baro_bosch_set_oversampling(board, oversamplingSelected.cppEnumValue)
        mbl_mw_baro_bosch_set_iir_filter(board, iirFilterSelected.cppEnumValue)

        switch model {
            case .bme280:
                mbl_mw_baro_bme280_set_standby_time(board, standbyTimeSelected.BME_cppEnumValue)

            case .bmp280:
                mbl_mw_baro_bmp280_set_standby_time(board, standbyTimeSelected.BMP_cppEnumValue)

            case .none: break
        }

        mbl_mw_baro_bosch_write_config(board)

        let signal = mbl_mw_baro_bosch_get_altitude_data_signal(board)!
        mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, obj) in
            let altitude: Float = obj!.pointee.valueAs()
            let _self: MWBarometerVM = bridge(ptr: context!)
            DispatchQueue.main.async {
                _self.setBarometerValue(altitude)
            }
        }
        mbl_mw_baro_bosch_start(board)

        let cleanup = {
            mbl_mw_baro_bosch_stop(board)
            mbl_mw_datasignal_unsubscribe(signal)
        }
        parent?.storeStream(signal, cleanup: cleanup)
    }

    func userRequestedStreamStop() {
        isStreaming = false
        delegate?.refreshView()
        guard let board = device?.board else { return }

        let signal = mbl_mw_baro_bosch_get_altitude_data_signal(board)!
        parent?.removeStream(signal)
    }

}

// MARK: - Helpers

private extension MWBarometerVM {

    func getStandbyOptions() -> [BarometerStandbyTime] {
        switch model {
            case .bme280: return BarometerStandbyTime.BMEoptions
            case .bmp280: return BarometerStandbyTime.BMPoptions
            // The below case should never occur, but providing safe options anyway
            case .none:
                let intersection = Set(BarometerStandbyTime.BMPoptions).intersection(Set(BarometerStandbyTime.BMEoptions))
                return intersection.sortedByRawValue()
        }
    }

    private func setBarometerValue(_ value: Float) {
        altitude = value
        altitudeString = String(format: "%.3f", value)
        delegate?.refreshView()
    }
}
