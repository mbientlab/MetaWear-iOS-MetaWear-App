//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
import MetaWearCpp

public struct TimeIdentifiedDataPoint: Hashable, Equatable, Identifiable {
    public var timepoint: Int64
    public var values: [Float]

    public var id: Int64 { timepoint }

    public init(timepoint: Int64, values: [Float]) {
        self.timepoint = timepoint
        self.values = values
    }
}

// MARK: - Kinds

public typealias TimeIdentifiedCartesianFloat = (id: Int64, value: MblMwCartesianFloat)
public typealias TimeIdentifiedEulerAngles = (id: Int64, value: MblMwEulerAngles)
public typealias TimeIdentifiedQuaternion = (id: Int64, value: MblMwQuaternion)

public extension TimeIdentifiedDataPoint {

    init(cartesian: TimeIdentifiedCartesianFloat) {
        self.timepoint = cartesian.id
        self.values = [cartesian.value.x, cartesian.value.y, cartesian.value.z]
    }

    init(euler: TimeIdentifiedEulerAngles) {
        self.timepoint = euler.id
        self.values = [euler.value.pitch, euler.value.roll, euler.value.yaw, euler.value.heading]
    }

    init(quaternion: TimeIdentifiedQuaternion) {
        self.timepoint = quaternion.id
        self.values = [quaternion.value.w, quaternion.value.x, quaternion.value.y, quaternion.value.z]
    }
}

public enum DataPointKind: Int {
    case cartesianXYZ
    case eulerAngle
    case quaternion

    public var channelCount: Int { channelLabels.endIndex }

    public var channelLabels: [String] {
        switch self {
            case .cartesianXYZ: return ["X", "Y", "Z"]
            case .eulerAngle: return ["Pitch", "Roll", "Yaw", "Heading"]
            case .quaternion: return ["W", "X", "Y", "Z"]
        }
    }

    public var indexedChannelLabels: [(index: Int, label: String)] {
        zip(channelLabels.indices, channelLabels).map { ($0.0, $0.1) }
    }

    public func makeCSVHeaderLine() -> String {
        let labels = ["Epoch"] + channelLabels
        return labels.joined(separator: ",").appending("\n")
    }

    public var csvFormattingMethod: ((TimeIdentifiedDataPoint) -> String) {
        csvFormat(rawData:)
    }

    private func csvFormat(rawData point: TimeIdentifiedDataPoint) -> String {
        let info = [String(point.timepoint)] + point.values.map { String($0) }
        return info.joined(separator: ",").appending("\n")
    }

}

// MARK: - Scaling

extension MblMwEulerAngles {
    mutating func scaled(in range: Float) {
        pitch.scaled(min: -180, max: 180, in: 180)
        roll.scaled(min: -90, max: 90, in: 90)
        yaw.scaled(min: 0, max: 360, in: 360)
        heading.scaled(min: 0, max: 360, in: 360)
    }
}

extension MblMwQuaternion {

    mutating func scaled(min: Float = -1.0, max: Float = 1.0, in range: Float) {
        self.w.scaled(min: min, max: max, in: range)
        self.x.scaled(min: min, max: max, in: range)
        self.y.scaled(min: min, max: max, in: range)
        self.z.scaled(min: min, max: max, in: range)
    }
}

extension MblMwCartesianFloat {

    mutating func scaledGravity(min: Float = -1.0, max: Float = 1.0, in range: Float) {
        self.x.scaled(min: min, max: max, in: range)
        self.y.scaled(min: min, max: max, in: range)
        self.z.scaled(min: min, max: max, in: range)
    }

    mutating func scaled(min: Float, max: Float, in range: Float = 1) {
        self.x.scaled(min: min, max: max, in: range)
        self.y.scaled(min: min, max: max, in: range)
        self.z.scaled(min: min, max: max, in: range)
    }

    mutating func scaled(by multiple: Float) {
        self.x = x * multiple
        self.y = y * multiple
        self.z = z * multiple
    }
}

extension Float {

    static func scaled(value: Float, min: Float, max: Float, in range: Float) -> Float {
        var value = value
        value.scaled(min: min, max: max, in: range)
        return value
    }

    mutating func scaled(min: Float, max: Float, in range: Float) {
        var value = Float.minimum(self, max)
        value = .maximum(self, min)
        let percent = (value - min) / (max - min)
        self = (range * 2 *  percent) - range
    }

    mutating func scaled(min: Float, max: Float, in range: Int) {
        scaled(min: min, max: max, in: Float(range))
    }
}
