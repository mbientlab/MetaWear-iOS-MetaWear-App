//
//  SignalLevel.swift
//  SignalLevel
//
//  Created by Ryan Ferrell on 8/6/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation

public enum SignalLevel: Int {
    case noBars
    case oneBar
    case twoBars
    case threeBars
    case fourBars
    case fiveBars

    public init(rssi: Double) {
        switch rssi {
            case ...(-80): self = .noBars
            case ...(-70): self = .oneBar
            case ...(-60): self = .twoBars
            case ...(-50): self = .threeBars
            case ...(-40): self = .fourBars
            default:       self = .fiveBars
        }
    }

    public init(rssi: Int) {
        self.init(rssi: Double(rssi))
    }

    public var dots: Int { rawValue }

    public var imageAsset: Images {
        switch self {
            case .noBars: return .noBars
            case .oneBar: return .oneBar
            case .twoBars: return .twoBars
            case .threeBars: return .threeBars
            case .fourBars: return .fourBars
            case .fiveBars: return .fiveBars
        }
    }

    public static let maxBars = 5
}
