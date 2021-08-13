//  Created by Ryan Ferrell on 8/6/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI
import MetaWear

// MARK: - App UI Factory

public class DevelopmentUIFactory: UIFactory {

    public override init(environment: UIEnvironment) {
        super.init(environment: environment)
    }

    // MARK: - Methods

    public override func makeScannedDeviceCellSVC(device: MetaWear?, parent: DevicesScanningVM?) -> MWScannedDeviceCellVM {
        ScannedDeviceCellSUIVC(device: device, parent: parent)
    }

    public override func makeScannedDeviceCellSVC(scannerItem: ScannerModelItem?, parent: DevicesScanningVM?) -> MWScannedDeviceCellVM {
        ScannedDeviceCellSUIVC(scannerItem: scannerItem, parent: parent)
    }


    public override func makeDetailScreenVC(device: MetaWear?) -> DeviceDetailsCoordinator {
        DeviceDetailScreenSUIVC(device: device, vms: makeDetailVMContainer())
    }

    // MARK: - Helpers

    private func makeDetailVMContainer() -> DetailVMContainer {
        switch environment {
            case .swiftUIMinimumV2: return DetailVMContainerA()
        }
    }
}

// MARK: - VMs

public class DetailVMContainerA: DetailVMContainer {

    public init() {}

    public lazy private(set) var header: HeaderVM                     = DetailHeaderSUIVC()
    public lazy private(set) var accelerometer: AccelerometerVM       = AccelerometerSUIVC()
    public lazy private(set) var ambientLight: MWAmbientLightVM       = AmbientLightSUIVC()
    public lazy private(set) var barometer: MWBarometerVM             = BarometerSUIVC()
    public lazy private(set) var battery: BatteryVM                   = BatterySUIVC()
    public lazy private(set) var firmware: FirmwareVM                 = FirmwareSUIVC()
    public lazy private(set) var gpio: MWGPIOVM                       = GPIOSUIVC()
    public lazy private(set) var gyroscope: MWGyroVM                  = GyroSUIVC()
    public lazy private(set) var haptic: MWHapticVM                   = HapticSUIVC()
    public lazy private(set) var hygrometer: MWHumidityVM             = HumiditySUIVC()
    public lazy private(set) var i2c: MWI2CBusVM                      = I2CBusSUIVC()
    public lazy private(set) var ibeacon: MWiBeaconVM                 = iBeaconSUIVC()
    public lazy private(set) var identifiers: IdentifiersVM           = IdentifiersSUIVC()
    public lazy private(set) var led: LedVM                           = LedSUIVC()
    public lazy private(set) var magnetometer: MWMagnetometerVM       = MagnetometerSUIVC()
    public lazy private(set) var mechanical: MechanicalSwitchVM       = MechanicalSwitchSUIVC()
    public lazy private(set) var reset: ResetVM                       = ResetSUIVC()
    public lazy private(set) var sensorFusion: MWSensorFusionVM       = SensorFusionSUIVC()
    public lazy private(set) var signal: SignalVM                     = SignalSUIVC()
    public lazy private(set) var temperature: TemperatureVM           = TemperatureSUIVC()

    public var configurables: [DetailConfiguring] { [
        header,
        accelerometer,
        ambientLight,
        barometer,
        battery,
        firmware,
        gpio,
        gyroscope,
        haptic,
        hygrometer,
        i2c,
        ibeacon,
        identifiers,
        led,
        magnetometer,
        mechanical,
        reset,
        sensorFusion,
        signal,
        temperature,
    ] }
}
