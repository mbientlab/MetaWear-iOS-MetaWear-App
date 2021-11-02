//  Created by Ryan Ferrell on 8/7/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI
import Combine

struct IdentifiableTimePoint: Identifiable {

    var x: CGFloat
    var heights: [CGFloat]
    /// Using x value
    var id: CGFloat { x }
}

extension IdentifiableTimePoint {

    static func enumerated(from timeseries: [[Float]]) -> [Self] {
        zip(timeseries.indices, timeseries).map { (index, value) in
            self.init(x: .init(index), heights: value.map(CGFloat.init))
        }
    }
}

class ScrollingStaticGraphController: ObservableObject {

    /// List of timepoints where x starts at zero.
    @Published var displayedPoints: [IdentifiableTimePoint] = []
    @Published var seriesColors: [Color]
    @Published var seriesNames: [String]
    @Published var rangeY: CGFloat = 2
    @Published var yMax: Double
    @Published var yMin: Double

    private var scrollOffset = CGFloat(0)
    let mouse = MouseVM()
    let focus: FocusedPointsVM

    /// Historical data store
    private var currentPointIndex: CGFloat = 0

    private let driver: GraphDriver
    private var colorUpdates: AnyCancellable? = nil
    private let updateQueue = DispatchQueue(label: Bundle.main.bundleIdentifier! + ".staticGraph", qos: .userInteractive, attributes: .concurrent)

    init(config: GraphConfig, colorProvider: ColorsetProvider, driver: GraphDriver = ThrottledGraphDriver(interval: 1.5)) {
        self.driver = driver
        self.rangeY = CGFloat(config.yAxisMax - config.yAxisMin)
        self.seriesColors = colorProvider.colorset.value.colors
        self.yMin = config.yAxisMin
        self.yMax = config.yAxisMax
        self.seriesNames = config.channelLabels
        self.focus = .init(series: config.channelLabels.count)
        self.add(points: config.initialData)
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
        objectWillChange.send()
    }

    func updateScrollOffset(_ value: CGFloat) {
        self.scrollOffset = value
    }

    func updateColors(for provider: ColorsetProvider) {
        colorUpdates = provider.colorset
            .receive(on: DispatchQueue.main)
            .sink { [weak self] colorset in
                self?.seriesColors = colorset.colors
                self?.refreshGraph()
        }
    }

    func mouseMoved(to point: CGPoint?, width: CGFloat, dotSize: CGFloat) {
        updateQueue.async {
            let pointCount = CGFloat(self.displayedPoints.endIndex)
            guard let point = point, pointCount > 0
            else { self.show(false); return }

            // Compute mouse
            let contentWidth = pointCount * dotSize
            let startPosition = (contentWidth / 2) - self.scrollOffset
            let mousePositionInPlot = point.x
            DispatchQueue.main.async {
                self.mouse.position = max(0, min(width, mousePositionInPlot))
            }

            let mouseIndexInData = Int( ((startPosition + mousePositionInPlot) / contentWidth) * pointCount )
            guard mouseIndexInData < self.displayedPoints.endIndex, mouseIndexInData >= 0
            else { self.show(false); return }


            let pointValues = self.displayedPoints[mouseIndexInData].heights.map { value -> String in
                let rounded = Float ( Int(value * 100) ) / 100
                return String(format: "%1.2f", rounded)
            }
            if self.focus.points != pointValues {
                DispatchQueue.main.async {
                    self.focus.points = pointValues
                }
            }
            self.show(true)
        }
    }

    func show(_ value: Bool) {
        DispatchQueue.main.async {
            if self.focus.show != value { self.focus.show = value }
            if self.mouse.show != value { self.mouse.show = value }
        }
    }
}

// Isolate diffs to improve performance
extension ScrollingStaticGraphController {

    class MouseVM: ObservableObject {
        @Published var position = CGFloat(0)
        @Published var show = false
    }

    class FocusedPointsVM: ObservableObject {
        init(series: Int) {
            self.points = Array(repeating: "", count: series)
        }
        @Published var show = false
        @Published var points: [String]
    }
}

extension ScrollingStaticGraphController: GraphObject {

    func pauseRendering() {
        // Not relevant
    }

    func restartRendering() {
        // Not relevant
    }

    func changeGraphFormat(_ config: GraphConfig) {
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
        self.displayedPoints = formattedData
        refreshGraph()
    }

    func clearData() {
        displayedPoints = []
        currentPointIndex = 0
    }

}

extension ScrollingStaticGraphController: GraphDriverDelegate {

    /// From series to time points
    func add(points: [[Float]]) {
        var displayables: [IdentifiableTimePoint] = []
        points.forEach { point in
            displayables.append(.init(x: currentPointIndex, heights: point.map(CGFloat.init)))
            currentPointIndex += 1
        }
        displayedPoints.append(contentsOf: displayables)
    }

}
