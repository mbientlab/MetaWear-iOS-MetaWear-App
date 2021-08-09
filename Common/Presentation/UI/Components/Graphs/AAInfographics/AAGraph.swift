//  Created by Ryan Ferrell on 8/5/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

#if os(iOS)
import SwiftUI
import Combine
import UIKit
import AAInfographics

// MARK: - AAInfographics Wrapper Controller

public class AAGraph: UIViewController, GraphObject {

    public init(config: GraphConfig, driver: GraphDriver = ThrottledGraphDriver(interval: 0.017)) {
        self.config = config
        self.driver = driver
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    private(set) var config: GraphConfig
    private var chart = AAChartView()
    private let driver: GraphDriver

    private var didFinishLoading = false

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupChart()
    }
}

public extension AAGraph {

     func addPointInAllSeries(_ point: [Float]) {
         driver.addRequests.send(point)
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

extension AAGraph: GraphDriverDelegate {

    public func add(points: [[Float]]) {
        // Injecting points into the WKWebView store before
        // it has finished loading will cause errors
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
        driver.delegate = self
    }
}

// MARK: - SwiftUI Host

public struct AAGraphViewWrapper: View {

    public init(initialConfig: GraphConfig, height: CGFloat = .detailsGraphHeight, graph: @escaping (AAGraph) -> Void) {
        self.initialConfig = initialConfig
        self.graphReferenceCallback = graph
        self.height = height
    }

    private var initialConfig: GraphConfig
    private var graphReferenceCallback: (AAGraph) -> Void
    private var height: CGFloat

    public var body: some View {
        AAGraphViewRep(config: initialConfig, graphReferenceCallback: graphReferenceCallback)
            .frame(height: height)
    }
}

struct AAGraphViewRep: UIViewControllerRepresentable {

    var config: GraphConfig
    var graphReferenceCallback: (AAGraph) -> Void

    func makeUIViewController(context: Context) -> AAGraph {
        let vc = AAGraph(config: config)
        graphReferenceCallback(vc)
        return vc
    }

    func updateUIViewController(_ vc: AAGraph, context: Context) { }

}
#endif
