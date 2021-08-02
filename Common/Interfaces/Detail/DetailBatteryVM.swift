//
//  MWDeviceDetailsCoordinator.swift
//  MWDeviceDetailsCoordinator
//
//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation

public protocol DetailBatteryVM: AnyObject, DetailConfiguring {

    var delegate: DetailBatteryVMDelegate? { get set }
    var batteryLevel: String { get }
    var batteryLevelPercentage: Int { get }

    func start()

    // Intents
    func userRequestedBatteryLevel()
}

public protocol DetailBatteryVMDelegate: AnyObject {
    func refreshView()
    func presentAlert(title: String, message: String)
}
