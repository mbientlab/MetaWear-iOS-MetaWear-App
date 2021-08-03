//  © 2021 Ryan Ferrell. github.com/importRyan


import Foundation

public enum AccelerometerSampleFrequency: Int, CaseIterable {
    case hz800
    case hz400
    case hz200
    case hz100
    case hz50
    case hz12_5

    var frequency: Float {
        switch self {
            case .hz800: return 800
            case .hz400: return 400
            case .hz200: return 200
            case .hz100: return 100
            case .hz50: return 50
            case .hz12_5: return 12.5
        }
    }

    var frequencyLabel: String { String(self.frequency) }
}
