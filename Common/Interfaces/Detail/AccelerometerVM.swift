//  © 2021 Ryan Ferrell. github.com/importRyan


import Foundation

public protocol DetailAccelerometerVM: AnyObject, DetailConfiguring {

    var isLogging: Bool { get }
    var isStreaming: Bool { get }
    var allowsNewLogging: Bool { get }
    var allowsNewStreaming: Bool { get }

    var isStepping: Bool { get }
    var stepCount: Int { get }
    var stepCountString: String { get }

    var isOrienting: Bool { get }
    var orientation: String { get }

    var graphScales: [AccelerometerGraphScale] { get }
    var graphScaleSelected: AccelerometerGraphScale { get }

    var samplingFrequencies: [AccelerometerSampleFrequency] { get }
    var samplingFrequencySelected: AccelerometerSampleFrequency { get }

    var delegate: DetailAccelerometerVMDelegate? { get set }
    func start()

    // Intents
    func userRequestedStartStreaming()
    func userRequestedStopStreaming()
    func userRequestedStartLogging()
    func userRequestedStopAndDownloadLog()
    func userRequestedDatExport()
    func userRequestedStartOrienting()
    func userRequestedStopOrienting()
    func userRequestedStartStepping()
    func userRequestedStopStepping()

    func userDidSelectSamplingFrequency(_ frequency: AccelerometerSampleFrequency)
    func userDidSelectGraphScale(_ scale: AccelerometerGraphScale)
}

public protocol DetailAccelerometerVMDelegate: AnyObject {
    func refreshView()
    func refreshGraphScale()
}
