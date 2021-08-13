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


    public func drawNewStreamGraphPoint(_ point: TimeIdentifiedCartesianFloat) {
        streamGraph?.addPointInAllSeries([point.value.x, point.value.y, point.value.z])
    }

    public func redrawStreamGraph() {
        streamingStats = .zero(for: data.streamKind)
        streamGraph?.clearData()
    }

    public func refreshGraphScale() {
        #warning("Scale unclear. Test.")
        streamGraph?.updateYScale(
            min: -Double(1),
            max: Double(1),
            data: data.stream.map(\.values)
        )

        loggerGraph?.updateYScale(
            min: -Double(1),
            max: Double(1),
            data: data.logged.map(\.values)
        )
    }

    // Stats

    public func refreshLoggerStats() {
        let stats = data.getLoggedStats()
        DispatchQueue.main.async { [weak self] in
            self?.loggerStats = stats
        }
    }

    public func refreshStreamStats() {
        let stats = data.getStreamedStats()
        DispatchQueue.main.async { [weak self] in
            self?.streamingStats = stats
        }
    }

}

extension GyroSUIVC:  StreamGraphManager, LoggerGraphManager, LoggingSectionDriver, StreamingSectionDriver {


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
