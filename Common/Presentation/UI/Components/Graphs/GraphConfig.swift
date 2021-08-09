//
//  AAGraphConfig.swift
//  AAGraphConfig
//
//  Created by Ryan Ferrell on 8/5/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI
#if os(iOS)
import AAInfographics
#endif

public struct GraphConfig {
    
    public var chartType: ChartType
    public var functionality: ChartFunction
    
    /// Names for series in graph. The number of names determines the number of channels (e.g., X, Y, Z). Data input should match this order.
    public var channelLabels: [String]
    /// Hex for series in graph. ["#fe117c","#ffc069","#06caf4"]
    public var channelColors: [String]
    /// SwiftUI colors for graphs not using JS
    public var channelColorsSwift: [Color] = [Color(.systemBlue), Color(.systemPink), Color(.systemPurple)]
    
    public var yAxisMin: Double
    public var yAxisMax: Double
    
    /// Optional. If empty, the dataPointCount will be used to generate zero-ed blank data.
    /// If supplied, the dataPointCount will be ignored. Data should be BY SERIES and not in time sequence tuples.
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
        case line
        case scatter
        
#if os(iOS)
        public var aaType: AAChartType {
            switch self {
                case .line: return .line
                case .scatter: return .scatter
            }
        }
#endif
    }
    
#if os(iOS)
    func makeAAOptions() -> AAOptions {
        let model = AAChartModel()
            .chartType(chartType.aaType)
            .animationType(.easeOutQuad)
        
            .legendEnabled(false)
            .dataLabelsEnabled(false)
            .xAxisVisible(false)
            .markerSymbolStyle(.borderBlank)
        
            .yAxisMax(yAxisMax)
            .yAxisMin(yAxisMin)
        
            .backgroundColor(AAColor.clear)
            .colorsTheme(channelColors)
        
            .series(makeDataSeries())
        
        let options = model.aa_toAAOptions()
        return options
        
    }
    
    private func makeDataSeries() -> [AASeriesElement] {
        if initialData.isEmpty { return makeBlankSeries() }
        return zip(channelLabels, initialData).map { label, data in
            AASeriesElement().name(label).data(data)
        }
    }
    
    private func makeBlankSeries() -> [AASeriesElement] {
        let data = makeBaseDataArray()
        
        return channelLabels.map { label in
            AASeriesElement()
                .name(label)
                .data(data)
        }
    }
    
    private func customizeToopTip(for options: AAOptions) {
        options.tooltip?.useHTML(true)
            .formatter("""
        function () {
                return 'Horizontal <b>'
                +  this.x
                + ' </b><br/>'
                + 'Vertical <b>'
                +  this.y
                + ' </b> ';
                }
        """)
    }
#endif
    
    mutating func loadDataConvertingFromTimeSeries(_ data: [[Float]]) {
        guard let first = data.first else { return }
        let seriesCount = first.count
        var ordered = Array(repeating: [Float](), count: seriesCount)
        
        for timepoint in data {
            for series in timepoint.indices {
                ordered[series].append(timepoint[series])
            }
        }
        
        self.initialData = ordered
    }
    
    private func makeBaseDataArray() -> Array<Float> {
        Array(repeating: Float(0), count: dataPointCount)
    }
}

public extension GraphConfig {
    
    static func makeXYZLiveOverwriting(yAxisScale: Double, dataPoints: Double = 300) -> GraphConfig {
        GraphConfig(
            chartType: .line,
            functionality: .liveViewOverwriting,
            channelLabels: ["X", "Y", "Z"],
            channelColors: ["#FD127C", "#04CBF4", "#FBBE69"],
            yAxisMin: -yAxisScale,
            yAxisMax: yAxisScale,
            initialData: [],
            dataPointCount: 300
        )
    }
    
    static func makeHistoricalScrollable(forSeries data: [[Float]], yAxisScale: Double) -> GraphConfig {
        GraphConfig(
            chartType: .line,
            functionality: .historicalStaticScrolling,
            channelLabels: ["X", "Y", "Z"],
            channelColors: ["#FD127C", "#04CBF4", "#FBBE69"],
            yAxisMin: -yAxisScale,
            yAxisMax: yAxisScale,
            initialData: data,
            dataPointCount: 0
        )
    }
    
    static func makeHistoricalScrollable(forTimePoints data: [[Float]], yAxisScale: Double) -> GraphConfig {
        var config = GraphConfig(
            chartType: .line,
            functionality: .historicalStaticScrolling,
            channelLabels: ["X", "Y", "Z"],
            channelColors: ["#FD127C", "#04CBF4", "#FBBE69"],
            yAxisMin: -yAxisScale,
            yAxisMax: yAxisScale,
            initialData: [],
            dataPointCount: 0
        )
        
        config.loadDataConvertingFromTimeSeries(data)
        
        return config
    }
}
