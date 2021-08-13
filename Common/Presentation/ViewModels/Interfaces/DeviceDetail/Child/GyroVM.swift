//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation

public protocol GyroVM: AnyObject, DetailConfiguring {

    var delegate: GyroVMDelegate? { get set }

    var isLogging: Bool { get }
    var isStreaming :Bool { get }
    var allowsNewLogging: Bool { get }
    var allowsNewStreaming: Bool { get }
    var isDownloadingLog: Bool { get }
    var canDownloadLog: Bool { get }

    var graphRanges: [GyroscopeGraphRange] { get }
    var graphRangeSelected: GyroscopeGraphRange { get }
    var samplingFrequencies: [GyroscopeFrequency] { get }
    var samplingFrequencySelected: GyroscopeFrequency { get }

    // Intents
    func userRequestedStartStreaming()
    func userRequestedStopStreaming()
    func userRequestedStreamExport()

    func userRequestedStartLogging()
    func userRequestedStopLogging()
    func userRequestedDownloadLog()
    func userRequestedLogExport()

    func userDidSelectSamplingFrequency(_ frequency: GyroscopeFrequency)
    func userDidSelectGraphScale(_ scale: GyroscopeGraphRange)
}

public protocol GyroVMDelegate {

    func refreshView()

    func redrawStreamGraph()
    func refreshGraphScale()
    func drawNewStreamGraphPoint(_ point: TimeIdentifiedCartesianFloat)

    func refreshStreamStats()
    func refreshLoggerStats()
}
