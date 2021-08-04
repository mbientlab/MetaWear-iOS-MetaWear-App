//  © 2021 Ryan Ferrell. github.com/importRyan


import SwiftUI

enum SFSymbol: String {
    case identity = "info.circle"
    case battery = "battery.25"
    case signal = "antenna.radiowaves.left.and.right"
    case firmware = "internaldrive"
    case reset = "restart.circle"
    case mechanicalSwitch = "circle"
    case led = "light.max"
    case temperature = "thermometer"
    case accelerometer = "hand.draw"

    case sensorFusion = "infinity"
    case gyroscope = "gyroscope"
    case magnetometer = "location.north.line"
    case gpio = "selection.pin.in.out"
    case haptic = "arrow.up.and.down.and.arrow.left.and.right"
    case ibeacon = "mappin.and.ellipse"
    case barometer = "barometer"
    case ambientLight = "rays"
    case i2c = "fiberchannel"

    case steps = "figure.walk"
    case refresh = "arrow.clockwise"
    case solidCircle = "circle.fill"
    case flash = "bolt.circle.fill"
    case orientation = "move.3d"
    case send = "paperplane"
}

extension SFSymbol {

    func image() -> Image {
        Image(systemName: self.rawValue)
    }

    var accessibilityDescription: String {
        switch self {
            case .accelerometer: return "Accelerometer"
            case .identity: return "Info"
            case .battery: return "Battery"
            case .signal: return "Signal Waves"
            case .firmware: return "Firmware"
            case .reset: return "Reset"
            case .mechanicalSwitch: return "Mechanical Switch"
            case .led: return "LED"
            case .temperature: return "Temperature"
            case .steps: return "Walking Steps"
            case .sensorFusion: return "Sensor Fusion"
            case .gyroscope: return "Gyroscope"
            case .magnetometer: return "Magnetometer"
            case .gpio: return "General Purpose In-Out"
            case .haptic: return "Haptic"
            case .ibeacon: return "iBeacon"
            case .barometer: return "Barometer"
            case .ambientLight: return "Ambient Light"
            case .i2c: return "I2C"

            case .refresh: return "Refresh Arrow"
            case .solidCircle: return "Circle"
            case .flash: return "Lightning Flash"
            case .orientation: return "3D Orientation"
            case .send: return "Export"
        }
    }
}
