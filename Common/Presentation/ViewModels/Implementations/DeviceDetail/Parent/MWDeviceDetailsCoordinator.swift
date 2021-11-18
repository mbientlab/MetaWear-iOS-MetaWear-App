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
    public private(set) var exporter: FileExporter = FileExporter()
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
        delegate?.hideAllCells()
    }

    func userIntentDidCauseDeviceDisconnect() {
        vms.header.refreshConnectionState()
        delegate?.hideAllCells()
    }

    func end() {
        device.cancelConnection()
        isObserving = false
        signalsStore.completeAllStreamingCleanups()
        vms = DetailVMContainerSUI()
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

}

// Helpers
private extension MWDeviceDetailsCoordinator {

    /// Set this parent instance and the target device as weak references in VMs
    func configureVMs() {
        vms.configurables.forEach {
            $0.configure(parent: self, device: device)
        }
    }

    /// Clear any existing references
    func resetStreamingEvents() {
        signalsStore.completeAllStreamingCleanups()
        delegate?.hideAllCells()
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

                // Check to see if the user hasn't decided not to connect after all
                guard self?.isObserving == true else { return }
                self?.readAndDisplayDeviceCapabilities()

                // Check to see if the user hasn't decided not to connect after all
                guard self?.isObserving == true else { return }
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

        signalConnectedToThisDevice()
        vms.header.refreshConnectionState() // ## Previously manually forced switch on
        logPeripheralIdentifier()
        showDefaultMinimumDeviceDetail()

        let board = device.board

        var supportedGroups = [DetailGroup]()
        defer { delegate?.show(groups: supportedGroups) }

        if featureExists(for: MBL_MW_MODULE_LED, in: board) {
            vms.led.start()
            supportedGroups.append(.LED)
        }

        if featureExists(for: MBL_MW_MODULE_SWITCH, in: board) {
            vms.mechanical.start()
            supportedGroups.append(.mechanicalSwitch)
        }

        if featureExists(for: MBL_MW_MODULE_TEMPERATURE, in: board) {
            vms.temperature.start()
            supportedGroups.append(.temperature)
        }

        let accelerometer = mbl_mw_metawearboard_lookup_module(board, MBL_MW_MODULE_ACCELEROMETER)
        if AccelerometerModel.allCases.map(\.int32Value).contains(accelerometer) {
            vms.accelerometer.start()
            supportedGroups.append(.accelerometer)
        }

        if featureExists(for: MBL_MW_MODULE_GYRO, in: board) {
            vms.gyroscope.start()
            supportedGroups.append(.gyroscope)
        }

        if featureExists(for: MBL_MW_MODULE_IBEACON, in: board) {
            vms.ibeacon.start()
            supportedGroups.append(.ibeacon)
        }

        if featureExists(for: MBL_MW_MODULE_HAPTIC, in: board) {
            vms.haptic.start()
            supportedGroups.append(.haptic)
        }

        if featureExists(for: MBL_MW_MODULE_SENSOR_FUSION, in: board) {
            vms.sensorFusion.start()
            supportedGroups.append(.sensorFusion)
        }

        if featureExists(for: MBL_MW_MODULE_AMBIENT_LIGHT, in: board) {
            vms.ambientLight.start()
            supportedGroups.append(.ambientLight)
        }

        if let _ = BarometerModel(board: board) {
            vms.barometer.start()
            supportedGroups.append(.barometer)
        }

        if featureExists(for: MBL_MW_MODULE_HUMIDITY, in: board) {
            vms.hygrometer.start()
            supportedGroups.append(.hygrometer)
        }

        if featureExists(for: MBL_MW_MODULE_GPIO, in: board) {
            vms.gpio.start()
            supportedGroups.append(.gpio)
        }

        if featureExists(for: MBL_MW_MODULE_I2C, in: board) {
            vms.i2c.start()
            supportedGroups.append(.i2c)
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
        delegate?.show(groups: [
            .headerInfoAndState,
            .identifiers,
            .signal,
            .reset
        ])

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

