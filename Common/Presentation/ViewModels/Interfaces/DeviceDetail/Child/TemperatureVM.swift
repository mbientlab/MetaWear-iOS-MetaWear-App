//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation

public protocol TemperatureVM: AnyObject, DetailConfiguring {

    var delegate: TemperatureVMDelegate? { get set }

    var channels: [String] { get }
    var selectedChannelIndex: Int { get }
    var selectedChannelType: String { get }
    var temperature: String { get }

    var showPinDetail: Bool { get }
    var readPin: GPIOPin { get }
    var enablePin: GPIOPin { get }

    // User Intents
    func selectChannel(at index: Int)
    func setReadPin(_ newValue: GPIOPin)
    func setEnablePin(_ newValue: GPIOPin)
    func readTemperature()
}

public protocol TemperatureVMDelegate: AnyObject {
    func resetView()
    func refreshView()
}
