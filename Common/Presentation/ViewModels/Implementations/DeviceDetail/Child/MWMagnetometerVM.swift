//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
import MetaWear
import MetaWearCpp
import Combine

public class MWMagnetometerVM: MagenetometerVM {

    // Button states
    public private(set) var isLogging = false
    public private(set) var isStreaming = false
    public private(set) var allowsNewLogging = false
    public private(set) var allowsNewStreaming = false

    // Graph and data state
    public private(set) var graphScaleFactor: Float = 4
    public private(set) var loggingScaleFactor: Float = 20000.0
    private(set) var data = MWSensorDataStore()

    // Stream UI state
    public var streamDataIsReadyForDisplay: Bool { !data.stream.isEmpty }
    private var streamingStatsTimer: AnyCancellable? = nil

    // Data transfer UI state
    public private(set) var isDownloadingLog = false
    public var canDownloadLog: Bool { downloadLogger != nil || isLogging }
    public var logDataIsReadyForDisplay: Bool { !data.logged.isEmpty && !isDownloadingLog }

    // Data transfer state
    private var loggingKey = "magnetic-field"
    private var downloadLogger: OpaquePointer? = nil
    private lazy var downloadProgressHandler = ToastPresentingLogDownloader()

    // Identity
    public weak var delegate: MagnetometerVMDelegate? = nil
    private var parent: DeviceDetailsCoordinator? = nil
    private var device: MetaWear? = nil
    lazy private var model: AccelerometerModel? = .init(board: device?.board)
}

extension MWMagnetometerVM: DetailConfiguring {

    public func configure(parent: DeviceDetailsCoordinator, device: MetaWear) {
        self.parent = parent
        self.device = device
    }

    public func start() {
        guard device?.board != nil else { return }
        let loggerExists = parent?.signals.loggers[loggingKey] != nil

        isLogging = loggerExists
        isStreaming = false
        allowsNewLogging = !isLogging
        allowsNewStreaming = true

        delegate?.refreshView()
    }
}

// MARK: - Intents for Sensor Streaming

public extension MWMagnetometerVM {

    @objc func userRequestedStartStreaming() {
        if isLogging {
            userRequestedStopLogging()
        }

        isStreaming = true
        isLogging = false
        (allowsNewStreaming, allowsNewLogging) = (false, false)

        DispatchQueue.main.async {
            self.data.clearStreamed(newKind: .cartesianXYZ)
            self.delegate?.refreshView()
            self.delegate?.redrawStreamGraph()
            self.startStreamingStatsUpdateTimer()
        }

        guard let board = device?.board else { return }
        let signal = mbl_mw_mag_bmm150_get_b_field_data_signal(board)!

        mbl_mw_datasignal_subscribe(signal, bridge(obj: self)) { (context, obj) in
            var magnetometerValue: MblMwCartesianFloat = obj!.pointee.valueAs()
            let _self: MWMagnetometerVM = bridge(ptr: context!)
            magnetometerValue.scaled(min: -100, max: 100, in: _self.graphScaleFactor)

            let point = (obj!.pointee.epoch, magnetometerValue)
            DispatchQueue.main.async {
                _self.delegate?.drawNewStreamGraphPoint(point)
            }
            _self.data.stream.append(.init(cartesian: point))
        }

        mbl_mw_mag_bmm150_enable_b_field_sampling(board)
        mbl_mw_mag_bmm150_start(board)

        let cleanup = {
            mbl_mw_mag_bmm150_stop(board)
            mbl_mw_mag_bmm150_disable_b_field_sampling(board)
            mbl_mw_datasignal_unsubscribe(signal)
        }
        parent?.signals.storeStream(signal, cleanup: cleanup)
    }

    @objc func userRequestedStopStreaming() {
        isStreaming = false
        isLogging = false
        allowsNewStreaming = true
        allowsNewLogging = true

        cancelStreamingStatsUpdateTimer()
        delegate?.refreshView()
        delegate?.refreshStreamStats()

        guard let board = device?.board else { return }
        let signal = mbl_mw_mag_bmm150_get_b_field_data_signal(board)!
        parent?.signals.removeStream(signal)
    }

    func userRequestedStreamExport() {
        data.exportStreamData(filePrefix: "Mag") { [weak self] in
            self?.delegate?.refreshView()
        } completion: { [weak self] result in
            self?.delegate?.refreshView()
            switch result {
                case .success(let url):
                    self?.parent?.exporter.export(fileURL: url)
                case .failure(let error):
                    self?.parent?.alerts.presentAlert(title: "Magnetometer Stream", message: error.localizedDescription)
            }
        }
    }
}

// Helpers

private extension MWMagnetometerVM {

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


// MARK: - Intents for Sensor Logging

public extension MWMagnetometerVM {

    func userRequestedStartLogging() {
        isStreaming = false
        isLogging = true
        (allowsNewStreaming, allowsNewLogging) = (false, false)

        data.clearLogged(newKind: .cartesianXYZ)
        delegate?.refreshView()
        delegate?.refreshLoggerStats()

        guard let board = device?.board else { return }
        let signal = mbl_mw_mag_bmm150_get_b_field_data_signal(board)!
        mbl_mw_datasignal_log(signal, bridge(obj: self)) { (context, logger) in
            let _self: MWMagnetometerVM = bridge(ptr: context!)
            let cString = mbl_mw_logger_generate_identifier(logger)!
            let identifier = String(cString: cString)
            _self.loggingKey = identifier
            _self.parent?.signals.addLog(identifier, logger!)
        }
        mbl_mw_logging_start(board, 0)
        mbl_mw_mag_bmm150_enable_b_field_sampling(board)
        mbl_mw_mag_bmm150_start(board)
    }

    func userRequestedStopLogging() {
        (isStreaming, isLogging) = (false, false)
        (allowsNewStreaming, allowsNewLogging) = (true, true)

        delegate?.refreshView()

        guard let board = device?.board else { return }
        guard let logger = parent?.signals.removeLog(loggingKey) else { return }

        mbl_mw_mag_bmm150_stop(board)
        mbl_mw_mag_bmm150_disable_b_field_sampling(board)
        if model == .bmi270 {
            mbl_mw_logging_flush_page(board)
        }

        downloadLogger = logger
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
            let _self: MWMagnetometerVM = bridge(ptr: context!)
            _self.recordLogEntry(_self: _self, obj: obj)
        }

        downloadProgressHandler = .init()
        downloadProgressHandler.reportProgress(board: board, to: self, parent: parent)

        downloadLogger = nil
    }

    func userRequestedLogExport() {
        data.exportLogData(filePrefix: "Mag") { [weak self] in
            self?.delegate?.refreshView()
        } completion: { [weak self] result in
            self?.delegate?.refreshView()
            switch result {
                case .success(let url):
                    self?.parent?.exporter.export(fileURL: url)
                case .failure(let error):
                    self?.parent?.alerts.presentAlert(title: "Magnetometer Log", message: error.localizedDescription)
            }
        }
    }

    func recordLogEntry(_self: MWMagnetometerVM, obj: UnsafePointer<MblMwData>?) {
        var acceleration: MblMwCartesianFloat = obj!.pointee.valueAs()
        acceleration.scaled(by: _self.loggingScaleFactor) // Original app specified two different scales
        let point = (obj!.pointee.epoch, acceleration)
        DispatchQueue.main.async {
            _self.data.logged.append(.init(cartesian: point))
        }
    }

}

// Helpers
extension MWMagnetometerVM: LogDownloadHandlerDelegate {

    public func updateStats() {
        delegate?.refreshLoggerStats()
    }

    public func initialDataTransferDidComplete() {
        data.exportLogData(filePrefix: "Mag") { [weak self] in
            /// Update display state when file is ready
            self?.delegate?.refreshView()
        } completion: { [weak self] _ in
            /// Simply get the file prepared in background, don't present export dialog
            self?.delegate?.refreshView()
        }
        isDownloadingLog = false
        delegate?.refreshLoggerStats()
        delegate?.refreshView()
    }

    public func receivedUnhandledEntry(context: LogDownloadHandlerDelegate?, data: UnsafePointer<MblMwData>?) {
        guard let _self = context as? Self else { return }
        _self.recordLogEntry(_self: _self, obj: data)
    }

}
