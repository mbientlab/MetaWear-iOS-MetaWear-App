//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation

public protocol IBeaconVM: AnyObject, DetailConfiguring {

    var delegate: IBeaconVMDelegate? { get set }

    var iBeaconIsOn: Bool { get }

    func userRequestedStartIBeacon()
    func userRequestedStopIBeacon()
}

public protocol IBeaconVMDelegate {
    func refreshView()
}
