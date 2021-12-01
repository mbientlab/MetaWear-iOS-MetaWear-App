//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

public class MagnetometerSUIVC: MWMagnetometerVM, ObservableObject {

    internal weak var loggerGraph: GraphObject? = nil
    internal weak var streamGraph: GraphObject? = nil

    @Published public private(set) var streamingStats = StatsVM(.zero(for: .cartesianXYZ), 0)
    @Published public private(set) var loggerStats = StatsVM(.zero(for: .cartesianXYZ), 0)
    @Published var showStreamingStartupSpinner = false

    public override init() {
        super.init()
        self.delegate = self
    }

}

extension MagnetometerSUIVC: MagnetometerVMDelegate {

    public func refreshView() {
        objectWillChange.send()
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

    // Stats

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

}

extension MagnetometerSUIVC:  StreamGraphManager, LoggerGraphManager, LoggingSectionDriver, StreamingSectionDriver {

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

    public func setStreamGraphReference(_ graph: GraphObject) {
        self.streamGraph = graph
    }

    public func setLoggerGraphReference(_ graph: GraphObject) {
        self.loggerGraph = graph
    }

    public func makeStreamDataConfig() -> GraphConfig {
        .makeXYZLiveOverwriting(yAxisScale: Double(graphScaleFactor), timepoints: data.stream.map(\.values), dataPoints: 300)
    }

    public func makeLoggedDataConfig() -> GraphConfig {
        .makeHistoricalScrollable(forTimePoints: data.logged.map(\.values), yAxisScale: Double(graphScaleFactor))
    }

}
