//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation

public protocol HeaderVM: AnyObject, DetailConfiguring {

    var delegate: HeaderVMDelegate? { get set }

    // State
    var deviceName: String { get }
    var connectionState: String { get }
    var connectionIsOn: Bool { get }
    var deviceNameRequirementsMessage: String { get }

    /// Signals model did update
    func refreshName()
    /// Signals model did update
    func refreshConnectionState()

    // User Intents
    func userSetConnection(to newState: Bool)
    func userRenamedDevice(to newValue: String)
    func didUserTypeValidDeviceName(_ newString: String, range: NSRange, fullString: String) -> Bool
}

public protocol HeaderVMDelegate: AnyObject {
    func refreshView()
}
