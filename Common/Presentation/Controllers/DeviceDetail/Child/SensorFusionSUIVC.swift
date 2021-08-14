//  © 2021 Ryan Ferrell. github.com/importRyan


import Foundation

public class SensorFusionSUIVC: MWSensorFusionVM, ObservableObject {
    
    internal weak var loggerGraph: GraphObject? = nil
    internal weak var streamGraph: GraphObject? = nil
    
    /// Refresh by manual call — as this is O(n)(m) over a long list
    @Published public private(set) var streamingStats: MWDataStreamStats
    /// Refresh by manual call — as this is O(n)(m) over a long list
    @Published public private(set) var loggerStats: MWDataStreamStats
    
    public var showStreamingStartupSpinner: Bool {
        isStreaming && data.stream.isEmpty
    }
    
    public func refreshView() {
        self.objectWillChange.send()
    }
    
    public override init() {
        self.loggerStats = .zero(for: .eulerAngle)
        self.streamingStats = .zero(for: .eulerAngle)
        super.init()
        self.delegate = self
    }
}

extension SensorFusionSUIVC: SensorFusionVMDelegate {
    
    public func drawNewStreamGraphPoint(_ point: TimeIdentifiedDataPoint) {
        streamGraph?.addPointInAllSeries(point.values)
    }
    
    public func drawNewStreamGraph() {
        streamingStats = .zero(for: data.streamKind)
        streamGraph?.clearData()
        streamGraph?.changeGraphFormat(makeStreamDataConfig())
    }
    
    public func drawNewLogGraph() {
        loggerStats = .zero(for: data.loggedKind)
        loggerGraph?.clearData()
        loggerGraph?.changeGraphFormat(makeLoggedDataConfig())
    }
    
    public func refreshStreamStats() {
        let stats = data.getStreamedStats()
        DispatchQueue.main.async { [weak self] in
            self?.streamingStats = stats
        }
    }
    
    public func refreshLoggerStats() {
        let stats = data.getLoggedStats()
        DispatchQueue.main.async { [weak self] in
            self?.loggerStats = stats
        }
    }
    
    
}

extension SensorFusionSUIVC:  StreamGraphManager, LoggerGraphManager, LoggingSectionDriver, StreamingSectionDriver {
    
    public func setStreamGraphReference(_ graph: GraphObject) {
        self.streamGraph = graph
    }
    
    public func setLoggerGraphReference(_ graph: GraphObject) {
        self.loggerGraph = graph
    }

    func makeStreamDataConfig() -> GraphConfig {
        .init(
            chartType: .line,
            functionality: .liveViewOverwriting,
            channelLabels: selectedOutputType.channelLabels,
            yAxisMin: -Double(selectedOutputType.scale),
            yAxisMax: Double(selectedOutputType.scale),
            initialData: [],
            dataPointCount: 300
        )
    }
    
    func makeLoggedDataConfig() -> GraphConfig {
        var config = GraphConfig(
            chartType: .line,
            functionality: .historicalStaticScrolling,
            channelLabels: selectedOutputType.channelLabels,
            yAxisMin: -Double(selectedOutputType.scale),
            yAxisMax: Double(selectedOutputType.scale),
            initialData: [],
            dataPointCount: 300
        )

        config.loadDataConvertingFromTimeSeries(data.logged.map(\.values))

        return config
    }
    
}

fileprivate extension SensorFusionOutputType {


}
