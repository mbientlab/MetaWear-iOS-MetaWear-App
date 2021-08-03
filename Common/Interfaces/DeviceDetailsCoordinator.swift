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

    /// Establish device connection and display relevant data.
    func start()

    /// Terminate device connection and clean up references.
    func end()

    /// Called to kickoff a newly connected device or when a user toggles the connection on or off
    func connectDevice(_ newState: Bool)

    /// Handle disconnecting and reconnecting the device for log reset.
    func logCleanup(_ handler: @escaping (Error?) -> Void)

    func storeStream(_ signal: OpaquePointer)

    func removeStream(_ signal: OpaquePointer)

    func userIntentDidCauseDeviceDisconnect()

    func presentProgressHUD(label: String)

    func updateProgressHUD(percentage: Float)

    /// Specify nil for default 2 second delay
    func updateAndCloseHUD(finalMessage: String, delay: Double?)
}


public protocol DeviceDetailsCoordinatorDelegate: AnyObject {

    /// When the device is changed, remove all displayed data and redisplay available cells.
    func hideAndReloadAllCells()

    func reloadAllCells()

    func changeVisibility(of group: DetailGroup, shouldShow: Bool)

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
}
