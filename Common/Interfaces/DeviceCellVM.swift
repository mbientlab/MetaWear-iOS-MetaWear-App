//
//  DeviceCellVM.swift
//  DeviceCellVM
//
//  Created by Ryan on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
import MetaWear

public protocol DeviceCell: AnyObject {
    func updateView()
}

public protocol DeviceCellVM: AnyObject {

    var cell:         DeviceCell?   { get set }

    var uuid:         String        { get }
    var rssi:         String        { get }
    var isConnected:  Bool          { get }
    var name:         String        { get }
    var signalImage:  String        { get }

    func configure(_ cell: DeviceCell, for device: MetaWear?)
    func configure(_ cell: DeviceCell, for scannerItem: ScannerModelItem?)
    func cancelSubscriptions()
}
