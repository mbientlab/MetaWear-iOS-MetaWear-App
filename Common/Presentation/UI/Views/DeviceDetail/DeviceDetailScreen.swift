//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI

#if canImport(UIKit)
class DeviceDetailScreenUIKitContainer: UIHostingController<DeviceDetailScreen> {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: DeviceDetailScreen())
    }
}
#endif

struct DeviceDetailScreen: View {

    @StateObject var vc: MWDeviceDetailScreenSVC = .init()

    var body: some View {
        ScrollViewReader { scroll in
            ScrollView {
                LazyVStack {
                    HeaderBlock()
                    blocksA
                    blocksB
                }
            }
        }
        .overlay(ToastServer())
        .pickerStyle(.segmented)
    }

    @ViewBuilder var blocksA: some View {

        DetailsBlockCard(
            title: "Identity",
            symbol: .identity,
            content: IdentifiersBlock(vm: vc.vms.identifiers as! MWDetailIdentifiersSVC)
        )

        DetailsBlockCard(
            title: "Battery",
            symbol: .battery,
            content: BatteryBlock(vm: vc.vms.battery as! MWDetailBatterySVC)
        )

        DetailsBlockCard(
            title: "Signal",
            symbol: .signal,
            content: SignalBlock(vm: vc.vms.signal as! MWSignalSVC)
        )

        DetailsBlockCard(
            title: "Firmware",
            symbol: .firmware,
            content: FirmwareBlock(vm: vc.vms.firmware as! MWFirmwareSVC)
        )

        DetailsBlockCard(
            title: "Reset",
            symbol: .reset,
            content: ResetBlock(vm: vc.vms.reset as! MWResetSVC)
        )

        DetailsBlockCard(
            title: "Mechanical Switch",
            symbol: .mechanicalSwitch,
            content: MechanicalSwitchBlock(vm: vc.vms.mechanical as! MWMechanicalSwitchSVC)
        )

        DetailsBlockCard(
            title: "LED",
            symbol: .led,
            content: LEDBlock(vm: vc.vms.led as! MWLEDSVC)
        )

        DetailsBlockCard(
            title: "Temperature",
            symbol: .temperature,
            content: TemperatureBlock(vm: vc.vms.temperature as! MWTemperatureSVC)
        )

        DetailsBlockCard(
            title: "Accelerometer (BMI160/270)",
            symbol: .accelerometer,
            content: AccelerometerBlock(vm: vc.vms.accelerometer as! MWAccelerometerSVC)
        )
    }

    @ViewBuilder var blocksB: some View {

        DetailsBlockCard(
            title: "Sensor Fusion",
            symbol: .sensorFusion,
            content: SensorFusionBlock()
        )

        DetailsBlockCard(
            title: "Gyroscope",
            symbol: .gyroscope,
            content: GyroscopeBlock()
        )

        DetailsBlockCard(
            title: "Magnetometer",
            symbol: .magnetometer,
            content: MagnetometerBlock()
        )

        DetailsBlockCard(
            title: "GPIO",
            symbol: .gpio,
            content: GPIOBlock()
        )

        DetailsBlockCard(
            title: "Haptic/Buzzer",
            symbol: .haptic,
            content: HapticBlock()
        )

        DetailsBlockCard(
            title: "iBeacon",
            symbol: .ibeacon,
            content: iBeaconBlock()
        )

        DetailsBlockCard(
            title: "Barometer",
            symbol: .barometer,
            content: BarometerBlock()
        )

        DetailsBlockCard(
            title: "Ambient Light",
            symbol: .ambientLight,
            content: AmbientLightBlock()
        )

        DetailsBlockCard(
            title: "I2C",
            symbol: .i2c,
            content: I2CBlock()
        )
    }

}
