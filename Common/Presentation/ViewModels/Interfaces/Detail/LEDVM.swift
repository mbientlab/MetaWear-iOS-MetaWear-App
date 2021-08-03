//  © 2021 Ryan Ferrell. github.com/importRyan


import Foundation

public protocol DetailLEDVM: AnyObject, DetailConfiguring {

    var delegate: DetailLEDVMDelegate? { get set }

    func start()

    func turnOnGreen()
    func flashGreen()
    func turnOnRed()
    func flashRed()
    func turnOnBlue()
    func flashBlue()

    func turnOffLEDs()
}

public protocol DetailLEDVMDelegate: AnyObject {
    func refreshView()
}
