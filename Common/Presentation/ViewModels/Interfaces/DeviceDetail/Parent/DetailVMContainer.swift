//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

public protocol DetailVMContainer: AnyObject {

    var header:         HeaderVM                 { get }
    var accelerometer:  AccelerometerVM          { get }
    var ambientLight:   MWAmbientLightVM         { get }
    var barometer:      MWBarometerVM            { get }
    var battery:        BatteryVM                { get }
    var firmware:       FirmwareVM               { get }
    var gpio:           MWGPIOVM                 { get }
    var gyroscope:      MWGyroVM                 { get }
    var haptic:         MWHapticVM               { get }
    var hygrometer:     MWHumidityVM             { get }
    var i2c:            MWI2CVM                  { get }
    var ibeacon:        MWiBeaconVM              { get }
    var identifiers:    IdentifiersVM            { get }
    var led:            LedVM                    { get }
    var magnetometer:   MWMagnetometerVM         { get }
    var mechanical:     MechanicalSwitchVM       { get }
    var reset:          ResetVM                  { get }
    var sensorFusion:   MWSensorFusionVM         { get }
    var signal:         SignalVM                 { get }
    var temperature:    TemperatureVM            { get }

    var configurables: [DetailConfiguring]       { get }
}


