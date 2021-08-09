//  Created by Ryan Ferrell on 8/8/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI
import Combine

public protocol GraphDriver: AnyObject {
    var delegate: GraphDriverDelegate? { get set }
    var addRequests: CurrentValueSubject<[Float],Never> { get }
    func stop()
    func restart()
    init(interval: Double)
}

public protocol GraphDriverDelegate: AnyObject {
    func add(points: [[Float]])
}

public class ThrottledGraphDriver: GraphDriver {

    public required init(interval: Double = 0.0333) {
        self.updateInterval = interval
        makePipeline()
    }

    public weak var delegate: GraphDriverDelegate? = nil
    public let addRequests = CurrentValueSubject<[Float],Never>([])
    public var updateInterval: Double

    private let queue = DispatchQueue(label: "Graph", qos: .userInteractive)
    private var additions: AnyCancellable? = nil

    private func makePipeline() {
        additions = addRequests
            .dropFirst()
            .collect(.byTime(queue, .init(floatLiteral: updateInterval)), options: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] floats in
                self?.delegate?.add(points: floats)
            }
    }

    public func stop() {
        additions = nil
    }

    public func restart() {
        makePipeline()
    }
}
//
//class DisplayLinkGraphDriver {
//
//    var callback: (([[Float]]) -> Void)?
//    let addRequests = CurrentValueSubject<[Float],Never>([])
//
//#if os(iOS)
//    private var link: CADisplayLink? = nil
//#elseif os(macOS)
//    private var link: CVDisplayLink? = nil
//    private var frameCounter = 0
//#endif
//
//
//    func setupLink() {
//        #if os(iOS)
//
//        let link = CADisplayLink(target: self, selector: #selector(refreshGraph))
//        link.preferredFramesPerSecond = 30
//        link.add(to: .main, forMode: .common)
//        self.link = link
//
//        #elseif os(macOS)
//
//        DispatchQueue.global().async { [weak self] in
//            guard let self = self else { return }
//            CVDisplayLinkCreateWithActiveCGDisplays(&self.link)
//            guard let displayLink = self.link else { return }
//
//            let callback: CVDisplayLinkOutputCallback = { (_, _, _, _, _, userInfo) -> CVReturn in
//                let _self = Unmanaged<NaiveGraphController>.fromOpaque(UnsafeRawPointer(userInfo!)).takeUnretainedValue()
//                DispatchQueue.main.async {
//                    _self.displayLinkCallback()
//                }
//                return kCVReturnSuccess
//            }
//
//            let userInfo = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
//            CVDisplayLinkSetOutputCallback(displayLink, callback, userInfo)
//            CVDisplayLinkStart(displayLink)
//        }
//
//        #endif
//    }
//
//    /// Grab frame every X display refresh calls
//    @objc func throttledRefreshGraph() {
//        guard frameCounter > 5 else {
//            frameCounter += 1
//            return
//        }
//        refreshGraph()
//        frameCounter = 0
//    }
//
//    @objc func immediatelyRefreshGraph() {
//        callback?()
//    }
//}
