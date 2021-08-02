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

#if os(iOS)
import MBProgressHUD
#endif

public class DetailVMContainer {
    public var header: DetailHeaderVM!
    public var identifiers: DetailIdentifiersVM!
    public var battery: DetailBatteryVM!
    public var signal: DetailSignalStrengthVM!
    public var firmware: DetailFirmwareAndResetVM!
    public var led: DetailLEDVM!
    public var mechanical: DetailMechanicalSwitchVM!
    public var temperature: DetailTemperatureVM!


    var configurables: [DetailConfiguring] { [header] }
}

public class MWDeviceDetailsCoordinator: NSObject, DeviceDetailsCoordinator {
    
    public weak var delegate: DeviceDetailsCoordinatorDelegate? = nil
    private var vms: DetailVMContainer = .init()
    
    private var device: MetaWear!
    private var initiator: DFUServiceInitiator?
    private var dfuController: DFUServiceController?

    /// Tracks all streaming events (even for other devices).
    private var streamingEvents: Set<OpaquePointer> = []
    private var streamingCleanup: [OpaquePointer: () -> Void] = [:]
    private var loggers: [String: OpaquePointer] = [:]

    private var disconnectTask: Task<MetaWear>?
    private var isObserving = false {
        didSet { didSetIsObserving(oldValue) }
    }

    private var bmi270: Bool = false
    private var accelerometerBMI160StepCount = 0
    private var accelerometerBMI160Data: [(Int64, MblMwCartesianFloat)] = []
    private var gyroBMI160Data: [(Int64, MblMwCartesianFloat)] = []
    private var magnetometerBMM150Data: [(Int64, MblMwCartesianFloat)] = []
    private var gpioPinChangeCount = 0
    private var hygrometerBME280Event: OpaquePointer?
    private var sensorFusionData = Data()
    
}

// MARK: - Coordinate ViewModels and Update Feed

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
    
    func deviceDisconnected() {
        vms.header.refreshConnectionState()
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
        /// lots of things
        delegate?.reloadAllCells()
    }
    
    func didSetIsObserving(_ oldValue: Bool) {
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

// MARK: - DeviceDetailsController Utility Functions

public extension MWDeviceDetailsCoordinator {
    
    /// After a user requests logging to stop, clean up device.
    func logCleanup(_ handler: @escaping (Error?) -> Void) {
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
    
}


// MARK: - Device Connection HUD Display

private extension MWDeviceDetailsCoordinator {

    /// First step in connecting the currently focused device. If no errors occur during connection, the HUD will disappear and deviceDidConnect() will be called.
    func attemptConnectionWithHUD() {
#if os(iOS)
        let window = UIApplication.shared.windows.first(where: \.isKeyWindow)!

        let hud = MBProgressHUD.showAdded(to: window, animated: true)
        hud.label.text = "Connecting..."

        device.connectAndSetup().continueWith(.mainThread) { [weak self] task in
            hud.mode = .text

            guard task.error == nil else {
                presentAlert(
                    in: window.rootViewController!,
                    title: "Error",
                    message: task.error!.localizedDescription
                )
                hud.hide(animated: false)
                return
            }

            self?.deviceDidConnect()
            hud.label.text! = "Connected!"
            hud.hide(animated: true, afterDelay: 0.5)

        }
#endif
    }

    /// Second step in connecting the currently focused device. Reads anonymous loggers. Previously called deviceConnectedReadAnonymousLoggers(). Calls the third step activateConnectedDeviceCapabilities() upon completion.
    func deviceDidConnect() {
        let task = device.createAnonymousDatasignals()
        task.continueWith(.mainThread) { t in
            //print(self.loggers)
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

        let board = device.board

        if featureExists(for: MBL_MW_MODULE_LED, in: board) {
            vms.led.start()
            delegate?.changeVisibility(of: .LED, shouldShow: true)
        }

        if featureExists(for: MBL_MW_MODULE_SWITCH, in: board) {
            delegate?.changeVisibility(of: .mechanicalSwitch, shouldShow: true)
        }

        if featureExists(for: MBL_MW_MODULE_TEMPERATURE, in: board) {
            delegate?.changeVisibility(of: .temperature, shouldShow: true)
        }

        #warning("STOPPED AT LINE 358")
    }

    func showDefaultMinimumDeviceDetail() {
        delegate?.changeVisibility(of: .headerInfoAndState, shouldShow: true)
        delegate?.changeVisibility(of: .identifiers, shouldShow: true)
        delegate?.changeVisibility(of: .battery, shouldShow: true)
        delegate?.changeVisibility(of: .signal, shouldShow: true)
        delegate?.changeVisibility(of: .firmware, shouldShow: true)

        vms.identifiers.start()
        vms.battery.start()
        vms.signal.start()
        vms.firmware.start()
    }

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
        print("ID: \(self.device.peripheral.identifier.uuidString) MAC: \(self.device.mac ?? "N/A")")
#endif
    }
}
