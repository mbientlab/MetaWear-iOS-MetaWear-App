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
    case battery
    case firmware
    case reset
    case signal

    // Features
    case mechanicalSwitch
    case temperature
    case LED
    case accelerometer
    case sensorFusion
    case gyroscope
    case magnetometer
    case gpio
    case haptic
    case ibeacon
    case barometer
    case ambientLight
    case hygrometer
    case i2c

    public var title: String {
        switch self {
            case .headerInfoAndState:   return "MetaWear"
            case .identifiers:          return "Identity"
            case .battery:              return "Battery"
            case .signal:               return "Signal"
            case .firmware:             return "Firmware"
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
            case .i2c:                  return "I2C"
        }
    }

    public var symbol: SFSymbol {
        switch self {
            case .headerInfoAndState:   return .identity
            case .identifiers:          return .identity
            case .battery:              return .battery
            case .signal:               return .signal
            case .firmware:             return .firmware
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

    public var isInfo: Bool {
        switch self {
            case .headerInfoAndState:   return true
            case .identifiers:          return true
            case .battery:              return true
            case .signal:               return true
            case .firmware:             return true
            case .reset:                return true
            case .mechanicalSwitch:     return false
            case .LED:                  return false
            case .temperature:          return false
            case .accelerometer:        return false
            case .sensorFusion:         return false
            case .gyroscope:            return false
            case .magnetometer:         return false
            case .gpio:                 return false
            case .haptic:               return false
            case .ibeacon:              return false
            case .barometer:            return false
            case .ambientLight:         return false
            case .hygrometer:           return false
            case .i2c:                  return false
        }
    }

    public var id: Int { rawValue }

    public var sortOrder: Int { rawValue }
}
