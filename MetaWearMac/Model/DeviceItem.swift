//
//  DeviceItem.swift
//  DeviceItem
//
//  Created by Ryan Ferrell on 8/5/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation

struct DeviceItem: Identifiable, Hashable, Equatable {
    var id: UUID
    var name: String
    var signal: String
    var signalLevel: Int
    var mac: String
}
