//  Created by Ryan on 8/5/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI
import UIKit
import Combine
import AAInfographics

// MARK: - AAInfographics Wrapper Controller

public class AAGraph: UIViewController, GraphObject {

    public init(config: GraphConfig) {
        self.config = config
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    private(set) var config: GraphConfig
    private var chart = AAChartView()

    private let collectionQueue = DispatchQueue(label: "Graph")
    private let addRequests = CurrentValueSubject<[Float],Never>([])
    private var additions: AnyCancellable? = nil
    private var didFinishLoading = false

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupChart()
        additions = makeAdditionsPipeline()
    }
}

public extension AAGraph {

     func addPointInAllSeries(_ point: [Float]) {
        addRequests.send(point)
    }

    func updateYScale(min: Double, max: Double, data: [[Float]]) {
        config.yAxisMin = min
        config.yAxisMax = max
        config.loadDataConvertingFromTimeSeries(data)
        let newOptions = config.makeAAOptions()
        chart.aa_refreshChartWholeContentWithChartOptions(newOptions)
    }

    func clearData() {
        chart.aa_drawChartWithChartOptions(config.makeAAOptions())
    }
}

extension AAGraph: AAChartViewDelegate {

    public func aaChartViewDidFinishLoad(_ aaChartView: AAChartView) {
        didFinishLoading = true
    }
}

// MARK: - Setup

extension AAGraph {

    /// Throttle or WKWebView will block updating
    private func makeAdditionsPipeline(interval: Double = 0.0333) -> AnyCancellable {
        addRequests
            .dropFirst()
            .collect(.byTime(collectionQueue, .init(floatLiteral: interval)), options: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] floats in
                self?.addPoints(points: floats)
            }
    }

    private func addPoints(points: [[Float]]) {
        guard didFinishLoading else { return }
        for point in points {
            for i in point.indices {
                chart.aa_addPointToChartSeriesElement(
                    elementIndex: i,
                    options: [point[i]],
                    redraw: false,
                    shift: true,
                    animation: false
                )
            }
        }

        self.chart.aa_redraw(animation: true)
    }
}

private extension AAGraph {

    func setupChart() {
        chart.scrollEnabled = true
        view.addSubview(chart)
        chart.frame = view.frame
        chart.scrollView.contentInsetAdjustmentBehavior = .never
        chart.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        view.isOpaque = false
        chart.isOpaque = false
        chart.backgroundColor = .clear
        chart.isClearBackgroundColor = true

        let options = config.makeAAOptions()
        chart.delegate = self
        chart.aa_drawChartWithChartOptions(options)
    }
}

// MARK: - SwiftUI Host

public struct AAGraphViewWrapper: View {

    public init(initialConfig: GraphConfig, height: CGFloat = .detailsGraphHeight, graph: @escaping (AAGraph) -> Void) {
        self.initialConfig = initialConfig
        self.graphCallback = graph
        self.height = height
    }

    private var initialConfig: GraphConfig
    private var graphCallback: (AAGraph) -> Void
    private var height: CGFloat

    public var body: some View {
        AAGraphViewRep(config: initialConfig, graphCallback: graphCallback)
            .frame(height: height)
    }
}

struct AAGraphViewRep: UIViewControllerRepresentable {

    var config: GraphConfig
    var graphCallback: (AAGraph) -> Void

    func makeUIViewController(context: Context) -> AAGraph {
        let vc = AAGraph(config: config)
        graphCallback(vc)
        return vc
    }

    func updateUIViewController(_ vc: AAGraph, context: Context) { }

}
