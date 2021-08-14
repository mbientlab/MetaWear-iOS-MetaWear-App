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
    
    public var yAxisMin: Double
    public var yAxisMax: Double
    
    /// Optional. If empty, the dataPointCount will be used to generate zero-ed blank data.
    /// If supplied, the dataPointCount will be ignored. Data should be BY SERIES (outer array) and not in time sequence tuples.
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
                case .scatter: return .line
            }
        }
#endif
    }
    
#if os(iOS)
    func makeAAOptions(colors: [String]) -> AAOptions {
        let model = AAChartModel()
            .chartType(chartType.aaType)
            .animationType(.easeOutQuad)
        
            .legendEnabled(false)
            .dataLabelsEnabled(false)
            .xAxisVisible(false)
            .markerSymbolStyle(.borderBlank)
            .markerRadius(dataPointCount > 100 ? 2 : 3)
        
            .yAxisMax(yAxisMax)
            .yAxisMin(yAxisMin)
        
            .backgroundColor(AAColor.clear)
            .colorsTheme(colors)

            .series(makeDataSeries())

        if functionality == .historicalStaticScrolling {
            let width = initialData.first?.countedByEndIndex() ?? dataPointCount
            model.scrollablePlotArea(
                .init()
                    .minWidth(width)
                    .scrollPositionX(Float(max(0, width - 1)))
            )
        }

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
            chartType: .scatter,
            functionality: .liveViewOverwriting,
            channelLabels: ["X", "Y", "Z"],
            yAxisMin: -yAxisScale,
            yAxisMax: yAxisScale,
            initialData: [],
            dataPointCount: 300
        )
    }
    
    static func makeHistoricalScrollable(forSeries data: [[Float]], yAxisScale: Double) -> GraphConfig {
        GraphConfig(
            chartType: .scatter,
            functionality: .historicalStaticScrolling,
            channelLabels: ["X", "Y", "Z"],
            yAxisMin: -yAxisScale,
            yAxisMax: yAxisScale,
            initialData: data,
            dataPointCount: 0
        )
    }
    
    static func makeHistoricalScrollable(forTimePoints data: [[Float]], yAxisScale: Double) -> GraphConfig {
        var config = GraphConfig(
            chartType: .scatter,
            functionality: .historicalStaticScrolling,
            channelLabels: ["X", "Y", "Z"],
            yAxisMin: -yAxisScale,
            yAxisMax: yAxisScale,
            initialData: [],
            dataPointCount: 0
        )
        
        config.loadDataConvertingFromTimeSeries(data)
        return config
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

    static func makeWXYZHistoricalScrollable(forSeries data: [[Float]], yAxisScale: Double) -> GraphConfig {
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

    static func makeWXYZHistoricalScrollable(forTimePoints data: [[Float]], yAxisScale: Double) -> GraphConfig {
        var config = GraphConfig(
            chartType: .scatter,
            functionality: .historicalStaticScrolling,
            channelLabels: ["W", "X", "Y", "Z"],
            yAxisMin: -yAxisScale,
            yAxisMax: yAxisScale,
            initialData: [],
            dataPointCount: 0
        )

        config.loadDataConvertingFromTimeSeries(data)
        return config
    }

}
