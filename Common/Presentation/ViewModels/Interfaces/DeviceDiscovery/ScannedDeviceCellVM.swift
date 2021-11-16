//
//  ScannedDeviceCellVM.swift
//  ScannedDeviceCellVM
//
//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
import MetaWear

public protocol ScannedDeviceCellVM: AnyObject {

    var cell:         ScannedDeviceCell?   { get set }
    var parent:       DevicesScanningVM?   { get set }

    var uuid:         String        { get }
    var rssi:         String        { get }
    var isConnected:  Bool          { get }
    var name:         String        { get }
    var signalImage:  String        { get }
    var signal:       SignalLevel   { get }

    func configure(_ cell: ScannedDeviceCell, for device: MetaWear?)
    func configure(_ cell: ScannedDeviceCell, for scannerItem: ScannerModelItem?)
    func cancelSubscriptions()
    func manuallyRefresh()
}

public protocol ScannedDeviceCell: AnyObject {
    func refreshView()
}
