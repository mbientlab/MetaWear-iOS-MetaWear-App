//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

public class GyroSUIVC: MWGyroVM, ObservableObject {

    internal weak var loggerGraph: GraphObject? = nil
    internal weak var streamGraph: GraphObject? = nil

    /// Refresh by manual call — as this is O(n)(m) over a long list
    @Published public private(set) var streamingStats: MWDataStreamStats = .zero(for: .cartesianXYZ)
    /// Refresh by manual call — as this is O(n)(m) over a long list
    @Published public private(set) var loggerStats: MWDataStreamStats = .zero(for: .cartesianXYZ)

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

    public func redrawStreamGraph() {

    }

    public func refreshGraphScale() {

    }

    public func drawNewStreamGraphPoint(_ point: TimeIdentifiedCartesianFloat) {

    }

    public func drawNewLoggerGraphPoint(_ point: TimeIdentifiedCartesianFloat) {

    }

    public func refreshStreamStats() {

    }

    public func refreshLoggerStats() {

    }

}

extension GyroSUIVC:  StreamGraphManager, LoggerGraphManager {

    public func setStreamGraphReference(_ graph: GraphObject) {
        self.streamGraph = graph
    }

    public func setLoggerGraphReference(_ graph: GraphObject) {
        self.loggerGraph = graph
    }
    
    func makeStreamDataConfig() -> GraphConfig {
        .makeXYZLiveOverwriting(yAxisScale: Double(graphScaleFactor), dataPoints: 300)
    }

    func makeLoggedDataConfig() -> GraphConfig {
        .makeHistoricalScrollable(forTimePoints: data.logged.map(\.values), yAxisScale: Double(graphScaleFactor))
    }

}
