//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation

public struct MWDataStreamStats: Hashable, Equatable {
    public var mins: [Float]
    public var maxs: [Float]
    public var kind: DataPointKind

    public init(kind: DataPointKind, mins: [Float], maxs: [Float]) {
        self.kind = kind
        self.mins = mins
        self.maxs = maxs
    }

    public init(kind: DataPointKind, data: [TimeIdentifiedDataPoint]) {
        var stats = Self.calculationPlaceholder(for: kind)

        for point in data {

            for index in point.values.indices {
                let dataPointValue = point.values[index]
                let currentMin = stats.mins[index]
                let currentMax = stats.maxs[index]

                if dataPointValue < currentMin {
                    stats.mins[index] = dataPointValue
                }
                if dataPointValue > currentMax {
                    stats.maxs[index] = dataPointValue
                }
            }
        }

        self = stats
    }

    public static func calculationPlaceholder(for kind: DataPointKind) -> Self {
        MWDataStreamStats(
            kind: kind,
            mins: Array(repeating: Float.greatestFiniteMagnitude, count: kind.channelCount),
            maxs: Array(repeating: -Float.greatestFiniteMagnitude, count: kind.channelCount)
        )
    }

    public static func zero(for kind: DataPointKind) -> Self {
        MWDataStreamStats(
            kind: kind,
            mins: Array(repeating: 0, count: kind.channelCount),
            maxs: Array(repeating: 0, count: kind.channelCount)
        )
    }
}
