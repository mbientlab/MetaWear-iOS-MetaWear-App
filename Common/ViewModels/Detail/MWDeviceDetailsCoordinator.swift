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

public class MWDeviceDetailsCoordinator: NSObject {
    
    public weak var delegate: DeviceDetailsCoordinatorDelegate? = nil
    private var deviceHeaderVM: DetailHeaderVM!
    
    private var device: MetaWear!
    private var initiator: DFUServiceInitiator?
    private var dfuController: DFUServiceController?
    
    private var bmi270: Bool = false
    
    /// Tracks all streaming events (even for other devices).
    private var streamingEvents: Set<OpaquePointer> = []
    private var streamingCleanup: [OpaquePointer: () -> Void] = [:]
    private var loggers: [String: OpaquePointer] = [:]
    
    private var disconnectTask: Task<MetaWear>?
    private var isObserving = false {
        didSet { didSetIsObserving(oldValue) }
    }
    
    private var accelerometerBMI160StepCount = 0
    private var accelerometerBMI160Data: [(Int64, MblMwCartesianFloat)] = []
    private var gyroBMI160Data: [(Int64, MblMwCartesianFloat)] = []
    private var magnetometerBMM150Data: [(Int64, MblMwCartesianFloat)] = []
    private var gpioPinChangeCount = 0
    private var hygrometerBME280Event: OpaquePointer?
    private var sensorFusionData = Data()
    
}

// MARK: - Coordinate ViewModels and Update Feed

extension MWDeviceDetailsCoordinator: DeviceDetailsCoordinator {
    
    public func start() {
        resetStreamingEvents()
        configureVMs()
        deviceHeaderVM.start()
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
        startShowingConnectionProgressInHUDAndReadAnonymousLoggersWhenConnected()
    }
    
}

/// Helpers
private extension MWDeviceDetailsCoordinator {
    
    func configureVMs() {
        [deviceHeaderVM].forEach {
            $0.configure(parent: self, device: device)
        }
    }
    
    func resetStreamingEvents() {
        streamingEvents = []
        delegate?.hideAndReloadAllCells()
    }
    
    func deviceDisconnected() {
        deviceHeaderVM.refreshConnectionState()
        delegate?.hideAndReloadAllCells()
    }
    
    func deviceConnected() {
        deviceHeaderVM.refreshConnectionState()
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
    
    func deviceConnectedReadAnonymousLoggers() {
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
            self.deviceConnected()
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

    func startShowingConnectionProgressInHUDAndReadAnonymousLoggersWhenConnected() {
#if os(iOS)
        let window = UIApplication.shared.windows.first(where: \.isKeyWindow)!

        let hud = MBProgressHUD.showAdded(to: window, animated: true)
        hud.label.text = "Connecting..."

        device.connectAndSetup().continueWith(.mainThread) { task in
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

            self.deviceConnectedReadAnonymousLoggers()
            hud.label.text! = "Connected!"
            hud.hide(animated: true, afterDelay: 0.5)

        }
#endif
    }
}

