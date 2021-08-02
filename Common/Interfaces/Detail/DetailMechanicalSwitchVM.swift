//  © 2021 Ryan Ferrell. github.com/importRyan


import Foundation

public protocol DetailMechanicalSwitchVM: AnyObject, DetailConfiguring {

    var delegate: DetailMechanicalSwitchVMDelegate? { get set }

    func start()
}

public protocol DetailMechanicalSwitchVMDelegate: AnyObject {
    func refreshView()
}
