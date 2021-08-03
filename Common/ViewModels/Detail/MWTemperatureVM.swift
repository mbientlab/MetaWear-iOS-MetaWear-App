//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
import MetaWear
import MetaWearCpp

public class MWDetailTemperatureVM: DetailTemperatureVM {

    public var channels: [String] = []
    public var selectedChannelIndex = 0
    public var selectedChannelType = ""
    public var temperature = ""

    public var showPinDetail = false
    public var readPin = ""
    public var enablePin = ""

    public var delegate: DetailTemperatureVMDelegate? = nil
    private weak var parent: DeviceDetailsCoordinator? = nil
    private weak var device: MetaWear? = nil

}

extension MWDetailTemperatureVM: DetailConfiguring {

    public func configure(parent: DeviceDetailsCoordinator, device: MetaWear) {
        self.parent = parent
        self.device = device
    }
}

extension MWDetailTemperatureVM {

    public func start() {
        channels = []
        guard let device = device else { return }

        let maxChannels = mbl_mw_multi_chnl_temp_get_num_channels(device.board)
        for i in 0..<maxChannels {
            channels.append(String(i))
        }

        selectedChannelIndex = 0
        selectChannel(at: selectedChannelIndex)
        readTemperature()
        delegate?.resetView()
    }

}

// MARK: - Intents

extension MWDetailTemperatureVM {

    public func selectChannel(at index: Int) {
        guard let device = device else { return }
        selectedChannelIndex = index
        let source = mbl_mw_multi_chnl_temp_get_source(device.board, UInt8(selectedChannelIndex))

        switch source {
            case MBL_MW_TEMPERATURE_SOURCE_NRF_DIE:
                selectedChannelType = "On-Die"
            case MBL_MW_TEMPERATURE_SOURCE_EXT_THERM:
                selectedChannelType = "External"
            case MBL_MW_TEMPERATURE_SOURCE_BMP280:
                selectedChannelType = "BMP280"
            case MBL_MW_TEMPERATURE_SOURCE_PRESET_THERM:
                selectedChannelType = "On-Board"
            default:
                selectedChannelType = "Custom"
        }

        showPinDetail = source == MBL_MW_TEMPERATURE_SOURCE_EXT_THERM
        readTemperature()
        delegate?.refreshView()
    }

    public func readTemperature() {
        guard let device = device else { return }

        let isBMP280 = selectedChannelType == "BMP280"

        if isBMP280 {
            mbl_mw_baro_bosch_start(device.board)
        }

        let selected = mbl_mw_multi_chnl_temp_get_temperature_data_signal(device.board, UInt8(selectedChannelIndex))!
        selected.read().continueOnSuccessWith(.mainThread) { [self] obj in
            self.temperature = String(format: "%.1f°C", (obj.valueAs() as Float))
        }

        if isBMP280 {
            mbl_mw_baro_bosch_stop(device.board)
        }
        
        delegate?.refreshView()
    }

    public func setReadPin(_ newValue: String) {
#warning("Not implemented in original app, but present in UI")
    }

    public func setEnablePin(_ newValue: String) {
#warning("Not implemented in original app, but present in UI")
    }
}
