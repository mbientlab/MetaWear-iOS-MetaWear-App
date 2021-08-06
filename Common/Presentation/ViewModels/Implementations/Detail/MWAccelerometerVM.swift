//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
import MetaWear
import MetaWearCpp
import Combine

public class MWDetailAccelerometerVM: DetailAccelerometerVM {

    public private(set) var isLogging = false
    public private(set) var isStreaming = false
    public private(set) var allowsNewLogging = false
    public private(set) var allowsNewStreaming = false

    public private(set) var isStepping = false
    public private(set) var stepCount = 0
    public private(set) var stepCountString = ""

    public private(set) var orientation = ""
    @objc public private(set) var isOrienting = false

    public private(set) var graphScales = AccelerometerGraphScale.allCases
    public private(set) var graphScaleSelected = AccelerometerGraphScale.two
    public private(set) var samplingFrequencies = AccelerometerSampleFrequency.allCases
    public private(set) var samplingFrequencySelected = AccelerometerSampleFrequency.hz100

    public private(set) var isDownloadingLog = false
    public var canDownloadLog: Bool { downloadLogger != nil || isLogging }
    public var logDataIsReadyForDisplay: Bool { !data.logged.isEmpty && !isDownloadingLog }
    public var streamDataIsReadyForDisplay: Bool { !data.stream.isEmpty }

    private(set) var data = MWSensorDataStore()
    private var loggingKey = "acceleration"
    private var downloadLogger: OpaquePointer? = nil

    lazy private var model: AccelerometerModel? = getAccelerometerModel()
    public var delegate: DetailAccelerometerVMDelegate? = nil
    private weak var parent: DeviceDetailsCoordinator? = nil
    private weak var device: MetaWear? = nil

    private var streamingStatsTimer: AnyCancellable? = nil
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

        let loggerExists = parent?.loggers["acceleration"] != nil

        isLogging = loggerExists
        isStreaming = false
        allowsNewLogging = !isLogging
        allowsNewStreaming = true

        delegate?.refreshView()
    }

}

// MARK: - Intents for Configuration

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

}

// MARK: - Intents for Sensor Streaming and Logging

public extension MWDetailAccelerometerVM {

    func userRequestedLogExport() {
        parent?.export(data.makeLogData(), titled: "AccLogData")
    }

    func userRequestedStreamExport() {
        parent?.export(data.makeStreamData(), titled: "AccStreamData")
    }

    private func startStreamingStatsUpdateTimer() {
        streamingStatsTimer = Timer.publish(every: 3, tolerance: 1, on: .main, in: .default)
                .autoconnect()
                .receive(on: DispatchQueue.global())
                .sink { [weak self] _ in
                    self?.delegate?.refreshStreamStats()
                }
    }

    private func cancelStreamingStatsUpdateTimer() {
        streamingStatsTimer = nil
    }

    func userRequestedStartStreaming() {
        guard let board = device?.board else { return }

        if isLogging {
            userRequestedStopLogging()
        }

        isStreaming = true
        allowsNewStreaming = false
        isLogging = false
        allowsNewLogging = false

        DispatchQueue.main.async {
            self.data.clearStreamed()
            self.delegate?.refreshView()
            self.delegate?.redrawStreamGraph()
            self.startStreamingStatsUpdateTimer()
        }

        updateAccelerometerSettingsPriorToStream()

        let signal = mbl_mw_acc_bosch_get_acceleration_data_signal(board)!
        mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, obj) in
            let acceleration: MblMwCartesianFloat = obj!.pointee.valueAs()
            let point = (obj!.pointee.epoch, acceleration)
            let _self: MWDetailAccelerometerVM = bridge(ptr: context!)
            DispatchQueue.main.async {
                _self.delegate?.drawNewStreamGraphPoint(point)
            }
            _self.data.stream.append(point)
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

    func userRequestedStopStreaming() {
        isStreaming = false
        isLogging = false
        allowsNewStreaming = true
        allowsNewLogging = true

        delegate?.refreshView()
        delegate?.refreshStreamStats()

        guard let board = device?.board else { return }
        let signal = mbl_mw_acc_bosch_get_acceleration_data_signal(board)!
        parent?.removeStream(signal)
    }

    func userRequestedStartLogging() {
        isStreaming = false
        isLogging = true
        allowsNewStreaming = false
        allowsNewLogging = false

        data.clearLogged()
        delegate?.refreshView()
        delegate?.refreshLoggerStats()

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

    func userRequestedStopLogging() {
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
        downloadLogger = logger
    }

    func userRequestedDownloadLog() {
        guard let board = device?.board else { return }
        guard let logger = downloadLogger else {
            parent?.toast.present(.textOnly, "No Logger Found", disablesInteraction: false, onDismiss: nil)
            parent?.toast.dismiss(delay: 1.5)
            return
        }

        isDownloadingLog = true
        data.clearLogged()
        delegate?.refreshLoggerStats()
        delegate?.refreshView()
        parent?.toast.present(.horizontalProgress, "Downloading", disablesInteraction: true, onDismiss: nil)

        mbl_mw_logger_subscribe(logger, bridge(obj: self)) { (context, obj) in
            let acceleration: MblMwCartesianFloat = obj!.pointee.valueAs()
            let _self: MWDetailAccelerometerVM = bridge(ptr: context!)
            _self.data.logged.append((obj!.pointee.epoch, acceleration))
        }

        var handlers = MblMwLogDownloadHandler()
        handlers.context = bridgeRetained(obj: self)
        handlers.received_progress_update = { (context, remainingEntries, totalEntries) in
            let _self: MWDetailAccelerometerVM = bridge(ptr: context!)
            let progress = Double(totalEntries - remainingEntries) / Double(totalEntries)
            let safeProgress = progress.isNaN ? 0 : progress
            let percentage = Int(safeProgress * 100)

            if safeProgress != 0 {
                DispatchQueue.main.async {
                    guard percentage != _self.parent?.toast.percentComplete else { return }
                    _self.parent?.toast.updateProgress(percentage: percentage)
                }
            }

            if remainingEntries == 0 {
                DispatchQueue.main.async {
                    _self.isDownloadingLog = false
                    _self.delegate?.refreshLoggerStats()
                    _self.delegate?.refreshView()
                    _self.parent?.toast.update(mode: .foreverSpinner, text: "Clearing log", disablesBluetoothActions: true, onDismiss: nil)
                }

                _self.parent?.logCleanup { error in
                    DispatchQueue.main.async {
                        _self.parent?.toast.dismiss(delay: 0)
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

        downloadLogger = nil
    }
}

// MARK: - Intents for Orienting and Stepping

public extension MWDetailAccelerometerVM {

    func userRequestedStartOrienting() {
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

    func userRequestedStopOrienting() {
        guard model != .bmi270 else { return }
        guard let board = device?.board else { return }

        isOrienting = false
        orientation = "—"
        delegate?.refreshView()

        let signal = mbl_mw_acc_bosch_get_orientation_detection_data_signal(board)!
        parent?.removeStream(signal)
    }

    func userRequestedStartStepping() {
        guard model != .bmi270 else { return }
        guard let board = device?.board else { return }

        isStepping = true
        stepCount = 0
        stepCountString = "0"
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

    func userRequestedStopStepping() {
        guard model != .bmi270 else { return }
        guard let board = device?.board else { return }

        isStepping = false
        delegate?.refreshView()

        let signal = mbl_mw_acc_bmi160_get_step_detector_data_signal(board)!
        parent?.removeStream(signal)
    }
}

// MARK: - Helpers

private extension MWDetailAccelerometerVM {

    func getAccelerometerModel() -> AccelerometerModel? {
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
