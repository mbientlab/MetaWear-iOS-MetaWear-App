//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

public class GyroSUIVC: MWGyroVM, ObservableObject {

    internal weak var loggerGraph: GraphObject? = nil
    internal weak var streamGraph: GraphObject? = nil

    /// Refresh by manual call — as this is O(n)(m) over a long list
    @Published public private(set) var streamingStats = StatsVM(.zero(for: .cartesianXYZ), 0)
    /// Refresh by manual call — as this is O(n)(m) over a long list
    @Published public private(set) var loggerStats = StatsVM(.zero(for: .cartesianXYZ), 0)

    public var showStreamingStartupSpinner: Bool {
        isStreaming && data.stream.isEmpty
    }

    public override init() {
        super.init()
        self.delegate = self
    }

}

extension GyroSUIVC: GyroVMDelegate {

    public func refreshView() {
        objectWillChange.send()
    }

    public func drawNewStreamGraphPoint(_ point: TimeIdentifiedCartesianFloat) {
        streamGraph?.addPointInAllSeries([point.value.x, point.value.y, point.value.z])
    }

    public func redrawStreamGraph() {
        streamingStats = .init(.zero(for: data.streamKind), 0)
        streamGraph?.clearData()
    }

    public func refreshGraphScale() {
        streamGraph?.updateYScale(
            min: -Double(graphRangeSelected.fullScale),
            max: Double(graphRangeSelected.fullScale),
            data: data.stream.map(\.values)
        )

        loggerGraph?.updateYScale(
            min: -Double(graphRangeSelected.fullScale),
            max: Double(graphRangeSelected.fullScale),
            data: data.logged.map(\.values)
        )
    }

    // Stats

    public func refreshStreamStats() {
        let stats = data.getStreamedStats()
        DispatchQueue.main.async { [weak self] in
            self?.streamingStats.stats = stats
            self?.streamingStats.count = self?.data.streamCount ?? 0
        }
    }

    public func refreshLoggerStats() {
        let stats = data.getLoggedStats()
        DispatchQueue.main.async { [weak self] in
            self?.loggerStats.stats = stats
            self?.loggerStats.count = self?.data.loggedCount ?? 0
        }
    }

}

extension GyroSUIVC:  StreamGraphManager, LoggerGraphManager, LoggingSectionDriver, StreamingSectionDriver {

    public override func userRequestedStopStreaming() {
        super.userRequestedStopStreaming()
        streamGraph?.pauseRendering()
    }

    public override func userRequestedStartStreaming() {
        super.userRequestedStartStreaming()
        streamGraph?.restartRendering()
    }

    public func setStreamGraphReference(_ graph: GraphObject) {
        self.streamGraph = graph
    }

    public func setLoggerGraphReference(_ graph: GraphObject) {
        self.loggerGraph = graph
    }
    
    func makeStreamDataConfig() -> GraphConfig {
        .makeXYZLiveOverwriting(yAxisScale: Double(graphRangeSelected.fullScale),
                                timepoints: data.stream.map(\.values),
                                dataPoints: 300)
    }

    func makeLoggedDataConfig() -> GraphConfig {
        .makeHistoricalScrollable(forTimePoints: data.logged.map(\.values),
                                  yAxisScale: Double(graphRangeSelected.fullScale))
    }

}
