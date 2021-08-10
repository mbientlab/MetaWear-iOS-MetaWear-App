//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//


import Foundation

public enum AccelerometerSampleFrequency: Int, CaseIterable, Identifiable {
    case hz800
    case hz400
    case hz200
    case hz100
    case hz50
    case hz12_5

    public var frequency: Float {
        switch self {
            case .hz800: return 800
            case .hz400: return 400
            case .hz200: return 200
            case .hz100: return 100
            case .hz50: return 50
            case .hz12_5: return 12.5
        }
    }

    public var frequencyLabel: String {
        switch self {
            case .hz12_5: return "12.5"
            default: return String(format: "%1.0f", frequency)
        }
    }

    public var id: Int { rawValue }
}
