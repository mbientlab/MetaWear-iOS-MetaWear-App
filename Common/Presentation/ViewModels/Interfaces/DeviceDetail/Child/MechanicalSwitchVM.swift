//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation

public protocol MechanicalSwitchVM: AnyObject, DetailConfiguring {

    var delegate: MechanicalSwitchVMDelegate? { get set }
    
    var isMonitoring: Bool { get }
    var switchState: String { get }

    // Intents
    func userStartedMonitoringSwitch()
    func userStoppedMonitoringSwitch()
}

public protocol MechanicalSwitchVMDelegate: AnyObject {
    func refreshView()
}
