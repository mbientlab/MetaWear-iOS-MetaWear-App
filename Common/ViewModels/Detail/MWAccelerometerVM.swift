//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
import MetaWear
import MetaWearCpp

public class MWDetailAccelerometerVM: DetailAccelerometerVM {

    public private(set) var isLogging = false
    public private(set) var isStreaming = false
    public private(set) var allowsNewLogging = false
    public private(set) var allowsNewStreaming = false

    public private(set) var isStepping = false
    public private(set) var stepCount = 0
    public private(set) var stepCountString = ""

    public private(set) var orientation = ""
    public private(set) var isOrienting = false

    public private(set) var graphScales = AccelerometerGraphScale.allCases
    public private(set) var graphScaleSelected = AccelerometerGraphScale.two
    public private(set) var samplingFrequencies = AccelerometerSampleFrequency.allCases
    public private(set) var samplingFrequencySelected = AccelerometerSampleFrequency.hz800


    lazy private var model: AccelerometerModel? = getAccelerometerModel()
    private var loggingKey = "acceleration"
    private var accelerometerBMI160Data: [(Int64, MblMwCartesianFloat)] = []

    public var delegate: DetailAccelerometerVMDelegate? = nil
    private weak var parent: DeviceDetailsCoordinator? = nil
    private weak var device: MetaWear? = nil

}

extension MWDetailAccelerometerVM: DetailConfiguring {

    public func configure(parent: DeviceDetailsCoordinator, device: MetaWear) {
        self.parent = parent
        self.device = device
    }
}

extension MWDetailAccelerometerVM {

    public func start() {
        guard device?.board != nil else { return }
        guard model == .bmi160 || model == .bmi270 else { return }
        isStreaming = false
        isLogging = parent?.loggers["acceleration"] != nil
        allowsNewStreaming = !isStreaming && !isLogging
        allowsNewLogging = !isLogging
        delegate?.refreshView()
    }

    private func getAccelerometerModel() -> AccelerometerModel? {
        guard let board = device?.board else { return nil }
        return .init(board: board)
    }

    /// Send user preferences to device before starting a new stream
    func updateAccelerometerSettingsPriorToStream() {
        guard let board = device?.board else { return }

        mbl_mw_acc_bosch_set_range(board, graphScaleSelected.cppEnumValue)
        mbl_mw_acc_set_odr(board, samplingFrequencySelected.frequency)
        mbl_mw_acc_bosch_write_acceleration_config(board)
    }
}

// MARK: - Intents

extension MWDetailAccelerometerVM {

    public func userDidSelectSamplingFrequency(_ frequency: AccelerometerSampleFrequency) {
        self.samplingFrequencySelected = frequency
        delegate?.refreshView()
    }

    public func userDidSelectGraphScale(_ scale: AccelerometerGraphScale) {
        self.graphScaleSelected = scale
        delegate?.refreshView()
        delegate?.refreshGraphScale()
    }

    public func userRequestedDataExport() {
        var accelerometerData = Data()
        for dataElement in accelerometerBMI160Data {
            accelerometerData.append("\(dataElement.0),\(dataElement.1.x),\(dataElement.1.y),\(dataElement.1.z)\n".data(using: String.Encoding.utf8)!)
        }
        parent?.export(accelerometerData, titled: "AccData")
    }

    public func userRequestedStartStreaming() {
        isStreaming = true
        allowsNewStreaming = false
        isLogging = false
        allowsNewLogging = false
        delegate?.refreshView()

        guard let board = device?.board else { return }

        updateAccelerometerSettingsPriorToStream()
        accelerometerBMI160Data.removeAll()

        DispatchQueue.main.async {
            self.delegate?.willStartNewGraphStream()
        }

        let signal = mbl_mw_acc_bosch_get_acceleration_data_signal(board)!
        mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, obj) in
            let acceleration: MblMwCartesianFloat = obj!.pointee.valueAs()
            let _self: MWDetailAccelerometerVM = bridge(ptr: context!)
            DispatchQueue.main.async {
                _self.delegate?.drawNewGraphPoint(x: acceleration.x,
                                                  y: acceleration.y,
                                                  z: acceleration.z)
            }
            // Add data to data array for saving
            _self.accelerometerBMI160Data.append((obj!.pointee.epoch, acceleration))
        }
        mbl_mw_acc_enable_acceleration_sampling(board)
        mbl_mw_acc_start(board)

        let cleanup = {
            mbl_mw_acc_stop(board)
            mbl_mw_acc_disable_acceleration_sampling(board)
            mbl_mw_datasignal_unsubscribe(signal)
        }
        parent?.storeStream(signal, cleanup: cleanup)
    }

    public func userRequestedStopStreaming() {
        isStreaming = false
        isLogging = false
        allowsNewStreaming = true
        allowsNewLogging = true
        delegate?.refreshView()

        guard let board = device?.board else { return }
        let signal = mbl_mw_acc_bosch_get_acceleration_data_signal(board)!
        parent?.removeStream(signal)
    }

    public func userRequestedStartLogging() {
        isStreaming = false
        isLogging = true
        allowsNewStreaming = false
        allowsNewLogging = false
        delegate?.refreshView()

        updateAccelerometerSettingsPriorToStream()
        guard let board = device?.board else { return }

        let signal = mbl_mw_acc_bosch_get_acceleration_data_signal(board)!
        mbl_mw_datasignal_log(signal, bridge(obj: self)) { (context, logger) in
            let _self: MWDetailAccelerometerVM = bridge(ptr: context!)
            let cString = mbl_mw_logger_generate_identifier(logger)!
            let identifier = String(cString: cString)
            _self.loggingKey = identifier
            _self.parent?.addLog(identifier, logger!)
        }
        mbl_mw_logging_start(board, 0)
        mbl_mw_acc_enable_acceleration_sampling(board)
        mbl_mw_acc_start(board)
    }

    public func userRequestedStopAndDownloadLog() {
        isStreaming = false
        isLogging = false
        allowsNewStreaming = true
        allowsNewLogging = true
        delegate?.refreshView()

        guard let board = device?.board else { return }
        guard let logger = parent?.removeLog(loggingKey) else { return }
        mbl_mw_acc_stop(board)
        mbl_mw_acc_disable_acceleration_sampling(board)
        if model == .bmi270 {
            mbl_mw_logging_flush_page(board)
        }

        parent?.hud.presentProgressHUD(label: "Downloading...", in: nil)
        DispatchQueue.main.async {
            self.delegate?.willStartNewGraphStream()
        }

        accelerometerBMI160Data.removeAll()
        mbl_mw_logger_subscribe(logger, bridge(obj: self)) { (context, obj) in
            let acceleration: MblMwCartesianFloat = obj!.pointee.valueAs()
            let _self: MWDetailAccelerometerVM = bridge(ptr: context!)
            DispatchQueue.main.async {
                _self.delegate?.drawNewGraphPoint(x: acceleration.x,
                                                  y: acceleration.y,
                                                  z: acceleration.z)
            }
            // Add data to data array for saving
            _self.accelerometerBMI160Data.append((obj!.pointee.epoch, acceleration))
        }

        var handlers = MblMwLogDownloadHandler()
        handlers.context = bridgeRetained(obj: self)
        handlers.received_progress_update = { (context, remainingEntries, totalEntries) in
            let _self: MWDetailAccelerometerVM = bridge(ptr: context!)
            let progress = Double(totalEntries - remainingEntries) / Double(totalEntries)
            DispatchQueue.main.async {
                _self.parent?.hud.updateProgressHUD(percentage: Float(progress))
            }
            if remainingEntries == 0 {
                DispatchQueue.main.async {
                    _self.parent?.hud.updateHUD(mode: .indeterminate, newText: "Clearing log...")
                }

                _self.parent?.logCleanup { error in
                    DispatchQueue.main.async {
                        _self.parent?.hud.closeHUD(finalMessage: nil, delay: 0)
                        if error != nil {
                            _self.parent?.connectDevice(true)
                        }
                    }
                }
            }
        }
        handlers.received_unknown_entry = { (context, id, epoch, data, length) in
            NSLog("received_unknown_entry")
        }
        handlers.received_unhandled_entry = { (context, data) in
            NSLog("received_unhandled_entry")
        }
        mbl_mw_logging_download(board, 100, &handlers)
    }

    public func userRequestedStartOrienting() {
        guard model != .bmi270 else { return }
        guard let board = device?.board else { return }

        isOrienting = true
        delegate?.refreshView()
        updateAccelerometerSettingsPriorToStream()

        let signal = mbl_mw_acc_bosch_get_orientation_detection_data_signal(board)!
        mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, obj) in
            let orientation: MblMwSensorOrientation = obj!.pointee.valueAs()
            let _self: MWDetailAccelerometerVM = bridge(ptr: context!)
            DispatchQueue.main.async {
                switch orientation {
                    case MBL_MW_SENSOR_ORIENTATION_FACE_UP_PORTRAIT_UPRIGHT:
                        _self.orientation = "Portrait Face Up"
                    case MBL_MW_SENSOR_ORIENTATION_FACE_UP_PORTRAIT_UPSIDE_DOWN:
                        _self.orientation = "Portrait Upside Down Face Up"
                    case MBL_MW_SENSOR_ORIENTATION_FACE_UP_LANDSCAPE_LEFT:
                        _self.orientation = "Landscape Left Face Up"
                    case MBL_MW_SENSOR_ORIENTATION_FACE_UP_LANDSCAPE_RIGHT:
                        _self.orientation = "Landscape Right Face Up"
                    case MBL_MW_SENSOR_ORIENTATION_FACE_DOWN_PORTRAIT_UPRIGHT:
                        _self.orientation = "Portrait Face Down"
                    case MBL_MW_SENSOR_ORIENTATION_FACE_DOWN_PORTRAIT_UPSIDE_DOWN:
                        _self.orientation = "Portrait Upside Down Face Down"
                    case MBL_MW_SENSOR_ORIENTATION_FACE_DOWN_LANDSCAPE_LEFT:
                        _self.orientation = "Landscape Left Face Down"
                    case MBL_MW_SENSOR_ORIENTATION_FACE_DOWN_LANDSCAPE_RIGHT:
                        _self.orientation = "Landscape Right Face Down"
                    default:
                        _self.orientation = "N/A"
                }
                _self.delegate?.refreshView()
            }
        }
        mbl_mw_acc_bosch_enable_orientation_detection(board)
        mbl_mw_acc_start(board)


        let cleanup = {
            mbl_mw_acc_stop(board)
            mbl_mw_acc_bosch_disable_orientation_detection(board)
            mbl_mw_datasignal_unsubscribe(signal)
        }
        parent?.storeStream(signal, cleanup: cleanup)
    }

    public func userRequestedStopOrienting() {
        guard model != .bmi270 else { return }
        guard let board = device?.board else { return }

        isOrienting = false
        orientation = "XXXXXXXXXXXXXX"
        delegate?.refreshView()

        let signal = mbl_mw_acc_bosch_get_orientation_detection_data_signal(board)!
        parent?.removeStream(signal)
    }

    public func userRequestedStartStepping() {
        guard model != .bmi270 else { return }
        guard let board = device?.board else { return }

        isStepping = true
        delegate?.refreshView()
        updateAccelerometerSettingsPriorToStream()

        let signal = mbl_mw_acc_bmi160_get_step_detector_data_signal(board)!
        mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, obj) in
            let _self: MWDetailAccelerometerVM = bridge(ptr: context!)
            _self.stepCount += 1
            DispatchQueue.main.async {
                _self.stepCountString = String(_self.stepCount)
                _self.delegate?.refreshView()
            }
        }
        mbl_mw_acc_bmi160_enable_step_detector(board)
        mbl_mw_acc_start(board)


        let cleanup = {
            mbl_mw_acc_stop(board)
            mbl_mw_acc_bmi160_disable_step_detector(board)
            mbl_mw_datasignal_unsubscribe(signal)
        }
        parent?.storeStream(signal, cleanup: cleanup)
    }

    public func userRequestedStopStepping() {
        guard model != .bmi270 else { return }
        guard let board = device?.board else { return }

        isStepping = false
        stepCount = 0
        stepCountString = "Step Count: 0"
        delegate?.refreshView()

        let signal = mbl_mw_acc_bmi160_get_step_detector_data_signal(board)!
        parent?.removeStream(signal)
    }
}
