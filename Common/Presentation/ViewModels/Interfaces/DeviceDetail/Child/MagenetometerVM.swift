//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation

public protocol MagenetometerVM: AnyObject, DetailConfiguring {

    var delegate: MagnetometerVMDelegate? { get set }

    var isLogging: Bool { get }
    var isStreaming :Bool { get }
    var allowsNewLogging: Bool { get }
    var allowsNewStreaming: Bool { get }
    var isDownloadingLog: Bool { get }
    var canDownloadLog: Bool { get }

    // Intents
    func userRequestedStartStreaming()
    func userRequestedStopStreaming()
    func userRequestedStreamExport()

    func userRequestedStartLogging()
    func userRequestedStopLogging()
    func userRequestedDownloadLog()
    func userRequestedLogExport()
}

public protocol MagnetometerVMDelegate: AnyObject {

    func refreshView()

    func drawNewStreamGraphPoint(_ point: TimeIdentifiedCartesianFloat)
    func redrawStreamGraph()

    func refreshStreamStats()
    func refreshLoggerStats()
}
