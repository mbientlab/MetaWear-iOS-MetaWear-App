//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation

public protocol SensorFusionVM: AnyObject, DetailConfiguring {

    var delegate: SensorFusionVMDelegate? { get set }

    var isLogging: Bool { get }
    var isStreaming: Bool { get }
    var allowsNewLogging: Bool { get }
    var allowsNewStreaming: Bool { get }

    var isDownloadingLog: Bool { get }
    var canDownloadLog: Bool { get }
    var logDataIsReadyForDisplay: Bool { get }
    var streamDataIsReadyForDisplay: Bool { get }

    var selectedFusionMode: SensorFusionMode { get }
    var fusionModes: [SensorFusionMode] { get }
    var selectedOutputType: SensorFusionOutputType { get }
    var outputTypes: [SensorFusionOutputType] { get }

    // Intents
    func userSetFusionMode(_ mode: SensorFusionMode)
    func userSetOutputType(_ type: SensorFusionOutputType)
    func userRequestedResetOrientation()

    func userRequestedStartStreaming()
    func userRequestedStopStreaming()
    func userRequestedStreamExport()

    func userRequestedStartLogging()
    func userRequestedStopLogging()
    func userRequestedDownloadLog()
    func userRequestedLogExport()
}

public protocol SensorFusionVMDelegate: AnyObject {

    func refreshView()

    func drawNewStreamGraphPoint(_ point: TimeIdentifiedDataPoint)

    /// Called when a new graph is started, with potentially different series count or scale
    func drawNewStreamGraph()

    /// Called when a new log is started, with potentially different series count or scale
    func drawNewLogGraph()

    /// Called off the main queue to allow for processing
    func refreshStreamStats()

    /// Called off the main queue to allow for processing
    func refreshLoggerStats()

}
