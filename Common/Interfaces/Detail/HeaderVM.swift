//
//  DetailHeaderVM.swift
//  DetailHeaderVM
//
//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation

public protocol DetailHeaderVM: AnyObject, DetailConfiguring {

    // State
    var delegate: DetailHeaderVMDelegate? { get set }
    var deviceName: String { get }
    var connectionState: String { get }
    var connectionIsOn: Bool { get }

    /// Model data is now available
    func start()
    /// Signals model did update
    func refreshName()
    /// Signals model did update
    func refreshConnectionState()

    // User Intents
    func userSetConnection(to newState: Bool)
    func userUpdatedName(to newValue: String)
    func didUserTypeValidDeviceName(_ newString: String, range: NSRange, fullString: String) -> Bool
}

public protocol DetailHeaderVMDelegate: AnyObject {
    func refreshView()
}

