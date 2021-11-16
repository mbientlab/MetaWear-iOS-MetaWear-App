//  Created by Ryan Ferrell.
//  Copyright © 2021 MbientLab. All rights reserved.

import Foundation

public class SensorFusionSUIVC: MWSensorFusionVM, ObservableObject {
    
    internal weak var loggerGraph: GraphObject? = nil
    internal weak var streamGraph: GraphObject? = nil
    
    /// Refresh by manual call — as this is O(n)(m) over a long list
    @Published public private(set) var streamingStats: StatsVM
    /// Refresh by manual call — as this is O(n)(m) over a long list
    @Published public private(set) var loggerStats: StatsVM
    
    public var showStreamingStartupSpinner: Bool {
        isStreaming && data.stream.isEmpty
    }
    
    public func refreshView() {
        self.objectWillChange.send()
    }
    
    public override init() {
        self.loggerStats = .init(.zero(for: .eulerAngle), 0)
        self.streamingStats = .init(.zero(for: .eulerAngle), 0)
        super.init()
        self.delegate = self
    }
}

extension SensorFusionSUIVC: SensorFusionVMDelegate {
    
    public func drawNewStreamGraphPoint(_ point: TimeIdentifiedDataPoint) {
        streamGraph?.addPointInAllSeries(point.values)
    }
    
    public func drawNewStreamGraph() {
        streamingStats = .init(.zero(for: data.streamKind), 0)
        streamGraph?.clearData()
        streamGraph?.changeGraphFormat(makeStreamDataConfig())
    }
    
    public func drawNewLogGraph() {
        loggerStats = .init(.zero(for: data.loggedKind), 0)
        loggerGraph?.clearData()
        loggerGraph?.changeGraphFormat(makeLoggedDataConfig())
    }
    
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

extension SensorFusionSUIVC:  StreamGraphManager, LoggerGraphManager, LoggingSectionDriver, StreamingSectionDriver {

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
        .init(
            chartType: .scatter,
            functionality: .liveViewOverwriting,
            channelLabels: selectedOutputType.channelLabels,
            yAxisMin: -Double(selectedOutputType.scale),
            yAxisMax: Double(selectedOutputType.scale),
            initialData: data.stream.map(\.values),
            maxX: selectedOutputType.channelCount * 100
        )
    }
    
    func makeLoggedDataConfig() -> GraphConfig {
        GraphConfig(
            chartType: .scatter,
            functionality: .historicalStaticScrolling,
            channelLabels: selectedOutputType.channelLabels,
            yAxisMin: -Double(selectedOutputType.scale),
            yAxisMax: Double(selectedOutputType.scale),
            initialData: data.logged.map(\.values),
            maxX: data.loggedCount
        )
    }
}

fileprivate extension SensorFusionOutputType {


}
