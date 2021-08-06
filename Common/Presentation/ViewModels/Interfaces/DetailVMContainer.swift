//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import Foundation

public class DetailVMContainer {

    init(flag: VMContainerFlag = .swiftUI) {
        switch flag {
            case .swiftUI:
                self.header = MWDetailHeaderSVC()
                self.identifiers = MWDetailIdentifiersSVC()
                self.battery = MWDetailBatterySVC()
                self.signal = MWSignalSVC()
                self.firmware = MWFirmwareSVC()
                self.led = MWLEDSVC()
                self.mechanical = MWMechanicalSwitchSVC()
                self.temperature = MWTemperatureSVC()
                self.reset = MWResetSVC()
                self.accelerometer = MWAccelerometerSVC()

        }
    }

    public var header: DetailHeaderVM!
    public var identifiers: DetailIdentifiersVM!
    public var battery: DetailBatteryVM!
    public var signal: DetailSignalStrengthVM!
    public var firmware: DetailFirmwareVM!
    public var led: DetailLEDVM!
    public var mechanical: DetailMechanicalSwitchVM!
    public var temperature: DetailTemperatureVM!
    public var reset: DetailResetVM!
    public var accelerometer: DetailAccelerometerVM!

    var configurables: [DetailConfiguring] { [
        header, identifiers, battery, signal, firmware, led, mechanical, temperature, reset, accelerometer
    ] }
}

enum VMContainerFlag {
    case swiftUI
}
