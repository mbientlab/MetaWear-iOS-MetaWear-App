//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

public class MagnetometerSUIVC: MWMagnetometerVM, ObservableObject {

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

extension MagnetometerSUIVC: MagnetometerVMDelegate {

    public func refreshView() {

    }

    public func refreshStreamStats() {

    }

    public func refreshLoggerStats() {

    }

    public func drawNewLoggerGraphPoint(_ point: TimeIdentifiedCartesianFloat) {

    }

    public func drawNewStreamGraphPoint(_ point: TimeIdentifiedCartesianFloat) {

    }

    public func redrawStreamGraph() {
        
    }

}

extension MagnetometerSUIVC:  StreamGraphManager, LoggerGraphManager, LoggingSectionDriver {

    public func setStreamGraphReference(_ graph: GraphObject) {
        self.streamGraph = graph
    }

    public func setLoggerGraphReference(_ graph: GraphObject) {
        self.loggerGraph = graph
    }

    public func makeStreamDataConfig() -> GraphConfig {
        .makeXYZLiveOverwriting(yAxisScale: Double(graphScaleFactor), dataPoints: 300)
    }

    public func makeLoggedDataConfig() -> GraphConfig {
        .makeHistoricalScrollable(forTimePoints: data.logged.map(\.values), yAxisScale: Double(graphScaleFactor))
    }

}
