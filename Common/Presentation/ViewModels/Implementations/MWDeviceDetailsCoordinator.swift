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
import iOSDFULibrary
import SwiftUI

let na = MBL_MW_MODULE_TYPE_NA

public class MWDeviceDetailsCoordinator: NSObject, DeviceDetailsCoordinator {

    init(vms: DetailVMContainer) {
        self.vms = vms
    }

    public private(set) var vms: DetailVMContainer
    public weak var delegate: DeviceDetailsCoordinatorDelegate? = nil
    
    private var device: MetaWear!
    public private(set) var toast: ToastServerVM = ToastServerVM()
    public private(set) var alerts: AlertPresenter = CrossPlatformAlertPresenter()

    /// Tracks all streaming events (even for other devices).
    private var streamingEvents: Set<OpaquePointer> = []
    private var streamingCleanup: [OpaquePointer: () -> Void] = [:]
    public var loggers: [String: OpaquePointer] = [:]


    private var isObserving = false {
        didSet { didSetIsObserving(oldValue) }
    }

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM_dd_yyyy-HH_mm_ss"
        return formatter
    }()

    public func setDevice(_ newDevice: MetaWear) {
        self.device = newDevice
    }
}

// MARK: - Coordinate Connection State

extension MWDeviceDetailsCoordinator {

    /// Called before view appears
    public func start() {
        resetStreamingEvents()
        configureVMs()
        vms.header.start()
        isObserving = true
        attemptConnectionWithHUD()
    }
    
    /// Coordinates device connection HUD and eventually presenting the relevant data feeds (either on appear/disappear or for a user intent).
    public func connectDevice(_ shouldConnect: Bool) {
        guard shouldConnect else {
            device.cancelConnection()
            return
        }
        attemptConnectionWithHUD()
    }

    public func userRequestedDeviceDisconnect() {
        device.cancelConnection()
        vms.header.refreshConnectionState()
        delegate?.hideAndReloadAllCells()
    }

    public func userIntentDidCauseDeviceDisconnect() {
        vms.header.refreshConnectionState()
    }

    public func end() {
        device.cancelConnection()
        isObserving = false
        streamingCleanup.forEach { $0.value() }
        streamingCleanup.removeAll()
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
        let fileName = getFilenameByDate(and: titled)
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)

        do {
            try data.write(to: fileURL, options: .atomic)
            delegate?.presentFileExportDialog(
                fileURL: fileURL,
                saveErrorTitle: "Save Error",
                saveErrorMessage: "No programs installed that could save the file"
            )
        } catch let error {
            self.alerts.presentAlert(
                title: "Save Error",
                message: error.localizedDescription
            )
        }
    }

    private func getFilenameByDate(and name: String) -> String {
        let dateString = dateFormatter.string(from: Date())
        return "\(name)_\(dateString).csv"
    }
}

/// Helpers
private extension MWDeviceDetailsCoordinator {

    /// Set this parent instance and the target device as weak references in VMs
    func configureVMs() {
        vms.configurables.forEach {
            $0.configure(parent: self, device: device)
        }
    }

    /// Clear any existing references
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
        toast.present(.foreverSpinner, "Connecting", disablesInteraction: true) { [weak self] in
            // on dismiss callback
            self?.connectDevice(false)
            self?.vms.header.refreshConnectionState()
        }

        device.connectAndSetup().continueWith(.mainThread) { task in
            self.toast.update(mode: .textOnly, text: nil, disablesBluetoothActions: nil, onDismiss: nil)

            guard task.error == nil else {
                self.alerts.presentAlert(
                    title: "Connection Error",
                    message: task.error!.localizedDescription
                )
                self.toast.dismiss(delay: 0)
                return
            }

            self.deviceDidConnect()
            // Delay just enough to let initial data loading happen without being perceived as "lag"
            self.toast.dismiss(updatingText: "Connected", disablesInteraction: false, delay: 0.3)
        }
    }

    /// Second step in connecting the currently focused device. Store pointers for anonymous logging signals.
    func deviceDidConnect() {
        let task = device.createAnonymousDatasignals()
        task.continueWith(.mainThread) { [weak self] t in
            if let signals = t.result {
                for signal in signals {
                    let cString = mbl_mw_anonymous_datasignal_get_identifier(signal)!
                    let identifier = String(cString: cString)
                    self?.loggers[identifier] = signal
                }
            }
            self?.readAndDisplayDeviceCapabilities()
        }
    }


    /// Third step in connecting the currently focused device. Parses the device's capabilities and instructs relevant view models to display UI.
    func readAndDisplayDeviceCapabilities() {

        defer { delegate?.reloadAllCells() }

        signalConnectedToThisDevice()
        vms.header.refreshConnectionState() // ## Previously manually forced switch on
        logPeripheralIdentifier()
        showDefaultMinimumDeviceDetail()

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

    func signalConnectedToThisDevice() {
        #if os(macOS)
        device.flashLED(color: MBLColor(srgbRed: 0, green: 1, blue: 0, alpha: 1), intensity: 1)
        #elseif os(iOS)
        device.flashLED(color: MBLColor(red: 0, green: 1, blue: 0, alpha: 1), intensity: 1)
        #endif

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) { [weak self] in
            self?.device.turnOffLed()
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
        NSLog("ID: \(self.device.peripheral.identifier.uuidString) MAC: \(self.device.mac ?? "N/A")")
#endif
    }
}
