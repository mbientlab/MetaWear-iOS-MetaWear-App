//  Created by Ryan Ferrell.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI
import Combine
import FeedPlot

struct FeedPlotFixedSize: View {

    @StateObject var controller: FeedPlotController

    let width: CGFloat
    let height: CGFloat = .detailsGraphHeight

    var body: some View {
        FeedPlotView(.drawAtMonitorFPS, from: controller.dataStore) { [weak controller] in
            controller?.plot = $0
        }
        .background(ScrollingStaticGraph.PlotBackgroundLinesAndLabels(min: controller.yMin, max: controller.yMax))
        .background(Color.plotBackground)
        .frame(width: width, height: height)
    }

}

class FeedPlotController: ObservableObject {

    /// List of timepoints where x starts at zero.
    @Published var seriesColors: [FPColor]
    @Published var seriesNames: [String]
    @Published var rangeY: CGFloat = 2
    @Published var yMax: Double
    @Published var yMin: Double

    weak var plot: FPPlot? = nil
    let dataStore: (FPDataProvider & FPDataStore)
    private var colorUpdates: AnyCancellable? = nil

    init(config: GraphConfig, colorProvider: ColorsetProvider) {
        let colors = colorProvider.colorset.value.colors.map { $0.asFeedPlotColor() }
        self.rangeY = CGFloat(config.yAxisMax - config.yAxisMin)
        self.seriesColors = colors

        #if os(iOS)
        let streamingPointSize: Float = UIDevice.current.userInterfaceIdiom == .pad ? 4 : 7
        #else
        let streamingPointSize: Float = 2
        #endif

        self.dataStore = FPStreaming2DDataStore(
            data: Self.makeInitialData(from: config, colors: colors),
            bounds: Self.makeBounds(from: config),
            dataPointsPerFrame: config.maxX,
            pointSize: streamingPointSize
        )
        self.yMin = config.yAxisMin
        self.yMax = config.yAxisMax
        self.seriesNames = config.channelLabels
        updateColors(for: colorProvider)
    }

    convenience init(logger: LoggerGraphManager,
                     config: GraphConfig,
                     colorProvider: ColorsetProvider) {
        self.init(config: config, colorProvider: colorProvider)
        logger.loggerGraph = self
    }

    convenience init(stream: StreamGraphManager,
                     config: GraphConfig,
                     colorProvider: ColorsetProvider) {
        self.init(config: config, colorProvider: colorProvider)
        stream.streamGraph = self
    }

    func updateColors(for provider: ColorsetProvider) {
        colorUpdates = provider.colorset
            .receive(on: DispatchQueue.main)
            .map { $0.colors.map { $0.asFeedPlotColor() } }
            .sink { [weak self] colors in
                self?.seriesColors = colors
                self?.plot?.updatePlot()
        }
    }
}


extension FeedPlotController: GraphObject {

    func pauseRendering() {
        plot?.updateDrawMode(.drawWhenNotified)
    }

    func restartRendering() {
        plot?.updateDrawMode(.drawAtMonitorFPS)
    }

    func addPointInAllSeries(_ point: [Float]) {
        let latest = Float((dataStore.data.last?.point.x ?? 0) + 1)
        let points = zip(point.indices, point).map { (index, p) in
            FPColoredDataPoint(point: .init(x: latest, y: p, z: 0), color: seriesColors[index])
        }
        dataStore.addData(points: points)
    }

    func changeGraphFormat(_ config: GraphConfig) {
        updateYScale(min: config.yAxisMin, max: config.yAxisMax, data: config.initialData)
    }

    func updateYScale(min: Double, max: Double, data: [[Float]]) {
        rangeY = CGFloat(max - min)
        yMax = max
        yMin = min
        var bounds = dataStore.bounds
        bounds.yAxis = Float(min)...Float(max)
        dataStore.setBounds(bounds)
        plot?.updatePlot()
    }

    func clearData() {
        dataStore.clearData()
    }

    static func blankData(color: FPColor, count: Int) -> [FPColoredDataPoint] {
        Array(repeating: .init(point: .zero, color: color), count: count)
    }

    static func makeInitialData(from config: GraphConfig, colors: [FPColor]) -> [FPColoredDataPoint] {

        guard !config.initialData.isEmpty else {
            return Self.blankData(color: colors[0], count: config.maxX)
        }

        var x = Float(0)
        var points = [FPColoredDataPoint]()

        if config.initialData.endIndex < config.maxX {
            let gap = config.maxX - points.endIndex
            for _ in 0..<gap {
                points.append(.init(point: .init(x, 0, 0), color: colors[0]))
                x += 1
            }
        }

        for xIndex in config.initialData.indices {
            let timepoint = config.initialData[xIndex]
            let datapoints = zip(timepoint.indices, timepoint).map { (index, value) in
                FPColoredDataPoint(point: .init(x: x, y: value, z: 0),
                                   color: colors[index])
            }
            points.append(contentsOf: datapoints)
            x += 1
        }

        return points
    }

    static func makeBounds(from config: GraphConfig) -> FPBounds {
        let xMax = Float(config.maxX / config.channelLabels.endIndex)
        return .init(xAxis: (0...xMax), yAxis: (Float(config.yAxisMin)...Float(config.yAxisMax)))
    }

}
