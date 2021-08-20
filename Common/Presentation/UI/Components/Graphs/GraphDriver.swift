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
