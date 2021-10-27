
//  Created by Ryan Ferrell on 8/5/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

public struct GraphConfig {
    
    public var chartType: ChartType
    public var functionality: ChartFunction
    
    /// Names for series in graph. The number of names determines the number of channels (e.g., X, Y, Z). Data input should match this order.
    public var channelLabels: [String]
    
    public var yAxisMin: Double
    public var yAxisMax: Double
    
    /// Outer: Timepoint. Inner: Series values at timepoint.
    public var initialData: [[Float]] = []

    /// Used to generate zero-ed data for a "overwriting" graph. Ignored if initial data supplied.
    public var dataPointCount: Int = 300
}

public extension GraphConfig {
    
    enum ChartFunction {
        case liveViewOverwriting
        case historicalStaticScrolling
    }
    
    enum ChartType {
        case scatter
    }
}

public extension GraphConfig {
    
    static func makeXYZLiveOverwriting(yAxisScale: Double, timepoints: [[Float]], dataPoints: Double = 300) -> GraphConfig {
        GraphConfig(
            chartType: .scatter,
            functionality: .liveViewOverwriting,
            channelLabels: ["X", "Y", "Z"],
            yAxisMin: -yAxisScale,
            yAxisMax: yAxisScale,
            initialData: timepoints,
            dataPointCount: 300
        )
    }
    
    static func makeHistoricalScrollable(forTimePoints data: [[Float]], yAxisScale: Double) -> GraphConfig {
        GraphConfig(
            chartType: .scatter,
            functionality: .historicalStaticScrolling,
            channelLabels: ["X", "Y", "Z"],
            yAxisMin: -yAxisScale,
            yAxisMax: yAxisScale,
            initialData: [],
            dataPointCount: 0
        )
    }
}

public extension GraphConfig {

    static func makeWXYZLiveOverwriting(yAxisScale: Double, dataPoints: Double = 300) -> GraphConfig {
        GraphConfig(
            chartType: .scatter,
            functionality: .liveViewOverwriting,
            channelLabels: ["W", "X", "Y", "Z"],
            yAxisMin: -yAxisScale,
            yAxisMax: yAxisScale,
            initialData: [],
            dataPointCount: 300
        )
    }

    static func makeWXYZHistoricalScrollable(forTimePoints data: [[Float]], yAxisScale: Double) -> GraphConfig {
        GraphConfig(
            chartType: .scatter,
            functionality: .historicalStaticScrolling,
            channelLabels: ["W", "X", "Y", "Z"],
            yAxisMin: -yAxisScale,
            yAxisMax: yAxisScale,
            initialData: data,
            dataPointCount: 0
        )
    }

}
