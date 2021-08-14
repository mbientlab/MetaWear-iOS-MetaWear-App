//  Created by Ryan Ferrell on 8/5/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
import MetaWear
import MetaWearCpp
import Combine

public class MWGyroVM: GyroVM {

    // Button states
    public private(set) var isLogging = false
    public private(set) var isStreaming = false
    public private(set) var allowsNewLogging = false
    public private(set) var allowsNewStreaming = false

    // Sensor settings + graph settings
    public private(set) var graphRanges = GyroscopeGraphRange.allCases
    public private(set) var graphRangeSelected = GyroscopeGraphRange.dps250
    public private(set) var samplingFrequencies = GyroscopeFrequency.allCases
    public private(set) var samplingFrequencySelected = GyroscopeFrequency.hz100
#warning("Original App - Had TODO to scale value for better graphing")
    public private(set) var graphScaleFactor: Float = 0.008

    // Data transfer UI state
    public private(set) var isDownloadingLog = false
    public var canDownloadLog: Bool { downloadLogger != nil || isLogging }
    public var logDataIsReadyForDisplay: Bool { !data.logged.isEmpty && !isDownloadingLog }
    public var streamDataIsReadyForDisplay: Bool { !data.stream.isEmpty }
    private var streamingStatsTimer: AnyCancellable? = nil

    // Data transfer state
    private(set) var data = MWSensorDataStore()
    private var loggingKey = "angular-velocity"
    private var downloadLogger: OpaquePointer? = nil
    private lazy var downloadProgressHandler = ToastPresentingLogDownloader()

    // Identity
    public var delegate: GyroVMDelegate? = nil
    private var parent: DeviceDetailsCoordinator? = nil
    private var device: MetaWear? = nil
    lazy private var model: AccelerometerModel? = .init(board: device?.board)
}

extension MWGyroVM: DetailConfiguring {

    public func configure(parent: DeviceDetailsCoordinator, device: MetaWear) {
        self.parent = parent
        self.device = device
    }

    public func start() {
        guard device?.board != nil else { return }
        let loggerExists = parent?.loggers[loggingKey] != nil

        isLogging = loggerExists
        isStreaming = false
        allowsNewLogging = !isLogging
        allowsNewStreaming = true

        delegate?.refreshView()
    }
}

// MARK: - Intents for Configuration

public extension MWGyroVM {

    func userDidSelectSamplingFrequency(_ frequency: GyroscopeFrequency) {
        samplingFrequencySelected = frequency
        delegate?.refreshView()
    }

    func userDidSelectGraphScale(_ scale: GyroscopeGraphRange) {
        graphRangeSelected = scale
        delegate?.refreshView()
        delegate?.refreshGraphScale()
    }
}

// MARK: - Intents for Sensor Streaming

public extension MWGyroVM {

    func userRequestedStartStreaming() {
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

        updateGyroscopeSettingsPriorToUse()

        switch model {
            case .bmi160: startStreamingBMI160()
            case .bmi270: startStreamingBMI270()
            case .none: return
        }
    }

    func userRequestedStopStreaming() {
        (isStreaming, isLogging) = (false, false)
        (allowsNewStreaming, allowsNewLogging) = (true, true)

        cancelStreamingStatsUpdateTimer()
        delegate?.refreshView()
        delegate?.refreshStreamStats()

        guard let board = device?.board else { return }

        var signal: OpaquePointer?
        switch model {
            case .bmi270: signal = mbl_mw_gyro_bmi270_get_rotation_data_signal(board)!
            case .bmi160: signal = mbl_mw_gyro_bmi160_get_rotation_data_signal(board)!
            case .none: return
        }
        parent?.removeStream(signal!)
    }

    func userRequestedStreamExport() {
        parent?.export(data.makeStreamData(), titled: "GyroStreamData")
    }
}

// Helpers
private extension MWGyroVM {

    func startStreamingBMI270() {
        guard let board = device?.board else { return }

        let signal = mbl_mw_gyro_bmi270_get_rotation_data_signal(board)!
        subscribeToStreaming(signal: signal)

        mbl_mw_gyro_bmi270_enable_rotation_sampling(board)
        mbl_mw_gyro_bmi270_start(board)

        let cleanup = {
            mbl_mw_gyro_bmi270_stop(board)
            mbl_mw_gyro_bmi270_disable_rotation_sampling(board)
            mbl_mw_datasignal_unsubscribe(signal)
        }
        parent?.storeStream(signal, cleanup: cleanup)
    }

    func startStreamingBMI160() {
        guard let board = device?.board else { return }

        let signal = mbl_mw_gyro_bmi160_get_rotation_data_signal(board)!
        subscribeToStreaming(signal: signal)

        mbl_mw_gyro_bmi160_enable_rotation_sampling(board)
        mbl_mw_gyro_bmi160_start(board)

        let cleanup = {
            mbl_mw_gyro_bmi160_stop(board)
            mbl_mw_gyro_bmi160_disable_rotation_sampling(board)
            mbl_mw_datasignal_unsubscribe(signal)
        }
        parent?.storeStream(signal, cleanup: cleanup)
    }

    func subscribeToStreaming(signal: OpaquePointer) {
        mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, obj) in
            let _self: MWGyroVM = bridge(ptr: context!)

            var acceleration: MblMwCartesianFloat = obj!.pointee.valueAs()
            acceleration.scaled(by: _self.graphScaleFactor)
            let point = (obj!.pointee.epoch, acceleration)

            DispatchQueue.main.async {
                _self.delegate?.drawNewStreamGraphPoint(point)
                _self.data.stream.append(.init(cartesian: point))
            }
        }
    }

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

public extension MWGyroVM {

    func userRequestedStartLogging() {
        isStreaming = false
        isLogging = true
        allowsNewStreaming = false
        allowsNewLogging = false

        data.clearLogged(newKind: .cartesianXYZ)
        delegate?.refreshView()
        delegate?.refreshLoggerStats()

        updateGyroscopeSettingsPriorToUse()
        switch model {
            case .bmi160: startLoggingBMI160()
            case .bmi270: startLoggingBMI270()
            case .none: return
        }
    }

    func userRequestedStopLogging() {
        (isStreaming, isLogging) = (false, false)
        (allowsNewStreaming, allowsNewLogging) = (true, true)

        delegate?.refreshView()

        guard let board = device?.board else { return }
        downloadLogger = parent?.removeLog(loggingKey)

        switch model {
            case .bmi270:
                mbl_mw_gyro_bmi270_stop(board)
                mbl_mw_gyro_bmi270_disable_rotation_sampling(board)
                mbl_mw_logging_flush_page(board)

            case .bmi160:
                mbl_mw_gyro_bmi160_stop(board)
                mbl_mw_gyro_bmi160_disable_rotation_sampling(board)

            case .none: break
        }
    }

    func userRequestedDownloadLog() {
        guard let board = device?.board else { return }
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
        delegate?.refreshLoggerStats()
        delegate?.refreshView()
        parent?.toast.present(mode: .horizontalProgress,
                              "Downloading",
                              disablesInteraction: true,
                              onDismiss: nil)

        mbl_mw_logger_subscribe(logger, bridge(obj: self)) { (context, obj) in
            let _self: MWGyroVM = bridge(ptr: context!)
            var acceleration: MblMwCartesianFloat = obj!.pointee.valueAs()
            acceleration.scaled(by: _self.graphScaleFactor)
            let point = (obj!.pointee.epoch, acceleration)
            DispatchQueue.main.async {
                _self.data.logged.append(.init(cartesian: point))
                print(point.1.x)
            }
        }

        downloadProgressHandler = .init()
        downloadProgressHandler.reportProgress(board: board, to: self, parent: parent)
    }

    func userRequestedLogExport() {
        parent?.export(data.makeLogData(), titled: "GyroData")
    }

}

private extension MWGyroVM {

    func startLoggingBMI270() {
        guard let board = device?.board else { return }

        let signal = mbl_mw_gyro_bmi270_get_rotation_data_signal(board)!
        startLogging(signal)

        mbl_mw_logging_start(board, 0)
        mbl_mw_gyro_bmi270_enable_rotation_sampling(board)
        mbl_mw_gyro_bmi270_start(board)
    }

    func startLoggingBMI160() {
        guard let board = device?.board else { return }

        let signal = mbl_mw_gyro_bmi160_get_rotation_data_signal(board)!
        startLogging(signal)

        mbl_mw_logging_start(board, 0)
        mbl_mw_gyro_bmi160_enable_rotation_sampling(board)
        mbl_mw_gyro_bmi160_start(board)
    }

    func startLogging(_ signal: OpaquePointer) {
        mbl_mw_datasignal_log(signal, bridge(obj: self)) { (context, logger) in
            let _self: MWGyroVM = bridge(ptr: context!)

            let cString = mbl_mw_logger_generate_identifier(logger)!
            let identifier = String(cString: cString)
            _self.loggingKey = identifier
            _self.parent?.addLog(identifier, logger!)
        }
    }

}

// Helpers
extension MWGyroVM: LogDownloadHandlerDelegate {
    
    public func updateStats() {
        delegate?.refreshLoggerStats()
    }

    public func initialDataTransferDidComplete() {
        isDownloadingLog = false
        delegate?.refreshLoggerStats()
        delegate?.refreshView()
    }

}

// MARK: - Helpers

extension MWGyroVM {

    func updateGyroscopeSettingsPriorToUse() {
        guard let board = device?.board else { return }

        switch model {
            case .bmi160:
                mbl_mw_gyro_bmi160_set_range(board, graphRangeSelected.cppEnumValue)
                mbl_mw_gyro_bmi160_set_odr(board, samplingFrequencySelected.cppEnumValue)
                mbl_mw_gyro_bmi160_write_config(board)

            case .bmi270:
                mbl_mw_gyro_bmi270_set_range(board, graphRangeSelected.cppEnumValue)
                mbl_mw_gyro_bmi270_set_odr(board, samplingFrequencySelected.cppEnumValue)
                mbl_mw_gyro_bmi270_write_config(board)

            case .none:
                return
        }

    }
}
