//  © 2021 Ryan Ferrell. github.com/importRyan


import Foundation

protocol DetailAccelerometerVM: AnyObject, DetailConfiguring {

    var delegate: DetailAccelerometerVMDelegate? { get set }
    func start()

    // Intents
    func userRequestedStartStreaming()
    func userRequestedStopStreaming()
    func userRequestedStartLogging()
    func userRequestedStopLogging()
    func userRequestedRequestedToEmailData()
    func userRequestedStartOrienting()
    func userRequestedStopOrienting()
    func userRequestedStartStepping()
    func userRequestedStopStepping()
}

public protocol DetailAccelerometerVMDelegate: AnyObject {
    func refreshView()
}
