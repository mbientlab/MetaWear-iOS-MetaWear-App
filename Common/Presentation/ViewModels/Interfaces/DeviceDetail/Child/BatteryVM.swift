//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation

public protocol BatteryVM: AnyObject, DetailConfiguring {

    var delegate: BatteryVMDelegate? { get set }

    var batteryLevel: String { get }
    var batteryLevelPercentage: Int { get }

    // Intents
    func userRequestedBatteryLevel()
}

public protocol BatteryVMDelegate: AnyObject {
    func refreshView()
}
