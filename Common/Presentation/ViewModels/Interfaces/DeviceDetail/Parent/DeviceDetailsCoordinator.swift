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
    var toast: ToastVM { get }

    /// Present alerts
    var alerts: AlertPresenter { get }

    /// Logs and streams
    var signals: SignalReferenceStore { get }

    /// Present and move files for user requests
    var exporter: FileExporter { get }

    func setDevice(_ device: MetaWear)

    /// Establish device connection and display relevant data.
    func start()

    /// Terminate device connection and clean up references.
    func end()

    /// Called to kickoff a newly connected device
    func connectDevice(_ newState: Bool)

    /// When a user toggles the connection on or off, the visible cells will also be reloaded
    func userRequestedDeviceDisconnect()

    /// Side effect: An action such as a restart intent caused the device state to change
    func userIntentDidCauseDeviceDisconnect()

    /// Handle disconnecting and reconnecting the device for log reset.
    func logCleanup(_ handler: @escaping (Error?) -> Void)

    /// Call to cleanup KVO or other items
    func viewWillDisappear()
}


public protocol DeviceDetailsCoordinatorDelegate: AnyObject {

    /// When the device is changed, remove all displayed data and redisplay available cells.
    func hideAllCells()

    func reloadAllCells()

    func changeVisibility(of group: DetailGroup, shouldShow: Bool)

    func show(groups: [DetailGroup])

}

public protocol SignalReferenceStore: AnyObject {

    var loggers: [String: OpaquePointer] { get }

    func getLogSize()
    func clearEntries()
    func stopLogging()
    func startLogging()
    func clearEntriesAndRemoveLoggers()

    func addLog(_ log: String, _ pointer: OpaquePointer)
    @discardableResult func removeLog(_ log: String) -> OpaquePointer?

    func storeStream(_ signal: OpaquePointer, cleanup: (() -> Void)? )
    func removeStream(_ signal: OpaquePointer)

}

public protocol SignalReferenceStoreSetup: AnyObject {

    func setup(_ parent: MWDeviceDetailsCoordinator, _ device: MetaWear)
    func completeAllStreamingCleanups()
    func removeAllLogs()

}
