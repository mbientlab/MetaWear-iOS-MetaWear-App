//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation

public protocol SignalVM: AnyObject, DetailConfiguring {

    var delegate: SignalVMDelegate? { get set }

    var rssiLevel: String { get }
    var transmissionPowerLevels: [Int] { get }
    var chosenPowerLevelIndex: Int { get }

    // Intents
    func userRequestsRSSI()
    func userChangedTransmissionPower(toIndex: Int)
}

public protocol SignalVMDelegate: AnyObject {
    func refreshView()
}
