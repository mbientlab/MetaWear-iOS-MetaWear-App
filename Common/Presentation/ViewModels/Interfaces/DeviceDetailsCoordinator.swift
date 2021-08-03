//
//  DeviceDetailsController.swift
//  DeviceDetailsController
//
//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
import MetaWear
import MetaWearCpp
import BoltsSwift

public protocol DeviceDetailsCoordinator: AnyObject {

    /// Presents relevant cells for data feeds made available
    var delegate: DeviceDetailsCoordinatorDelegate? { get set }

    /// Present progress dialogs
    var hud: HUDVM { get }

    var loggers: [String: OpaquePointer] { get }

    /// Establish device connection and display relevant data.
    func start()

    /// Terminate device connection and clean up references.
    func end()

    /// Called to kickoff a newly connected device or when a user toggles the connection on or off
    func connectDevice(_ newState: Bool)

    /// Handle disconnecting and reconnecting the device for log reset.
    func logCleanup(_ handler: @escaping (Error?) -> Void)
    func addLog(_ log: String, _ pointer: OpaquePointer)
    @discardableResult func removeLog(_ log: String) -> OpaquePointer?

    func storeStream(_ signal: OpaquePointer, cleanup: (() -> Void)? )

    func removeStream(_ signal: OpaquePointer)

    func userIntentDidCauseDeviceDisconnect()

    func export(_ data: Data, titled: String)
}


public protocol DeviceDetailsCoordinatorDelegate: AnyObject {

    /// When the device is changed, remove all displayed data and redisplay available cells.
    func hideAndReloadAllCells()

    func reloadAllCells()

    func changeVisibility(of group: DetailGroup, shouldShow: Bool)

    func presentFileExportDialog(fileURL: URL, saveErrorTitle: String, saveErrorMessage: String)

}


public enum DetailGroup {

    // Minimum (reflecting existing iOS storyboard)
    case headerInfoAndState
    case identifiers
    case battery
    case signal
    case firmware
    case reset

    // Features
    case LED
    case mechanicalSwitch
    case temperature
    case accelerometer
}
