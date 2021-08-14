//  Created by Ryan Ferrell on 8/7/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI
import Combine

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
    private var colorUpdates: AnyCancellable? = nil

    init(config: GraphConfig, colorProvider: ColorsetProvider, driver: GraphDriver) {
        self.driver = driver
        self.rangeY = CGFloat(config.yAxisMax - config.yAxisMin)
        self.seriesColors = colorProvider.colorset.value.colors
        self.yMin = config.yAxisMin
        self.yMax = config.yAxisMax
        self.seriesNames = config.channelLabels
        self.add(points: Self.moveFromSeriesToTimePoints(config.initialData))
        self.driver.delegate = self
        updateColors(for: colorProvider)
    }

    convenience init(logger: LoggerGraphManager,
                     config: GraphConfig,
                     driver: GraphDriver,
                     colorProvider: ColorsetProvider) {
        self.init(config: config, colorProvider: colorProvider, driver: driver)
        logger.loggerGraph = self
    }

    convenience init(stream: StreamGraphManager,
                     config: GraphConfig,
                     driver: GraphDriver,
                     colorProvider: ColorsetProvider) {
        self.init(config: config, colorProvider: colorProvider, driver: driver)
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

    func updateColors(for provider: ColorsetProvider) {
        colorUpdates = provider.colorset
            .receive(on: DispatchQueue.main)
            .sink { [weak self] colorset in
                self?.seriesColors = colorset.colors
                self?.refreshGraph()
        }
    }
}

extension NaiveGraphController: GraphObject {

    func changeGraphFormat(_ config: GraphConfig) {
        self.displayablePointCount = CGFloat(config.dataPointCount)
        updateYScale(min: config.yAxisMin, max: config.yAxisMax, data: config.initialData)
    }

    func addPointInAllSeries(_ point: [Float]) {
        driver.addRequests.send(point)
    }

    func updateYScale(min: Double, max: Double, data: [[Float]]) {
        rangeY = CGFloat(max - min)
        yMax = max
        yMin = min
        let formattedData = IdentifiableTimePoint.enumerated(from: data)
        clearData()
        self.data = formattedData
        refreshGraph()
    }

    func clearData() {
        displayedPoints = []
        data = []
        currentPointIndex = 0
    }

}

extension NaiveGraphController: GraphDriverDelegate {

    /// From series to time points
    func add(points: [[Float]]) {
        points.forEach { point in
            data.append(.init(x: currentPointIndex, heights: point.map(CGFloat.init)))
            currentPointIndex += 1
        }
        refreshGraph()
    }

}

extension IdentifiableTimePoint {

    static func enumerated(from timeseries: [[Float]]) -> [Self] {
        zip(timeseries.indices, timeseries).map { (index, value) in
            self.init(x: .init(index), heights: value.map(CGFloat.init))
        }
    }
}
