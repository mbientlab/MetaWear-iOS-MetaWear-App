//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
import MetaWearCpp
import MetaWear

public enum AccelerometerGraphScale: Int, CaseIterable {
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
    var cppEnumValue: MblMwAccBoschRange {
        switch self {
            case .two: return MBL_MW_ACC_BOSCH_RANGE_2G
            case .four: return MBL_MW_ACC_BOSCH_RANGE_4G
            case .eight: return MBL_MW_ACC_BOSCH_RANGE_8G
            case .sixteen: return MBL_MW_ACC_BOSCH_RANGE_16G
        }
    }
}

public enum AccelerometerModel: CaseIterable {
    case bmi270
    case bmi160

    /// Raw Cpp constant
    var int8Value: UInt8 {
        switch self {
            case .bmi270: return MetaWearCpp.MBL_MW_MODULE_ACC_TYPE_BMI270
            case .bmi160: return MetaWearCpp.MBL_MW_MODULE_ACC_TYPE_BMI160
        }
    }

    /// Cpp constant for Swift
    var int32Value: Int32 {
        Int32(int8Value)
    }

    init?(value: Int32) {
        switch value {
            case Self.bmi270.int32Value: self = .bmi270
            case Self.bmi160.int32Value: self = .bmi160
            default: return nil
        }
    }

    init?(board: OpaquePointer) {
        let accelerometer = mbl_mw_metawearboard_lookup_module(board, MBL_MW_MODULE_ACCELEROMETER)
        self.init(value: accelerometer)
    }
}
