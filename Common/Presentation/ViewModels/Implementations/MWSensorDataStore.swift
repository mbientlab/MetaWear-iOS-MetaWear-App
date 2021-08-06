//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation
import MetaWearCpp

public typealias MWDataPoint = (id: Int64, value: MblMwCartesianFloat)

class MWSensorDataStore {

    var logged: [MWDataPoint] = []
    var stream: [MWDataPoint] = []

    var loggedCount: Int { logged.countedByEndIndex() }
    var streamCount: Int { stream.countedByEndIndex() }
}

extension MWSensorDataStore {

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

extension Array {

    func countedByEndIndex() -> Int {
        if self.isEmpty { return 0 }
        return endIndex > 1 ? endIndex : 1
    }
}

extension Array where Element == MWDataPoint {

    func getMinMaxes() -> MWDataStreamStats {
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

    func asFloats() -> [[Float]] {
        map { id, point in
            [point.x, point.y, point.z]
        }
    }
}

struct MWDataStreamStats {
    var xMin: Float
    var xMax: Float
    var yMin: Float
    var yMax: Float
    var zMin: Float
    var zMax: Float

    static let placeholder: MWDataStreamStats = {
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

    static let zero: Self = MWDataStreamStats(
        xMin: 0,
        xMax: 0,
        yMin: 0,
        yMax: 0,
        zMin: 0,
        zMax: 0
    )
}
