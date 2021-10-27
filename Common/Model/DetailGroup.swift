//
//  DetailGroup.swift
//  DetailGroup
//
//  Created by Ryan Ferrell on 8/6/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation

public enum DetailGroup: Int, CaseIterable, Identifiable, IntSortOrder {

    // Minimum (reflecting existing iOS storyboard)
    case headerInfoAndState
    case identifiers
    case signal
    case reset

    // Features
    case accelerometer
    case ambientLight
    case barometer
    case gpio
    case gyroscope
    case haptic
    case hygrometer
    case ibeacon
    case i2c
    case LED
    case magnetometer
    case mechanicalSwitch
    case sensorFusion
    case temperature

    public var title: String {
        switch self {
            case .headerInfoAndState:   return "MetaWear"
            case .identifiers:          return "Device"
            case .signal:               return "Signal"
            case .reset:                return "Reset & Power"
            case .mechanicalSwitch:     return "Mechanical Switch"
            case .LED:                  return "LED"
            case .temperature:          return "Temperature"
            case .accelerometer:        return "Accelerometer"
            case .sensorFusion:         return "Sensor Fusion"
            case .gyroscope:            return "Gyroscope"
            case .magnetometer:         return "Magnetometer"
            case .gpio:                 return "GPIO"
            case .haptic:               return "Haptic/Buzzer"
            case .ibeacon:              return "iBeacon"
            case .barometer:            return "Barometer"
            case .ambientLight:         return "Ambient Light"
            case .hygrometer:           return "Hygrometer"
            case .i2c:                  return "I2C Bus"
        }
    }

    public var symbol: SFSymbol {
        switch self {
            case .headerInfoAndState:   return .identity
            case .identifiers:          return .firmware
            case .signal:               return .signal
            case .reset:                return .reset
            case .mechanicalSwitch:     return .mechanicalSwitch
            case .LED:                  return .led
            case .temperature:          return .temperature
            case .accelerometer:        return .accelerometer
            case .sensorFusion:         return .sensorFusion
            case .gyroscope:            return .gyroscope
            case .magnetometer:         return .magnetometer
            case .gpio:                 return .gpio
            case .haptic:               return .haptic
            case .ibeacon:              return .ibeacon
            case .barometer:            return .barometer
            case .ambientLight:         return .ambientLight
            case .hygrometer:           return .hygrometer
            case .i2c:                  return .i2c
        }
    }

    public var id: Int { rawValue }

    public var sortOrder: Int { rawValue }
}
