//  © 2021 Ryan Ferrell. github.com/importRyan

import Foundation

public class DetailVMContainer {
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

    var configurables: [DetailConfiguring] { [header] }
}
