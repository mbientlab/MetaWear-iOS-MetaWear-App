//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation

public protocol GPIOVM: AnyObject, DetailConfiguring {

    var delegate: GPIOVMDelegate? { get set }

    var digitalValue: String { get }
    var analogAbsoluteValue: String { get }
    var analogRatioValue: String { get }

    var isChangingPins: Bool { get }

    var pins: [GPIOPin] { get }
    var pinSelected: GPIOPin { get }
    var mode: GPIOMode { get }
    var modes: [GPIOMode] { get }

    var changeType: GPIOChangeType { get }
    var pullMode: GPIOPullMode { get }
    var pullModeOptions: [GPIOPullMode] { get }
    var changeTypeOptions: [GPIOChangeType] { get }

    var pinChangeCount: Int { get }
    var pinChangeCountString: String { get }

    // Intents
    func userDidSelectMode(_ mode: GPIOMode)

    func userDidSelectPin(_ pin: GPIOPin)
    func userDidPressPull(_ pull: GPIOPullMode)

    func userPressedSetPin()
    func userPressedClearPin()

    func userRequestedPinChangeStart()
    func userRequestedPinChangeStop()

    func userRequestedDigitalReadout()
    func userRequestedAnalogAbsoluteReadout()
    func userRequestedAnalogRatioReadout()
}

public protocol GPIOVMDelegate: AnyObject {
    func refreshView()
    func indicateCommandWasSentToBoard()
}
