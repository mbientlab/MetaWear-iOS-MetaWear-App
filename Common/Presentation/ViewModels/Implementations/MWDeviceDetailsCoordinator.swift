//
//  MWDeviceDetailsCoordinator.swift
//  MWDeviceDetailsCoordinator
//
//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
import MetaWear
import MetaWearCpp
import BoltsSwift
import MBProgressHUD
import iOSDFULibrary

let na = MBL_MW_MODULE_TYPE_NA

public class MWDeviceDetailsCoordinator: NSObject, DeviceDetailsCoordinator {
    
    public weak var delegate: DeviceDetailsCoordinatorDelegate? = nil
    public private(set) var vms: DetailVMContainer = .init()
    
    private var device: MetaWear!
    public private(set) var hud: HUDVM = iOSHUDVM()
    public private(set) var alerts: AlertPresenter = CrossPlatformAlertPresenter()

    /// Tracks all streaming events (even for other devices).
    private var streamingEvents: Set<OpaquePointer> = []
    private var streamingCleanup: [OpaquePointer: () -> Void] = [:]
    public var loggers: [String: OpaquePointer] = [:]

//    private var disconnectTask: Task<MetaWear>?
    private var isObserving = false {
        didSet { didSetIsObserving(oldValue) }
    }

//    private var gyroBMI160Data: [(Int64, MblMwCartesianFloat)] = []
//    private var magnetometerBMM150Data: [(Int64, MblMwCartesianFloat)] = []
//    private var gpioPinChangeCount = 0
//    private var hygrometerBME280Event: OpaquePointer?
//    private var sensorFusionData = Data()
    
}

// MARK: - Coordinate Connection State

extension MWDeviceDetailsCoordinator {
    
    public func start() {
        resetStreamingEvents()
        configureVMs()
        vms.header.start()
        isObserving = true
        connectDevice(true)
    }
    
    public func end() {
        isObserving = false
        streamingCleanup.forEach { $0.value() }
        streamingCleanup.removeAll()
    }
    
    /// Coordinates device connection HUD and eventually presenting the relevant data feeds (either on appear/disappear or for a user intent).
    public func connectDevice(_ newState: Bool) {
        guard newState else {
            device.cancelConnection()
            return
        }
        attemptConnectionWithHUD()
    }

    public func userIntentDidCauseDeviceDisconnect() {
        deviceDisconnected()
    }

    private func deviceDisconnected() {
        vms.header.refreshConnectionState()
        delegate?.hideAndReloadAllCells()
    }

}

// MARK: - Handle Stream/Logging Memory

extension MWDeviceDetailsCoordinator {

    public func storeStream(_ signal: OpaquePointer, cleanup: (() -> Void)? ) {
        streamingCleanup[signal] = cleanup ?? { mbl_mw_datasignal_unsubscribe(signal) }
    }

    public func removeStream(_ signal: OpaquePointer) {
        streamingCleanup.removeValue(forKey: signal)?()
    }

    public func addLog(_ log: String, _ pointer: OpaquePointer) {
        loggers[log] = pointer
    }

    @discardableResult public func removeLog(_ log: String) -> OpaquePointer? {
        loggers.removeValue(forKey: log)
    }


    /// After a user requests logging to stop, clean up device, then reconnect.
    public func logCleanup(_ handler: @escaping (Error?) -> Void) {
        // In order for the device to actaully erase the flash memory we can't be in a connection
        // so temporally disconnect to allow flash to erase.
        isObserving = false
        device.connectAndSetup().continueOnSuccessWithTask { t -> Task<MetaWear> in
            self.device.cancelConnection()
            return t
        }.continueOnSuccessWithTask { t -> Task<Task<MetaWear>> in
            return self.device.connectAndSetup()
        }.continueWith { t in
            self.isObserving = true
            handler(t.error)
        }
    }

    public func export(_ data: Data, titled: String) {
        // Get current Time/Date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM_dd_yyyy-HH_mm_ss"
        let dateString = dateFormatter.string(from: Date())
        let name = "\(titled)_\(dateString).csv"
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(name)


        do {
            try data.write(to: fileURL, options: .atomic)
#if os(iOS)
            delegate?.presentFileExportDialog(fileURL: fileURL, saveErrorTitle: "Save Error", saveErrorMessage: "No programs installed that could save the file")
#endif

        } catch let error {
            self.alerts.presentAlert(
                title: "Save Error",
                message: error.localizedDescription
            )
        }
    }
}

/// Helpers
private extension MWDeviceDetailsCoordinator {
    
    func configureVMs() {
        vms.configurables.forEach {
            $0.configure(parent: self, device: device)
        }
    }
    
    func resetStreamingEvents() {
        streamingEvents = []
        delegate?.hideAndReloadAllCells()
    }

    /// Formerly called deviceConnected() and called by
    /// - deviceConnectedReadAnonymousLoggers (called only by connectDevice(:Bool) after a no-error HUD execution
    /// - accelerometerBMI160StopLogPressed after logCleanup
    /// - gyroBMI160StopLogPressed after logCleanup
    /// - magnetometerBMM150StopLogPressed after logCleanup
    /// - sensorFusionStopLogPressed after log cleanup
    func reactivateDeviceCapabilitiesAfterLoggingEvent() {
        vms.header.refreshConnectionState()
        delegate?.reloadAllCells()
    }
}

// KVO Peripheral Connection Status
extension MWDeviceDetailsCoordinator {

    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        OperationQueue.main.addOperation {
            self.vms.header.refreshConnectionState()
            if self.device.peripheral.state == .disconnected {
                self.deviceDisconnected()
            }
        }
    }

    public func viewWillDisappear() {
        isObserving = false
        streamingEvents.forEach(removeStream(_:))
        loggers = [:]
    }

    private func didSetIsObserving(_ oldValue: Bool) {
        if self.isObserving {
            if !oldValue {
                self.device.peripheral.addObserver(self, forKeyPath: "state", options: .new, context: nil)
            }
        } else {
            if oldValue {
                self.device.peripheral.removeObserver(self, forKeyPath: "state")
            }
        }
    }
}

// MARK: - Device Connection HUD Display

private extension MWDeviceDetailsCoordinator {

    /// First step in connecting the currently focused device. If no errors occur during connection, the HUD will disappear and deviceDidConnect() will be called.
    func attemptConnectionWithHUD() {
#if os(iOS)
        hud.presentHUD(mode: .indeterminate, text: "Connecting...", in: nil)

        device.connectAndSetup().continueWith(.mainThread) { [weak self] task in
            self?.hud.updateHUD(mode: .text, newText: nil)

            guard task.error == nil else {
                self?.alerts.presentAlert(
                    title: "Connection Error",
                    message: task.error!.localizedDescription
                )
                self?.hud.closeHUD(finalMessage: nil, delay: 0)
                return
            }

            self?.deviceDidConnect()
            self?.hud.closeHUD(finalMessage: "Connected!", delay: 0.5)
        }
#endif
    }

    /// Second step in connecting the currently focused device. Reads anonymous loggers. Previously called deviceConnectedReadAnonymousLoggers(). Calls the third step activateConnectedDeviceCapabilities() upon completion.
    func deviceDidConnect() {
        let task = device.createAnonymousDatasignals()
        task.continueWith(.mainThread) { t in
            if let signals = t.result {
                for signal in signals {
                    let cString = mbl_mw_anonymous_datasignal_get_identifier(signal)!
                    let identifier = String(cString: cString)
                    self.loggers[identifier] = signal
                }
            }
            self.activateConnectedDeviceCapabilities()
        }
    }


    /// Third step in connecting the currently focused device. Parses the device's capabilities and instructs relevant view models to display UI.
    func activateConnectedDeviceCapabilities() {
        vms.header.refreshConnectionState() // ## Previously manually forced switch on
        logPeripheralIdentifier()
        showDefaultMinimumDeviceDetail()
        defer { delegate?.reloadAllCells() }

        let board = device.board

        if featureExists(for: MBL_MW_MODULE_LED, in: board) {
            vms.led.start()
            delegate?.changeVisibility(of: .LED, shouldShow: true)
        }

        if featureExists(for: MBL_MW_MODULE_SWITCH, in: board) {
            vms.mechanical.start()
            delegate?.changeVisibility(of: .mechanicalSwitch, shouldShow: true)
        }

        if featureExists(for: MBL_MW_MODULE_TEMPERATURE, in: board) {
            vms.temperature.start()
            delegate?.changeVisibility(of: .temperature, shouldShow: true)
        }

        let accelerometer = mbl_mw_metawearboard_lookup_module(board, MBL_MW_MODULE_ACCELEROMETER)
        if AccelerometerModel.allCases.map(\.int32Value).contains(accelerometer) {
            vms.accelerometer.start()
            delegate?.changeVisibility(of: .accelerometer, shouldShow: true)
        }
    }

    func showDefaultMinimumDeviceDetail() {
        delegate?.changeVisibility(of: .headerInfoAndState, shouldShow: true)
        delegate?.changeVisibility(of: .identifiers, shouldShow: true)
        delegate?.changeVisibility(of: .battery, shouldShow: true)
        delegate?.changeVisibility(of: .signal, shouldShow: true)
        delegate?.changeVisibility(of: .firmware, shouldShow: true)
        delegate?.changeVisibility(of: .reset, shouldShow: true)

        vms.identifiers.start()
        vms.battery.start()
        vms.signal.start()
        vms.firmware.start()
        vms.reset.start()
        delegate?.reloadAllCells()
    }
}

private extension MWDeviceDetailsCoordinator {

    /// Sugar for determining device captabilities
    func featureExists(for module: MblMwModule, in board: OpaquePointer?) -> Bool {
        mbl_mw_metawearboard_lookup_module(board, module) != na
    }

    /// Sugar for determining device captabilities
    func featureIs(_ constant: Int32, for module: MblMwModule, in board: OpaquePointer?) -> Bool {
        mbl_mw_metawearboard_lookup_module(board, module) == constant
    }

    func logPeripheralIdentifier() {
#if DEBUG
        print("ID: \(self.device.peripheral.identifier.uuidString) MAC: \(self.device.mac ?? "N/A")")
#endif
    }
}
