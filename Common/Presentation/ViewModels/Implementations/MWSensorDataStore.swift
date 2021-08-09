//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
import MetaWearCpp

public typealias MWDataPoint = (id: Int64, value: MblMwCartesianFloat)

public class MWSensorDataStore {

    var logged: [MWDataPoint] = []
    var stream: [MWDataPoint] = []

    var loggedCount: Int { logged.countedByEndIndex() }
    var streamCount: Int { stream.countedByEndIndex() }
}

public extension MWSensorDataStore {

    func getLoggedStats() -> MWDataStreamStats {
        logged.getMinMaxes()
    }

    func getStreamedStats() -> MWDataStreamStats {
        stream.getMinMaxes()
    }

    func clearLogged() {
        logged = []
    }

    func clearStreamed() {
        stream = []
    }

    func makeLogData() -> Data {
        var data = Data()
        for dataElement in logged {
            let string = "\(dataElement.0),\(dataElement.1.x),\(dataElement.1.y),\(dataElement.1.z)\n"
            data.append(string.data(using: String.Encoding.utf8)!)
        }
        return data
    }

    func makeStreamData() -> Data {
        var data = Data()
        for dataElement in stream {
            let string = "\(dataElement.0),\(dataElement.1.x),\(dataElement.1.y),\(dataElement.1.z)\n"
            data.append(string.data(using: String.Encoding.utf8)!)
        }
        return data
    }
}

// MARK: - Helpers

extension Array where Element == MWDataPoint {

    public func getMinMaxes() -> MWDataStreamStats {
        var stats = MWDataStreamStats.placeholder
        for (_, pt) in self {
            if pt.x > stats.xMax { stats.xMax = pt.x }
            if pt.x < stats.xMin { stats.xMin = pt.x }

            if pt.y > stats.yMax { stats.yMax = pt.y }
            if pt.y < stats.yMin { stats.yMin = pt.y }

            if pt.z > stats.zMax { stats.zMax = pt.z }
            if pt.z < stats.zMin { stats.zMin = pt.z }
        }
        return stats
    }

    public func asFloats() -> [[Float]] {
        map { id, point in
            [point.x, point.y, point.z]
        }
    }
}

public struct MWDataStreamStats {
    public var xMin: Float
    public var xMax: Float
    public var yMin: Float
    public var yMax: Float
    public var zMin: Float
    public var zMax: Float

    public static let placeholder: MWDataStreamStats = {
        let minPlaceholder = Float.greatestFiniteMagnitude
        let maxPlaceholder = -Float.greatestFiniteMagnitude
        return MWDataStreamStats(
            xMin: minPlaceholder,
            xMax: maxPlaceholder,
            yMin: minPlaceholder,
            yMax: maxPlaceholder,
            zMin: minPlaceholder,
            zMax: maxPlaceholder
        )
    }()

    public static let zero: Self = MWDataStreamStats(
        xMin: 0,
        xMax: 0,
        yMin: 0,
        yMax: 0,
        zMin: 0,
        zMax: 0
    )

    public init(xMin: Float, xMax: Float, yMin: Float, yMax: Float, zMin: Float, zMax: Float) {
        self.xMin = xMin
        self.xMax = xMax
        self.yMin = yMin
        self.yMax = yMax
        self.zMin = zMin
        self.zMax = zMax
    }
}
