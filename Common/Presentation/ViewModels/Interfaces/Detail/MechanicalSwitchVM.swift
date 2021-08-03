//  Created by Ryan Ferrell on 7/30/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//


import Foundation

public protocol DetailMechanicalSwitchVM: AnyObject, DetailConfiguring {

    var delegate: DetailMechanicalSwitchVMDelegate? { get set }
    var isMonitoring: Bool { get }
    var switchState: String { get }

    func start()

    // Intents
    func userStartedMonitoringSwitch()
    func userStoppedMonitoringSwitch()
}

public protocol DetailMechanicalSwitchVMDelegate: AnyObject {
    func refreshView()
}
