//
//  DeviceItem.swift
//  DeviceItem
//
//  Created by Ryan Ferrell on 8/5/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation

public struct DeviceItem: Identifiable, Hashable, Equatable {

    public init(name: String, signal: String, signalLevel: SignalLevel, mac: String? = nil, reservedID: UUID = UUID(), isDiscoveredList: Bool) {
        self.name = name
        self.signal = signal
        self.signalLevel = signalLevel
        self.mac = mac
        self.reservedID = reservedID
        self.isDiscoveredList = isDiscoveredList
    }

    public var id: String { (mac ?? reservedID.uuidString) + isDiscoveredList.description }
    public var name: String
    public var signal: String
    public var signalLevel: SignalLevel
    public var mac: String?
    public var reservedID = UUID()
    public var isDiscoveredList: Bool
}
