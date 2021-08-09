//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

public class MWAccelerometerSVC: MWDetailAccelerometerVM, ObservableObject, StreamGraphManager, LoggerGraphManager {

    internal weak var loggerGraph: GraphObject? = nil
    internal weak var streamGraph: GraphObject? = nil

    /// Refresh by manual call — as this is O(n)(m) over a long list
    @Published public private(set) var streamingStats: MWDataStreamStats = .zero
    /// Refresh by manual call — as this is O(n)(m) over a long list
    @Published public private(set) var loggerStats: MWDataStreamStats = .zero

    public var showStreamingStartupSpinner: Bool {
        isStreaming && data.stream.isEmpty
    }

    public override init() {
        super.init()
        self.delegate = self
    }

}

extension MWAccelerometerSVC: DetailAccelerometerVMDelegate {

    public func refreshView() {
        self.objectWillChange.send()
    }

    public func drawNewStreamGraphPoint(_ point: MWDataPoint) {
        streamGraph?.addPointInAllSeries([point.value.x, point.value.y, point.value.z])
    }

    public func redrawStreamGraph() {
        streamingStats = .zero
        streamGraph?.clearData()
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

    public func refreshGraphScale() {
        streamGraph?.updateYScale(
            min: -Double(graphScaleSelected.fullScale),
            max: Double(graphScaleSelected.fullScale),
            data: data.stream.asFloats()
        )

        loggerGraph?.updateYScale(
            min: -Double(graphScaleSelected.fullScale),
            max: Double(graphScaleSelected.fullScale),
            data: data.logged.asFloats()
        )
    }

}


public extension MWAccelerometerSVC {

    func graphScaleLabel(_ scale: AccelerometerGraphScale) -> String {
        "\(scale.fullScale)"
    }

    func setStreamGraphReference(_ graph: GraphObject) {
        self.streamGraph = graph
    }

    func setLoggerGraphReference(_ graph: GraphObject) {
        self.loggerGraph = graph
    }


    func makeStreamDataConfig() -> GraphConfig {
        .makeXYZLiveOverwriting(yAxisScale: Double(graphScaleSelected.fullScale), dataPoints: 300)
    }

    func makeLoggedDataConfig() -> GraphConfig {
        .makeHistoricalScrollable(forTimePoints: data.logged.asFloats(), yAxisScale: Double(graphScaleSelected.fullScale))
    }

}
