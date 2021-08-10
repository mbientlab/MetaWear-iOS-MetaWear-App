//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
import MetaWear
import MetaWearCpp

public class MWTemperatureVM: TemperatureVM {

    public private(set) var channels: [String] = []
    public private(set) var selectedChannelIndex = 0
    public var selectedChannelType: String { selectedSource.displayName }
    public private(set) var selectedSource = TemperatureSource.onboard
    public private(set) var temperature = " "
    public private(set) var temperatureCelcius = Float(0)

    public private(set) var showPinDetail = false
    public private(set) var readPin = ""
    public private(set) var enablePin = ""

    // Identity
    public var delegate: TemperatureVMDelegate? = nil
    private weak var parent: DeviceDetailsCoordinator? = nil
    private weak var device: MetaWear? = nil

}

extension MWTemperatureVM: DetailConfiguring {

    public func configure(parent: DeviceDetailsCoordinator, device: MetaWear) {
        self.parent = parent
        self.device = device
    }

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

public extension MWTemperatureVM {

    func selectChannel(at index: Int) {
        guard let device = device else { return }
        selectedChannelIndex = index
        let source = mbl_mw_multi_chnl_temp_get_source(device.board, UInt8(selectedChannelIndex))
        selectedSource = TemperatureSource(cpp: source)
        showPinDetail = selectedSource == .external
        readTemperature()
        delegate?.refreshView()
    }

    func readTemperature() {
        guard let device = device else { return }
        switch selectedSource {
            case .bmp280:
                mbl_mw_baro_bosch_start(device.board)
                readSensor()
                mbl_mw_baro_bosch_stop(device.board)

            case .external:
                readExternalThermistor()

            default:
                readSensor()
        }


    }

    func setReadPin(_ newValue: String) {
        readPin = newValue
        delegate?.refreshView()
    }

    func setEnablePin(_ newValue: String) {
        enablePin = newValue
        delegate?.refreshView()
    }
}

// MARK: - Helpers

private extension MWTemperatureVM {

    func readSensor() {
        guard let device = device else { return }
        let channel = UInt8(selectedChannelIndex)
        let selected = mbl_mw_multi_chnl_temp_get_temperature_data_signal(device.board, channel)!

        selected.read().continueOnSuccessWith(.mainThread) { [weak self] obj in
            self?.setTemperature((obj.valueAs() as Float))
        }
    }

    func readExternalThermistor() {
        guard let board = device?.board else { return }
        let channel = UInt8(selectedChannelIndex)
        guard let dataPin = UInt8(readPin),
              let pulldownPin = UInt8(enablePin)
        else {
            parent?.alerts.presentAlert(title: "Invalid GPIO Pin", message: "Input must be representable as UInt8.")
            return
        }
        let isActiveHigh = UInt8(1)
#warning("Original App — Not implemented, but present in UI. Documentation unclear on Read vs Enable terminology. Is this correct? I'm unfamiliar with GPIO")
        mbl_mw_multi_chnl_temp_configure_ext_thermistor(board, channel, dataPin, pulldownPin, isActiveHigh)
        readSensor()

    }

    func setTemperature(_ temp: Float) {
        self.temperatureCelcius = temp
        self.temperature = String(format: "%.1f°C", temp)
        delegate?.refreshView()
    }
}
