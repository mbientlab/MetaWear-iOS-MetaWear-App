//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation

public protocol GraphObject: AnyObject {

    func addPointInAllSeries(_ point: [Float])
    /// Data in time point format (outer array)
    func updateYScale(min: Double, max: Double, data: [[Float]])
    func changeGraphFormat(_ config: GraphConfig)
    func clearData()

}

protocol LoggerGraphManager: AnyObject {
    /// Use weak reference
    var loggerGraph: GraphObject? { get set }
    func setLoggerGraphReference(_ graph: GraphObject)
}

protocol StreamGraphManager: AnyObject {
    /// Use  weak reference
    var streamGraph: GraphObject? { get set }
    func setStreamGraphReference(_ graph: GraphObject)
}

public extension GraphObject {

    static func moveFromSeriesToTimePoints(_ data: [[Float]]) -> [[Float]] {
        guard !data.isEmpty else { return [] }

        let seriesCount = data.count
        let nearestEndIndex = data.map(\.endIndex).min() ?? 0
        guard nearestEndIndex > 0 else { return [] }

        var points: [[Float]] = []

        for index in 0..<nearestEndIndex {

            var heights: [Float] = []
            for i in 0..<seriesCount {
                heights.append(data[i][index])
            }

            points.append(heights)
        }
        return points
    }

    static func moveFromTimePointsToSeries(_ data: [[Float]]) -> [[Float]] {
        guard let first = data.first else { return [] }
        let seriesCount = first.count
        var ordered = Array(repeating: [Float](), count: seriesCount)

        for timepoint in data {
            for series in timepoint.indices {
                ordered[series].append(timepoint[series])
            }
        }

        return ordered
    }
}
