//  © 2021 Ryan Ferrell. github.com/importRyan


import Foundation

public protocol DetailLEDVM: AnyObject, DetailConfiguring {

    var delegate: DetailLEDVM? { get set }

    func start()
}

public protocol DetailLEDVMDelegate: AnyObject {
    func refreshView()
}
