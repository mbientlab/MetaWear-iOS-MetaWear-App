//
//  MetaWearDeviceModel.swift
//  MetaWearDeviceModel
//
//  Created by Ryan Ferrell on 8/7/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
import MetaWear
import MetaWearCpp

public enum MetaWearDeviceModel {
    case s
    case c
    case notFound

    public init(device: MetaWear) {
        let string = String(cString: mbl_mw_metawearboard_get_model_name(device.board))
        self.init(string: string)
    }

    public init(string: String) {
        if string.contains("MetaMotion S") {
            self = .s
        } else if string.contains("MetaMotion C") {
            self = .c
        } else {
            self = .notFound
        }
    }

    var isolatedModelName: String {
        switch self {
            case .s: return "MetaMotion S"
            case .c: return "MetaMotion C"
            case .notFound: return "Model Unknown"
        }
    }
}

public extension MetaWearDeviceModel {

    var bundleName: String? {
        switch self {
            case .s: return "metamotionS"
            case .c: return "metamotionC"
            case .notFound: return nil
        }
    }
}
