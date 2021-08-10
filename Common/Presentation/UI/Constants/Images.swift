//
//  Images.swift
//  Images
//
//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation

public enum Images {
    case noBars
    case oneBar
    case twoBars
    case threeBars
    case fourBars
    case fiveBars
    case noSignal

    public var catalogName: String {
        switch self {
            case .noBars:    return "wifi_d1"
            case .oneBar:    return "wifi_d2"
            case .twoBars:   return "wifi_d3"
            case .threeBars: return "wifi_d4"
            case .fourBars:  return "wifi_d5"
            case .fiveBars:  return "wifi_d6"
            case .noSignal:  return "wifi_not_connected"
        }
    }
}
