//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

public class AccelerometerSUIVC: MWAccelerometerVM, ObservableObject {

    internal weak var loggerGraph: GraphObject? = nil
    internal weak var streamGraph: GraphObject? = nil

    var streamingStats = StatsVM(.zero(for: .cartesianXYZ), 0)
    var loggerStats = StatsVM(.zero(for: .cartesianXYZ), 0)
    @Published var showStreamingStartupSpinner = false

    public override init() {
        super.init()
        self.delegate = self
    }

}

extension AccelerometerSUIVC: AccelerometerVMDelegate {

    public func drawNewLogGraph() {
        // Write scrolling graph interface
    }

    public func refreshView() {
        self.objectWillChange.send()
    }

    public func drawNewStreamGraphPoint(_ point: TimeIdentifiedCartesianFloat) {
        streamGraph?.addPointInAllSeries([point.value.x, point.value.y, point.value.z])
        if showStreamingStartupSpinner {
            showStreamingStartupSpinner = false
        }
    }

    public func redrawStreamGraph() {
        streamingStats = .init(.zero(for: data.streamKind), 0)
        streamGraph?.clearData()
    }

    public func refreshStreamStats() {
        let newPointCount = data.streamCount - streamingStats.count
        let latest = data.stream.suffix(newPointCount)
        let kind = data.streamKind
        streamingStats.addNewPoints(latest, kind: kind)
    }

    public func refreshLoggerStats() {
        let stats = data.getLoggedStats()
        DispatchQueue.main.async { [weak self] in
            self?.loggerStats.stats = stats
            self?.loggerStats.count = self?.data.loggedCount ?? 0
        }
    }

    public func refreshGraphScale() {
        streamGraph?.updateYScale(
            min: -Double(graphScaleSelected.fullScale),
            max: Double(graphScaleSelected.fullScale),
            data: data.stream.map(\.values)
        )

        loggerGraph?.updateYScale(
            min: -Double(graphScaleSelected.fullScale),
            max: Double(graphScaleSelected.fullScale),
            data: data.logged.map(\.values)
        )
    }

}

extension AccelerometerSUIVC: StreamGraphManager, LoggerGraphManager, LoggingSectionDriver, StreamingSectionDriver {

    public override func userRequestedStopStreaming() {
        super.userRequestedStopStreaming()
        streamGraph?.pauseRendering()
        showStreamingStartupSpinner = false
    }

    public override func userRequestedStartStreaming() {
        super.userRequestedStartStreaming()
        streamGraph?.restartRendering()
        showStreamingStartupSpinner = true
    }

    public func graphScaleLabel(_ scale: AccelerometerGraphScale) -> String {
        "\(scale.fullScale)"
    }

    public func setStreamGraphReference(_ graph: GraphObject) {
        self.streamGraph = graph
    }

    public func setLoggerGraphReference(_ graph: GraphObject) {
        self.loggerGraph = graph
    }

    public func makeStreamDataConfig() -> GraphConfig {
        .makeXYZLiveOverwriting(yAxisScale: Double(graphScaleSelected.fullScale),
                                timepoints: data.stream.map(\.values),
                                dataPoints: 300)
    }

    public func makeLoggedDataConfig() -> GraphConfig {
        .makeHistoricalScrollable(forTimePoints: data.logged.map(\.values),
                                  yAxisScale: Double(graphScaleSelected.fullScale))
    }

}
