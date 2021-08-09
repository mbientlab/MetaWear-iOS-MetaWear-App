//  Created by Ryan Ferrell on 8/7/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

class NaiveGraphController_DisplayLink: ObservableObject {

    /// List of timepoints where x starts at zero.
    @Published var displayedPoints: [IdentifiableTimePoint] = []
    @Published var seriesColors: [Color]
    @Published var rangeY: CGFloat = 2
    @Published var displayablePointCount: CGFloat = 100

    /// Historical data store
    private var data: [IdentifiableTimePoint] = []
    private var currentPointIndex: CGFloat = 0

#if os(iOS)
    private var link: CADisplayLink? = nil
#elseif os(macOS)
    private var link: CVDisplayLink? = nil
    private var frameCounter = 0
#endif

    init(config: GraphConfig) {
        self.rangeY = config.yAxisMax - config.yAxisMin
        self.seriesColors = config.channelColorsSwift
        #warning("TODO: Write loop to pull out of serial array and into time point series")
        setupLink()
    }

    convenience init(logger: LoggerGraphManager, config: GraphConfig) {
        self.init(config: config)
        logger.loggerGraph = self
    }

    convenience init(stream: StreamGraphManager, config: GraphConfig) {
        self.init(config: config)
        stream.streamGraph = self
    }

    @objc func refreshGraph() {
        guard !data.isEmpty else { return }
        let endIndex = data.endIndex - 1
        let startIndex = max(0, endIndex - Int(displayablePointCount))
        var displayables = Array(data[startIndex...endIndex])
        displayables.indices.forEach { displayables[$0].x = CGFloat($0) }
        displayedPoints = displayables
    }
}

extension NaiveGraphController_DisplayLink: GraphObject {


    func addPointInAllSeries(_ point: [Float]) {
        data.append(.init(x: currentPointIndex, heights: point.map(CGFloat.init)))
        currentPointIndex += 1
    }

    func updateYScale(min: Double, max: Double, data: [[Float]]) {
        rangeY = max - min
        // No data update
    }

    func clearData() {
        displayedPoints = []
        data = []
        currentPointIndex = 0
    }

}

private extension NaiveGraphController_DisplayLink {

    func setupLink() {
        #if os(iOS)

        let link = CADisplayLink(target: self, selector: #selector(refreshGraph))
        link.preferredFramesPerSecond = 30
        link.add(to: .main, forMode: .common)
        self.link = link

        #elseif os(macOS)



        #endif
    }

    #if os(macOS)

    private func setupDisplayLink() {

        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            CVDisplayLinkCreateWithActiveCGDisplays(&self.link)
            guard let displayLink = self.link else { return }

            let callback: CVDisplayLinkOutputCallback = { (_, _, _, _, _, userInfo) -> CVReturn in
                let _self = Unmanaged<NaiveGraphController_DisplayLink>.fromOpaque(UnsafeRawPointer(userInfo!)).takeUnretainedValue()
                DispatchQueue.main.async {
                    _self.displayLinkCallback()
                }
                return kCVReturnSuccess
            }

            let userInfo = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
            CVDisplayLinkSetOutputCallback(displayLink, callback, userInfo)
            CVDisplayLinkStart(displayLink)
        }
    }

    /// Grab frame every X display refresh calls
    private func displayLinkCallback() {
        guard frameCounter > 5 else {
            frameCounter += 1
            return
        }
        refreshGraph()
        frameCounter = 0
    }
    #endif

}
