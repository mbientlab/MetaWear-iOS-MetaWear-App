//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

public protocol DetailVMContainer: AnyObject {
    var header: DetailHeaderVM { get }
    var identifiers: DetailIdentifiersVM { get }
    var battery: DetailBatteryVM { get }
    var signal: DetailSignalStrengthVM { get }
    var firmware: DetailFirmwareVM { get }
    var led: DetailLEDVM { get }
    var mechanical: DetailMechanicalSwitchVM { get }
    var temperature: DetailTemperatureVM { get }
    var reset: DetailResetVM { get }
    var accelerometer: DetailAccelerometerVM { get }

    var configurables: [DetailConfiguring] { get }
}


