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
        
    }
    
    public func drawNewStreamGraph() {
        
    }
    
    public func drawNewLogGraph() {
        // check kind
    }
    
    public func refreshStreamStats() {
        // check kind
    }
    
    public func refreshLoggerStats() {
        
    }
    
    
}

extension SensorFusionSUIVC:  StreamGraphManager, LoggerGraphManager {
    
    public func setStreamGraphReference(_ graph: GraphObject) {
        self.streamGraph = graph
    }
    
    public func setLoggerGraphReference(_ graph: GraphObject) {
        self.loggerGraph = graph
    }
    
#warning("SCALE FOR SENSOR FUSION")
    func makeStreamDataConfig() -> GraphConfig {
        .makeXYZLiveOverwriting(yAxisScale: Double(1), dataPoints: 300)
    }
    
    func makeLoggedDataConfig() -> GraphConfig {
        .makeHistoricalScrollable(forTimePoints: data.logged.map(\.values), yAxisScale: Double(1))
    }
    
}
