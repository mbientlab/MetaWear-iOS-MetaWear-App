//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation

public protocol AccelerometerVM: AnyObject, DetailConfiguring {

    var delegate: AccelerometerVMDelegate? { get set }

    var isLogging: Bool { get }
    var isStreaming: Bool { get }
    var allowsNewLogging: Bool { get }
    var allowsNewStreaming: Bool { get }

    var isDownloadingLog: Bool { get }
    var canDownloadLog: Bool { get }
    var logDataIsReadyForDisplay: Bool { get }
    var streamDataIsReadyForDisplay: Bool { get }

    var isStepping: Bool { get }
    var stepCount: Int { get }
    var stepCountString: String { get }

    var isOrienting: Bool { get }
    var orientation: String { get }

    var graphScales: [AccelerometerGraphScale] { get }
    var graphScaleSelected: AccelerometerGraphScale { get }
    var samplingFrequencies: [AccelerometerSampleFrequency] { get }
    var samplingFrequencySelected: AccelerometerSampleFrequency { get }

    // Intents
    func userRequestedStartStreaming()
    func userRequestedStopStreaming()
    func userRequestedStreamExport()

    func userRequestedStartLogging()
    func userRequestedStopLogging()
    func userRequestedDownloadLog()
    func userRequestedLogExport()

    func userRequestedStartOrienting()
    func userRequestedStopOrienting()

    func userRequestedStartStepping()
    func userRequestedStopStepping()

    func userDidSelectSamplingFrequency(_ frequency: AccelerometerSampleFrequency)
    func userDidSelectGraphScale(_ scale: AccelerometerGraphScale)
}

public protocol AccelerometerVMDelegate: AnyObject {

    func refreshView()

    func refreshGraphScale()
    func drawNewStreamGraphPoint(_ point: TimeIdentifiedCartesianFloat)
    func redrawStreamGraph()
    func drawNewLogGraph()

    /// Called off the main queue to allow for processing
    func refreshStreamStats()
    /// Called off the main queue to allow for processing
    func refreshLoggerStats()
}
