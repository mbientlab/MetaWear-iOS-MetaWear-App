//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
import MetaWear
import MetaWearCpp
import Combine

public class MWAccelerometerVM: AccelerometerVM {

    // Button states
    public private(set) var isLogging = false
    public private(set) var isStreaming = false
    public private(set) var allowsNewLogging = false
    public private(set) var allowsNewStreaming = false

    public var canOrientOrStep: Bool { model != .bmi270 }

    // Step count state
    public private(set) var isStepping = false
    public private(set) var stepCount = 0
    public var stepCountString: String { String(stepCount) }

    // Orientation state
    public private(set) var orientation = ""
    @objc public private(set) var isOrienting = false

    // Accelerometer settings + graph settings
    public private(set) var graphScales = AccelerometerGraphScale.allCases
    public private(set) var graphScaleSelected = AccelerometerGraphScale.two
    public private(set) var samplingFrequencies = AccelerometerSampleFrequency.allCases
    public private(set) var samplingFrequencySelected = AccelerometerSampleFrequency.hz100

    // Data transfer UI state
    public var streamDataIsReadyForDisplay: Bool { !data.stream.isEmpty }
    private var streamingStatsTimer: AnyCancellable? = nil

    public private(set) var isDownloadingLog = false
    public var canDownloadLog: Bool { downloadLogger != nil || isLogging }
    public var logDataIsReadyForDisplay: Bool { !data.logged.isEmpty }

    // Data transfer state
    private(set) var data = MWSensorDataStore()
    private var loggingKey = "acceleration"
    private var downloadLogger: OpaquePointer? = nil
    private lazy var downloadProgressHandler = ToastPresentingLogDownloader()

    // Identity
    lazy private var model: AccelerometerModel? = .init(board: device?.board)
    public weak var delegate: AccelerometerVMDelegate? = nil
    private weak var parent: DeviceDetailsCoordinator? = nil
    private weak var device: MetaWear? = nil
}

extension MWAccelerometerVM: DetailConfiguring {

    public func configure(parent: DeviceDetailsCoordinator, device: MetaWear) {
        self.parent = parent
        self.device = device
    }

    public func start() {
        guard device?.board != nil else { return }
        guard model == .bmi160 || model == .bmi270 else { return }

        let loggerExists = parent?.signals.loggers[loggingKey] != nil

        isLogging = loggerExists
        isStreaming = false
        allowsNewLogging = !isLogging
        allowsNewStreaming = true

        delegate?.refreshView()
    }
}

// MARK: - Intents for Configuration

extension MWAccelerometerVM {

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

// MARK: - Intents for Streaming

public extension MWAccelerometerVM {

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
            self.data.clearStreamed(newKind: .cartesianXYZ)
            self.delegate?.refreshView()
            self.delegate?.redrawStreamGraph()
            self.startStreamingStatsUpdateTimer()
        }

        updateAccelerometerSettingsPriorToStream()

        let signal = mbl_mw_acc_bosch_get_acceleration_data_signal(board)!
        mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, obj) in
            let acceleration: MblMwCartesianFloat = obj!.pointee.valueAs()
            let point = (obj!.pointee.epoch, acceleration)
            let _self: MWAccelerometerVM = bridge(ptr: context!)
            DispatchQueue.main.async {
                _self.delegate?.drawNewStreamGraphPoint(point)
            }
            _self.data.stream.append(.init(cartesian: point))
        }
        mbl_mw_acc_enable_acceleration_sampling(board)
        mbl_mw_acc_start(board)

        let cleanup = {
            mbl_mw_acc_stop(board)
            mbl_mw_acc_disable_acceleration_sampling(board)
            mbl_mw_datasignal_unsubscribe(signal)
        }

        parent?.signals.storeStream(signal, cleanup: cleanup)
    }

    func userRequestedStopStreaming() {
        isStreaming = false
        isLogging = false
        allowsNewStreaming = true
        allowsNewLogging = true

        cancelStreamingStatsUpdateTimer()
        delegate?.refreshView()
        delegate?.refreshStreamStats()

        guard let board = device?.board else { return }
        let signal = mbl_mw_acc_bosch_get_acceleration_data_signal(board)!
        parent?.signals.removeStream(signal)
    }

    func userRequestedStreamExport() {
        parent?.export(data.makeStreamData, titled: "AccStreamData")
    }

}

// Helpers
private extension MWAccelerometerVM {

    func startStreamingStatsUpdateTimer() {
        streamingStatsTimer = Timer.publish(every: 3, tolerance: 1, on: .main, in: .default)
                .autoconnect()
                .receive(on: DispatchQueue.global())
                .sink { [weak self] _ in
                    self?.delegate?.refreshStreamStats()
                }
    }

    func cancelStreamingStatsUpdateTimer() {
        streamingStatsTimer = nil
    }
}

// MARK: - Intents for Logging

public extension MWAccelerometerVM {

    func userRequestedStartLogging() {
        guard device != nil else { return }

        if isStreaming {
            userRequestedStopStreaming()
        }

        isStreaming = false
        isLogging = true
        (allowsNewStreaming, allowsNewLogging) = (false, false)

        data.clearLogged(newKind: .cartesianXYZ)
        delegate?.refreshView()
        delegate?.refreshLoggerStats()

        updateAccelerometerSettingsPriorToStream()

        guard let board = device?.board else { return }

        if let downloader = downloadLogger {
            parent?.signals.addLog(loggingKey, downloader)
        }

        let signal = mbl_mw_acc_bosch_get_acceleration_data_signal(board)!
        mbl_mw_datasignal_log(signal, bridge(obj: self)) { (context, logger) in
            let _self: MWAccelerometerVM = bridge(ptr: context!)
            let cString = mbl_mw_logger_generate_identifier(logger)!
            let identifier = String(cString: cString)
            _self.loggingKey = identifier
            _self.parent?.signals.addLog(identifier, logger!)
        }
        mbl_mw_logging_start(board, 0)
        mbl_mw_acc_enable_acceleration_sampling(board)
        mbl_mw_acc_start(board)
    }

    func userRequestedStopLogging() {
        guard let board = device?.board else { return }

        (isStreaming, isLogging) = (false, false)
        (allowsNewLogging, allowsNewStreaming) = (true, true)
        delegate?.refreshView()

        guard let logger = parent?.signals.removeLog(loggingKey)
        else { NSLog("No logger found for \(loggingKey)"); return }
        mbl_mw_acc_stop(board)
        mbl_mw_acc_disable_acceleration_sampling(board)
        if model == .bmi270 { mbl_mw_logging_flush_page(board) }

        downloadLogger = logger
    }



    func userRequestedDownloadLog() {
        guard let board = device?.board else { return }
        if isLogging { userRequestedStopLogging() }
        guard let logger = downloadLogger else {
            parent?.toast.present(mode: .textOnly,
                                  "No Logger Found",
                                  disablesInteraction: false,
                                  onDismiss: nil)
            parent?.toast.dismiss(delay: 1.5)
            return
        }

        isDownloadingLog = true
        data.clearLogged(newKind: .cartesianXYZ)
        delegate?.drawNewLogGraph()
        delegate?.refreshLoggerStats()
        delegate?.refreshView()
        parent?.toast.present(mode: .horizontalProgress,
                              "Downloading",
                              disablesInteraction: true,
                              onDismiss: nil)

        mbl_mw_logger_subscribe(logger, bridge(obj: self)) { (context, obj) in
            let _self: MWAccelerometerVM = bridge(ptr: context!)
            _self.recordLogEntry(_self: _self, obj: obj)
        }

        downloadProgressHandler = .init()
        downloadProgressHandler.reportProgress(board: board, to: self, parent: parent)
    }

    func userRequestedLogExport() {
        parent?.export(data.makeLogData, titled: "AccLogData")
    }

    func recordLogEntry(_self: MWAccelerometerVM, obj: UnsafePointer<MblMwData>?) {
        let acceleration: MblMwCartesianFloat = obj!.pointee.valueAs()
        let point = TimeIdentifiedDataPoint(cartesian: (obj!.pointee.epoch, acceleration))
        DispatchQueue.main.async {
            _self.data.logged.append(point)
        }
    }
}

extension MWAccelerometerVM: LogDownloadHandlerDelegate {

    public func updateStats() {
        delegate?.refreshLoggerStats()
    }

    public func initialDataTransferDidComplete() {
        isDownloadingLog = false
        delegate?.refreshLoggerStats()
        delegate?.refreshView()
    }
    
    public func receivedUnhandledEntry(context: LogDownloadHandlerDelegate?, data: UnsafePointer<MblMwData>?) {
        guard let _self = context as? Self else { return }
        _self.recordLogEntry(_self: _self, obj: data)
    }

}

// MARK: - Intents for Orienting

public extension MWAccelerometerVM {

    func userRequestedStartOrienting() {
        guard model != .bmi270 else { return }
        guard let board = device?.board else { return }

        isOrienting = true
        delegate?.refreshView()
        updateAccelerometerSettingsPriorToStream()

        let signal = mbl_mw_acc_bosch_get_orientation_detection_data_signal(board)!
        mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, obj) in
            let orientation: MblMwSensorOrientation = obj!.pointee.valueAs()
            let _self: MWAccelerometerVM = bridge(ptr: context!)

            DispatchQueue.main.async {
                _self.orientation = Orientation(sensor: orientation)?.displayName ?? "N/A"
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
        parent?.signals.storeStream(signal, cleanup: cleanup)
    }

    func userRequestedStopOrienting() {
        guard model != .bmi270 else { return }
        guard let board = device?.board else { return }

        isOrienting = false
        delegate?.refreshView()

        let signal = mbl_mw_acc_bosch_get_orientation_detection_data_signal(board)!
        parent?.signals.removeStream(signal)
    }

}

// MARK: - Intents for Stepping

public extension MWAccelerometerVM {

    func userRequestedStartStepping() {
        guard model != .bmi270 else { return }
        guard let board = device?.board else { return }

        isStepping = true
        stepCount = 0
        delegate?.refreshView()
        updateAccelerometerSettingsPriorToStream()

        let signal = mbl_mw_acc_bmi160_get_step_detector_data_signal(board)!
        mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, obj) in
            let _self: MWAccelerometerVM = bridge(ptr: context!)

            DispatchQueue.main.async {
                _self.stepCount += 1
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
        parent?.signals.storeStream(signal, cleanup: cleanup)
    }

    func userRequestedStopStepping() {
        guard model != .bmi270 else { return }
        guard let board = device?.board else { return }

        isStepping = false
        delegate?.refreshView()

        let signal = mbl_mw_acc_bmi160_get_step_detector_data_signal(board)!
        parent?.signals.removeStream(signal)
    }
}

// MARK: - Helpers

private extension MWAccelerometerVM {

    /// Send user preferences to device before starting a new stream
    func updateAccelerometerSettingsPriorToStream() {
        guard let board = device?.board else { return }

        mbl_mw_acc_bosch_set_range(board, graphScaleSelected.cppEnumValue)
        mbl_mw_acc_set_odr(board, samplingFrequencySelected.frequency)
        mbl_mw_acc_bosch_write_acceleration_config(board)
    }
}
