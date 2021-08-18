//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
import MetaWearCpp
import MetaWear

// MARK: - Accelerometer

public enum AccelerometerGraphScale: Int, CaseIterable, Identifiable {
    case two
    case four
    case eight
    case sixteen

    public var fullScale: Int {
        switch self {
            case .two: return 2
            case .four: return 4
            case .eight: return 8
            case .sixteen: return 16
        }
    }

    /// Raw Cpp constant
    public var cppEnumValue: MblMwAccBoschRange {
        switch self {
            case .two: return MBL_MW_ACC_BOSCH_RANGE_2G
            case .four: return MBL_MW_ACC_BOSCH_RANGE_4G
            case .eight: return MBL_MW_ACC_BOSCH_RANGE_8G
            case .sixteen: return MBL_MW_ACC_BOSCH_RANGE_16G
        }
    }

    public var id: Int { fullScale }
}

public enum AccelerometerModel: CaseIterable {
    case bmi270
    case bmi160

    /// Raw Cpp constant
    public var int8Value: UInt8 {
        switch self {
            case .bmi270: return MetaWearCpp.MBL_MW_MODULE_ACC_TYPE_BMI270
            case .bmi160: return MetaWearCpp.MBL_MW_MODULE_ACC_TYPE_BMI160
        }
    }

    /// Cpp constant for Swift
    public var int32Value: Int32 {
        Int32(int8Value)
    }

    public init?(value: Int32) {
        switch value {
            case Self.bmi270.int32Value: self = .bmi270
            case Self.bmi160.int32Value: self = .bmi160
            default: return nil
        }
    }

    public init?(board: OpaquePointer?) {
        let accelerometer = mbl_mw_metawearboard_lookup_module(board, MBL_MW_MODULE_ACCELEROMETER)
        self.init(value: accelerometer)
    }
}

enum Orientation: CaseIterable {
    case faceUpPortraitUpright
    case faceUpPortraitUpsideDown
    case faceUpLandscapeLeft
    case faceUpLandscapeRight

    case faceDownPortraitUpright
    case faceDownPortraitUpsideDown
    case faceDownLandscapeLeft
    case faceDownLandscapeRight

    /// Raw Cpp constant
    public var cppEnumValue: MblMwSensorOrientation {
        switch self {
            case .faceUpPortraitUpright:
                return MBL_MW_SENSOR_ORIENTATION_FACE_UP_PORTRAIT_UPRIGHT

            case .faceUpPortraitUpsideDown:
                return MBL_MW_SENSOR_ORIENTATION_FACE_UP_PORTRAIT_UPSIDE_DOWN

            case .faceUpLandscapeLeft:
                return MBL_MW_SENSOR_ORIENTATION_FACE_UP_LANDSCAPE_LEFT

            case .faceUpLandscapeRight:
                return MBL_MW_SENSOR_ORIENTATION_FACE_UP_LANDSCAPE_RIGHT


            case .faceDownPortraitUpright:
                return MBL_MW_SENSOR_ORIENTATION_FACE_DOWN_PORTRAIT_UPRIGHT

            case .faceDownPortraitUpsideDown:
                return MBL_MW_SENSOR_ORIENTATION_FACE_DOWN_PORTRAIT_UPSIDE_DOWN

            case .faceDownLandscapeLeft:
                return MBL_MW_SENSOR_ORIENTATION_FACE_DOWN_LANDSCAPE_LEFT

            case .faceDownLandscapeRight:
                return MBL_MW_SENSOR_ORIENTATION_FACE_DOWN_LANDSCAPE_RIGHT
        }
    }

    public var displayName: String {
        switch self {
            case .faceUpPortraitUpright:
                return "Portrait Upright, Face Up"
            case .faceUpPortraitUpsideDown:
                return "Portrait Upsidedown, Face Up"
            case .faceUpLandscapeLeft:
                return "Landscape Left, Face Up"
            case .faceUpLandscapeRight:
                return "Landscape Right, Face Up"
            case .faceDownPortraitUpright:
                return "Portrait Upright, Face Down"
            case .faceDownPortraitUpsideDown:
                return "Portrait Upsidedown, Face Down"
            case .faceDownLandscapeLeft:
                return "Landscape Left, Face Down"
            case .faceDownLandscapeRight:
                return "Landscape Right, Face Down"
        }
    }

    init?(sensor: MblMwSensorOrientation) {
        guard let match = Self.allCases.first(where: { $0.cppEnumValue == sensor })
        else { return nil }
        self = match
    }
}

// MARK: - Gyroscope

public enum GyroscopeGraphRange: Int, CaseIterable, Identifiable {
    case dps125 = 125
    case dps250 = 250
    case dps500 = 500
    case dps1000 = 1000
    case dps2000 = 2000

    public var fullScale: Int {
        switch self {
            case .dps125: return 1
            case .dps250: return 2
            case .dps500: return 4
            case .dps1000: return 8
            case .dps2000: return 16
        }
    }

    /// Raw Cpp constant
    public var cppEnumValue: MblMwGyroBoschRange {
        switch self {
            case .dps125: return MBL_MW_GYRO_BOSCH_RANGE_125dps
            case .dps250: return MBL_MW_GYRO_BOSCH_RANGE_250dps
            case .dps500: return MBL_MW_GYRO_BOSCH_RANGE_500dps
            case .dps1000: return MBL_MW_GYRO_BOSCH_RANGE_1000dps
            case .dps2000: return MBL_MW_GYRO_BOSCH_RANGE_2000dps
        }
    }

    public var displayName: String { String(rawValue) }

    public var id: Int { fullScale }

}

public enum GyroscopeFrequency: Int, CaseIterable, Identifiable {
case hz1600 = 1600
case hz800 = 800
case hz400 = 400
case hs200 = 200
case hz100 = 100
case hz50 = 50
case hz25 = 25

    /// Raw Cpp constant
    public var cppEnumValue: MblMwGyroBoschOdr {
        switch self {
            case .hz1600: return MBL_MW_GYRO_BOSCH_ODR_1600Hz
            case .hz800: return MBL_MW_GYRO_BOSCH_ODR_800Hz
            case .hz400: return MBL_MW_GYRO_BOSCH_ODR_400Hz
            case .hs200: return MBL_MW_GYRO_BOSCH_ODR_200Hz
            case .hz100: return MBL_MW_GYRO_BOSCH_ODR_100Hz
            case .hz50: return MBL_MW_GYRO_BOSCH_ODR_50Hz
            case .hz25: return MBL_MW_GYRO_BOSCH_ODR_25Hz
        }
    }

    var frequencyLabel: String { String(rawValue) }

    public var id: Int { rawValue }

}

// MARK: - Ambient Light

public enum AmbientLightGain: Int, CaseIterable, Identifiable {
    case gain1 = 1
    case gain2 = 2
    case gain4 = 4
    case gain8 = 8
    case gain48 = 48
    case gain96 = 96

    public var cppEnumValue: MblMwAlsLtr329Gain {
        switch self {
            case .gain1: return MBL_MW_ALS_LTR329_GAIN_1X
            case .gain2: return MBL_MW_ALS_LTR329_GAIN_2X
            case .gain4: return MBL_MW_ALS_LTR329_GAIN_4X
            case .gain8: return MBL_MW_ALS_LTR329_GAIN_8X
            case .gain48: return MBL_MW_ALS_LTR329_GAIN_48X
            case .gain96: return MBL_MW_ALS_LTR329_GAIN_96X
        }
    }

    var displayName: String { String(rawValue) }

    public var id: Int { rawValue }
}

public enum AmbientLightTR329IntegrationTime: Int, CaseIterable, Identifiable {
    case ms50 = 50
    case ms100 = 100
    case ms150 = 150
    case ms200 = 200
    case ms250 = 250
    case ms300 = 300
    case ms350 = 350
    case ms400 = 400

    public var cppEnumValue: MblMwAlsLtr329IntegrationTime {
        switch self {
            case .ms50: return MBL_MW_ALS_LTR329_TIME_50ms
            case .ms100: return MBL_MW_ALS_LTR329_TIME_100ms
            case .ms150: return MBL_MW_ALS_LTR329_TIME_150ms
            case .ms200: return MBL_MW_ALS_LTR329_TIME_200ms
            case .ms250: return MBL_MW_ALS_LTR329_TIME_250ms
            case .ms300: return MBL_MW_ALS_LTR329_TIME_300ms
            case .ms350: return MBL_MW_ALS_LTR329_TIME_350ms
            case .ms400: return MBL_MW_ALS_LTR329_TIME_400ms
        }
    }

    var displayName: String { String(rawValue) }

    public var id: Int { rawValue }
}

public enum AmbientLightTR329MeasurementRate: Int, CaseIterable, Identifiable {
    case ms50 = 50
    case ms100 = 100
    case ms200 = 200
    case ms500 = 500
    case ms1000 = 1000
    case ms2000 = 2000

    public var cppEnumValue: MblMwAlsLtr329MeasurementRate {
        switch self {
            case .ms50: return MBL_MW_ALS_LTR329_RATE_50ms
            case .ms100: return MBL_MW_ALS_LTR329_RATE_100ms
            case .ms200: return MBL_MW_ALS_LTR329_RATE_200ms
            case .ms500: return MBL_MW_ALS_LTR329_RATE_500ms
            case .ms1000: return MBL_MW_ALS_LTR329_RATE_1000ms
            case .ms2000: return MBL_MW_ALS_LTR329_RATE_2000ms
        }
    }

    var displayName: String { String(rawValue) }

    public var id: Int { rawValue }
}

// MARK: - Barometer

public enum BarometerStandbyTime: Int, Identifiable {
    case ms0_5
    case ms10 // Not BMP
    case ms20 // Not BMP
    case ms62_5
    case ms125
    case ms250
    case ms500
    case ms1000

    case ms2000 // Not BME
    case ms4000 // Not BME

    static let BMPoptions: [Self] = [
        .ms0_5,
// Missing these two options
        .ms62_5,
        .ms125,
        .ms250,
        .ms500,
        .ms1000,
        .ms2000,
        .ms4000
    ]
    static let BMEoptions: [Self] = [
        .ms0_5,
        .ms10,
        .ms20,
        .ms62_5,
        .ms125,
        .ms250,
        .ms500,
        .ms1000
        // Missing these two options
    ]

    public var displayName: String {
        switch self {
            case .ms0_5: return "0.5"
            case .ms10: return "10"
            case .ms20: return "20"
            case .ms62_5: return "62.5"
            case .ms125: return "125"
            case .ms250: return "250"
            case .ms500: return "500"
            case .ms1000: return "100"
            case .ms2000: return "2000"
            case .ms4000: return "4000"
        }
    }

    public var BME_cppEnumValue: MblMwBaroBme280StandbyTime {
        switch self {
            case .ms0_5: return MBL_MW_BARO_BME280_STANDBY_TIME_0_5ms
            case .ms10: return MBL_MW_BARO_BME280_STANDBY_TIME_10ms
            case .ms20: return MBL_MW_BARO_BME280_STANDBY_TIME_20ms
            case .ms62_5: return MBL_MW_BARO_BME280_STANDBY_TIME_62_5ms
            case .ms125: return MBL_MW_BARO_BME280_STANDBY_TIME_125ms
            case .ms250: return MBL_MW_BARO_BME280_STANDBY_TIME_250ms
            case .ms500: return MBL_MW_BARO_BME280_STANDBY_TIME_500ms
            case .ms1000: return MBL_MW_BARO_BME280_STANDBY_TIME_1000ms

            case .ms2000: return MBL_MW_BARO_BME280_STANDBY_TIME_1000ms // Not present
            case .ms4000: return MBL_MW_BARO_BME280_STANDBY_TIME_1000ms // Not present
        }
    }

    public var BMP_cppEnumValue: MblMwBaroBmp280StandbyTime {
        switch self {
            case .ms0_5: return MBL_MW_BARO_BMP280_STANDBY_TIME_0_5ms

            case .ms62_5: return MBL_MW_BARO_BMP280_STANDBY_TIME_62_5ms
            case .ms125: return MBL_MW_BARO_BMP280_STANDBY_TIME_125ms
            case .ms250: return MBL_MW_BARO_BMP280_STANDBY_TIME_250ms
            case .ms500: return MBL_MW_BARO_BMP280_STANDBY_TIME_500ms
            case .ms1000: return MBL_MW_BARO_BMP280_STANDBY_TIME_1000ms
            case .ms2000: return MBL_MW_BARO_BMP280_STANDBY_TIME_2000ms
            case .ms4000: return MBL_MW_BARO_BMP280_STANDBY_TIME_4000ms

            case .ms10: return MBL_MW_BARO_BMP280_STANDBY_TIME_62_5ms // Not present
            case .ms20: return MBL_MW_BARO_BMP280_STANDBY_TIME_62_5ms // Not present
        }
    }

    public var id: Int { rawValue }
}

public enum BarometerIIRFilter: Int, CaseIterable, Identifiable {
    case off
    case avg2
    case avg4
    case avg8
    case avg16

    public var cppEnumValue: MblMwBaroBoschIirFilter {
        switch self {
            case .off: return MBL_MW_BARO_BOSCH_IIR_FILTER_OFF
            case .avg2: return MBL_MW_BARO_BOSCH_IIR_FILTER_AVG_2
            case .avg4: return MBL_MW_BARO_BOSCH_IIR_FILTER_AVG_4
            case .avg8: return MBL_MW_BARO_BOSCH_IIR_FILTER_AVG_8
            case .avg16: return MBL_MW_BARO_BOSCH_IIR_FILTER_AVG_16
        }
    }

    public var displayName: String {
        switch self {
            case .off: return "Off"
            case .avg2: return "2"
            case .avg4: return "4"
            case .avg8: return "8"
            case .avg16: return "16"
        }
    }

    public var id: Int { rawValue }
}

public enum BarometerOversampling: Int, CaseIterable, Identifiable {
    case ultraLowPower
    case lowPower
    case standard
    case high
    case ultraHigh

    public var cppEnumValue: MblMwBaroBoschOversampling {
        switch self {
            case .ultraLowPower: return MBL_MW_BARO_BOSCH_OVERSAMPLING_ULTRA_LOW_POWER
            case .lowPower: return MBL_MW_BARO_BOSCH_OVERSAMPLING_LOW_POWER
            case .standard: return MBL_MW_BARO_BOSCH_OVERSAMPLING_STANDARD
            case .high: return MBL_MW_BARO_BOSCH_OVERSAMPLING_HIGH
            case .ultraHigh: return MBL_MW_BARO_BOSCH_OVERSAMPLING_ULTRA_HIGH
        }
    }

    public var displayName: String {
        switch self {
            case .ultraLowPower: return "Ultra Low"
            case .lowPower: return "Low"
            case .standard: return "Standard"
            case .high: return "High"
            case .ultraHigh: return "Ultra High"
        }
    }

    public var id: Int { rawValue }
}

public enum BarometerModel: CaseIterable {
    case bmp280
    case bme280

    /// Raw Cpp constant
    public var int8Value: UInt8 {
        switch self {
            case .bmp280: return MetaWearCpp.MBL_MW_MODULE_BARO_TYPE_BMP280
            case .bme280: return MetaWearCpp.MBL_MW_MODULE_BARO_TYPE_BME280
        }
    }

    /// Cpp constant for Swift
    public var int32Value: Int32 {
        Int32(int8Value)
    }

    public init?(value: Int32) {
        switch value {
            case Self.bmp280.int32Value: self = .bmp280
            case Self.bme280.int32Value: self = .bme280
            default: return nil
        }
    }

    public init?(board: OpaquePointer?) {
        let device = mbl_mw_metawearboard_lookup_module(board, MBL_MW_MODULE_BAROMETER)
        self.init(value: device)
    }
}

// MARK: - Hygrometer

public enum HumidityOversampling: Int, CaseIterable, Identifiable {
    case x1 = 1
    case x2 = 2
    case x4 = 4
    case x8 = 8
    case x16 = 16

    public var cppEnumValue: MblMwHumidityBme280Oversampling {
        switch self {
            case .x1: return MBL_MW_HUMIDITY_BME280_OVERSAMPLING_1X
            case .x2: return MBL_MW_HUMIDITY_BME280_OVERSAMPLING_2X
            case .x4: return MBL_MW_HUMIDITY_BME280_OVERSAMPLING_4X
            case .x8: return MBL_MW_HUMIDITY_BME280_OVERSAMPLING_8X
            case .x16: return MBL_MW_HUMIDITY_BME280_OVERSAMPLING_16X
        }
    }

    public var displayName: String { String(rawValue) }

    public var id: Int { rawValue }

}

// MARK: - GPIO

public enum GPIOPullMode: Int, CaseIterable, Identifiable {
    case up
    case down
    case pullNone

    public var cppEnumValue: MblMwGpioPullMode {
        switch self {
            case .up: return MBL_MW_GPIO_PULL_MODE_UP
            case .down: return MBL_MW_GPIO_PULL_MODE_DOWN
            case .pullNone: return MBL_MW_GPIO_PULL_MODE_NONE
        }
    }

    public var id: Int { rawValue }

}

public enum GPIOChangeType: Int, CaseIterable, Identifiable {
    case rising
    case falling
    case any

    public var cppEnumValue: MblMwGpioPinChangeType {
        switch self {
            case .rising: return MBL_MW_GPIO_PIN_CHANGE_TYPE_RISING
            case .falling: return MBL_MW_GPIO_PIN_CHANGE_TYPE_FALLING
            case .any: return MBL_MW_GPIO_PIN_CHANGE_TYPE_ANY
        }
    }

    public var displayName: String {
        switch self {
            case .rising: return "Rising"
            case .falling: return "Falling"
            case .any: return "Any"
        }
    }

    public var id: Int { rawValue }

}

public enum GPIOPin: Int, CaseIterable, Identifiable {
    case zero
    case one
    case two
    case three
    case four
    case five

    public var pinValue: UInt8 { UInt8(rawValue) }

    public var displayName: String { String(rawValue) }

    public var isReadable: Bool { return true } // Not the case

    public var id: Int { rawValue }

}

// MARK: - Sensor Fusion

public enum SensorFusionOutputType: Int, CaseIterable, Identifiable {
    case eulerAngles
    case quaternion
    case gravity
    case linearAcceleration

    public var cppEnumValue: MblMwSensorFusionData {
        switch self {
            case .eulerAngles: return MBL_MW_SENSOR_FUSION_DATA_EULER_ANGLE
            case .quaternion: return MBL_MW_SENSOR_FUSION_DATA_QUATERNION
            case .gravity: return MBL_MW_SENSOR_FUSION_DATA_GRAVITY_VECTOR
            case .linearAcceleration: return MBL_MW_SENSOR_FUSION_DATA_LINEAR_ACC
        }
    }

    public var channelCount: Int { channelLabels.endIndex }

    public var channelLabels: [String] {
        switch self {
            case .eulerAngles: return ["Heading", "Pitch", "Roll", "Yaw"]
            case .quaternion: return ["W", "X", "Y", "Z"]
            case .gravity: return ["X", "Y", "Z"]
            case .linearAcceleration: return ["X", "Y", "Z"]
        }
    }

    public var dataPointKind: DataPointKind {
        switch self {
            case .eulerAngles: return .eulerAngle
            case .quaternion: return .quaternion
            case .gravity: return .cartesianXYZ
            case .linearAcceleration: return .cartesianXYZ
        }
    }

    public var fullName: String {
        switch self {
            case .eulerAngles: return "Euler Angles"
            case .quaternion: return "Quaternion"
            case .gravity: return "Gravity"
            case .linearAcceleration: return "Linear Acceleration"
        }
    }

    public var shortFileName: String {
        switch self {
            case .eulerAngles: return "Euler"
            case .quaternion: return "Quaternion"
            case .gravity: return "Gravity"
            case .linearAcceleration: return "LinearAcc"
        }
    }

    public var scale: Float {
        switch self {
            case .eulerAngles: return 360
            case .quaternion: return 1
            case .gravity: return 1
            case .linearAcceleration: return 8
        }
    }

    public var id: Int { rawValue }

}

public enum SensorFusionMode: Int, CaseIterable, Identifiable {
    case ndof
    case imuplus
    case compass
    case m4g

    var cppValue: UInt32 { UInt32(rawValue + 1) }

    var cppMode: MblMwSensorFusionMode { MblMwSensorFusionMode(cppValue) }

    var displayName: String {
        switch self {
            case .ndof: return "NDoF"
            case .imuplus: return "IMUPlus"
            case .compass: return "Compass"
            case .m4g: return "M4G"
        }
    }

    public var id: Int { rawValue }

}

// MARK: - Temperature

public enum TemperatureSource: Int, CaseIterable, Identifiable {
    case onDie
    case external
    case bmp280
    case onboard
    case custom

    init(cpp: MblMwTemperatureSource) {
        self = Self.allCases.first(where: { $0.cppValue == cpp }) ?? .custom
    }

    var cppValue: MblMwTemperatureSource? {
        switch self {
            case .onDie: return MBL_MW_TEMPERATURE_SOURCE_NRF_DIE
            case .external: return MBL_MW_TEMPERATURE_SOURCE_EXT_THERM
            case .bmp280: return MBL_MW_TEMPERATURE_SOURCE_BMP280
            case .onboard: return MBL_MW_TEMPERATURE_SOURCE_PRESET_THERM
            case .custom: return nil
        }
    }

    var displayName: String {
        switch self {
            case .onDie: return "On-Die"
            case .external: return "External"
            case .bmp280: return "BMP280"
            case .onboard: return "Onboard"
            case .custom: return "Custom"
        }
    }

    public var id: Int { rawValue }

}
