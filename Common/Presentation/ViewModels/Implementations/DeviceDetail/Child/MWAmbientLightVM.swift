//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
import MetaWear
import MetaWearCpp

public class MWAmbientLightVM: ObservableObject, AmbientLightVM {

    // Button state
    public private(set) var isStreaming = false

    // Sensor settings
    public private(set) var gainOptions: [AmbientLightGain] = AmbientLightGain.allCases
    public private(set) var gainSelected: AmbientLightGain = .gain96
    public private(set) var integrationTimeOptions: [AmbientLightTR329IntegrationTime] = AmbientLightTR329IntegrationTime.allCases
    public private(set) var integrationTimeSelected: AmbientLightTR329IntegrationTime = .ms400
    public private(set) var measurementRateOptions: [AmbientLightTR329MeasurementRate] = AmbientLightTR329MeasurementRate.allCases
    public private(set) var measurementRateSelected: AmbientLightTR329MeasurementRate = .ms2000

    // Data state
    public private(set) var illuminance: Double = 0
    public private(set) var illuminanceString: String = " "
    public let illuminanceUnitLabel = "lux"

    // Identity
    public var delegate: AmbientLightVMDelegate? = nil
    private var parent: DeviceDetailsCoordinator? = nil
    private var device: MetaWear? = nil

}

extension MWAmbientLightVM: DetailConfiguring {

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

public extension MWAmbientLightVM {

    func userSetGain(_ newValue: AmbientLightGain) {
        gainSelected = newValue
        delegate?.refreshView()
    }

    func userSetIntegrationTime(_ newValue: AmbientLightTR329IntegrationTime) {
        integrationTimeSelected = newValue
        delegate?.refreshView()
    }

    func userSetMeasurementRate(_ newValue: AmbientLightTR329MeasurementRate) {
        measurementRateSelected = newValue
        delegate?.refreshView()
    }
}

// MARK: - Intents for Sensor Streaming

public extension MWAmbientLightVM {

    func userRequestedStreamStart() {
        isStreaming = true
        delegate?.refreshView()

        guard let board = device?.board else { return }
        mbl_mw_als_ltr329_set_gain(board, gainSelected.cppEnumValue)
        mbl_mw_als_ltr329_set_integration_time(board, integrationTimeSelected.cppEnumValue)
        mbl_mw_als_ltr329_set_measurement_rate(board, measurementRateSelected.cppEnumValue)
        mbl_mw_als_ltr329_write_config(board)

        let signal = mbl_mw_als_ltr329_get_illuminance_data_signal(board)!
        mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, obj) in
            let illuminance: UInt32 = obj!.pointee.valueAs()
            let _self: MWAmbientLightVM = bridge(ptr: context!)
            DispatchQueue.main.async {
                _self.setIlluminanceLabel(illuminance)
            }
        }
        mbl_mw_als_ltr329_start(board)

        let cleanup = {
            mbl_mw_als_ltr329_stop(board)
            mbl_mw_datasignal_unsubscribe(signal)
        }
        parent?.storeStream(signal, cleanup: cleanup)
    }

    func userRequestedStreamStop() {
        isStreaming = false
        delegate?.refreshView()
        guard let board = device?.board else { return }

        let signal = mbl_mw_als_ltr329_get_illuminance_data_signal(board)!
        parent?.removeStream(signal)
    }
}

// MARK: - Helpers

private extension MWAmbientLightVM {

    func setIlluminanceLabel(_ value: UInt32) {
        illuminance = Double(value) / 1000.0
        illuminanceString = String(format: "%.3f", illuminance)
        delegate?.refreshView()
    }
}
