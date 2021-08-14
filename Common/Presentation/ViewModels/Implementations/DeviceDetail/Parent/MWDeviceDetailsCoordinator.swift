//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
import MetaWear
import MetaWearCpp
import BoltsSwift
import iOSDFULibrary
import SwiftUI

public class MWDeviceDetailsCoordinator: NSObject, DeviceDetailsCoordinator {

    public private(set) var vms: DetailVMContainer

    init(vms: DetailVMContainer) {
        self.vms = vms
    }

    // Configure
    public weak var delegate: DeviceDetailsCoordinatorDelegate? = nil
    private var device: MetaWear!

    public func setDevice(_ newDevice: MetaWear) {
        self.device = newDevice
    }

    // Services
    public private(set) var toast: ToastVM = MWToastServerVM()
    public private(set) var alerts: AlertPresenter = CrossPlatformAlertPresenter()
    public var signals: SignalReferenceStore { signalsStore }
    private var signalsStore: SignalReferenceStoreSetup & SignalReferenceStore = MWSignalsStore()

    /// Tracks device connection state
    private var isObserving = false {
        didSet { didSetIsObserving(oldValue) }
    }

}

// MARK: - Coordinate Connection State

public extension MWDeviceDetailsCoordinator {

    /// Called before view appears
    func start() {
        signalsStore.setup(self, self.device)
        resetStreamingEvents()
        configureVMs()
        vms.header.start()
        isObserving = true
        attemptConnection()
    }
    
    /// Coordinates device connection toast and eventually presenting the relevant data feeds (either on appear/disappear or for a user intent).
    func connectDevice(_ shouldConnect: Bool) {
        guard shouldConnect else {
            device.cancelConnection()
            return
        }
        attemptConnection()
    }

    func userRequestedDeviceDisconnect() {
        device.cancelConnection()
        vms.header.refreshConnectionState()
        delegate?.hideAndReloadAllCells()
    }

    func userIntentDidCauseDeviceDisconnect() {
        vms.header.refreshConnectionState()
    }

    func end() {
        device.cancelConnection()
        isObserving = false
        signalsStore.completeAllStreamingCleanups()
        vms = DetailVMContainerA()
    }
}

// MARK: - Handle Stream/Logging Memory

public extension MWDeviceDetailsCoordinator {


    /// After a user requests logging to stop, clean up device, then reconnect.
    func logCleanup(_ handler: @escaping (Error?) -> Void) {
        // In order for the device to actually erase the flash memory we can't be in a connection
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

    func export(_ data: @escaping () -> Data, titled: String) {
        let fileName = getFilenameByDate(and: titled)
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try data().write(to: fileURL, options: .atomic)
                DispatchQueue.main.async { [weak self] in
                    self?.delegate?.presentFileExportDialog(
                        fileURL: fileURL,
                        saveErrorTitle: "Save Error",
                        saveErrorMessage: "No programs installed that could save the file"
                    )
                }
            } catch let error {
                self.alerts.presentAlert(
                    title: "Save Error",
                    message: error.localizedDescription
                )
            }
        }
    }

}

// Helpers
private extension MWDeviceDetailsCoordinator {

    func getFilenameByDate(and name: String) -> String {
        let dateString = dateFormatter.string(from: Date())
        return "\(name)_\(dateString).csv"
    }

    /// Set this parent instance and the target device as weak references in VMs
    func configureVMs() {
        vms.configurables.forEach {
            $0.configure(parent: self, device: device)
        }
    }

    /// Clear any existing references
    func resetStreamingEvents() {
        signalsStore.completeAllStreamingCleanups()
        delegate?.hideAndReloadAllCells()
    }

    /// Formerly called deviceConnected() and called by
    /// - deviceConnectedReadAnonymousLoggers
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
public extension MWDeviceDetailsCoordinator {

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        OperationQueue.main.addOperation {
            self.vms.header.refreshConnectionState()
        }
    }

    func viewWillDisappear() {
        isObserving = false
        signalsStore.completeAllStreamingCleanups()
        signalsStore.removeAllLogs()
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

// MARK: - Device Connection Toast

private extension MWDeviceDetailsCoordinator {

    /// First step in connecting the currently focused device. If no errors occur during connection, toast will disappear and deviceDidConnect() will be called.
    func attemptConnection() {
        toast.present(mode: .foreverSpinner, "Connecting", disablesInteraction: true) { [weak self] in
            // on dismiss callback
            self?.connectDevice(false)
            self?.vms.header.refreshConnectionState()
        }

        device.connectAndSetup().continueWith { [weak self] task in
            DispatchQueue.main.async { [weak self] in
                self?.toast.update(mode: .textOnly, text: nil, disablesBluetoothActions: nil, onDismiss: nil)

                if let error = task.error {
                    self?.alerts.presentAlert(
                        title: "Connection Error",
                        message: error.localizedDescription
                    )
                    self?.toast.dismiss(delay: 0)
                    return
                }

                self?.readAndDisplayDeviceCapabilities()
                self?.loadAnonymousDataSignals()
                self?.toast.dismiss(updatingText: "Connected", disablesInteraction: false, delay: 0.3)
            }
        }
    }

    /// Second step in connecting the currently focused device. Store pointers for anonymous logging signals.
    func loadAnonymousDataSignals() {
        let task = device.createAnonymousDatasignals()
        task.continueWith(.mainThread) { [weak self] t in
            if let signals = t.result {
                for signal in signals {
                    let cString = mbl_mw_anonymous_datasignal_get_identifier(signal)!
                    let identifier = String(cString: cString)
                    self?.signals.addLog(identifier, signal)
                }
            }
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

        if featureExists(for: MBL_MW_MODULE_GYRO, in: board) {
            vms.gyroscope.start()
            delegate?.changeVisibility(of: .gyroscope, shouldShow: true)
        }

        if featureExists(for: MBL_MW_MODULE_IBEACON, in: board) {
            vms.ibeacon.start()
            delegate?.changeVisibility(of: .ibeacon, shouldShow: true)
        }

        if featureExists(for: MBL_MW_MODULE_HAPTIC, in: board) {
            vms.haptic.start()
            delegate?.changeVisibility(of: .haptic, shouldShow: true)
        }

        if featureExists(for: MBL_MW_MODULE_SENSOR_FUSION, in: board) {
            vms.sensorFusion.start()
            delegate?.changeVisibility(of: .sensorFusion, shouldShow: true)
        }

        if featureExists(for: MBL_MW_MODULE_AMBIENT_LIGHT, in: board) {
            vms.ambientLight.start()
            delegate?.changeVisibility(of: .ambientLight, shouldShow: true)
        }

        if let _ = BarometerModel(board: board) {
            vms.barometer.start()
            delegate?.changeVisibility(of: .barometer, shouldShow: true)
        }

        if featureExists(for: MBL_MW_MODULE_HUMIDITY, in: board) {
            vms.hygrometer.start()
            delegate?.changeVisibility(of: .hygrometer, shouldShow: true)
        }

        if featureExists(for: MBL_MW_MODULE_GPIO, in: board) {
            vms.gpio.start()
            delegate?.changeVisibility(of: .gpio, shouldShow: true)
        }

        if featureExists(for: MBL_MW_MODULE_I2C, in: board) {
            vms.i2c.start()
            delegate?.changeVisibility(of: .i2c, shouldShow: true)
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
        mbl_mw_metawearboard_lookup_module(board, module) != MBL_MW_MODULE_TYPE_NA
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

/// MM_dd_yyyy-HH_mm_ss
let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MM_dd_yyyy-HH_mm_ss"
    return formatter
}()
