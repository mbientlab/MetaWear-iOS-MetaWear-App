//  Created by Ryan Ferrell on 8/7/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

struct IdentifiableTimePoint: Identifiable {
//    var id: UUID = UUID()
    var x: CGFloat
    var heights: [CGFloat]
    var id: CGFloat { x }
}

class NaiveGraphController: ObservableObject {

    /// List of timepoints where x starts at zero.
    @Published var displayedPoints: [IdentifiableTimePoint] = []
    @Published var seriesColors: [Color]
    @Published var seriesNames: [String]
    @Published var rangeY: CGFloat = 2
    @Published var yMax: Double
    @Published var yMin: Double
    @Published var displayablePointCount: CGFloat = 100

    /// Historical data store
    private var data: [IdentifiableTimePoint] = []
    private var currentPointIndex: CGFloat = 0

    private let driver: GraphDriver

    init(config: GraphConfig, driver: GraphDriver) {
        self.driver = driver
        self.rangeY = CGFloat(config.yAxisMax - config.yAxisMin)
        self.seriesColors = config.channelColorsSwift
        self.yMin = config.yAxisMin
        self.yMax = config.yAxisMax
        self.seriesNames = config.channelLabels
        self.add(points: moveFromSeriesToTimePoints(config.initialData))
        self.driver.delegate = self
    }

    convenience init(logger: LoggerGraphManager, config: GraphConfig, driver: GraphDriver) {
        self.init(config: config, driver: driver)
        logger.loggerGraph = self
    }

    convenience init(stream: StreamGraphManager, config: GraphConfig, driver: GraphDriver) {
        self.init(config: config, driver: driver)
        stream.streamGraph = self
    }

    @objc func refreshGraph() {
        guard !data.isEmpty else { return }
        let endIndex = data.endIndex - 1
        let startIndex = max(0, endIndex - Int(displayablePointCount))
        var displayables = Array(data[startIndex...endIndex])
        displayables.indices.forEach { displayables[$0].x = CGFloat($0) }
        displayedPoints = displayables
    }
}

extension NaiveGraphController: GraphObject {

    func addPointInAllSeries(_ point: [Float]) {
        driver.addRequests.send(point)
    }

    func updateYScale(min: Double, max: Double, data: [[Float]]) {
        rangeY = CGFloat(max - min)
        yMax = max
        yMin = min
        // No data update
    }

    func clearData() {
        displayedPoints = []
        data = []
        currentPointIndex = 0
    }

    private func moveFromSeriesToTimePoints(_ data: [[Float]]) -> [[Float]] {
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

}

extension NaiveGraphController: GraphDriverDelegate {
    func add(points: [[Float]]) {
        points.forEach { point in
            data.append(.init(x: currentPointIndex, heights: point.map(CGFloat.init)))
            currentPointIndex += 1
        }
        refreshGraph()
    }

}
