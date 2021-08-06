//  Created by Ryan Ferrell on 7/31/21.
//  Copyright © 2021 MbientLab. All rights reserved.
//

import SwiftUI
import MetaWear

#if canImport(UIKit)
class DeviceDetailScreenUIKitContainer: UIHostingController<DeviceDetailScreen> {

    private let vc = MWDeviceDetailScreenSVC()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder,
                   rootView: DeviceDetailScreen(vc: vc)
        )
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        vc.start()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        vc.end()
    }

    /// Pass selected device from storyboard segue
    func setDevice(device: MetaWear) {
        vc.setDevice(device)
    }


}
#endif

struct DeviceDetailScreen: View {

    @ObservedObject var vc: MWDeviceDetailScreenSVC = .init()
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        VStack(spacing: 0) {
            ToastServer(vm: vc.toast as! ToastServerType)
                .background(bg.ignoresSafeArea())

            ScrollViewReader { scroll in
                ScrollView {
                    VStack(spacing: 24) {
                        TitlelessDetailsBlockCard(content: HeaderBlock(vm: vc.vms.header as! MWDetailHeaderSVC))
                            .padding(.top, 10)
                        blocksA
                        blocksB
                    }
                }
                .background(bg.ignoresSafeArea())
            }
            .pickerStyle(.segmented)
            .environment(\.allowBluetoothRequests, (vc.toast as! ToastServerType).allowBluetoothRequests)
            .animation(.easeOut)
            .animation(.easeOut, value: (vc.toast as! ToastServerType).showToast)
        }
    }

    private var bg: some View {
        Color(.systemGroupedBackground).opacity(scheme == .light ? 0.8 : 1)
    }

    @ViewBuilder private var blocksA: some View {

        if vc.visibleGroupsDict[.identifiers] == true {
            DetailsBlockCard(
                title: "Identity",
                symbol: .identity,
                content: IdentifiersBlock(vm: vc.vms.identifiers as! MWDetailIdentifiersSVC)
            )
        }

        if vc.visibleGroupsDict[.battery] == true {
            DetailsBlockCard(
                title: "Battery",
                symbol: .battery,
                content: BatteryBlock(vm: vc.vms.battery as! MWDetailBatterySVC)
            )
        }

        if vc.visibleGroupsDict[.signal] == true {
            DetailsBlockCard(
                title: "Signal",
                symbol: .signal,
                content: SignalBlock(vm: vc.vms.signal as! MWSignalSVC)
            )
        }

        if vc.visibleGroupsDict[.firmware] == true {
            DetailsBlockCard(
                title: "Firmware",
                symbol: .firmware,
                content: FirmwareBlock(vm: vc.vms.firmware as! MWFirmwareSVC)
            )
        }

        if vc.visibleGroupsDict[.reset] == true {
            DetailsBlockCard(
                title: "Cycle",
                symbol: .reset,
                content: ResetBlock(vm: vc.vms.reset as! MWResetSVC)
            )
        }

        if vc.visibleGroupsDict[.mechanicalSwitch] == true {
            DetailsBlockCard(
                title: "Mechanical Switch",
                symbol: .mechanicalSwitch,
                content: MechanicalSwitchBlock(vm: vc.vms.mechanical as! MWMechanicalSwitchSVC)
            )
        }

        if vc.visibleGroupsDict[.LED] == true {
            DetailsBlockCard(
                title: "LED",
                symbol: .led,
                content: LEDBlock(vm: vc.vms.led as! MWLEDSVC)
            )
        }

        if vc.visibleGroupsDict[.temperature] == true {
            DetailsBlockCard(
                title: "Temperature",
                symbol: .temperature,
                content: TemperatureBlock(vm: vc.vms.temperature as! MWTemperatureSVC)
            )
        }

        if vc.visibleGroupsDict[.accelerometer] == true {
            DetailsBlockCard(
                title: "Accelerometer (BMI160/270)",
                symbol: .accelerometer,
                content: AccelerometerBlock(vm: vc.vms.accelerometer as! MWAccelerometerSVC)
            )
        }
    }

    @ViewBuilder private var blocksB: some View {

        if vc.visibleGroupsDict[.identifiers] == true {
            DetailsBlockCard(
                title: "Sensor Fusion",
                symbol: .sensorFusion,
                content: SensorFusionBlock()
            )
        }

        if vc.visibleGroupsDict[.identifiers] == true {
            DetailsBlockCard(
                title: "Gyroscope",
                symbol: .gyroscope,
                content: GyroscopeBlock()
            )
        }

        if vc.visibleGroupsDict[.identifiers] == true {
            DetailsBlockCard(
                title: "Magnetometer",
                symbol: .magnetometer,
                content: MagnetometerBlock()
            )
        }

        if vc.visibleGroupsDict[.identifiers] == true {
            DetailsBlockCard(
                title: "GPIO",
                symbol: .gpio,
                content: GPIOBlock()
            )
        }

        if vc.visibleGroupsDict[.identifiers] == true {
            DetailsBlockCard(
                title: "Haptic/Buzzer",
                symbol: .haptic,
                content: HapticBlock()
            )
        }

        if vc.visibleGroupsDict[.identifiers] == true {
            DetailsBlockCard(
                title: "iBeacon",
                symbol: .ibeacon,
                content: iBeaconBlock()
            )
        }

        if vc.visibleGroupsDict[.identifiers] == true {
            DetailsBlockCard(
                title: "Barometer",
                symbol: .barometer,
                content: BarometerBlock()
            )
        }

        if vc.visibleGroupsDict[.identifiers] == true {
            DetailsBlockCard(
                title: "Ambient Light",
                symbol: .ambientLight,
                content: AmbientLightBlock()
            )
        }

        if vc.visibleGroupsDict[.identifiers] == true {
            DetailsBlockCard(
                title: "I2C",
                symbol: .i2c,
                content: I2CBlock()
            )
        }
    }

}
