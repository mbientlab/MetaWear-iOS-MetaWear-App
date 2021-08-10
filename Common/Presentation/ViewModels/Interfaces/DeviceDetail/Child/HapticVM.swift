//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation

public protocol HapticVM: AnyObject, DetailConfiguring {

    var delegate: HapticVMDelegate? { get set }

    var canSendCommand: Bool { get }

    var hapticPulseWidth: Double{ get }
    var dutyCycle: Int { get }
    var hapticPulseWidthString: String { get }
    var hapticDutyCycleString: String { get }

    func userRequestedStartHapticDriver()
    func userRequestedStartBuzzerDriver()

    func userSetPulseWidth(ms: Double)
    func userSetDutyCycle(cycle: Int)
}

public protocol HapticVMDelegate {
    func refreshView()
}
