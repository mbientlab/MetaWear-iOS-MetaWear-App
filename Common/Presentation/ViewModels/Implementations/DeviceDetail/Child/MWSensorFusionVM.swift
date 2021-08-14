//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
import MetaWear
import MetaWearCpp
import Combine

public class MWSensorFusionVM: DetailSensorFusionVM {

    // Button states
    public private(set) var isLogging = false
    public private(set) var isStreaming = false
    public private(set) var allowsNewLogging = false
    public private(set) var allowsNewStreaming = false

    // Data and graph state
    private let graphScale = 8
    private(set) var data = MWSensorDataStore()

    // Stream UI state
    public var streamDataIsReadyForDisplay: Bool { !data.stream.isEmpty }
    private var streamingStatsTimer: AnyCancellable? = nil

    // Data transfer UI state
    public private(set) var isDownloadingLog = false
    public private(set) var canDownloadLog = false
    public var logDataIsReadyForDisplay: Bool { !data.logged.isEmpty && !isDownloadingLog }

    // Data transfer state
    private var downloadLogger: OpaquePointer? = nil
    private var downloadLoggerDataHandler: MblMwFnData? = nil
    private lazy var downloadProgressHandler = ToastPresentingLogDownloader()

    // Sensor settings
    /// Should not change during a log or stream event. Cancel and restart the event.
    public private(set) var selectedOutputType = SensorFusionOutputType.eulerAngles
    public let outputTypes = SensorFusionOutputType.allCases
    public private(set) var selectedFusionMode = SensorFusionMode.ndof
    public let fusionModes = SensorFusionMode.allCases

    // Identity
    lazy private var model: AccelerometerModel? = .init(board: device?.board)
    public weak var delegate: SensorFusionVMDelegate? = nil
    private var parent: DeviceDetailsCoordinator? = nil
    private var device: MetaWear? = nil
}

extension MWSensorFusionVM: DetailConfiguring {

    public func configure(parent: DeviceDetailsCoordinator, device: MetaWear) {
        self.parent = parent
        self.device = device
    }

    public func start() {
        guard device?.board != nil else { return }

        let activeLoggers: Set<String> = Set(parent!.loggers.keys)
        if let outputTypeWithLogger = outputTypes.first(where: { activeLoggers.contains($0.loggerKey) }) {
            selectedOutputType = outputTypeWithLogger
            isLogging = true
        } else {
            isLogging = false
        }

        allowsNewLogging = !isLogging
        allowsNewStreaming = !isLogging
        delegate?.refreshView()
    }
}

// MARK: - Settings

public extension MWSensorFusionVM {

    func userRequestedResetOrientation() {
        guard let board = device?.board else { return }
        mbl_mw_sensor_fusion_reset_orientation(board)
    }

    func userSetFusionMode(_ mode: SensorFusionMode) {
        guard !isLogging, !isStreaming else {
            warnOngoingActivityPreventsSettingsChange()
            return
        }

        selectedFusionMode = mode
        delegate?.refreshView()
    }

    func userSetOutputType(_ type: SensorFusionOutputType) {
        guard !isLogging, !isStreaming else {
            warnOngoingActivityPreventsSettingsChange()
            return
        }

        selectedOutputType = type
        delegate?.refreshView()
    }

    private func warnOngoingActivityPreventsSettingsChange() {
        parent?.alerts.presentAlert(title: "\(isLogging ? "Logging" : "Streaming") is Ongoing",
                                    message: "To issue new commands to your device, cancel the current data collection activity.")
    }
}

// MARK: - Streaming Intents

public extension MWSensorFusionVM {

    func userRequestedStartStreaming() {
        guard device != nil else { return }

        if isLogging {
            userRequestedStopLogging()
        }

        isStreaming = true
        isLogging = false
        (allowsNewLogging, allowsNewStreaming) = (false, false)
        delegate?.refreshView()

        updateSensorFusionSettings()
        data.clearStreamed(newKind: selectedOutputType.dataPointKind)
        delegate?.drawNewStreamGraph()
        startStreamingStatsUpdateTimer()

        switch selectedOutputType {
            case .eulerAngles: streamEulerAngle()
            case .quaternion: streamQuaternion()
            case .gravity: streamGravity()
            case .linearAcceleration: streamLinearAcceleration()
        }
    }

    func userRequestedStopStreaming() {
        isStreaming = false
        (allowsNewStreaming, allowsNewLogging) = (true, true)

        cancelStreamingStatsUpdateTimer()
        delegate?.refreshView()
        delegate?.refreshStreamStats()

        guard let board = device?.board else { return }
        let signal = mbl_mw_sensor_fusion_get_data_signal(board, selectedOutputType.cppEnumValue)!
        parent?.removeStream(signal)
    }

    func userRequestedStreamExport() {
        parent?.export(data.makeStreamData(), titled: "\(selectedOutputType.shortFileName)StreamData")
    }

}

// Helper methods
private extension MWSensorFusionVM {

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

    /// Issues common stream setup commands.
    /// Accepts a closure that must subscribe to a board signal
    /// and handle processing that signal for the user's desired output type.
    func _setupStream(with outputSpecificSubscription: (OpaquePointer) -> Void) {
        guard let board = device?.board else { return }

        let signal = mbl_mw_sensor_fusion_get_data_signal(board, selectedOutputType.cppEnumValue)!

        outputSpecificSubscription(signal)

        mbl_mw_sensor_fusion_clear_enabled_mask(board)
        mbl_mw_sensor_fusion_enable_data(board, selectedOutputType.cppEnumValue)
        mbl_mw_sensor_fusion_write_config(board)
        mbl_mw_sensor_fusion_start(board)

        let cleanup = {
            mbl_mw_sensor_fusion_stop(board)
            mbl_mw_sensor_fusion_clear_enabled_mask(board)
            mbl_mw_datasignal_unsubscribe(signal)
        }
        parent?.storeStream(signal, cleanup: cleanup)
    }

    func streamEulerAngle() {
        _setupStream { [weak self] signal in
            guard let self = self else { return }

            mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, obj) in
                let _self: MWSensorFusionVM = bridge(ptr: context!)
                var euler: MblMwEulerAngles = obj!.pointee.valueAs()

                let range = Float(_self.graphScale)
                euler.scaled(in: range)

                let point = TimeIdentifiedDataPoint(euler: (obj!.pointee.epoch, euler))
                DispatchQueue.main.async {
                    _self.delegate?.drawNewStreamGraphPoint(point)
                    _self.data.stream.append(point)
                }
            }
        }
    }

    func streamQuaternion() {
        _setupStream { [weak self] signal in
            guard let self = self else { return }

            mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, obj) in
                let _self: MWSensorFusionVM = bridge(ptr: context!)
                var quaternion: MblMwQuaternion = obj!.pointee.valueAs()

                let range = Float(_self.graphScale)
                quaternion.scaled(in: range)

                let point = TimeIdentifiedDataPoint(quaternion: (obj!.pointee.epoch, quaternion))
                DispatchQueue.main.async {
                    _self.delegate?.drawNewStreamGraphPoint(point)
                    _self.data.stream.append(point)
                }
            }
        }
    }

    func streamGravity() {
        _setupStream { [weak self] signal in
            guard let self = self else { return }

            mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, obj) in
                let _self: MWSensorFusionVM = bridge(ptr: context!)
                var acc: MblMwCartesianFloat = obj!.pointee.valueAs()

                let range = Float(_self.graphScale)
                acc.scaledGravity(in: range)

                let point = TimeIdentifiedDataPoint(cartesian: (obj!.pointee.epoch, acc))
                DispatchQueue.main.async {
                    _self.delegate?.drawNewStreamGraphPoint(point)
                    _self.data.stream.append(point)
                }
            }
        }
    }

    func streamLinearAcceleration() {
        _setupStream { [weak self] signal in
            guard let self = self else { return }

            mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, obj) in
                let _self: MWSensorFusionVM = bridge(ptr: context!)
                let acc: MblMwCartesianFloat = obj!.pointee.valueAs()

                let point = TimeIdentifiedDataPoint(cartesian: (obj!.pointee.epoch, acc))
                DispatchQueue.main.async {
                    _self.delegate?.drawNewStreamGraphPoint(point)
                    _self.data.stream.append(point)
                }
            }

            guard let board = self.device?.board else { return }
            mbl_mw_sensor_fusion_set_acc_range(board, MBL_MW_SENSOR_FUSION_ACC_RANGE_8G)
        }
    }
}

// MARK: - Logging Intents

public extension MWSensorFusionVM {

    func userRequestedStartLogging() {
        guard device != nil else { return }

        if isStreaming {
            userRequestedStopStreaming()
        }

        isStreaming = false
        isLogging = true
        (allowsNewLogging, allowsNewStreaming) = (false, false)

        data.clearStreamed(newKind: selectedOutputType.dataPointKind)
        delegate?.refreshView()
        delegate?.drawNewStreamGraph()

        updateSensorFusionSettings()

        guard let board = device?.board else { return }

        mbl_mw_sensor_fusion_clear_enabled_mask(board)
        let signal = mbl_mw_sensor_fusion_get_data_signal(board, selectedOutputType.cppEnumValue)!
        mbl_mw_sensor_fusion_enable_data(board, selectedOutputType.cppEnumValue)


        mbl_mw_datasignal_log(signal, bridge(obj: self)) { (context, logger) in
            let _self: MWSensorFusionVM = bridge(ptr: context!)

            let identifier = String(cString: mbl_mw_logger_generate_identifier(logger)!)
            _self.parent?.addLog(identifier, logger!)
        }
        mbl_mw_logging_start(board, 0)
        mbl_mw_sensor_fusion_write_config(board)
        mbl_mw_sensor_fusion_start(board)
    }

    func userRequestedStopLogging() {
        guard let board = device?.board else { return }

        (isStreaming, isLogging) = (false, false)
        (allowsNewLogging, allowsNewStreaming) = (true, true)
        delegate?.refreshView()

        guard let logger = parent?.removeLog(selectedOutputType.loggerKey) else { return }
        let dataHandler: MblMwFnData = { (context, obj) in
            let _self: MWSensorFusionVM = bridge(ptr: context!)

            switch _self.selectedOutputType {
                case .eulerAngles: _self.processEulerLog((context, obj, _self))
                case .quaternion: _self.processQuaternionLog((context, obj, _self))
                case .gravity: _self.processGravityLog((context, obj, _self))
                case .linearAcceleration: _self.processLinearAccelerationLog((context, obj, _self))
            }
        }

        mbl_mw_sensor_fusion_stop(board)
        mbl_mw_sensor_fusion_clear_enabled_mask(board)
        if model == .bmi270 { mbl_mw_logging_flush_page(board) }

        downloadLogger = logger
        downloadLoggerDataHandler = dataHandler
    }

    func userRequestedDownloadLog() {

        guard let board = device?.board else { return }
        guard let logger = downloadLogger,
              let dataHandler = downloadLoggerDataHandler else {
                  parent?.toast.present(mode: .textOnly,
                                        "No Logger Found",
                                        disablesInteraction: false,
                                        onDismiss: nil)
                  parent?.toast.dismiss(delay: 1.5)
                  return
              }

        isDownloadingLog = true
        data.clearLogged(newKind: selectedOutputType.dataPointKind)
        delegate?.drawNewLogGraph()
        delegate?.refreshLoggerStats()
        delegate?.refreshView()
        parent?.toast.present(mode: .horizontalProgress,
                              "Downloading",
                              disablesInteraction: true,
                              onDismiss: nil)

        mbl_mw_logger_subscribe(logger, bridge(obj: self), dataHandler)

        downloadProgressHandler = .init()
        downloadProgressHandler.reportProgress(board: board, to: self, parent: parent)
    }

    func userRequestedLogExport() {
        parent?.export(data.makeLogData(), titled: "\(selectedOutputType.shortFileName)LogData")
    }

}

// Helper methods - Passing dynamic types is not allowed with C functions
private extension MWSensorFusionVM {

    typealias LogDataContext = (context: UnsafeMutableRawPointer?,
                                            obj: UnsafePointer<MblMwData>?,
                                            _self: MWSensorFusionVM)

    func processEulerLog(_ log: LogDataContext) {
        let time = log.obj!.pointee.epoch

        var data: MblMwEulerAngles = log.obj!.pointee.valueAs()      // - Diffs
        let range = Float(log._self.graphScale)
        data.scaled(in: range)                                       // - Diffs

        let point = TimeIdentifiedDataPoint(euler: (time, data))     // - Diffs
        DispatchQueue.main.async {
            log._self.data.logged.append(point)
        }
    }

    func processQuaternionLog(_ log: LogDataContext) {
        let time = log.obj!.pointee.epoch

        var data: MblMwQuaternion = log.obj!.pointee.valueAs()        //
        let range = Float(log._self.graphScale)
        data.scaled(in: range)                                        //

        let point = TimeIdentifiedDataPoint(quaternion: (time, data)) //
        DispatchQueue.main.async {
            log._self.data.logged.append(point)
        }
    }

    func processGravityLog(_ log: LogDataContext) {
        let time = log.obj!.pointee.epoch

        var data: MblMwCartesianFloat = log.obj!.pointee.valueAs()    //
        let range = Float(log._self.graphScale)
        data.scaledGravity(in: range)                                 //

        let point = TimeIdentifiedDataPoint(cartesian: (time, data))  //
        DispatchQueue.main.async {
            log._self.data.logged.append(point)
        }
    }

    func processLinearAccelerationLog(_ log: LogDataContext) {
        let time = log.obj!.pointee.epoch
        let data: MblMwCartesianFloat = log.obj!.pointee.valueAs()     //
        // No scaling                                                  //
        let point = TimeIdentifiedDataPoint(cartesian: (time, data))   //
        DispatchQueue.main.async {
            log._self.data.logged.append(point)
        }
    }

}

extension MWSensorFusionVM: LogDownloadHandlerDelegate {

    public func updateStats() {
        delegate?.refreshLoggerStats()
    }

    public func initialDataTransferDidComplete() {
        isDownloadingLog = false
        delegate?.refreshLoggerStats()
        delegate?.refreshView()
    }

}

// MARK: - General Helper Methods

private extension MWSensorFusionVM {

    func updateSensorFusionSettings() {
        guard let board = device?.board else { return }
        mbl_mw_sensor_fusion_set_acc_range(board, MBL_MW_SENSOR_FUSION_ACC_RANGE_16G)
        mbl_mw_sensor_fusion_set_gyro_range(board, MBL_MW_SENSOR_FUSION_GYRO_RANGE_2000DPS)
        mbl_mw_sensor_fusion_set_mode(board, selectedFusionMode.cppMode)
    }

}

fileprivate extension SensorFusionOutputType {

    var loggerKey: String {
        switch self {
            case .eulerAngles: return "euler-angles"
            case .quaternion: return "quaternion"
            case .gravity: return "gravity"
            case .linearAcceleration: return "linear-acceleration"
        }
    }
}

